//
//  HomeViewController.swift
//  Life
//
//  Created by XianHuang on 6/25/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import RealmSwift
import JGProgressHUD
import FittedSheets
import SwipeCellKit

protocol CreateGroupDelegate {
    func onGroupCreated(group: Group)
}

protocol ChatViewControllerProtocol {
    func singleChatView(_ indexPath: IndexPath)
    func groupChatView(_ indexPath: IndexPath)
    func removeFriend(_ indexPath: IndexPath)
    func groupInfo(_ group: Group)
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CreateGroupDelegate, ChatViewControllerProtocol {

    private var person: Person!

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var redCircle: UIImageView!
    
    
    @IBOutlet weak var imageReceivedUnRead: UIImageView!
    @IBOutlet weak var addFriendView: UIView!
    
    @IBOutlet weak var uiv_zedpay: UIView!
    
    var buttonStyle: ButtonStyle = .backgroundColor
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    
    
    let hud = JGProgressHUD(style: .light)
    var headerSections =  [HeaderSection(name: "ステータス", collapsed: false), HeaderSection(name: "グループ"+" 0", collapsed: false), HeaderSection(name: "お友達"+" 0", collapsed: false)]

    private var tokenFriends: NotificationToken? = nil
    private var tokenPersons: NotificationToken? = nil
    private var tokenGroups: NotificationToken? = nil
    private var tokenMembers: NotificationToken? = nil
    private var friends = realm.objects(Friend.self).filter(falsepredicate)
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    private var groups = realm.objects(Group.self).filter(falsepredicate)
    private var members = realm.objects(Group.self).filter(falsepredicate)
    @IBOutlet weak var textEULA: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.backgroundImage = UIImage()
        searchBar.barStyle = .default
        searchBar.barTintColor = UIColor(hexString: "#16406F")
        searchBar.layer.cornerRadius = 8
        searchBar.tintColor = UIColor(hexString: "#FFFFFF")
        searchBar.placeholder = "検索"
        searchBar.set(textColor: UIColor(hexString: "#FFFFFF")!)
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.init(named: "searchBarBack")
        }
        searchBar.delegate = self
        
        
        // Init TableView
        ExpandableHeaderCell.RegisterAsAHeader(withTableView: self.homeTableView)
        UserStatusCell.Register(withTableView: self.homeTableView)
        FriendCell.Register(withTableView: self.homeTableView)
        
        homeTableView.dataSource = self
        homeTableView.delegate = self
        
