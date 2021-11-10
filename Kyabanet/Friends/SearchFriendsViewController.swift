//
//  SearchFriendsViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/26.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import BEMCheckBox
import Contacts
import RealmSwift

class SearchFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating,UISearchControllerDelegate {

    var radioGroup : BEMCheckBoxGroup!
    let searchController = UISearchController(searchResultsController: nil)
    var refresher: UIRefreshControl!
    
    
    @IBOutlet var noDataView: UIView!
    @IBOutlet weak var searchFriendsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultTxt: UILabel!
    @IBOutlet weak var searchResultBk: UIImageView!
    @IBOutlet weak var searchResultBkImage: UIImageView!
    @IBOutlet weak var showingResult: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var radioUsername: BEMCheckBox!
    @IBOutlet weak var radioPhoneNumber: BEMCheckBox!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupProfileImageView: UIImageView!
    @IBOutlet weak var popupNameLabel: UILabel!
    @IBOutlet weak var popupPhoneNumberLabel: UILabel!
    @IBOutlet weak var popupStatusLabel: UILabel!
    @IBOutlet weak var resultPictureHeight: NSLayoutConstraint!
    @IBOutlet weak var resultViewBottomConstraint: NSLayoutConstraint!
    
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    private var person: Person!
    private var tokenPerson: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = self.noDataView
        tableView.isHidden = false
        tableView.delegate = self
        tableView.dataSource = self
        showingResult.isHidden = true
        radioGroup = BEMCheckBoxGroup(checkBoxes: [radioUsername, radioPhoneNumber])
        radioGroup.mustHaveSelection = true
        radioGroup.selectedCheckBox = radioUsername
        // Initialize search bar
        searchController.searchResultsUpdater = self
        //searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "検索する"
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchFriendsTableView.tableHeaderView = searchController.searchBar
        
        radioUsername.delegate = self
        radioPhoneNumber.delegate = self
        
        definesPresentationContext = false
        
