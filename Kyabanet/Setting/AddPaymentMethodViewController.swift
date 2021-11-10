//
//  AddPaymentMethodViewController.swift
//  Life
//
//  Created by mac on 2021/6/28.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import FormTextField
import CreditCardValidator
import JGProgressHUD
import RealmSwift
class AddPaymentMethodViewController: UIViewController {

    @IBOutlet weak var btnAddCard: RoundButton!
    @IBOutlet weak var imageCard: UIImageView!
    @IBOutlet weak var addCardForm: UIView!
    @IBOutlet weak var cardNo: FormTextField!
    @IBOutlet weak var cardExp: FormTextField!
    
    @IBOutlet weak var cardCVC: FormTextField!
    var delegate: UpdatePayDelegateProtocol?
    let hud = JGProgressHUD(style: .light)
    
    private var tokenPaymentmethod: NotificationToken? = nil
    private var paymentMethods = realm.objects(PaymentMethod.self).filter(falsepredicate)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cardNo.formatter = CardNumberFormatter()
        cardExp.formatter = CardExpirationDateFormatter()
        cardExp.inputValidator = CardExpirationDateInputValidator()
        
        var validation = Validation()
        validation.minimumLength = 19
        validation.maximumLength = 19
        cardNo.inputValidator = InputValidator(validation: validation)
        
        var validation1 = Validation()
        validation1.minimumLength = 3
        validation1.maximumLength = 3
        cardCVC.inputValidator = InputValidator(validation: validation1)
        
        cardExp.textFieldDelegate = self
        cardNo.textFieldDelegate = self
        cardCVC.textFieldDelegate = self
        btnAddCard.isHidden = true
        imageCard.isHidden = true
    }
    
    @IBAction func actionTapClosed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionTapAdd(_ sender: Any) {
        self.hud.show(in: self.view, animated: true)
        let predicate = NSPredicate(format: "userId == %@ AND status == %@", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
        if let customer = realm.objects(StripeCustomer.self).filter(predicate).first {
            let cardNumber = cardNo.text?.replacingOccurrences(of: " ", with: "")
            let cvc = cardCVC.text!
            let cardExpDates = cardExp.text?.components(separatedBy: "/")
            let cardExpMonth = cardExpDates?[0]
            let cardExpYear = cardExpDates?[1]
            self.hud.show(in: self.view, animated: true)
            PaymentMethods.create(userId: AuthUser.userId(), customerId: customer.customerId, cardNumber: cardNumber!, expMonth: cardExpMonth!, expYear:cardExpYear!, cvc: cvc)
            let predicate = NSPredicate(format: "userId == %@ AND status == %@ AND isDeleted == NO", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
            paymentMethods = realm.objects(PaymentMethod.self).filter(predicate)
            
            tokenPaymentmethod?.invalidate()
            paymentMethods.safeObserve({ changes in
                self.addPaymentMethod()
            }, completion: { token in
                self.tokenPaymentmethod = token
            })
            
            
        }else{
            self.hud.dismiss()
            self.dismiss(animated: true){
                self.delegate?.updateCard(result: false)
            }
        }
    }
    
    func addPaymentMethod(){
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

extension AddPaymentMethodViewController: FormTextFieldDelegate{
    func formTextField(_ textField: FormTextField, didUpdateWithText text: String?){
        
        let number = cardNo.text!
        if CreditCardValidator(number).isValid {
            imageCard.isHidden = false
            if CreditCardValidator(number).isValid(for: .visa) {
                imageCard.image = UIImage(named: "ic_card_visa")
            } else if CreditCardValidator(number).isValid(for: .amex){
                imageCard.image = UIImage(named: "ic_card_amex")
            } else if CreditCardValidator(number).isValid(for: .masterCard){
                imageCard.image = UIImage(named: "ic_card_mastercard")
            } else if CreditCardValidator(number).isValid(for: .maestro){
                imageCard.image = UIImage(named: "ic_card_maestro")
            } else if CreditCardValidator(number).isValid(for: .dinersClub){
                imageCard.image = UIImage(named: "ic_card_dinersclub")
            } else if CreditCardValidator(number).isValid(for: .discover){
                imageCard.image = UIImage(named: "ic_card_discovery")
            } else if CreditCardValidator(number).isValid(for: .unionPay){
                imageCard.image = UIImage(named: "ic_card_unionpay")
            } else if CreditCardValidator(number).isValid(for: .mir){
                imageCard.image = UIImage(named: "ic_card_mir")
            } else if CreditCardValidator(number).isValid(for: .jcb){
                imageCard.image = UIImage(named: "ic_card_jcb")
            } else{
                btnAddCard.isHidden = true
                return
            }
            
            if( cardExp.validate() && cardCVC.validate()){
                btnAddCard.isHidden = false
            }else{
                btnAddCard.isHidden = true
            }
        } else {
            btnAddCard.isHidden = true
            imageCard.isHidden = false
            imageCard.image = UIImage(named: "ic_card_error")
            
        }
        
        
    }
}
