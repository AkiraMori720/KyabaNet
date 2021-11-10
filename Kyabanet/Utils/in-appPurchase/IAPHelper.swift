//
//  IAPHelper.swift
//  Keto Diet
//
//  Created by Developer on 11/13/18.
//  Copyright © 2021 topdev. All rights reserved.
//
import Foundation

import UIKit
import StoreKit

enum IAPHandlerAlertType{
    case disabled
    case restored
    case purchased
    
    func message() -> String?{
        switch self {
        case .disabled: return nil
        case .restored: return "You have restored successfully."
        case .purchased: return "You have purchased successfully."
        /**case .restored: return "購入が正常に復元されました。"
        case .purchased: return "この購入を正常に購入しました。"*/
        }
    }
}

class IAPHandler: NSObject {
    
    static let shared = IAPHandler()
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    
    var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchaseMyProduct(strProductID : String) {
        
        if iapProducts.count == 0 {
            purchaseStatusBlock?(.disabled)
            return
        }
        
        if  self.canMakePurchases() {
            var product : SKProduct!
            for item in iapProducts {
                if item.productIdentifier == strProductID {
                    product = item
                }
            }

            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
            
        } else {
            purchaseStatusBlock?(.disabled)
        }
    }
    
    // MARK: - RESTORE PURCHASE
    func restorePurchase(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts(){
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects:
                                       KyabanetProducts.KyabanetCharge500Yen,
                                       KyabanetProducts.KyabanetCharge1000Yen,
                                       KyabanetProducts.KyabanetCharge5000Yen,
                                       KyabanetProducts.KyabanetCharge10000Yen)
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
}


extension IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        if (response.products.count > 0) {
            iapProducts = response.products
            for product in iapProducts{
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = product.priceLocale
                let price1Str = numberFormatter.string(from: product.price)
                print(product.localizedDescription + "\nfor just \(price1Str!)")
            }
        } else {
            print(response.description)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        if queue.transactions.count == 0 {
            purchaseStatusBlock?(.disabled)
        } else {
            print("restore completed with queue \(queue.transactions[0].payment.productIdentifier)")
            purchaseStatusBlock?(.restored)
        }
    }
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    print("purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.purchased)
                    break
                    
                case .failed:
                    print("failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.disabled)
                    break
                case .restored:
                    print("restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }
            }
        }
    }
}

public struct KyabanetProducts {
    public static let KyabanetCharge500Yen   = "com.zed.kyabnet.charge500"
    public static let KyabanetCharge1000Yen  = "com.zed.kyabnet.charge1000"
    public static let KyabanetCharge5000Yen  = "com.zed.kyabnet.charge5000"
    public static let KyabanetCharge10000Yen = "com.zed.kyabnet.charge10000"
}
