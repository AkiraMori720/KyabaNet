//
//  AccountSettingsViewController.swift
//  Life
//
//  Created by Yun Li on 2020/7/3.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import SwiftyAvatar
import JGProgressHUD
import FittedSheets
import FirebaseAuth
import FirebaseStorage
import RealmSwift
import FirebaseFirestore
import OneSignal

protocol UpdateDataDelegateProtocol {
    func updateUserName(name: String, fromUsername: Bool)
    func updatePassword(password: String)
    func deleteAccount()
    func updateEmail(email: String)
}

class AccountSettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UpdateDataDelegateProtocol {
    
    private var person: Person! 
    private var tokenPerson: NotificationToken? = nil
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    @IBOutlet weak var profileImageView: SwiftyAvatar!
    
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteRight: UIImageView!
    @IBOutlet weak var emailRight: UIImageView!
    @IBOutlet weak var phoneRight: UIImageView!
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var imgPopup: UIImageView!
    @IBOutlet weak var labelPopup: UILabel!
    var oldusername: String!
    let hud = JGProgressHUD(style: .light)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberButton.isHidden = true
        //emailButton.isHidden = true
        //emailRight.isHidden = true
        phoneRight.isHidden = true
        //deleteRight.isHidden = true
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        popUpView.isHidden = true
        if (AuthUser.userId() != "") {
            loadPerson()
        }
    }
    @IBAction func onBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func updateUserName(name: String, fromUsername: Bool) {
        if fromUsername{
            self.person.update(username: name)
        }else{
            self.person.update(fullname: name)
        }
        
        loadPerson()
        
        imgPopup.image = UIImage(named: "ic_checkmark_success")
        labelPopup.text = "名前をアップデートしました。"
        popUpView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.popUpView.isHidden = true
        }
    }
    
    func updatePassword(password: String) {
        DispatchQueue.main.async {
            self.hud.show(in: self.view, animated: true)
        }
        AuthUser.updatePassword(password: password) { (error) in
            self.hud.dismiss()
            if let _ = error {
                self.imgPopup.image = UIImage(named: "ic_pay_fail")
                self.labelPopup.text = "パスワードのアップデートに失敗しました。"
            }else{
                self.imgPopup.image = UIImage(named: "ic_checkmark_success")
                self.labelPopup.text = "パスワードをアップデートしました。"
            }
           
            
            self.popUpView.isHidden = false
            
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                self.popUpView.isHidden = true
            }
        }
    }
    
    func updateEmail(email: String) {
        DispatchQueue.main.async {
            self.hud.show(in: self.view, animated: true)
        }
        AuthUser.updateEmail(email: email){ (error) in
            self.hud.dismiss()
            if let _ = error {
                
                self.imgPopup.image = UIImage(named: "ic_pay_fail")
                self.labelPopup.text = "メールアドレスのアップデートに失敗しました。"
            }else{
                self.person.update(email: email)
                self.imgPopup.image = UIImage(named: "ic_checkmark_success")
                self.labelPopup.text = "パスワードをアップデートしました。"
            }
           
            
            self.popUpView.isHidden = false
            
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                self.popUpView.isHidden = true
            }
        }
    }
    
    func deleteAccount(){
        DispatchQueue.main.async {
            self.hud.show(in: self.view, animated: true)
        }
        AuthUser.deleteAccount { (error) in
            self.hud.dismiss()
            if let _ = error {
                self.imgPopup.image = UIImage(named: "ic_pay_fail")
                self.labelPopup.text = "アカウントを削除できません。"
            }else{
                FirebaseAPI.removeUsername()
                self.person.update(isDeleted: true)
                self.imgPopup.image = UIImage(named: "ic_checkmark_delete")
                self.labelPopup.text = "アカウントを削除しました。"
            }
            self.popUpView.isHidden = false
            
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                self.popUpView.isHidden = true
                PrefsManager.setEmail(val: "")
                self.gotoWelcomeViewController()
            }
        }
    }
    
    @IBAction func onNameChangeTapped(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "updateNameVC") as! UpdateNameViewController
        vc.setName(withName: person.fullname)
        vc.fromUsername = false
        vc.delegate = self

        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(290)])
        
        //sheetController.blurBottomSafeArea = false
        //sheetController.adjustForBottomSafeArea = false

        // Make corners more round
        //sheetController.topCornersRadius = 15
        

        // It is important to set animated to false or it behaves weird currently
        self.present(sheetController, animated: false, completion: nil)
    }
    @IBAction func onUserNameChangeTapped(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "updateNameVC") as! UpdateNameViewController
        vc.setName(withName: person.username)
        vc.fromUsername = true
        vc.oldusername = self.oldusername
        vc.delegate = self

        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(290)])
        
        //sheetController.blurBottomSafeArea = false
        //sheetController.adjustForBottomSafeArea = false

        // Make corners more round
        //sheetController.topCornersRadius = 15
        

        // It is important to set animated to false or it behaves weird currently
        self.present(sheetController, animated: false, completion: nil)
    }
    
    @IBAction func onPasswordChangeTapped(_ sender: Any) {
        self.hud.textLabel.text = ""
        self.hud.show(in: self.view, animated: true)
        PhoneAuthProvider.provider().verifyPhoneNumber(self.person.phone, uiDelegate: nil) { (verificationID, error) in
            self.hud.dismiss(afterDelay: 1.0, animated: true)
            if error != nil {
                Util.showAlert(vc: self, "承認コードの送信に失敗しました。", "")
                return
            }
            // Save Verification ID
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            let vc =  self.storyboard?.instantiateViewController(identifier: "updateOPTVC") as! UpdateOPTViewController
            vc.delegate = self
            vc.updateType = UPDATE_ACCOUNT.PASSWORD
            let sheetController = SheetViewController(controller: vc, sizes: [.fixed(300)])
            
            self.present(sheetController, animated: false, completion: nil)
        }
    }
    @IBAction func onPhoneNumberChangeTapped(_ sender: Any) {
    }
    
    @IBAction func onEmailChangeTapped(_ sender: Any) {
        self.hud.textLabel.text = ""
        self.hud.show(in: self.view, animated: true)
        PhoneAuthProvider.provider().verifyPhoneNumber(self.person.phone, uiDelegate: nil) { (verificationID, error) in
            self.hud.dismiss(afterDelay: 1.0, animated: true)
            if error != nil {
                Util.showAlert(vc: self, "承認コードの送信に失敗しました。", "")
                return
            }
            // Save Verification ID
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            let vc =  self.storyboard?.instantiateViewController(identifier: "updateOPTVC") as! UpdateOPTViewController
            vc.delegate = self
            vc.updateType = UPDATE_ACCOUNT.EMAIL
            let sheetController = SheetViewController(controller: vc, sizes: [.fixed(300)])
            self.present(sheetController, animated: false, completion: nil)
        }
    }
    
    @IBAction func onDeleteAccountTapped(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "本当にアカウントを削除しますか？", message: "", preferredStyle: .alert)

        refreshAlert.addAction(UIAlertAction(title: "はい", style: .default, handler: { (action: UIAlertAction!) in
            self.hud.textLabel.text = ""
            self.hud.show(in: self.view, animated: true)
            
            PhoneAuthProvider.provider().verifyPhoneNumber(self.person.phone, uiDelegate: nil) { (verificationID, error) in
                self.hud.dismiss(afterDelay: 1.0, animated: true)
                if error != nil {
                    Util.showAlert(vc: self, "承認コードの送信に失敗しました。", "")
                    return
                }
                // Save Verification ID
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                let vc =  self.storyboard?.instantiateViewController(identifier: "updateOPTVC") as! UpdateOPTViewController
                vc.delegate = self
                vc.updateType = UPDATE_ACCOUNT.DELETE
                let sheetController = SheetViewController(controller: vc, sizes: [.fixed(300)])
                
                self.present(sheetController, animated: false, completion: nil)
            }
            
            
            
        }))

        refreshAlert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    func gotoWelcomeViewController() {
        let mainstoryboard = UIStoryboard.init(name: "Login", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "rootNavigationViewController")
        UIApplication.shared.windows.first?.rootViewController = vc
    }
    
    func loadPerson() {
        let predicate = NSPredicate(format: "objectId == %@", AuthUser.userId())
        let persons = realm.objects(Person.self).filter(predicate)
        
        
        tokenPerson?.invalidate()
        persons.safeObserve({ changes in
            self.person = persons.first!
            self.refreshAccountInfo()
        }, completion: { token in
            self.tokenPerson = token
        })
        
    }
    
    func refreshAccountInfo(){
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.profileImageView.image = image
            }
            else {
                self.profileImageView.image = UIImage(named: "ic_default_profile")
            }
        }
        name.text = person.fullname
        username.text = person.username
        oldusername = person.username
        password.text = person.fullname
        phoneNumber.text = person.phone
        emailAddress.text = person.email
    }
    
    @IBAction func onCameraTapped(_ sender: Any) {
        
        let confirmationAlert = UIAlertController(title: "プロフィールに設定する画像を選択してください", message: "", preferredStyle: .alert)

        confirmationAlert.addAction(UIAlertAction(title: "カメラ", style: .default, handler: { (action: UIAlertAction!) in
            confirmationAlert.dismiss(animated: true, completion: nil)
            self.openCamera()
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "ギャラリー", style: .default, handler: { (action: UIAlertAction!) in
            confirmationAlert.dismiss(animated: true, completion: nil)
            self.openGallery()
        }))

        confirmationAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    func openCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func openGallery(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            // print("No image found")
            return
        }
        let data = image.jpegData(compressionQuality: 1.0)
        let correct_image = UIImage(data: data! as Data)
        DispatchQueue.main.async{
            self.profileImageView.image = correct_image
        }
        // print out the image size as a test
        // print(correct_image?.size)
        uploadPicture(image: correct_image!)
    }
    func uploadPicture(image: UIImage) {
        // print("uploadPicture")
        if let data = image.jpegData(compressionQuality: 0.6) {
            MediaUpload.user(AuthUser.userId(), data: data, completion: { error in
                if (error == nil) {
                    MediaDownload.saveUser(AuthUser.userId(), data: data)
                    self.person.update(pictureAt: Date().timestamp())
                } else {
                    DispatchQueue.main.async {
                        self.hud.textLabel.text = "写真をアップロードできませんでした"
                        self.hud.show(in: self.view, animated: true)
                    }
                    self.hud.dismiss(afterDelay: 1.0, animated: true)
                }
            })
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
}
