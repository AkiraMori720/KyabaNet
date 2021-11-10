//
//  PassPayViewController.swift
//  Life
//
//  Created by mac on 2021/6/23.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import DPOTPView
import JGProgressHUD
import RealmSwift
import KAPinField

class PassPayViewController: UIViewController {
    weak var pvc : UIViewController?
    @IBOutlet weak var nextButton: RoundButton!
    @IBOutlet weak var nextBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var imageNext: UIImageView!
    @IBOutlet weak var otpCodeView: KAPinField!
    
    
    private var tokenTransactions: NotificationToken? = nil
    private var transactions = realm.objects(ZEDPay.self).filter(falsepredicate)
    
    let hud = JGProgressHUD(style: .light)
    var toUserId: String = ""
    var quantity: Float = 0
    var updating = false
    var transactionObjectId = ""
    
    
    var chatId: String?
    var recipientId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setStyle() {
        otpCodeView.properties.delegate = self
        otpCodeView.properties.animateFocus = true
        otpCodeView.text = ""
        otpCodeView.keyboardType = .numberPad
        otpCodeView.properties.numberOfCharacters = 4
        otpCodeView.appearance.tokenColor = UIColor.black.withAlphaComponent(0.2)
        otpCodeView.appearance.tokenFocusColor = UIColor.black.withAlphaComponent(0.2)
        otpCodeView.appearance.textColor = UIColor.black
        otpCodeView.appearance.font = .menlo(40)
        
        otpCodeView.appearance.kerning = 40
        otpCodeView.appearance.backOffset = 5
        otpCodeView.appearance.backColor = UIColor.clear
        otpCodeView.appearance.backBorderWidth = 1
        otpCodeView.appearance.backBorderColor = UIColor.black.withAlphaComponent(0.2)
        otpCodeView.appearance.backCornerRadius = 4
        otpCodeView.appearance.backFocusColor = UIColor.clear
        otpCodeView.appearance.backBorderFocusColor = UIColor.black.withAlphaComponent(0.8)
        otpCodeView.appearance.backActiveColor = UIColor.clear
        otpCodeView.appearance.backBorderActiveColor = UIColor.black
        otpCodeView.appearance.backRounded = false
        otpCodeView.becomeFirstResponder()
    }
    
    //MARK:- check validation
    func checkValidation(text: String){
        if(text.count == 4){
            let predicate = NSPredicate(format: "userId == %@ AND status == %@ ", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
            let customers = realm.objects(StripeCustomer.self).filter(predicate)
            guard let customer = customers.first else{
                return
            }
            if(text != customer.passcode.decryptedString()){
                let confirmationAlert = UIAlertController(title: "", message: "パスコードが違います", preferredStyle: .alert)
                confirmationAlert.addAction(UIAlertAction(title: "OK".localized, style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                present(confirmationAlert, animated: true, completion: nil)
            }else{
                self.hud.textLabel.text = "送金しています"
                self.hud.show(in: self.view, animated: true)
                self.updating = true
                self.transactionObjectId = ZEDPays.create(fromUserId: (Persons.currentPerson()?.objectId)!, toUserId: toUserId, quantity: quantity * 0.975)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                let predicate = NSPredicate(format: "objectId == %@", self.transactionObjectId )
                self.transactions = realm.objects(ZEDPay.self).filter(predicate)
                self.tokenTransactions?.invalidate()
                self.transactions.safeObserve({ changes in
                self.callBack()
                }, completion: { token in
                self.tokenTransactions = token
                })
                }
            }
        }
   }
    
    // MARK: - keyboard layout
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            nextBottomContraint.constant = keyboardHeight + 30
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            nextBottomContraint.constant = 30
        }
    }
    //MARK:- close
    @IBAction func actionClose(_ sender: Any) {
        if(updating == false){
            self.dismiss(animated: true, completion: nil)
        }
    }
    // MARK: - next tap
    /*@IBAction func actionTapNext(_ sender: Any) {
        let passCode = dpPassCode.text ?? ""
        
        let predicate = NSPredicate(format: "userId == %@ AND status == %@ ", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
        let customers = realm.objects(StripeCustomer.self).filter(predicate)
        guard let customer = customers.first else{
            return
        }
        if(passCode != customer.passcode.decryptedString()){
            let confirmationAlert = UIAlertController(title: "", message: "PassCode incorrect".localized, preferredStyle: .alert)
            confirmationAlert.addAction(UIAlertAction(title: "OK".localized, style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(confirmationAlert, animated: true, completion: nil)
        }else{
            self.hud.textLabel.text = "Sending Money...".localized
            self.hud.show(in: self.view, animated: true)
            self.updating = true
            self.transactionObjectId = ZEDPays.create(fromUserId: (Persons.currentPerson()?.objectId)!, toUserId: toUserId, quantity: quantity * 0.975)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                let predicate = NSPredicate(format: "objectId == %@", self.transactionObjectId )
                self.transactions = realm.objects(ZEDPay.self).filter(predicate)
                self.tokenTransactions?.invalidate()
                self.transactions.safeObserve({ changes in
                    self.callBack()
                }, completion: { token in
                    self.tokenTransactions = token
                })
            }
        }
    }*/
    
    //MARK: - Transcation callback
    func callBack(){
        
        guard let transaction = self.transactions.first else{
            return
        }
        if transaction.status == TRANSACTION_STATUS.PENDING{
            return
        }
        self.hud.dismiss()
        
        self.updating = false
        
        
        weak var pvc = self.presentingViewController
        self.dismiss(animated: false, completion: {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "payResultVC") as! PayResultViewController
            vc.transaction = self.transactions.first!
            vc.chatId = self.chatId
            vc.recipientId = self.recipientId
            vc.modalPresentationStyle = .fullScreen
            pvc?.present(vc, animated: true)
        })
    }
}

extension PassPayViewController : KAPinFieldDelegate {
    func pinField(_ field: KAPinField, didChangeTo string: String, isValid: Bool) {
        
    }
    
    func pinField(_ field: KAPinField, didFinishWith code: String) {
        checkValidation(text: code)
    }
}
