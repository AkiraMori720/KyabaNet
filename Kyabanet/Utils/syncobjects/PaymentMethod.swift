//
//  PaymentMethod.swift
//  Life
//
//  Created by mac on 2021/6/28.
//  Copyright © 2021 Zed. All rights reserved.
//

import Foundation
import RealmSwift
import CryptoSwift
//-------------------------------------------------------------------------------------------------------------------------------------------------
class PaymentMethod: SyncObject {
    @objc dynamic var userId = ""
    @objc dynamic var cardNumber = ""
    @objc dynamic var expMonth = ""
    @objc dynamic var expYear = ""
    @objc dynamic var cvc = ""
    @objc dynamic var customerId = ""
    @objc dynamic var error = ""
    @objc dynamic var status = ZEDPAY_STATUS.PENDING
    @objc dynamic var cardId = ""
    @objc dynamic var cardBrand = ""
    @objc dynamic var isDeleted = false
    
    func update(isDeleted value: Bool) {

        if (isDeleted == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            isDeleted = value
            status = ZEDPAY_STATUS.PENDING
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }
}
