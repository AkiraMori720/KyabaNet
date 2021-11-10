//
//  SelectUserViewController.swift
//  Kyabanet
//
//  Created by top Dev on 07.09.2021.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit

class SelectUserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func hostBtnClicked(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "signupViewController") as! SignupViewController
        vc.userType = .hostess
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func userBtnClicked(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "signupViewController") as! SignupViewController
        vc.userType = .generalUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
