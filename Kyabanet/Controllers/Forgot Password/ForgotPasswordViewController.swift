//
//  ForgotPasswordViewController.swift
//  Life
//
//  Created by Lukas Bimba on 9/18/20.
//  Copyright © 2020 Zed. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorText: UILabel!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendPasswordReset(_ sender: Any) {
        if self.emailTextField.text == "" {
            let alertController = UIAlertController(title: "エラー", message: "メールアドレスを入力してください。", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
           
            
            Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!, completion: { (error) in
                
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Error!".localized
                    message = "メールアドレスが見つかりません。他のアドレスを入力してください。"
                } else {
                    title = "完了！"
                    message = "パスワードリセットのメールを送信しました。"
                    self.emailTextField.text = ""
                }
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            })
        }
    }
    

    // Hide Keyboard when User Touches Outside of Keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Hide Keybaord when User Taps Return Key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        return(true)
    }

    
}
