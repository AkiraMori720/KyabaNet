//
//  MainTabViewController.swift
//  Life
//
//  Created by Jaelhorton on 7/11/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import RealmSwift

class MainTabViewController: UITabBarController {

    private var tokenChats: NotificationToken? = nil
    private var chats    = realm.objects(Chat.self).filter(falsepredicate)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadChats()
        // Do any additional setup after loading the view.
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadChats(text: String = "") {

        let predicate1 = NSPredicate(format: "objectId IN %@ AND lastMessageAt != 0", Members.chatIds())
        let predicate2 = NSPredicate(format: "isDeleted == NO AND isArchived == NO AND isGroupDeleted == NO")
        let predicate3 = (text != "") ? NSPredicate(format: "fullName1 CONTAINS[c] %@ OR fullName2 CONTAINS[c] %@", text, text) : NSPredicate(value: true)

        let predicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2, predicate3])
        chats = realm.objects(Chat.self).filter(predicate).sorted(byKeyPath: "lastMessageAt", ascending: false)

        tokenChats?.invalidate()
        chats.safeObserve({ changes in
            self.refreshTableView()
        }, completion: { token in
            self.tokenChats = token
        })
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func refreshTableView() {
        self.refreshTabCounter()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func refreshTabCounter() {

        var total: Int = 0

        for chat in chats {
            total += chat.unreadCount
        }

        if let items = tabBar.items {
            let tabItem = items[1]
            tabItem.badgeValue = (total != 0) ? "\(total)" : nil
        }
        UIApplication.shared.applicationIconBadgeNumber = total
    }
}
