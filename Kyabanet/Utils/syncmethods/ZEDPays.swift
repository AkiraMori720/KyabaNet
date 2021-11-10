//
//  Transactions.swift
//  Life
//
//  Created by mac on 2021/6/18.
//  Copyright © 2021 Zed. All rights reserved.
//
import RealmSwift
class ZEDPays: NSObject {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    class func create(fromUserId: String, toUserId: String, quantity: Float) -> String {
        let zedPay = ZEDPay()
        zedPay.transId = zedPay.objectId.crc32().uppercased()
        zedPay.fromUserId = fromUserId
        zedPay.toUserId = toUserId
        zedPay.quantity = quantity.encryptedString()
        zedPay.status = TRANSACTION_STATUS.PENDING
        //transaction.callBack = callBack
        let realm = try! Realm()
        try! realm.safeWrite {
            realm.add(zedPay, update: .modified)
        }
        return zedPay.objectId
    }
    
    class func callFeecreate(fromUserId: String, toUserId: String, quantity: Float) -> String {
        let zedPay = ZEDPay()
        zedPay.transId = zedPay.objectId.crc32().uppercased()
        zedPay.fromUserId = fromUserId
        zedPay.toUserId = toUserId
        zedPay.quantity = quantity.encryptedString()
        zedPay.status = TRANSACTION_STATUS.PENDING
        zedPay.callFee = true
        //transaction.callBack = callBack
        let realm = try! Realm()
        try! realm.safeWrite {
            realm.add(zedPay, update: .modified)
        }
        return zedPay.objectId
    }
    
    class func createAdd(userId: String, customerId: String, cardId: String, quantity: Float) -> String {


        let zedPay = ZEDPay()
        
        zedPay.transId = zedPay.objectId.crc32().uppercased()
        zedPay.fromUserId = userId
        zedPay.toUserId = userId
        //usd dollar smallest unit 0.5
        zedPay.amount = Int(floor(quantity * 100))
        
        zedPay.quantity = ((Persons.currentPerson()?.getBalance())! + quantity).encryptedString()
        zedPay.customerId = customerId
        zedPay.status = TRANSACTION_STATUS.PENDING
        zedPay.cardId = cardId
        //transaction.callBack = callBack
        let realm = try! Realm()
        try! realm.safeWrite {
            realm.add(zedPay, update: .modified)
        }
        return zedPay.objectId
        
    }

    // MARK: -
    //---------------------------------------------------------------------------------------------------------------------------------------------
    class func update(_ transactionId: String, status: Int) {

        if let zedPay = realm.object(ofType: ZEDPay.self, forPrimaryKey: transactionId) {
            zedPay.update(status: status)
        }
    }
    class func update(_ transactionId: String, fromUserId: String) {

        if let zedPay = realm.object(ofType: ZEDPay.self, forPrimaryKey: transactionId) {
            zedPay.update(fromUserId: fromUserId)
        }
    }
    
    class func update(_ transactionId: String, toUserId: String) {

        if let zedPay = realm.object(ofType: ZEDPay.self, forPrimaryKey: transactionId) {
            zedPay.update(toUserId: toUserId)
        }
    }
    
    class func update(_ transactionId: String, quantity: Float) {

        if let zedPay = realm.object(ofType: ZEDPay.self, forPrimaryKey: transactionId) {
            zedPay.update(quantity: quantity)
        }
    }
}