        subscribeToShowKeyboardNotifications()
        loadPerson()
    }
    
    func loadPerson() {
        let predicate = NSPredicate(format: "objectId == %@", AuthUser.userId())
        let persons = realm.objects(Person.self).filter(predicate)
        
        
        tokenPerson?.invalidate()
        persons.safeObserve({ changes in
            self.person = persons.first!
        }, completion: { token in
            self.tokenPerson = token
        })
        
    }
    
    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            resultViewBottomConstraint.constant = keyboardHeight
            resultPictureHeight.constant = 100
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            resultViewBottomConstraint.constant = 0
            resultPictureHeight.constant = 200
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        //dismiss(animated: true, completion: nil)
        self.searchController.isEditing = false
        self.searchController.isActive = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPopupClosePreseed(_ sender: Any) {
        popupView.isHidden = true
        refreshTableView()
    }
    
    @IBAction func onStartChatPressed(_ sender: Any) {
        popupView.isHidden = true
        self.dismiss(animated: true) {
        }        
    }
    
    func loadImage(person: Person, completion: @escaping () -> Void) {
        if let path = MediaDownload.pathUser(person.objectId) {
            popupProfileImageView.image = UIImage.image(path, size: 40)
            //labelInitials.text = nil
            completion()
        } else {
            popupProfileImageView.image = nil
            //labelInitials.text = person.initials()
            downloadImage(person: person, completion: completion)
        }
        popupProfileImageView.makeRounded()
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func downloadImage(person: Person, completion: @escaping () -> Void) {
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.popupProfileImageView.image = image
                self.popupProfileImageView.makeRounded()
            }
            else{
                self.popupProfileImageView.image = UIImage(named: "ic_default_profile")
            }
            completion()
        }
    }
    
    // MARK: - Refresh methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func refreshTableView() {
        tableView.reloadData()
    }
    // MARK: - Backend methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchPersonsByUserName(text: String = "") {
        
        if text.count < 1 {
            return
        }
        let predicate1 = NSPredicate(format: "objectId != %@ AND isDeleted == NO", AuthUser.userId())
        let predicate2 = (text != "") ? NSPredicate(format: "username == %@", text) : NSPredicate(value: true)
        let predicate3 = (person.userType == UserType.hostess.rawValue) ? NSPredicate(format: "userType == 0") : NSPredicate(format: "userType == 1")
        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).filter(predicate3).sorted(byKeyPath: "username")
        
        if persons.count > 0 {
            tableView.isHidden = false
            refreshTableView()
        }
        else{
            tableView.isHidden = true
        }
    }
    
    func searchPersonsByPhoneNumber(text: String = "") {
        if text.count < 1 {
            return
        }
        let predicate1 = NSPredicate(format: "objectId != %@ AND isDeleted == NO", AuthUser.userId())
        let predicate2 = (text != "") ? NSPredicate(format: "phone == %@", text) : NSPredicate(value: true)
        let predicate3 = (person.userType == UserType.hostess.rawValue) ? NSPredicate(format: "userType == 0") : NSPredicate(format: "userType == 1")
        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).filter(predicate3).sorted(byKeyPath: "phone")
        if persons.count > 0 {
            tableView.isHidden = false
            refreshTableView()
        }
        else{
            tableView.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            return persons.count
        }
        return persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchFriendCell", for: indexPath) as! SearchFriendCell
        let person = persons[indexPath.row]
        cell.index = indexPath.row
        cell.bindData(person: person)
        cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
        //cell.userNameLabel.text = person.fullname
        //cell.phoneNumberLabel.text = person.phone
        //let userImage = loadImage(person: person)
        //cell.imageView?.image = userImage
        
        cell.selectionStyle = .none
        
        cell.callbackAddFriend = { (index) in
            self.searchController.searchBar.resignFirstResponder()
            let person = self.persons[index]
            // Display info on popupview
            self.popupNameLabel.text = person.fullname
            self.popupPhoneNumberLabel.text = person.phone
            self.loadImage(person: person){
                self.popupView.isHidden = false
            }
            print("Selcted Person TOKEN: ", person.oneSignalId)
            PushNotification.send(token: person.oneSignalId, title: "友達リクエスト", body:self.person.fullname + " "  + "が友達リクエストをしています", type: .friendRequest, chatId: nil )
            if (Friends.isFriend(person.objectId)) {
                self.popupStatusLabel.text = "既に友達に登録済みです"
            } else {
                Friends.create(person.objectId)
                self.popupStatusLabel.text = "友達申請を送信しました。相手が承認後お知らせします。"
            }
        }
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResultBk.image = UIImage(named: "no_available_bk")
        if radioGroup.selectedCheckBox == radioUsername{
            searchResultTxt.text = "このユーザーネームは見つかりません。"
        }else{
            searchResultTxt.text = "この電話番号は見つかりません。"
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            // print("Search Controller is now active *******************")
            //searchResultBkImage.image = UIImage(named: "no_available_bk")
            //searchResultBk.image = UIImage(named: "no_available_bk")
            //tableView.backgroundView = self.noDataView
        } else {
            // print("Search Controller is now unactive !!!!!!!!!!!!!!!!!!")
            //searchResultBkImage.image = UIImage(named: "no_available_bk")
            //searchResultBk.image = UIImage(named: "no_available_bk")
            tableView.backgroundView = nil
        }
        
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    
    func filterContent(searchText:String) {
        if searchText.isEmpty == true {
            return
        }
        if radioGroup.selectedCheckBox == radioUsername{
            searchPersonsByUserName(text: searchText ?? "")
        }else{
            searchPersonsByPhoneNumber(text: searchText ?? "")
        }
        tableView.reloadData()
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
        //loadPersons()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchText = searchBar_.text
        
        if radioGroup.selectedCheckBox == radioUsername{
            searchPersonsByUserName(text: searchText ?? "")
        }else{
            searchPersonsByPhoneNumber(text: searchText ?? "")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillDisappear(_ animated: Bool){
        
    }

}

extension SearchFriendsViewController : BEMCheckBoxDelegate {
     func didTap(_ checkBox: BEMCheckBox) {
        searchController.searchBar.resignFirstResponder()
        if(checkBox == radioUsername){
            searchController.searchBar.keyboardType = .default
        }
        if(checkBox == radioPhoneNumber){
            searchController.searchBar.keyboardType = .phonePad
        }
    }
}
