//
//  OTPVerificationViewController.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import DPOTPView
import FirebaseAuth
import JGProgressHUD
class OTPVerificationViewController: UIViewController {
    
    @IBOutlet weak var nextButton: RoundButton!
    
    @IBOutlet weak var nextButtonArrow: UIImageView!
    
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var otpCodeView: DPOTPView!
    var userType: UserType?
    
    let hud = JGProgressHUD(style: .light)
    
    var phoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        otpCodeView.dpOTPViewDelegate = self
        subscribeToShowKeyboardNotifications()
        // initialize next button color
        checkOTPValidation(text: otpCodeView.text ?? "")
    }
    override func viewDidAppear(_ animated: Bool) {
        otpCodeView.becomeFirstResponder()
    }
    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            nextButtonBottomConstraint.constant = keyboardHeight + 30
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            nextButtonBottomConstraint.constant = 30
        }
    }
    
    func setPhoneNumber(withPhoneNumber phoneNumber: String){
        self.phoneNumber = phoneNumber
        
    }
    
    func checkOTPValidation(text: String){
        if(text.count == 6){
            nextButton.backgroundColor = UIColor(hexString: "#16406F")
            nextButtonArrow.tintColor = .white
        }
        else{
            nextButton.backgroundColor = UIColor(white: 0, alpha: 0.17)
            nextButtonArrow.tintColor = UIColor(white: 0, alpha: 0.31)
        }
    }
    @IBAction func onSubmitPressed(_ sender: Any) {
        let verificationCode = otpCodeView.text ?? "123456"
        if verificationCode.count != 6 {
            return
        }
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: verificationCode)
        DispatchQueue.main.async {
            self.hud.textLabel.text = ""
            self.hud.show(in: self.view, animated: true)
        }
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                self.hud.dismiss()
                Util.showAlert(vc: self, "認証コードが間違っています。もう一度入力してください。" , "")
                return
            }
            
            // Create Person
            //self.createPerson()
            // OTP Verification completed
            self.hud.textLabel.text = "登録が完了しました"
            self.hud.dismiss(afterDelay: 1.0, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now()+1.1, execute: {
                if self.userType == .hostess{
                    self.gotoHostessFillViewController()
                }else{
                    self.gotoBasicDetailInsertViewController()
                }
            })
        }
    }
    
    
    func gotoBasicDetailInsertViewController() {
        let vc =  self.storyboard?.instantiateViewController(identifier: "basicDetailInsertVC") as! BasicDetailInsertViewController
        vc.setPhoneNumber(withPhoneNumber: phoneNumber)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoHostessFillViewController() {
        let vc =  self.storyboard?.instantiateViewController(identifier: "HostFillViewController") as! HostFillViewController
        vc.phoneNumber = phoneNumber
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onResendCodePressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.hud.textLabel.text = "Sending...".localized
            self.hud.show(in: self.view, animated: true)
        }
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            self.hud.dismiss(afterDelay: 1.0, animated: true)
            if error != nil {
                Util.showAlert(vc: self, error?.localizedDescription ?? "", "")
                return
            }
            // Save Verification ID
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        }
    }
    
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension OTPVerificationViewController : DPOTPViewDelegate {
   func dpOTPViewAddText(_ text: String, at position: Int) {
        //// print("addText:- " + text + " at:- \(position)" )
        self.checkOTPValidation(text: text)
    }
    
    func dpOTPViewRemoveText(_ text: String, at position: Int) {
        //// print("removeText:- " + text + " at:- \(position)" )
        self.checkOTPValidation(text: text)
    }
    
    func dpOTPViewChangePositionAt(_ position: Int) {
        // print("at:-\(position)")
    }
    func dpOTPViewBecomeFirstResponder() {
        
    }
    func dpOTPViewResignFirstResponder() {
        
    }
}
