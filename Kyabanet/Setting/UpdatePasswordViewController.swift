//
//  UpdatePasswordViewController.swift
//  Life
//
//  Created by Jaelhorton on 7/10/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class UpdatePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var informLabel: UILabel!
    
    @IBOutlet weak var newPasswordEye: UIButton!
    
    @IBOutlet weak var confirmPasswordEye: UIButton!
    
    var delegate: UpdateDataDelegateProtocol? = nil
    
    var newpassword_eye_off = true
    var confirmpassword_eye_off = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        informLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        newPasswordTextField.becomeFirstResponder()
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onNewPasswordEyeTapped(_ sender: Any) {
        if newpassword_eye_off{
            newPasswordTextField.isSecureTextEntry = false
            newPasswordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        }else {
            newPasswordTextField.isSecureTextEntry = true
            newPasswordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }
        newpassword_eye_off = !newpassword_eye_off
    }
    
    @IBAction func onConfirmPasswordEyeTapped(_ sender: Any) {
        if confirmpassword_eye_off{
            confirmPasswordTextField.isSecureTextEntry = false
            confirmPasswordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        }else {
            confirmPasswordTextField.isSecureTextEntry = true
            confirmPasswordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }
        confirmpassword_eye_off = !confirmpassword_eye_off
    }
    
    func showInformText(withOption option: Bool, withText value: String = "")
    {
        informLabel.isHidden = option
        informLabel.text = value
    }
    @IBAction func onSubmitTapped(_ sender: Any) {
        let newPassword = self.newPasswordTextField.text
        if newPassword?.isEmpty == true {
            return
        }
        if newPasswordTextField.text == confirmPasswordTextField.text {
            showInformText(withOption: true)
            self.dismiss(animated: true) {
                self.delegate?.updatePassword(password: self.newPasswordTextField.text!)
            }
        }
        else{
            showInformText(withOption: false, withText: "パスワードは同じものを入力してください")
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        // Try to find next responder
        let nextResponder = textField.superview?.superview?.viewWithTag(nextTag) as UIResponder?

        if nextResponder != nil {
            // Found next responder, so set it
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }

        return false
    }
}
