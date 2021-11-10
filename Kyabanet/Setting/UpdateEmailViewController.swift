//
//  UpdateEmailViewController.swift
//  Life
//
//  Created by mac on 2021/6/27.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit

class UpdateEmailViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    var name: String? = nil
    var delegate: UpdateDataDelegateProtocol? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        let updatedName = self.nameTextField.text
        if updatedName?.isEmpty == true {
            return
        }
        self.dismiss(animated: true) {
            self.delegate?.updateEmail(email: updatedName!)
        }
    }

}
