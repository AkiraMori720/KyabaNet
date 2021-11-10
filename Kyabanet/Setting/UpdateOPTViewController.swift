//
//  DeleteOPTViewController.swift
//  Life
//
//  Created by mac on 2021/6/16.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import DPOTPView
import FirebaseAuth
import JGProgressHUD
import FittedSheets
class UpdateOPTViewController: UIViewController {

    @IBOutlet weak var optView: DPOTPView!
    var delegate: UpdateDataDelegateProtocol? = nil
    
    var updateType = UPDATE_ACCOUNT.UNKNOWN
    let hud = JGProgressHUD(style: .light)
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
        optView.becomeFirstResponder()
    }

    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func onSubmitTapped(_ sender: Any) {
        optView.resignFirstResponder()
        let verificationCode = optView.text ?? "123456"
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
            self.hud.dismiss()
            if let _ = error {
                
                Util.showAlert(vc: self, "認証コードが間違っています。もう一度入力してください。" , "")
                return
            }
            
            weak var pvc = self.presentingViewController
            self.dismiss(animated: true) {
                if(self.updateType == UPDATE_ACCOUNT.DELETE){
                    self.delegate?.deleteAccount()
                }else if(self.updateType == UPDATE_ACCOUNT.PASSWORD){
                    let vc =  self.storyboard?.instantiateViewController(identifier: "updatePasswordVC") as! UpdatePasswordViewController
                    vc.delegate = self.delegate
                    
                    let sheetController = SheetViewController(controller: vc, sizes: [.fixed(350)])
                    pvc?.present(sheetController, animated: false, completion: nil)
                }else if(self.updateType == UPDATE_ACCOUNT.EMAIL){
                    let vc =  self.storyboard?.instantiateViewController(identifier: "updateEmailVC") as! UpdateEmailViewController
                    vc.delegate = self.delegate
                    
                    let sheetController = SheetViewController(controller: vc, sizes: [.fixed(350)])
                    pvc?.present(sheetController, animated: false, completion: nil)
                }
            }
            

        }

    }

}
