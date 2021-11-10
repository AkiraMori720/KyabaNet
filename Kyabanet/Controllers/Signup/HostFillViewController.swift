//
//  HostFillViewController.swift
//  Kyabanet
//
//  Created by top Dev on 07.09.2021.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import FirebaseFirestore
import FirebaseAuth
import JGProgressHUD
import RealmSwift

class HostFillViewController: UIViewController {

    @IBOutlet weak var imv_firstcheck: UIImageView!
    @IBOutlet weak var imv_secondcheck: UIImageView!
    
    @IBOutlet weak var edt_email: UITextField!
    @IBOutlet weak var edt_password: UITextField!
    @IBOutlet weak var edt_confirmpassword: UITextField!
    @IBOutlet weak var edt_fullname: UITextField!
    @IBOutlet weak var edt_birthday: UITextField!
    @IBOutlet weak var edt_address: UITextField!
    @IBOutlet weak var edt_bankname: UITextField!
    @IBOutlet weak var edt_bankbranch: UITextField!
    @IBOutlet weak var edt_bankbranch_number: UITextField!
    @IBOutlet weak var edt_bankaccount_number: UITextField!
    @IBOutlet weak var edt_bankaccount_name: UITextField!
    @IBOutlet weak var edt_bank_institution_code: UITextField!
    
    @IBOutlet weak var passwordEye: UIButton!
    @IBOutlet weak var confirmPasswordEye: UIButton!
    
