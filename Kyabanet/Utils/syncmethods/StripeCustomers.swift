//
//  StripeCustomers.swift
//  Life
//
//  Created by mac on 2021/6/27.
//  Copyright © 2021 Zed. All rights reserved.
//

import Foundation
import RealmSwift
class StripeCustomers: NSObject {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    class func create(passcode: String) {


        let stripeCustomer = StripeCustomer()
        guard let person = Persons.currentPerson() else{
            return
        }
        stripeCustomer.userId = person.objectId
        stripeCustomer.email = person.email
        stripeCustomer.name = person.fullname
        stripeCustomer.phone = person.phone
        stripeCustomer.passcode = passcode.encryptedString()
        let realm = try! Realm()
        try! realm.safeWrite {
            realm.add(stripeCustomer, update: .modified)
        }
        
    }

    
}
