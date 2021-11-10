//
//  FireTransaction.swift
//  Life
//
//  Created by mac on 2021/6/23.
//  Copyright © 2021 Zed. All rights reserved.
//

import Foundation

import FirebaseFirestore
import RealmSwift

class FireZEDPayUpdaters: NSObject {
    private var updating = false
    private var objects: Results<ZEDPay>?
    init(type: SyncObject.Type) {
        
        super.init()
        let predicate = NSPredicate(format: "syncRequired == YES AND status IN %@", [TRANSACTION_STATUS.PENDING])
        objects = realm.objects(ZEDPay.self).filter(predicate).sorted(byKeyPath: "updatedAt")

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if (AuthUser.userId() != "") {
                if (Connectivity.isReachable()) {
                    self.updateNextObject()
                }
            }
        }
    }
    private func updateNextObject() {

       if (updating) { return }
       
       if let object = objects?.first {
           updateObject(object)
       }
    }
    private func updateObject(_ object: ZEDPay) {
        updating = true
        
        object.updateLast()
        
        if object.fromUserId != object.toUserId{
            object.update(status: TRANSACTION_STATUS.SUCCESS)
            let transValues = populateObject(object)
            let db = Firestore.firestore()
            let batch = db.batch()
            let _fromUser = realm.object(ofType: Person.self, forPrimaryKey: object.fromUserId)
            
            guard let fromUser = _fromUser else {
                return
            }
            let fromUserBalance = fromUser.getBalance()
            
            let _toUser = realm.object(ofType: Person.self, forPrimaryKey: object.toUserId)
            guard let toUser = _toUser else {
                return
            }
            
            let toUserBalance = toUser.getBalance()
            let quantity = object.getQuantity()
            if object.callFee{
                fromUser.update(balance: fromUserBalance - quantity)
            }else{
                fromUser.update(balance: fromUserBalance - quantity * 100 / 97.5)
            }
            
           
            let fromUserValues = populateObject(fromUser)
            if object.callFee{
                toUser.update(balance: toUserBalance + quantity * 0.6)
            }else{
                toUser.update(balance: toUserBalance + quantity)
            }
            
            let toUserValues = populateObject(toUser)
           
            let fromUserRef = db.collection("Person").document(fromUser.objectId)
            batch.updateData(fromUserValues, forDocument: fromUserRef)
            let toUserRef = db.collection("Person").document(toUser.objectId)
            batch.updateData(toUserValues, forDocument: toUserRef)
            let transactionRef = db.collection("ZEDPay").document(object.objectId)
            
            if (object.neverSynced) {
                 batch.setData(transValues, forDocument: transactionRef)
            } else {
                 batch.updateData(transValues, forDocument: transactionRef)
            }
            batch.commit() { err in
                 if err==nil {
                 
                     object.update(status: TRANSACTION_STATUS.SUCCESS)
                     object.updateSynced()
                 }else{
                 
                     object.update(status: TRANSACTION_STATUS.FAILED)
                     if(object.toUserId != object.fromUserId){
                         fromUser.update(balance: fromUserBalance)
                         toUser.update(balance: toUserBalance)
                     }
                 }
                 
                 self.updating = false
            }
        }else{
            let transValues = populateObject(object)
            if (object.neverSynced) {
                Firestore.firestore().collection("ZEDPay").document(object.objectId).setData(transValues) { error in
                    if (error == nil) {
                        object.updateSynced()
                    }
                    self.updating = false
                }
            } else {
                Firestore.firestore().collection("ZEDPay").document(object.objectId).updateData(transValues) { error in
                    if (error == nil) {
                        object.updateSynced()
                    }
                    self.updating = false
                }
            }
        }
        
   }

    private func populateObject(_ object: SyncObject) -> [String: Any] {

       var values: [String: Any] = [:]

       for property in object.objectSchema.properties {
           let name = property.name
           if (name != "neverSynced") && (name != "syncRequired"){
               switch property.type {
                   case .int:        if let value = object[name] as? Int64    { values[name] = value }
                   case .bool:        if let value = object[name] as? Bool    { values[name] = value }
                   case .float:    if let value = object[name] as? Float    { values[name] = value }
                   case .double:    if let value = object[name] as? Double    { values[name] = value }
                   case .string:    if let value = object[name] as? String    { values[name] = value }
                   case .date:        if let value = object[name] as? Date    { values[name] = value }
                   default:
                       print("Property type \(property.type.rawValue) is not populated.")
               }
           }
       }
       return values
   }


}