    var password_eye_off = true
    var confirmPassword_eye_off = true
    var phoneNumber = ""
    var isValidPhoneNumber = false
    private var person: Person!
    let hud = JGProgressHUD(style: .light)
    var driverLicenses = [(UIImage, DriverPicType)]()
    var driverpicType: DriverPicType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*edt_email.delegate = self
        edt_password.delegate = self
        edt_confirmpassword.delegate = self
        edt_fullname.delegate = self
        edt_address.delegate = self
        edt_bankname.delegate = self
        edt_bankbranch.delegate = self
        edt_bankbranch_number.delegate = self
        edt_bankaccount_number.delegate = self
        edt_bankaccount_name.delegate = self
        edt_bank_institution_code.delegate = self*/
        self.imv_firstcheck.tintColor = .darkGray
        self.imv_secondcheck.tintColor = .darkGray
    }
    
    @IBAction func submitBtnClicked(_ sender: Any) {
        let email = self.edt_email.text ?? ""
        let username = self.edt_fullname.text ?? ""
        let dateofBirth = self.edt_birthday.text ?? ""
        let address = self.edt_address.text ?? ""
        // TODO: rare and back license image
        let password = self.edt_password.text ?? ""
        let confirmPwd = self.edt_confirmpassword.text ?? ""
        let bankName = self.edt_bankname.text ?? ""
        let bankBranch = self.edt_bankbranch.text ?? ""
        let bankBranchNumber = self.edt_bankbranch_number.text ?? ""
        let bankAccountNumber = self.edt_bankaccount_number.text ?? ""
        let bankAccountName = self.edt_bankaccount_name.text ?? ""
        let bankInstitutionCode = self.edt_bank_institution_code.text ?? ""
        
        if email.isEmpty{
            Util.showAlert(vc: self, "注意" , "メールアドレスを先に入力してください。")
            return
        }else if username.isEmpty{
            Util.showAlert(vc: self,  "エラー", "ユーザーネームを先に入力してください")
            return
        }else if dateofBirth.isEmpty{
            Util.showAlert(vc: self,  "エラー","誕生日を選択してください")
            return
        }else if address.isEmpty{
            Util.showAlert(vc: self,  "エラー", "ご住所を先に入力してください")
            return
        }else if self.driverLicenses.count != 2{
            Util.showAlert(vc: self,  "エラー","　免許証の写真をアップロードしてください（表・裏面各１枚ずつ）")
            return
        }else if password.isEmpty{
            Util.showAlert(vc: self, "注意" ,"パスワードを先に入力してください。")
            return
        }else if confirmPwd.isEmpty{
            Util.showAlert(vc: self, "注意" , "同じパスワードを入力してください")
            return
        }else if password != confirmPwd{
            Util.showAlert(vc: self,  "エラー", "パスワードは同じものを入力してください")
            return
        }else if bankName.isEmpty{
            Util.showAlert(vc: self,  "エラー", "銀行名を先に入力してください")
            return
        }else if bankBranch.isEmpty{
            Util.showAlert(vc: self,  "エラー", "支店名を先に入力してください")
            return
        }else if bankBranchNumber.isEmpty{
            Util.showAlert(vc: self,  "エラー","支店コードを先に入力してください")
            return
        }else if bankAccountNumber.isEmpty{
            Util.showAlert(vc: self,  "エラー", "口座番号を先に入力してください")
            return
        }else if bankAccountName.isEmpty{
            Util.showAlert(vc: self,  "エラー", "氏名を先に入力してください")
            return
        }else if bankInstitutionCode.isEmpty{
            Util.showAlert(vc: self, "エラー", "銀行コードを先に入力してください")
            return
        }else{
            self.createPerson()
            person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
            
            // MARK: check username repeat
            FirebaseAPI.setUsername(username) { (isSuccess, data) in
            }
            
            Firestore.firestore().collection("Person").document(person.objectId).setData(["about": person.about, "country": person.country, "createdAt": person.createdAt, "email": person.email,"username": person.username, "firstName": person.firstname, "fullName": person.fullname, "isDeleted": person.isDeleted, "keepMedia": person.keepMedia, "lastActive": person.lastActive, "lastTerminate": person.lastTerminate, "lastname": person.lastname, "location": person.location, "loginMethod": person.loginMethod, "networkAudio": person.networkAudio, "networkPhoto": person.networkPhoto, "networkVideo": person.networkVideo, "objectId": person.objectId, "oneSignalId": person.oneSignalId, "phone": person.phone, "pictureAt": person.pictureAt, "status" : person.status, "updatedAt": person.updatedAt, "wallpaper": person.wallpaper]) { err in
                if let err = err {
                    // print("Error writing document: \(err)")
                } else {
                    // print("Document successfully written")
                    if let image = self.driverLicenses.first?.0{
                        self.uploadDriverLicense(image: image, driverPickType: .front)
                    }
                    if let image = self.driverLicenses.last?.0{
                        self.uploadDriverLicense(image: image, driverPickType: .back)
                    }
                }
            }
            DispatchQueue.main.async {
                self.hud.textLabel.text = "更新..."
                self.hud.show(in: self.view, animated: true)
            }
            Auth.auth().currentUser?.updateEmail(to: email) { (error) in
                if error != nil {
                    self.hud.dismiss(afterDelay: 1.0, animated: true)
                    Util.showAlert(vc: self, error?.localizedDescription ?? "", "")
                    return
                }
                Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                    self.hud.dismiss(afterDelay: 1.0, animated: true)
                    if error != nil {
                        Util.showAlert(vc: self, error?.localizedDescription ?? "", "")
                        return
                    }
                    // Save Email
                    let realm = try! Realm()
                    try! realm.safeWrite {
                        self.person.email = email
                        self.person.oneSignalId = PrefsManager.getFCMToken()
                        self.person.userType = UserType.hostess.rawValue
                        self.person.username = username
                        self.person.birthday = dateofBirth
                        self.person.address = address
                        self.person.bankName = bankName
                        self.person.bankBranchName = bankBranch
                        self.person.bankBranchNumber = bankBranchNumber
                        self.person.bankAccountNumber = bankAccountNumber
                        self.person.bankAccountName = bankAccountName
                        self.person.bankInstituteCode = bankInstitutionCode
                        self.person.syncRequired = true
                        self.person.updatedAt = Date().timestamp()
                    }
                    // Save to the UserDefaults
                    PrefsManager.setEmail(val: email)
                    PrefsManager.setPassword(val: password)
                    PrefsManager.setUserType(val: UserType.hostess.rawValue)
                    
                    let vc =  self.storyboard?.instantiateViewController(identifier: "addPictureVC") as! AddPictureViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func createPerson() {
        let userId = AuthUser.userId()
        Persons.create(userId, phone: self.phoneNumber)
    }
    
    func uploadDriverLicense(image: UIImage, driverPickType: DriverPicType) {
        let temp = image.square(to: 300)
        if let data = temp.jpegData(compressionQuality: 0.3) {
            if driverPickType == .front{
                MediaUpload.driverLicense(AuthUser.userId() + "_front", data: data, completion: { error in
                    if (error == nil) {
                        MediaDownload.saveDriverLicense(AuthUser.userId(), data: data)
                        self.person.update(licenseFrontAt: Date().timestamp())
                    }else{
                        DispatchQueue.main.async {
                            self.hud.textLabel.text = "写真をアップロードできませんでした"
                            self.hud.show(in: self.view, animated: true)
                        }
                        self.hud.dismiss(afterDelay: 1.0, animated: true)
                    }
                })
            }else{
                MediaUpload.driverLicense(AuthUser.userId() + "_back", data: data, completion: { error in
                    if (error == nil) {
                        MediaDownload.saveDriverLicense(AuthUser.userId(), data: data)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.person.update(licenseBackAt: Date().timestamp())
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.hud.textLabel.text = "写真をアップロードできませんでした"
                            self.hud.show(in: self.view, animated: true)
                        }
                        self.hud.dismiss(afterDelay: 1.0, animated: true)
                    }
                })
            }
        }
    }
    
    @IBAction func passwordEyeTapped(_ sender: Any) {
        if password_eye_off {
            edt_password.isSecureTextEntry = false
            passwordEye.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        } else {
            edt_password.isSecureTextEntry = true
            passwordEye.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }

        password_eye_off = !password_eye_off
    }
    
    @IBAction func confirmPasswordEyeTapped(_ sender: Any) {
        if confirmPassword_eye_off {
            edt_confirmpassword.isSecureTextEntry = false
            confirmPasswordEye.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        } else {
            edt_confirmpassword.isSecureTextEntry = true
            confirmPasswordEye.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }

        confirmPassword_eye_off = !confirmPassword_eye_off
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func utcToLocal(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "MM/dd/yyyy"
        
            return dateFormatter.string(from: date)
        }
        return nil
    }

    
    @IBAction func birthdayBtnClicked(_ sender: Any) {
        let datePicker = ActionSheetDatePicker(title:"生年月日をお選びください", datePickerMode: UIDatePicker.Mode.date, selectedDate: NSDate() as Date?, doneBlock: {
                    picker, value, index in
                    
        if let datee = value as? Date{
            self.edt_birthday.text = self.utcToLocal(dateStr: "\(datee)")
        }
        return
        }, cancel: { ActionStringCancelBlock in return }, origin: (sender as AnyObject).superview!.superview)
    
        datePicker?.show()
    }
    
    @IBAction func frontuploadBtnClicked(_ sender: Any) {
        let confirmationAlert = UIAlertController(title: "運転免許証のフロントページを選択してください。", message: "", preferredStyle: .alert)

        confirmationAlert.addAction(UIAlertAction(title: "カメラ", style: .default, handler: { (action: UIAlertAction!) in
            confirmationAlert.dismiss(animated: true, completion: nil)
            self.driverpicType = .front
            self.openCamera()
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "ギャラリー", style: .default, handler: { (action: UIAlertAction!) in
            confirmationAlert.dismiss(animated: true, completion: nil)
            self.driverpicType = .front
            self.openGallery()
        }))

        confirmationAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    @IBAction func backuploadBtnClicked(_ sender: Any) {
        let confirmationAlert = UIAlertController(title: "運転免許証のバックページを選択してください。", message: "", preferredStyle: .alert)

        confirmationAlert.addAction(UIAlertAction(title: "カメラ", style: .default, handler: { (action: UIAlertAction!) in
            confirmationAlert.dismiss(animated: true, completion: nil)
            self.driverpicType = .back
            self.openCamera()
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "ギャラリー", style: .default, handler: { (action: UIAlertAction!) in
            confirmationAlert.dismiss(animated: true, completion: nil)
            self.driverpicType = .back
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
}

extension HostFillViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        if self.driverpicType == .front{
            self.driverLicenses.append((image, .front))
            self.imv_firstcheck.tintColor = .systemGreen
        }else{
            self.driverLicenses.append((image, .back))
            self.imv_secondcheck.tintColor = .systemGreen
        }
    }
}

extension HostFillViewController: UITextFieldDelegate{
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

enum DriverPicType:Int {
    case front = 0
    case back = 1
}

