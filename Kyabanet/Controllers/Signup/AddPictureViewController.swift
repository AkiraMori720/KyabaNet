//
//  AddPictureViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/29.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import JGProgressHUD
import RealmSwift
import FirebaseFirestore
import OneSignal

class AddPictureViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var avatarCovered : Bool = false
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var avata: UIImageView!
    @IBOutlet weak var publicName: UITextField!
    
    let hud = JGProgressHUD(style: .light)
    private var person: Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.isHidden = true
        
        // load Person
        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
        // Do any additional setup after loading the view.
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
        avata.image = correct_image
        cameraView.isHidden = false
        avatarCovered = true
        // print out the image size as a test
        // print(correct_image?.size)
        uploadPicture(image: correct_image!)
    }
    @IBAction func onBottomCameraTapped(_ sender: Any) {
        openCamera()
    }
    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onNextTapped(_ sender: Any) {
        /*
        if !avatarCovered{
            Util.showAlert(vc: self, "Attention" , "Please take profile photo first.")
            return
        }
 */
        
        if publicName.text == ""{
            Util.showAlert(vc: self,"エラー" , "表示名を先に入力してください。")
            return
        }
        else if avatarCovered == false{
            Util.showAlert(vc: self, "エラー" , "プロフィール画像を設定してください")
            return
        }
        
        else {
            Firestore.firestore().collection("Person").document(person.objectId).setData(["about": person.about, "country": person.country, "createdAt": person.createdAt, "email": person.email, "firstName": person.firstname, "fullName": person.fullname, "isDeleted": person.isDeleted, "keepMedia": person.keepMedia, "lastActive": person.lastActive, "lastTerminate": person.lastTerminate, "lastname": person.lastname, "location": person.location, "loginMethod": person.loginMethod, "networkAudio": person.networkAudio, "networkPhoto": person.networkPhoto, "networkVideo": person.networkVideo, "objectId": person.objectId, "oneSignalId": person.oneSignalId, "phone": person.phone, "pictureAt": person.pictureAt, "status" : person.status, "updatedAt": person.updatedAt, "wallpaper": person.wallpaper]) { err in
                if let err = err {
                    // print("Error writing document: \(err)")
                } else {
                    // print("Document successfully written")
                }
            }
        }
        
        let realm = try! Realm()
        try! realm.safeWrite {
            person.fullname    = publicName.text!
            person.syncRequired = true
            person.updatedAt = Date().timestamp()
        }
        let vc =  self.storyboard?.instantiateViewController(identifier: "successVC") as! SuccessViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func uploadPicture(image: UIImage) {
        let temp = image.square(to: 300)
        if let data = temp.jpegData(compressionQuality: 0.3) {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
