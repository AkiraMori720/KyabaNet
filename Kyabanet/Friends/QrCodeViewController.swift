//
//  QrCodeViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/26.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import FittedSheets
class QrCodeViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    @IBOutlet weak var preView: QRCodeReaderView!{
      didSet {
        preView.setupComponents(with: QRCodeReaderViewControllerBuilder {
          $0.reader                 = qrReader
          $0.showTorchButton        = false
          $0.showSwitchCameraButton = false
          $0.showCancelButton       = false
          $0.showOverlayView        = true
          $0.rectOfInterest         = CGRect(x: 0.15, y: 0.2, width: 0.7, height: 0.4)
        })
      }
    }
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()

        dismiss(animated: true) { [weak self] in
          let alert = UIAlertController(
            title: "QRコードをスキャン",
            message: String (format:"%@ (of type %@)", result.value, result.metadataType),
            preferredStyle: .alert
          )
          alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

          self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()

        dismiss(animated: true, completion: nil)
    }
    
    lazy var qrReader: QRCodeReader = QRCodeReader()
    /*lazy var readerVC: QRCodeReaderViewController = {
      let builder = QRCodeReaderViewControllerBuilder {
        $0.reader                  = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        $0.showTorchButton         = true
        $0.preferredStatusBarStyle = .lightContent
        $0.showOverlayView         = true
        $0.rectOfInterest          = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        $0.reader.stopScanningWhenCodeIsFound = true
      }
      
      return QRCodeReaderViewController(builder: builder)
    }()*/
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        startReader()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //print("Scan disappear")
        super.viewDidDisappear(animated)
        qrReader.stopScanning()
    }
    func startReader(){
        guard checkScanPermissions(), !qrReader.isRunning else { return }
        
        qrReader.didFindCode = { result in
            print("detected")
            let qrcodeValue = result.value.components(separatedBy: "timestamp")
            let qrCode = qrcodeValue[0]
            let person = realm.object(ofType: Person.self, forPrimaryKey: qrCode)
            if let person = person{
                let vc =  self.storyboard?.instantiateViewController(identifier: "addFriendBottomSheetVC") as! AddFriendBottomSheetViewController
                vc.person = person
                vc.qrView = self
                let sheetController = SheetViewController(controller: vc, sizes: [.fixed(376)])
                self.present(sheetController, animated: false, completion: nil)
            }else{
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "エラー", message: "QRコードです", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
                        self.qrReader.startScanning()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
        qrReader.startScanning()
    }
    
    private func checkScanPermissions() -> Bool {
      do {
        return try QRCodeReader.supportsMetadataObjectTypes()
      } catch let error as NSError {
        let alert: UIAlertController

        switch error.code {
        case -11852:
            alert = UIAlertController(title: "エラー", message: "このアプリではバックカメラはご利用いただけません。", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "設定", style: .default, handler: { (_) in
            DispatchQueue.main.async {
              if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(settingsURL)
              }
            }
          }))

            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        default:
            alert = UIAlertController(title: "エラー", message: "このデバイスでは読み取れません。", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }

        present(alert, animated: true, completion: nil)

        return false
      }
    }
    @IBAction func onBackTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onMyQrTapped(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "myQrVC") as! MyQrGenerateViewController

        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(460)])
        
        self.present(sheetController, animated: false, completion: nil)
    }
    
}
