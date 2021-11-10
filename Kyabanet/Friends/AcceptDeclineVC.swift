//
//  AcceptDeclineVC.swift
//  Life
//
//  Created by Good Developer on 7/28/21.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit

class AcceptDeclineViewController: UIViewController {

    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhoneNum: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    var userId = ""
    var invitor = Person()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    fileprivate func initUI() {
        let predicate = NSPredicate(format: "objectId != %@", userId)
        let persons = realm.objects(Person.self).filter(predicate)
        invitor = persons[0]
        
        loadProfileImage()
        lblName.text = invitor.fullname
        lblPhoneNum.text = invitor.phone
        lblMessage.text = "You received a message request from" + " " + invitor.fullname + ". Do you want to accept the add request?"
    }
    
    @IBAction func onAcceptTapped(_ sender: Any) {
        Friends.update(invitor.objectId, isAccepted: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDeclineTapped(_ sender: Any) {
        Friends.update(invitor.objectId, isAccepted: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func loadProfileImage() {
        MediaDownload.startUser(invitor.objectId, pictureAt: invitor.pictureAt) { image, error in
            if (error == nil) {
                self.imvProfile.image = image
            } else {
                self.imvProfile.image = UIImage(named: "ic_default_profile")
            }
        }
    }
}
