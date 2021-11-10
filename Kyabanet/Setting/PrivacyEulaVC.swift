//
//  PrivacyEulaVC.swift
//  Life
//
//  Created by Good Developer on 7/26/21.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import PDFKit

class PrivacyEulaVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var uivPdfContainer: UIView!
    
    var privacy = true // false: eula
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func initUI() {
        if privacy {
            lblTitle.text = "プライバシーポリシー"
            
            let pdfView = PDFView(frame: self.uivPdfContainer.bounds)
            pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.uivPdfContainer.addSubview(pdfView)
            
            pdfView.autoScales = true
            
            let fileURL = Bundle.main.url(forResource: "Privacy", withExtension: "pdf")
            pdfView.document = PDFDocument(url: fileURL!)
        } else {
            lblTitle.text = "利用規約"
            
            let pdfView = PDFView(frame: self.uivPdfContainer.bounds)
            pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.uivPdfContainer.addSubview(pdfView)
            
            pdfView.autoScales = true
            
            let fileURL = Bundle.main.url(forResource: "EULA", withExtension: "pdf")
            pdfView.document = PDFDocument(url: fileURL!)
        }
    }
}
