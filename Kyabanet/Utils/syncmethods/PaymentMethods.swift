//
//  PaymentMethods.swift
//  Life
//
//  Created by mac on 2021/6/28.
//  Copyright © 2021 Zed. All rights reserved.
//

import Foundation
import RealmSwift
class PaymentMethods: NSObject {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    class func create(userId: String, customerId: String, cardNumber: String, expMonth: String, expYear: String, cvc: String) {


        let paymentMethod = PaymentMethod()
        paymentMethod.userId = userId
        paymentMethod.customerId = customerId
        
        paymentMethod.cardNumber = cardNumber
        paymentMethod.expMonth = expMonth
        paymentMethod.expYear = expYear
        paymentMethod.cvc = cvc
        
        let realm = try! Realm()
        try! realm.safeWrite {
            realm.add(paymentMethod, update: .modified)
        }
        
    }

    
}
