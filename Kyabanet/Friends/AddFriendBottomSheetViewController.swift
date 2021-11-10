//
//  AddFriendBottomSheetViewController.swift
//  Life
//
//  Created by Yun Li on 2020/7/2.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import SwiftyAvatar
import JGProgressHUD
class AddFriendBottomSheetViewController: UIViewController {

    var isFriend : Bool = false
    var person: Person!
    var qrCode : String!
    var qrView : QrCodeViewController!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var profile: SwiftyAvatar!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var addFriendButton: RoundButton!
    
    let hud = JGProgressHUD(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        name.text = person.fullname
        
        phoneNumber.text = person.phone
    
        if(person.objectId == AuthUser.userId() || Friends.isFriend(person.objectId)){
            addFriendButton.isHidden = true
            self.statusLabel.text = "既に友達に登録済みです"
            checkMark.isHidden = false
        }else{
            checkMark.isHidden = true
            addFriendButton.isHidden = false
        }
        
            
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.profile.image = image
            }
            else {
                self.profile.image = UIImage(named: "ic_default_profile")
            }
            self.view.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        
        
    }
    @IBAction func onCancelTapped(_ sender: Any) {
        dismiss(animated: true, completion:  nil)
    }
    
    @IBAction func onAddFriendTapped(_ sender: Any) {
        
        Friends.create(person.objectId)
        self.statusLabel.text = "友達に追加されました。"
        isFriend = true
        addFriendButton.backgroundColor = UIColor(hexString: "#00406E")
        addFriendButton.setTitleColor(UIColor.white, for: .normal)
        checkMark.isHidden = false
        
        self.hud.show(in: self.view, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.hud.dismiss(animated: true)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        qrView.qrReader.startScanning()
    }
    

}
