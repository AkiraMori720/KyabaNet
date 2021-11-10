//
//  AddParticipantsViewController.swift
//  Life
//
//  Created by Yun Li on 2020/7/8.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import RealmSwift

class AddParticipantsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate{
    
    var ownerVC : CreateGroupViewController!
    var configVC : ConfigGroupViewController!
    
    private var tokenFriends: NotificationToken? = nil
    private var tokenPersons: NotificationToken? = nil
    
    private var friends = realm.objects(Friend.self).filter(falsepredicate)
    private var persons = realm.objects(Person.self).filter(falsepredicate)
    
    private var temp : [Person] = []
    private var saveTaped = 0
    @IBOutlet weak var barTitle: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectedPersonsForGroup.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "horizontalAddedParticipantCell", for: indexPath) as! HorizontalAddedParticipantCell
        let person = selectedPersonsForGroup[indexPath.row]
        cell.index = indexPath.row
        
        cell.bindData(person: person)
        
        cell.loadImage(person: person, collectionView: collectionView, indexPath: indexPath)
        cell.callbackCancelTapped = {(index) in
            selectedPersonsForGroup.remove(at: index)
            self.refreshCollectionView()
            self.refreshTableView()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addParticipantCell", for: indexPath) as! AddParticipantCell
        let person = persons[indexPath.row]
        cell.index = indexPath.row
        
        
        cell.bindData(person: person)
        
        cell.loadImage(person: person, tableView: tableView, indexPath: indexPath)
        cell.selectionStyle = .none
        cell.callbackAddMember = {(index, checked) in
            let person = self.persons[index]
            if checked{
                selectedPersonsForGroup.append(person)
            }else{
                self.removeFromSelectedGroup(person: person)
            }
            self.refreshCollectionView()
        }
        return cell
    }
    
    @objc func removeFromSelectedGroup(person : Person){
        for (index, item) in selectedPersonsForGroup.enumerated(){
            if item == person{
                selectedPersonsForGroup.remove(at: index)
                break
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        temp = selectedPersonsForGroup
        refreshTableView()
        refreshCollectionView()
        loadFriends()
        // Initialize search bar
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.barStyle = .default
        searchBar.barTintColor = UIColor(hexString: "#999999")
        searchBar.layer.cornerRadius = 8
        searchBar.placeholder = "友達を検索する"
        searchBar.set(textColor: UIColor(hexString: "#333333")!)
        searchBar.setPlaceholder(textColor: UIColor(hexString: "#999999")!)
        searchBar.setSearchImage(color: UIColor(hexString: "#999999")!)
//        searchBar.setClearButton(color: UIColor(hexString: "#96B4D2")!)
        searchBar.tintColor = UIColor(hexString: "#333333")
    }
    
    func getSelectedIds() -> [String] {
        var friendIds: [String] = []
        if(ownerVC == nil){
            for friend in selectedPersonsForGroup {
                friendIds.append(friend.objectId)
            }
        }
        return friendIds
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = 70
        let height = 110
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
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
    
    func loadPersons(text: String = "") {

        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@ AND NOT objectId IN %@ AND isDeleted == NO", Friends.friendAcceptedIds(), Blockeds.blockerIds(), getSelectedIds())
        // Fix -- Friends.friendAcceptedIds() Friends.friendIds()
        let predicate2 = (text != "") ? NSPredicate(format: "fullname CONTAINS[c] %@", text) : NSPredicate(value: true)

        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "fullname")

        tokenPersons?.invalidate()
        persons.safeObserve({ changes in
            self.refreshTableView()
        }, completion: { token in
            self.tokenPersons = token
        })
    }
    
    @objc func refreshTableView() {
        friendsTableView.reloadData()
    }
    @objc func refreshCollectionView(){
        if selectedPersonsForGroup.count == 0{
            collectionView.isHidden = true
            divider.isHidden = true
        }else{
            collectionView.isHidden = false
            divider.isHidden = false
        }
        collectionView.reloadData()
        barTitle.text = "メンバーを追加する" + " (\(selectedPersonsForGroup.count))"
        let item = self.collectionView(self.collectionView, numberOfItemsInSection: 0) - 1
        let lastItemIndex = IndexPath(item: item, section: 0)
        collectionView.scrollToItem(at: lastItemIndex, at: .right, animated: false)
    }
    @IBAction func onSaveTapped(_ sender: Any) {
        
        saveTaped = 1
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onCancelTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        if(saveTaped == 1){
            if(ownerVC != nil){
                ownerVC.refreshCollectionView()
            }
            if(configVC != nil){
                configVC.invitePerson()
            }
        }else{
            if(ownerVC != nil){
                selectedPersonsForGroup = temp
            }else{
                selectedPersonsForGroup.removeAll()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        saveTaped = 0
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let predicate1 = NSPredicate(format: "objectId IN %@ AND NOT objectId IN %@ AND isDeleted == NO", Friends.friendIds(), Blockeds.blockerIds())
        let predicate2 = (searchText != "") ? NSPredicate(format: "fullname CONTAINS[c] %@ OR phone CONTAINS[c] %@", searchText, searchText) : NSPredicate(value: true)

        persons = realm.objects(Person.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "fullname")
        refreshTableView()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
