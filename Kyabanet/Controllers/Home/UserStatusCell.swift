//
//  UserStatusCell.swift
//  Life
//
//  Created by Jaelhorton on 7/8/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import SwiftyAvatar

class UserStatusCell: UITableViewCell {

    @IBOutlet weak var profileImageView: SwiftyAvatar!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var aboutUserLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadPerson(withPerson person: Person) {
        //labelInitials.text = person.initials()
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.profileImageView.image = image
                //self.profileImageView.makeRounded()
            }
            else {
                self.profileImageView.image = UIImage(named: "ic_default_profile")
            }
        }
        userNameLabel.text = person.fullname
        aboutUserLabel.text = person.about
    }
    
    class func GetCellReuseIdentifier() -> String {
        return "userStatusCell"
    }
    
    class func Register(withTableView tableView:UITableView) {
        tableView.register(self.GetCellNib(), forCellReuseIdentifier: self.GetCellReuseIdentifier())
    }
    
    class func GetCellNib() -> UINib {
        let aNib = UINib.init(nibName: "UserStatusCell",bundle: Bundle.main);
        return aNib
    }
}
