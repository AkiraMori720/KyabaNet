//
//  PayMyQrGenerateViewController.swift
//  Life
//
//  Created by mac on 2021/6/20.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit

class PayMyQrGenerateViewController: UIViewController {
    
    private var person: Person!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = generateQRCode(from: AuthUser.userId())
        myQrcode.image = image
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        
        if (AuthUser.userId() != "") {
            loadPerson()
        }
    }
    
    @IBOutlet weak var myQrcode: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBAction func onCancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func generateQRCode(from string: String) -> UIImage? {
        let timestamp = String(NSDate().timeIntervalSince1970)
        let original = string + ":pay:" + timestamp
        let data = original.data(using: String.Encoding.ascii)
        

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    func loadPerson() {
        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
        if let person = person{
            name.text = person.fullname
            phoneNumber.text = person.phone
        }
    }
    @IBAction func onRefreshTapped(_ sender: Any) {
        myQrcode.image = generateQRCode(from: AuthUser.userId())
    }
    @IBAction func onDownloadTapped(_ sender: Any) {
        let size = CGSize(width: myQrcode.frame.size.width, height: myQrcode.frame.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        myQrcode.image?.draw(in: CGRect(origin: .zero, size: size))
        if let qrcodeImage = UIGraphicsGetImageFromCurrentImageContext() {
            //let imageData = qrcodeImage.jpegData(compressionQuality: 1)
            UIImageWriteToSavedPhotosAlbum(qrcodeImage, self, #selector(saveError), nil)
        }
        
        
    }
    //MARK: - Add image to Library
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showAlertWith(title: "保存できませんでした", message: error.localizedDescription)
        } else {
            showAlertWith(title: "保存しました", message: "写真フォルダに保存されました")
        }
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @IBAction func actionTapShare(_ sender: Any) {
        guard let shareImage = myQrcode.image else{
            return
        }
        let activityController = UIActivityViewController(activityItems: [shareImage], applicationActivities: nil)
        present(activityController, animated: true)
    }
}
