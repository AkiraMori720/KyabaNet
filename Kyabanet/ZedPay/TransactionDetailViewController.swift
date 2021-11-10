//
//  TransactionDetailViewController.swift
//  Life
//
//  Created by mac on 2021/6/20.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import SwiftyAvatar
class TransactionDetailViewController: UIViewController {

    @IBOutlet weak var imageType: UIImageView!
    @IBOutlet weak var labelAmout: UILabel!
    @IBOutlet weak var labelPaidAt: UILabel!
    
    @IBOutlet weak var imageAvatar: SwiftyAvatar!
    
    @IBOutlet weak var lblSigned: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelPhone: UILabel!
    
    @IBOutlet weak var labelId: UILabel!
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var labelUserType: UILabel!
    
    @IBOutlet weak var labelTransactionType: UILabel!
    
    @IBOutlet weak var uiv_topfee: UIView!
    @IBOutlet weak var lbltopfeeamount: UILabel!
    @IBOutlet weak var uivPaidWith: UIView!
    @IBOutlet weak var lblReceive: UILabel!
    
    @IBOutlet weak var uivStackfee: UIView!
    @IBOutlet weak var lblStackfee: UILabel!
    
    var transaction: ZEDPay!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var person:Person?
        if(transaction.toUserId == transaction.fromUserId){
            self.uivStackfee.isHidden = true
            self.uivPaidWith.isHidden = true
            self.uiv_topfee.isHidden = true
            person = Persons.getById(transaction.fromUserId)
            imageType.image = UIImage(named: "ic_pay_charge")
            labelPaidAt.text = "お支払日" + " " + Convert.timestampPaid(transaction.updatedAt)
            lblSigned.text = "+"
            labelAmout.text = String(format: "%.2f",Double(transaction.amount)/100.0)
            labelUserType.text = "送金者："
            labelTransactionType.text = "ZED Payで入金する"
            labelTotal.text = String(format: "%.2f",Double(transaction.amount)/100.0)
            
            
        }else if(transaction.fromUserId == AuthUser.userId()){
            //sent
            self.uivStackfee.isHidden = true
            self.uivPaidWith.isHidden = true
            self.uiv_topfee.isHidden = true
            person = Persons.getById(transaction.toUserId)
            imageType.image = UIImage(named: "ic_sendmoney")
            labelPaidAt.text = "お支払日" + " " + Convert.timestampPaid(transaction.updatedAt)
            lblSigned.text = "-"
            if transaction.callFee{
                labelAmout.text = String(format: "%.2f",transaction.getQuantity())
                labelUserType.text = "通話代送金先："
                labelTotal.text = String(format: "%.2f",transaction.getQuantity())
            }else{
                labelAmout.text = String(format: "%.2f",transaction.getQuantity() * 100 / 97.5)
                labelUserType.text = "送金先："
                labelTotal.text = String(format: "%.2f",transaction.getQuantity() * 100 / 97.5)
            }
            labelTransactionType.text = "ZED Payで支払い済み"
            
            
        }else if(transaction.toUserId == AuthUser.userId()){
            //received
            if transaction.callFee{
                self.uivStackfee.isHidden = true
                self.uivPaidWith.isHidden = true
                self.uiv_topfee.isHidden = true
                person = Persons.getById(transaction.fromUserId)
                imageType.image = UIImage(named: "ic_receive")
                labelPaidAt.text = "お支払日" + " " + Convert.timestampPaid(transaction.updatedAt)
                lblSigned.text = "+"
                labelAmout.text = String(format: "%.2f",transaction.getQuantity() * 0.6)
                self.lblReceive.text = String(format: "%.2f",transaction.getQuantity() * 0.6)
                labelUserType.text = "受け取り合計金額："
                labelTransactionType.text = "ZED Payで受け取りました"
                labelTotal.text = String(format: "%.2f",transaction.getQuantity() * 0.6)
            }else{
                self.uivStackfee.isHidden = false
                self.uivPaidWith.isHidden = false
                self.uiv_topfee.isHidden = false
                let feeamount = transaction.getQuantity() * 2.5 / 97.5
                self.lbltopfeeamount.text = String(format: "%.2f",feeamount)
                
                self.lblStackfee.text = String(format: "%.2f",feeamount)
                
                person = Persons.getById(transaction.fromUserId)
                imageType.image = UIImage(named: "ic_receive")
                labelPaidAt.text = "お支払日" + " " + Convert.timestampPaid(transaction.updatedAt)
                lblSigned.text = "+"
                labelAmout.text = String(format: "%.2f",transaction.getQuantity() * 100 / 97.5)
                self.lblReceive.text = String(format: "%.2f",transaction.getQuantity() * 100 / 97.5)
                labelUserType.text = "受け取り合計金額："
                labelTransactionType.text = "ZED Payで受け取りました"
                labelTotal.text = String(format: "%.2f",transaction.getQuantity())
            }
        }
        labelId.text = transaction.transId
        labelName.text = person?.fullname
        labelPhone.text = person?.phone
        downloadImage(person: person!)
    }
    

    func downloadImage(person: Person) {

        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            
            if (error == nil) {
                self.imageAvatar.image = image
                //self.labelInitials.text = nil
            } else{
                self.imageAvatar.image = UIImage(named: "ic_default_profile")
            }
            
        }
    }

}
