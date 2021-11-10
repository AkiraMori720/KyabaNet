//
//  PayBottomSheetViewController.swift
//  Life
//
//  Created by mac on 2021/6/20.
//  Copyright © 2021 Zed. All rights reserved.
//

/**import UIKit
import SwiftyAvatar
import JGProgressHUD
import RealmSwift
class PayBottomSheetViewController: UIViewController {
    var isFriend : Bool = false
    var person: Person!
    
    var qrCode : String!
    var qrView : PayQRCodeViewController!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var profile: SwiftyAvatar!
   
    @IBOutlet weak var labelBalance: UILabel!
    @IBOutlet weak var inputAmount: UITextField!
    
    let hud = JGProgressHUD(style: .light)
    var chatId: String?
    var recipientId: String?
    var quantity: Float?
    
    
    private var stripeCustomers = realm.objects(StripeCustomer.self).filter(falsepredicate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            // Do any additional setup after loading the view.
            name.text = person.fullname
            
            phoneNumber.text = person.phone
        
            guard let currentPerson = Persons.currentPerson() else{
                return
            }
            labelBalance.text = String(format: "%.2f", currentPerson.getBalance())
            
            if(quantity != nil){
                inputAmount.text = String(format: "%.2f", quantity!)
            }
            MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
                if (error == nil) {
                    self.profile.image = image
                }
                else {
                    self.profile.image = UIImage(named: "ic_default_profile")
                }
                self.view.isHidden = false
            }
        
    }
    
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    @IBAction func onCancelTapped(_ sender: Any) {
        dismiss(animated: true, completion:  nil)
    }
    
    //MARK:- action send
    @IBAction func actionTapSend(_ sender: Any) {
        guard let currentPerson = Persons.currentPerson() else{
            return
        }
        guard let textAmount = inputAmount.text else{
            return
        }
        if textAmount == "" {
            return
        }
        let floatAmount = (textAmount as NSString).floatValue
        if(floatAmount <= 0){
            let confirmationAlert = UIAlertController(title: "", message: "The amount must be greater than 0.".localized, preferredStyle: .alert)
            confirmationAlert.addAction(UIAlertAction(title: "OK".localized, style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(confirmationAlert, animated: true, completion: nil)
            return
        }
        if(floatAmount > currentPerson.getBalance()){
            let confirmationAlert = UIAlertController(title: "", message: "The amount must be smaller than available.".localized, preferredStyle: .alert)
            confirmationAlert.addAction(UIAlertAction(title: "OK".localized, style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(confirmationAlert, animated: true, completion: nil)
            return
        }
        inputAmount.resignFirstResponder()
        
        
        weak var pvc = self.presentingViewController
        self.dismiss(animated: false, completion: {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "passPayVC") as! PassPayViewController
            vc.toUserId = self.person.objectId
            vc.quantity = floatAmount
           
            vc.chatId = self.chatId
            vc.recipientId = self.recipientId
            vc.modalPresentationStyle = .fullScreen
            pvc?.present(vc, animated: true)
        })
        
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        guard let _qrView = qrView else {
            return
        }
        _qrView.qrReader.startScanning()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if(inputAmount.text == "0"){
            inputAmount.text = ""
        }
    }
    @objc func keyboardWillHide(_ notification: Notification?) {
        if(inputAmount.text == ""){
            inputAmount.text = "0"
        }
        
    }
    

}*/
import UIKit
import SwiftyAvatar
import JGProgressHUD
import RealmSwift
class PayBottomSheetViewController: UIViewController {
    var isFriend : Bool = false
    var person: Person!
    
    var qrCode : String!
    var qrView : PayQRCodeViewController!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var profile: SwiftyAvatar!
   
    @IBOutlet weak var labelBalance: UILabel!
    @IBOutlet weak var inputAmount: UITextField!
    
    let hud = JGProgressHUD(style: .light)
    var chatId: String?
    var recipientId: String?
    var quantity: Float?
    
    
    private var stripeCustomers = realm.objects(StripeCustomer.self).filter(falsepredicate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            // Do any additional setup after loading the view.
            name.text = person.fullname
            
            phoneNumber.text = person.phone
        
            guard let currentPerson = Persons.currentPerson() else{
                return
            }
            labelBalance.text = String(format: "%.2f", currentPerson.getBalance())
            
            if(quantity != nil){
                inputAmount.text = String(format: "%.2f", quantity!)
            }
            MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
                if (error == nil) {
                    self.profile.image = image
                }
                else {
                    self.profile.image = UIImage(named: "ic_default_profile")
                }
                self.view.isHidden = false
            }
        
    }
    
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    @IBAction func onCancelTapped(_ sender: Any) {
        dismiss(animated: true, completion:  nil)
    }
    
    //MARK:- action send
    @IBAction func actionTapSend(_ sender: Any) {
        guard let currentPerson = Persons.currentPerson() else{
            return
        }
        guard let textAmount = inputAmount.text else{
            return
        }
        if textAmount == "" {
            return
        }
        let floatAmount = (textAmount as NSString).floatValue
        if(floatAmount <= 0){
            let confirmationAlert = UIAlertController(title: "", message: "０以上の額を入力してください。", preferredStyle: .alert)
            confirmationAlert.addAction(UIAlertAction(title: "OK".localized, style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(confirmationAlert, animated: true, completion: nil)
            return
        }
        if(floatAmount > currentPerson.getBalance()){
            let confirmationAlert = UIAlertController(title: "", message: "ご利用可能残高が入力した金額を超えている必要があります。", preferredStyle: .alert)
            confirmationAlert.addAction(UIAlertAction(title: "OK".localized, style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(confirmationAlert, animated: true, completion: nil)
            return
        }
        inputAmount.resignFirstResponder()
        
        
        weak var pvc = self.presentingViewController
        self.dismiss(animated: false, completion: {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "passPayVC") as! PassPayViewController
            vc.toUserId = self.person.objectId
            vc.quantity = floatAmount
           
            vc.chatId = self.chatId
            vc.recipientId = self.recipientId
            vc.modalPresentationStyle = .fullScreen
            pvc?.present(vc, animated: true)
        })
        
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        guard let _qrView = qrView else {
            return
        }
        _qrView.qrReader.startScanning()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if(inputAmount.text == "0"){
            inputAmount.text = ""
        }
    }
    @objc func keyboardWillHide(_ notification: Notification?) {
        if(inputAmount.text == ""){
            inputAmount.text = "0"
        }
        
    }
    

}