        updateFcmToken()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        
        if(Friends.friendPendingIds().count > 0){
            redCircle.isHidden = false
        }else{
            redCircle.isHidden = true
        }
        
        
        if (AuthUser.userId() != "") {
            loadPerson()
            //let _: [String] = Members.chatIds()
            loadMembers()
            //let _ = Friends.friendAcceptedIds()
            loadFriends()
        }
        if person.userType == UserType.hostess.rawValue{
            uiv_zedpay.isHidden = true
        }else{
            uiv_zedpay.isHidden = false
        }
    }
    
    // MARK: - upload fcm token
    fileprivate func updateFcmToken() {
        let token = PrefsManager.getFCMToken()
        Persons.update(oneSignalId: token)
    }
    
    
    // MARK: - Realm methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func loadFriends() {

        let predicate = NSPredicate(format: "userId == %@ AND isDeleted == NO  AND isAccepted == YES", AuthUser.userId())
        //// print("Auth UserId: \(predicate)")
        friends = realm.objects(Friend.self).filter(predicate)

        tokenFriends?.invalidate()
        friends.safeObserve({ changes in
            // load friend list
            self.loadPersons()
            //self.refreshTableView()
            
        }, completion: { token in
            self.tokenFriends = token
        })
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadPersons(text: String = "") {

        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@ AND isDeleted == NO", Friends.friendAcceptedIds(), Blockeds.blockerIds())
        let predicate2 = (text != "") ? NSPredicate(format: "fullname CONTAINS[c] %@", text) : NSPredicate(value: true)

        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "fullname")

        tokenPersons?.invalidate()
        persons.safeObserve({ changes in
            self.refreshTableView()
        }, completion: { token in
            self.tokenPersons = token
        })
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadGroups(text: String = "") {

        let predicate1 = NSPredicate(format: "objectId IN %@ AND isDeleted == NO", Members.chatIds())
        let predicate2 = (text != "") ? NSPredicate(format: "name CONTAINS[c] %@", text) : NSPredicate(value: true)

        groups = realm.objects(Group.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "name")

        tokenGroups?.invalidate()
        groups.safeObserve({ changes in
            
            self.refreshTableView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.hud.dismiss()
            }
            
        }, completion: { token in
            self.tokenGroups = token
        })
    }
    
    func loadMembers(text: String = "") {

        let predicate = NSPredicate(format: "userId == %@ AND isActive == YES", AuthUser.userId())
        let members = realm.objects(Member.self).filter(predicate)

        tokenMembers?.invalidate()
        members.safeObserve({ changes in
            self.loadGroups()
        }, completion: { token in
            self.tokenMembers = token
        })
    }
    
    func onGroupCreated(group: Group) {
        Util.showAlert(vc: self, "\(group.name) " + "が追加されました。", "")
    }

    // MARK: - Refresh methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func refreshTableView() {
        print("refreshTableView")
        headerSections[1].name = "グループ"+" \(groups.count)"
        headerSections[2].name = "お友達"+" \(persons.count)"
        homeTableView.reloadData()
    }
    func loadPerson() {
        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
        if(person.isBalanceRead == false){
            imageReceivedUnRead.isHidden = false
        }else{
            imageReceivedUnRead.isHidden = true
        }
    }
    @IBAction func onSettingPressed(_ sender: Any) {
        let mainstoryboard = UIStoryboard.init(name: "Setting", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "settingNav") as! UINavigationController
//        self.navigationController?.pushViewController(vc, animated: true)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func onAddFriendPressed(_ sender: Any) {
        let mainstoryboard = UIStoryboard.init(name: "Friend", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "addFriendRootVC")
//        self.navigationController?.pushViewController(vc, animated: true)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func openPrivateChat(chatId: String, recipientId: String) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "chatViewController") as! ChatViewController
        vc.setParticipant(chatId: chatId, recipientId: recipientId)
        vc.modalPresentationStyle = .fullScreen
        vc.hidesBottomBarWhenPushed = true
        //self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerSections.count
    }
    
    func createGroupView(){
        let mainstoryboard = UIStoryboard.init(name: "Group", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "createGroupVC") as! CreateGroupViewController
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func singleChatView(_ indexPath: IndexPath){
        let friend = persons[indexPath.row]
        let chatId = Singles.create(friend.objectId)
        openPrivateChat(chatId: chatId, recipientId: friend.objectId)
        
    }
    
    func groupChatView(_ indexPath: IndexPath){
        
        let chatId = groups[indexPath.row-1].chatId
        openPrivateChat(chatId: chatId, recipientId: "")
        
    }
    
    func removeFriend(_ indexPath: IndexPath) {
        let friend = persons[indexPath.row]
        let confirmationAlert = UIAlertController(title: "友達を削除する", message: "本当に削除しますか？" + friend.fullname, preferredStyle: .alert)

        confirmationAlert.addAction(UIAlertAction(title: "はい", style: .default, handler: {
                (action: UIAlertAction!) in
                confirmationAlert.dismiss(animated: true, completion: nil)
                Friends.removeFriend(friend.objectId){
                    self.loadFriends() 
                }
            
            })
        )
        
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(confirmationAlert, animated: true, completion: nil)
       
    }
    
    func groupInfo(_ group: Group){
        let mainstoryboard = UIStoryboard.init(name: "Group", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "configGroupVC") as! ConfigGroupViewController
        vc.group = group
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let mainstoryboard = UIStoryboard.init(name: "Group", bundle: nil)
                let vc = mainstoryboard.instantiateViewController(withIdentifier: "createGroupVC") as! CreateGroupViewController
                vc.delegate = self
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }else{
                let chatId = groups[indexPath.row-1].chatId
                openPrivateChat(chatId: chatId, recipientId: "")
            }
        }
        else if indexPath.section == 2 {
            let friend = persons[indexPath.row]
            let chatId = Singles.create(friend.objectId)
            openPrivateChat(chatId: chatId, recipientId: friend.objectId)
        }
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
        if section == 0 {
            return 0
        }
        return 40.00
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return headerSections[section].collapsed ? 0 : groups.count + 1
        }
        else if section == 2{
            return headerSections[section].collapsed ? 0 : persons.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userStatusCell", for: indexPath) as! UserStatusCell
            if person != nil{
                cell.loadPerson(withPerson: person)
            }
            return cell

        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "createGroupCell", for: indexPath) as! CreateGroupTableViewCell
                cell.homeViewController = self
                return cell
            }
            else {
                // Group Lists
                let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.GetCellReuseIdentifier(), for: indexPath) as! FriendCell
                cell.selectionStyle = .none
                let group = groups[indexPath.row-1]
                cell.homeViewController = self
                cell.bindGroupData(group: group, indexPath: indexPath)
                cell.loadGroupImage(group: group, tableView: tableView, indexPath: indexPath)
                //cell.delegate = self
                return cell
            }
        }
 
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.GetCellReuseIdentifier(), for: indexPath) as! FriendCell
        cell.selectionStyle = .none
        if( indexPath.section == 2) {
            let person = persons[indexPath.row]
            cell.homeViewController = self
            cell.bindData(person: person, indexPath: indexPath)
            cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    // MARK: - ZedPayView
    
    @IBOutlet weak var labelBalance: UILabel!
    @IBAction func onZedPay(_ sender: Any) {
        //labelBalance.text = "¥ " + String(format: "%.2f", person.getBalance())
        //balanceView.isHidden = false
        let mainstoryboard = UIStoryboard.init(name: "ZedPay", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "zedHistoryVC") as! ZedHistoryViewController
        vc.person = self.person
        
        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(430), .fullscreen])
        self.present(sheetController, animated: true, completion: nil)
        
        //self.present(vc, animated: true, completion: nil)
        
    }
}

