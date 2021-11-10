//
//  Transaction.swift
//  Life
//
//  Created by mac on 2021/6/18.
//  Copyright © 2021 Zed. All rights reserved.
//

import RealmSwift
import CryptoSwift
//-------------------------------------------------------------------------------------------------------------------------------------------------
class ZEDPay: SyncObject {
    @objc dynamic var transId = ""
    @objc dynamic var fromUserId = ""
    @objc dynamic var toUserId = ""
    @objc dynamic var quantity: String = ""
    @objc dynamic var status:Int = TRANSACTION_STATUS.PENDING
    @objc dynamic var amount: Int = 0
    @objc dynamic var customerId = ""
    @objc dynamic var error = ""
    @objc dynamic var cardId = ""
    @objc dynamic var callFee: Bool = false
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    class func lastUpdatedAt() -> Int64 {

        let realm = try! Realm()
        let predicate = NSPredicate(format: "objectId != %@", AuthUser.userId())
        let object = realm.objects(Person.self).filter(predicate).sorted(byKeyPath: "updatedAt").last
        return object?.updatedAt ?? 0
    }

    // MARK: -
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    func update(fromUserId value: String) {

        if (fromUserId == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            fromUserId = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }
    
    func update(callFee value: Bool) {

        if (callFee == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            callFee = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }
    
    func update(toUserId value: String) {

        if (toUserId == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            toUserId = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }
    
    func update(status value: Int) {

        if (status == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            status = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }
    
    func update(quantity value: Float) {
        
        
        let encryptedValue = value.encryptedString()
        if (quantity == encryptedValue) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            quantity = encryptedValue
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }
    
    func updateLast(){
        let realm = try! Realm()
        try! realm.safeWrite {
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }
    func getQuantity() -> Float {
        
        return quantity.decryptedFloat()
        
    }
    
}
