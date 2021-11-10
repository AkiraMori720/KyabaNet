//
//  NewConversationViewController.swift
//  Life
//
//  Created by XianHuang on 7/11/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import RealmSwift

class NewConversationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChatViewControllerProtocol {

    var delegate: NewConversationDelegate? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    private var tokenFriends: NotificationToken? = nil
    private var tokenPersons: NotificationToken? = nil
    
    private var friends = realm.objects(Friend.self).filter(falsepredicate)
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FriendCell.Register(withTableView: self.tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        
        if (AuthUser.userId() != "") {
            loadFriends()
        }
    }
    
    @objc func loadFriends() {

        let predicate = NSPredicate(format: "userId == %@ AND isDeleted == NO", AuthUser.userId())
        //// print("Auth UserId: \(predicate)")
        friends = realm.objects(Friend.self).filter(predicate)

        tokenFriends?.invalidate()
        friends.safeObserve({ changes in
            self.loadPersons()
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
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    @objc func refreshTableView() {
        tableView.reloadData()

    }
    func openPrivateChat(chatId: String, recipientId: String) {
        self.dismiss(animated: false) {
            self.delegate?.newConversationStart(chatId: chatId, recipientId: recipientId)
        }
    }
    /*
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
       
   }*/

   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       if section == 0 {
           return 0
       }
       return 40.00
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
   }

   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.GetCellReuseIdentifier(), for: indexPath) as! FriendCell
       cell.selectionStyle = .none

       let person = persons[indexPath.row]
       cell.bindData(person: person, indexPath: indexPath)
    cell.homeViewController = self
       cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
       return cell
   }
   
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 76
   }
    func singleChatView(_ indexPath: IndexPath){
        let friend = persons[indexPath.row]
        let chatId = Singles.create(friend.objectId)
        openPrivateChat(chatId: chatId, recipientId: friend.objectId)
    }
    
    func groupChatView(_ indexPath: IndexPath){
        
    }
    func removeFriend(_ indexPath: IndexPath) {
        let friend = persons[indexPath.row]
        let confirmationAlert = UIAlertController(title: "友達を削除する", message: "本当に削除しますか？" + friend.fullname, preferredStyle: .alert)

        confirmationAlert.addAction(UIAlertAction(title: "はい", style: .default, handler: {
                (action: UIAlertAction!) in
                confirmationAlert.dismiss(animated: true, completion: nil)
                Friends.removeFriend(friend.objectId){
                    self.refreshTableView()
                }
            
            })
        )
        
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(confirmationAlert, animated: true, completion: nil)
       
    }
    func groupInfo(_ group: Group){
        
    }
    
}
