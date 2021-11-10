//
//  StripeCustomer.swift
//  Life
//
//  Created by mac on 2021/6/27.
//  Copyright © 2021 Zed. All rights reserved.
//

import Foundation
import RealmSwift
import CryptoSwift
//-------------------------------------------------------------------------------------------------------------------------------------------------
class StripeCustomer: SyncObject {
    @objc dynamic var userId = ""
    @objc dynamic var email = ""
    @objc dynamic var phone = ""
    @objc dynamic var name = ""
    @objc dynamic var customerId = ""
    @objc dynamic var setupSecret = ""
    @objc dynamic var status = ZEDPAY_STATUS.PENDING
    @objc dynamic var passcode = ""
    @objc dynamic var error = ""
    
    
    func update(passcode value: String) {

        if (passcode == value.encryptedString()) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            passcode = value.encryptedString()
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }
}