// MARK: - UISearchBarDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension HomeViewController: UISearchBarDelegate {

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
        loadGroups()
        loadPersons()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchText = searchBar_.text
        
        loadGroups(text: searchText ?? "")
        loadPersons(text: searchText ?? "")
    }
}

extension HomeViewController: CollapsibleTableViewHeaderDelegate {
  func toggleSection(_ header: ExpandableHeaderCell, section: Int) {
    let collapsed = !headerSections[section].collapsed
        
    // Toggle collapse
    headerSections[section].collapsed = collapsed
    header.setCollapsed(collapsed: collapsed)
    
    // Reload the whole section
    homeTableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
  }
}

struct HeaderSection {
  var name: String
  var collapsed: Bool
    
  init(name: String, collapsed: Bool = false) {
    self.name = name
    self.collapsed = collapsed
  }
}

extension HomeViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {
            return nil
        }
       
        let block = SwipeAction(style: .default, title: nil, handler: nil)
        block.hidesWhenSelected = true
        configure(action: block, with: .block)
        
        let delete = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            self.removeFriend(indexPath)
            self.homeTableView.reloadData()
        }
        configure(action: delete, with: .delete)
        
//        let cell = tableView.cellForRow(at: indexPath) as! MailCell
//        let closure: (UIAlertAction) -> Void = { _ in cell.hideSwipe(animated: true) }
        let mute = SwipeAction(style: .default, title: nil) { action, indexPath in
//            let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//            controller.addAction(UIAlertAction(title: "Reply", style: .default, handler: closure))
//            controller.addAction(UIAlertAction(title: "Forward", style: .default, handler: closure))
//            controller.addAction(UIAlertAction(title: "Mark...", style: .default, handler: closure))
//            controller.addAction(UIAlertAction(title: "Notify Me...", style: .default, handler: closure))
//            controller.addAction(UIAlertAction(title: "Move Message...", style: .default, handler: closure))
//            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: closure))
//            self.present(controller, animated: true, completion: nil)
        }
        configure(action: mute, with: .mute)
        return [delete, block, mute]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .border
        
        switch buttonStyle {
        case .backgroundColor:
            options.buttonSpacing = 4
        case .circular:
            options.buttonSpacing = 4
        #if canImport(Combine)
            if #available(iOS 13.0, *) {
                options.backgroundColor = UIColor.systemGray6
            } else {
                options.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
            }
        #else
            options.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
        #endif
        }
        
        return options
    }
    
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        
        switch buttonStyle {
        case .backgroundColor:
            action.backgroundColor = descriptor.color(forStyle: buttonStyle)
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color(forStyle: buttonStyle)
            action.font = .systemFont(ofSize: 13)
            action.transitionDelegate = ScaleTransition.default
        }
    }
}

