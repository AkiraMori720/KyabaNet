//
//  ConfigGroupViewController.swift
//  Life
//
//  Created by mac on 2021/6/15.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import SwiftyAvatar
import RealmSwift
import JGProgressHUD
let hud = JGProgressHUD(style: .light)

class ConfigGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet weak var changeImage: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var group:Group!
    private var groupPicture: UIImage? = nil
    var headerSections =  [HeaderSection(name: "Members".localized+" 0", collapsed: false)]
    
    @IBOutlet weak var trashGroup: UIButton!
    @IBOutlet weak var inputGroupName: UITextField!
    @IBOutlet weak var labelGroupName: UILabel!
    @IBOutlet weak var imgGroup: SwiftyAvatar!
    private var tokenPersons: NotificationToken? = nil
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    
    private var tokenMembers: NotificationToken? = nil
    private var members = realm.objects(Member.self).filter(falsepredicate)
    let hud = JGProgressHUD(style: .light)
    var prevPersonsForGroup : [Person] = []
    
    
    @IBAction func actionTapImage(_ sender: Any) {
        let confirmationAlert = UIAlertController(title: "プロフィールに設定する画像を選択してください", message: "", preferredStyle: .alert)

        confirmationAlert.addAction(UIAlertAction(title: "カメラ", style: .default, handler: { (action: UIAlertAction!) in
            confirmationAlert.dismiss(animated: true, completion: nil)
            self.openCamera()
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "ギャラリー", style: .default, handler: { (action: UIAlertAction!) in
            confirmationAlert.dismiss(animated: true, completion: nil)
            self.openGallery()
        }))

        confirmationAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    func openCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func openGallery(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            // print("No image found")
            return
        }
        let data = image.jpegData(compressionQuality: 1.0)
        groupPicture = UIImage(data: data! as Data)
        DispatchQueue.main.async{
            self.imgGroup.image = self.groupPicture
            self.changeImage.setImage(nil, for: .normal)
            self.uploadGroupImage()
        }
        
        // print out the image size as a test
        // print(correct_image?.size)
        //uploadPicture(image: correct_image!)
    }
    func uploadGroupImage(){
        if self.groupPicture != nil {
            // upload picture
            if let data = groupPicture?.jpegData(compressionQuality: 0.6) {
                self.hud.textLabel.text = "Picture Uploading...".localized
                self.hud.show(in: self.view, animated: true)
                MediaUpload.group(group.objectId, data: data, completion: { error in
                    if (error == nil) {
                        MediaDownload.saveGroup(self.group.objectId, data: data)
                        self.group.update(pictureAt: Date().timestamp())
                        self.hud.dismiss()
                        
                    } else {
                        DispatchQueue.main.async {
                            self.hud.textLabel.text = "写真をアップロードできませんでした"
                            self.hud.show(in: self.view, animated: true)
                        }
                        self.hud.dismiss(afterDelay: 1.0, animated: true)
                    }
                })
            }
        }
    }
    @IBAction func actionTapTrash(_ sender: Any) {
        /*if(group.ownerId == AuthUser.userId()){
            let confirmationAlert = UIAlertController(title: "Remove Group".localized, message: "Are you sure remove Group".localized , preferredStyle: .alert)

            confirmationAlert.addAction(UIAlertAction(title: "はい", style: .default, handler: {
                    (action: UIAlertAction!) in
                    confirmationAlert.dismiss(animated: true, completion: nil)
                Groups.remove(self.group)
                self.dismiss(animated: true, completion: nil)
                })
            )
            confirmationAlert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(confirmationAlert, animated: true, completion: nil)
            
        }else{
            
            
        }*/
        let confirmationAlert = UIAlertController(title: "グループを退出する", message: "本当にグループを退出しますか？" , preferredStyle: .alert)

        confirmationAlert.addAction(UIAlertAction(title: "はい", style: .default, handler: {
                (action: UIAlertAction!) in
                confirmationAlert.dismiss(animated: true, completion: nil)
            Groups.leaveGroup(self.group)
            self.dismiss(animated: true, completion: nil)
            })
        )
        confirmationAlert.addAction(UIAlertAction(title:"キャンセル", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(confirmationAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func actionTapInvite(_ sender: Any) {
        loadSelectedPerson()
        if let viewController = storyboard?.instantiateViewController(identifier: "addParticipantVC") as? AddParticipantsViewController {
            viewController.configVC = self
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionTapBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        labelGroupName.text = "グループ名：" + group.name
        inputGroupName.text = group.name
        
       
        downloadGroupImage()
        
        //trashGroup.isHidden = false
        
        if(group.ownerId != AuthUser.userId()){
            
            changeImage.isHidden = true
            inputGroupName.isHidden = true
            labelGroupName.isHidden = false
        }else{
            
            changeImage.isHidden = false
            inputGroupName.isHidden = false
            labelGroupName.isHidden = true
            inputGroupName.delegate = self
        }
        
        
        searchBar.backgroundImage = UIImage()
        searchBar.barStyle = .default
        searchBar.barTintColor = UIColor(hexString: "#16406F")
        searchBar.layer.cornerRadius = 8
        searchBar.placeholder = "メンバーを検索する"
//        searchBar.backgroundColor = UIColor(hexString: "165c90")
        searchBar.set(textColor: UIColor(hexString: "#96B4D2")!)
        searchBar.setPlaceholder(textColor: UIColor(hexString: "#96B4D2")!)
        searchBar.setSearchImage(color: UIColor(hexString: "#96B4D2")!)
//        searchBar.setClearButton(color: UIColor(hexString: "#96B4D2")!)
        searchBar.tintColor = UIColor(hexString: "#FFFFFF")
        searchBar.delegate = self
        
        ExpandableHeaderCell.RegisterAsAHeader(withTableView: self.tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        
        
        if (AuthUser.userId() != "") {
            loadMembers()
        }
        
    }
    
    func invitePerson(){
        var newInvitePersonIds:[String] = []
        for person in selectedPersonsForGroup {
            var flag = 1
            for person1 in prevPersonsForGroup {
                if(person.objectId == person1.objectId){
                    flag = 0
                    break
                }
            }
            if(flag == 1){
                newInvitePersonIds.append(person.objectId)
                
            }
        }
        if(newInvitePersonIds.count > 0){
            Groups.invitePersons(group, newInvitePersonIds: newInvitePersonIds)
        }
    }
    
    func loadSelectedPerson(){
        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@ AND isDeleted == NO", Members.userIds(chatId: group.chatId), Blockeds.blockerIds())
        
        persons = realm.objects(Person.self).filter(predicate1)
        
        selectedPersonsForGroup.removeAll()
        prevPersonsForGroup.removeAll()
        for person in persons{
            selectedPersonsForGroup.append(person)
            prevPersonsForGroup.append(person)
        }
    }
    
    func loadMembers() {

        let predicate = NSPredicate(format: "chatId == %@ AND isActive == YES", group.chatId)
        members = realm.objects(Member.self).filter(predicate)
        
        
        tokenMembers?.invalidate()
        members.safeObserve({ changes in
            self.loadPersons()
        }, completion: { token in
            self.tokenMembers = token
        })
    }
    
    func loadPersons(text: String = "") {

        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@ AND isDeleted == NO", Members.userIds(chatId: group.chatId), Blockeds.blockerIds())
        let predicate2 = (text != "") ? NSPredicate(format: "fullname CONTAINS[c] %@", text) : NSPredicate(value: true)

        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "fullname")
        
        
        tokenPersons?.invalidate()
        persons.safeObserve({ changes in
            self.refreshTableView()
        }, completion: { token in
            self.tokenPersons = token
        })
    }
    
    func refreshTableView(){
        headerSections[0].name = "Members".localized+" \(persons.count)"
        tableView.reloadData()
    }
    func downloadGroupImage() {

        MediaDownload.startGroup(group.objectId, pictureAt: group.pictureAt) { image, error in
           
            if (error == nil) {
                self.imgGroup.image = image
                //self.labelInitials.text = nil
            } else{
                self.imgGroup.image = UIImage(named: "ic_default_profile")
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return headerSections.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExpandableHeaderCell.GetReuseIdentifier()) as! ExpandableHeaderCell
        header.titleLabel.text = headerSections[section].name
        header.setCollapsed(collapsed: headerSections[section].collapsed)
        header.section = section
        header.delegate = self
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40.00
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return persons.count
        }
        return 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(headerSections[indexPath.section].collapsed){
            return UITableViewCell()
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! MemberCell
            cell.selectionStyle = .none
            let person = persons[indexPath.row]
            cell.bindData(person: person)
            cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        let textFieldText = textField.text
        if textFieldText?.isEmpty == true {
            textField.text = group.name
            return
        }
        if(group.ownerId == AuthUser.userId()){
            group.update(name: textFieldText!)
        }
    }

}

extension ConfigGroupViewController: UISearchBarDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarTextDidBeginEditing(_ searchBar_: UISearchBar) {

        searchBar.setShowsCancelButton(true, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarTextDidEndEditing(_ searchBar_: UISearchBar) {

        searchBar.setShowsCancelButton(false, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarCancelButtonClicked(_ searchBar_: UISearchBar) {

        searchBar.text = ""
        searchBar.resignFirstResponder()
        
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchText = searchBar_.text
        
        loadPersons(text: searchText ?? "")
        
    }
}



extension ConfigGroupViewController: CollapsibleTableViewHeaderDelegate {
  func toggleSection(_ header: ExpandableHeaderCell, section: Int) {
    let collapsed = !headerSections[section].collapsed
        
    // Toggle collapse
    headerSections[section].collapsed = collapsed
    header.setCollapsed(collapsed: collapsed)
    
    // Reload the whole section
    tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
  }
}

