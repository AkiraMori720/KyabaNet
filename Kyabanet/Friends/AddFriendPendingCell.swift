//
//  AddFriendPendingCell.swift
//  Life
//
//  Created by mac on 2021/6/7.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import SwiftyAvatar
class AddFriendPendingCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profileImageView: SwiftyAvatar!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func downloadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {

        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            let indexSelf = tableView.indexPath(for: self)
            if ((indexSelf == nil) || (indexSelf == indexPath)) {
                if (error == nil) {
                    self.profileImageView.image = image?.square(to: 40)
                    //self.labelInitials.text = nil
                } else if (error  != nil) {
                    self.profileImageView.image = UIImage(named: "ic_default_profile")
                }
            }
        }
    }
    
    func loadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {

        if let path = MediaDownload.pathUser(person.objectId) {
            profileImageView.image = UIImage.image(path, size: 40)
            //labelInitials.text = nil
        } else {
            profileImageView.image = nil
            //labelInitials.text = person.initials()
            downloadImage(person: person, tableView: tableView, indexPath: indexPath)
        }
        profileImageView.makeRounded()

    }
    
    func bindData(person: Person) {

        name.text = person.fullname
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