enum ButtonStyle {
    case backgroundColor, circular
}

enum ActionDescriptor {
    case mute, block, delete
    
    func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        guard displayMode != .imageOnly else { return nil }
        
        switch self {
        case .mute: return "Mute".localized
        case .block: return "Block".localized
        case .delete: return "Delete".localized
        }
    }
    
    func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode) -> UIImage? {
        guard displayMode != .titleOnly else { return nil }
        
        let name: String
        switch self {
        case .mute: name = "Read"
        case .block: name = "Unread"
        case .delete: name = "Trash"
        }
        
    #if canImport(Combine)
        if #available(iOS 13.0, *) {
            let name: String
            switch self {
            case .mute: name = "bell.slash.fill"
            case .block: name = "xmark.octagon.fill"
            case .delete: name = "trash.fill"
            }
            
            if style == .backgroundColor {
                let config = UIImage.SymbolConfiguration(pointSize: 23.0, weight: .regular)
                return UIImage(systemName: name, withConfiguration: config)
            } else {
                let config = UIImage.SymbolConfiguration(pointSize: 22.0, weight: .regular)
                let image = UIImage(systemName: name, withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysTemplate)
                return circularIcon(with: color(forStyle: style), size: CGSize(width: 50, height: 50), icon: image)
            }
        } else {
            return UIImage(named: style == .backgroundColor ? name : name + "-circle")
        }
    #else
        return UIImage(named: style == .backgroundColor ? name : name + "-circle")
    #endif
    }
    
    func color(forStyle style: ButtonStyle) -> UIColor {
    #if canImport(Combine)
        switch self {
        case .mute:
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    return UIColor.systemGray
                }
                return style == .backgroundColor ? UIColor.systemGray3 : UIColor.systemGray2
            } else {
                return #colorLiteral(red: 0.7803494334, green: 0.7761332393, blue: 0.7967314124, alpha: 1)
            }
        case .block: return UIColor.systemOrange
        case .delete: return UIColor.systemRed
        }
    #else
        switch self {
        case .mute: return #colorLiteral(red: 0.7803494334, green: 0.7761332393, blue: 0.7967314124, alpha: 1)
        case .block: return #colorLiteral(red: 1, green: 0.5803921569, blue: 0, alpha: 1)
        case .delete: return #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
        }
    #endif
    }
    
    func circularIcon(with color: UIColor, size: CGSize, icon: UIImage? = nil) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        UIBezierPath(ovalIn: rect).addClip()

        color.setFill()
        UIRectFill(rect)

        if let icon = icon {
            let iconRect = CGRect(x: (rect.size.width - icon.size.width) / 2,
                                  y: (rect.size.height - icon.size.height) / 2,
                                  width: icon.size.width,
                                  height: icon.size.height)
            icon.draw(in: iconRect, blendMode: .normal, alpha: 1.0)
        }

        defer { UIGraphicsEndImageContext() }

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
}

    


