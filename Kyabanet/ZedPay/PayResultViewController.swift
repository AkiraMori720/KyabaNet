//
//  PayResultViewController.swift
//  Life
//
//  Created by mac on 2021/6/23.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import RealmSwift
import FittedSheets
class PayResultViewController: UIViewController {

    @IBOutlet weak var labelTransactionId: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    
    @IBOutlet weak var labelPaymenResult: UILabel!
    
    @IBOutlet weak var imagePayResult: UIImageView!
    
    var transactionObjectId = ""
    var transaction: ZEDPay!
    var chatId: String?
    var recipientId: String?
    @IBOutlet weak var btnAgain: RoundButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        labelTransactionId.text = transaction.transId
        labelAmount.text = String(format: "%.2f", transaction.getQuantity() * 100 / 97.5)
        if(transaction.status == TRANSACTION_STATUS.SUCCESS){
            labelPaymenResult.text = "お支払いが完了しました"
            imagePayResult.image = UIImage(named: "ic_pay_success")
            if(chatId != nil && recipientId != nil){
                Messages.sendMoney(chatId: chatId!, recipientId: recipientId!, payId: transaction.transId, failed: false)
            }
            btnAgain.setTitle("違うお支払いをする", for: .normal)
            
        }else if(transaction.status == TRANSACTION_STATUS.FAILED){
            labelPaymenResult.text = "お支払いに失敗しました"
            imagePayResult.image = UIImage(named: "ic_pay_fail")
            if(chatId != nil && recipientId != nil){
                Messages.sendMoney(chatId: chatId!, recipientId: recipientId!, payId: transaction.transId, failed: true)
            }
            btnAgain.setTitle("もう一度試す", for: .normal)
            
        }
        
        
    }
    
    @IBAction func actionTapAgain(_ sender: Any) {
        
        let toPerson = realm.object(ofType: Person.self, forPrimaryKey: transaction.toUserId)
        weak var pvc = self.presentingViewController
        self.dismiss(animated: false, completion: {
            let vc =  self.storyboard?.instantiateViewController(identifier: "payBottomSheetVC") as! PayBottomSheetViewController
            vc.person = toPerson
            vc.chatId = self.chatId
            vc.recipientId = self.recipientId
            if(self.transaction.status == TRANSACTION_STATUS.FAILED){
                vc.quantity = self.transaction.getQuantity()
            }
            
            let sheetController = SheetViewController(controller: vc, sizes: [.fixed(470)])
            pvc?.present(sheetController, animated: true, completion: nil)
        })
        
    }
    
    @IBAction func actionTapDone(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
