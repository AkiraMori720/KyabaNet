//
//  RemovePaymentViewController.swift
//  Life
//
//  Created by mac on 2021/6/28.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import JGProgressHUD
import RealmSwift
class RemovePaymentViewController: UIViewController {

    @IBOutlet weak var imageCard: UIImageView!
    var paymentMethod: PaymentMethod?
    var delegate: UpdatePayDelegateProtocol?
    
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var carExp: UILabel!
    @IBOutlet weak var cardImage: UIImageView!
    
    @IBOutlet weak var cardCVC: UILabel!
    let hud = JGProgressHUD(style: .light)
    private var tokenPaymentmethod: NotificationToken? = nil
    private var paymentMethods = realm.objects(PaymentMethod.self).filter(falsepredicate)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if paymentMethod?.cardBrand == "visa" {
            cardImage.image = UIImage(named: "ic_card_visa")
        } else if paymentMethod?.cardBrand == "amex"{
            cardImage.image = UIImage(named: "ic_card_amex")
        } else if paymentMethod?.cardBrand == "mastercard"{
            cardImage.image = UIImage(named: "ic_card_mastercard")
        } else if paymentMethod?.cardBrand == "diners"{
            cardImage.image = UIImage(named: "ic_card_dinersclub")
        } else if paymentMethod?.cardBrand == "discover"{
            cardImage.image = UIImage(named: "ic_card_discovery")
        } else if paymentMethod?.cardBrand == "unionpay"{
            cardImage.image = UIImage(named: "ic_card_unionpay")
        } else if paymentMethod?.cardBrand == "jcb"{
            cardImage.image = UIImage(named: "ic_card_jcb")
        } else{
            cardImage.isHidden = true
        }
        
        cardNumber.text = "**** **** **** " + paymentMethod!.cardNumber
        carExp.text = paymentMethod!.expMonth+"/"+paymentMethod!.expYear
        cardCVC.text = paymentMethod?.cvc
    }
    

    @IBAction func actionTapClosed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func actionTapRemove(_ sender: Any) {
        let predicate = NSPredicate(format: "userId == %@ AND status == %@ AND isDeleted == NO", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
        guard let paymentMethod = realm.objects(PaymentMethod.self).filter(predicate).first else{
            return
        }
        paymentMethod.update(isDeleted: true)
        self.hud.show(in: self.view, animated: true)
        
        let predicate1 = NSPredicate(format: "userId == %@ AND status == %@ AND isDeleted == YES", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
        paymentMethods = realm.objects(PaymentMethod.self).filter(predicate1)
        tokenPaymentmethod?.invalidate()
        paymentMethods.safeObserve({ changes in
            self.removePaymentMethod()
        }, completion: { token in
            self.tokenPaymentmethod = token
        })
    }
    
    func removePaymentMethod(){
        guard let paymentMethod = paymentMethods.first else{
            return
        }
        
        if paymentMethod.status == ZEDPAY_STATUS.PENDING {
            return
        }
        
        if paymentMethod.status == ZEDPAY_STATUS.FAILED {
            self.hud.dismiss()
            self.dismiss(animated: true){
                self.delegate?.updateCard(result: false)
            }
        }
        if paymentMethod.status == ZEDPAY_STATUS.SUCCESS {
            self.hud.dismiss()
            self.dismiss(animated: true){
                self.delegate?.updateCard(result: true)
            }
            
        }
    }
}
