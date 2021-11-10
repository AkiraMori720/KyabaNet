//
//  UpdateNameViewController.swift
//  Life
//
//  Created by XianHuang on 7/10/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class UpdateNameViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblcaption: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    var name: String? = nil
    var delegate: UpdateDataDelegateProtocol? = nil
    var fromUsername: Bool = false
    var usernames = [String]()
    var usernameHandle: UInt?
    var oldusername: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.usernames.removeAll()
        self.usernameHandle = FirebaseAPI.setUsernameListener{ [self] (username) in
            if let username = username{
                for one in username{
                    if let one =  one as? String{
                        self.usernames.append(one)
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let usernameHandle = usernameHandle{
            FirebaseAPI.removeUsernameListnerObserver(usernameHandle)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    func checkUsername(_ username: String) -> Bool {
        var isvalid: Bool = true
        if self.oldusername != username{
            for one in self.usernames{
                if one == username{
                    isvalid = false
                    break
                }
            }
        }
        return isvalid
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if fromUsername{
            self.lblTitle.text = "ユーザー名を更新する"
            self.lblcaption.text = "ユーザー名"
        }else{
            self.lblTitle.text = "名前を更新"
            self.lblcaption.text = "名前"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.nameTextField.text = self.name
        nameTextField.becomeFirstResponder()
    }
    
    func setName(withName name: String) {
        self.name = name
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func onSubmitTapped(_ sender: Any) {
        if self.fromUsername{
            if nameTextField.text == ""{
                Util.showAlert(vc: self, "注意" , "ユーザーネームを先に入力してください")
                return
            }else if !self.checkUsername(nameTextField.text!.trimmingCharacters(in: .whitespaces)){
                Util.showAlert(vc: self, "注意" , "このユーザーネームは既に使用されています。違うものを入力してください。")
                return
            }
            self.dismiss(animated: true) {
                FirebaseAPI.setUsername(self.nameTextField.text!) { (isSuccess, data) in
                    
                }
                self.delegate?.updateUserName(name: self.nameTextField.text!, fromUsername: true)
            }
        }else{
            let updatedName = self.nameTextField.text
            if updatedName?.isEmpty == true {
                return
            }
            self.dismiss(animated: true) {
                self.delegate?.updateUserName(name: updatedName!, fromUsername: false)
            }
        }
    }
}
