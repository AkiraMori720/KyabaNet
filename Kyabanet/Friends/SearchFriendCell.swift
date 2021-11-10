//
//  SearchFriendCell.swift
//  Life
//
//  Created by Yun Li on 2020/6/27.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import Foundation
import UIKit
import SwiftyAvatar

class SearchFriendCell : UITableViewCell{
    
    @IBOutlet weak var profileImageView: SwiftyAvatar!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var AddButton: UIView!
    var index: Int!
    var callbackAddFriend: ((_ index: Int) -> ())?
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func bindData(person: Person) {

        userNameLabel.text = person.fullname
        phoneNumberLabel.text = person.phone
        
        if(Friends.isFriend(person.objectId)){
            AddButton.isHidden = true
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {
/*
        if let path = MediaDownload.pathUser(person.objectId) {
            profileImageView.image = UIImage.image(path, size: 40)
            //labelInitials.text = nil
        } else {
            profileImageView.image = nil
            //labelInitials.text = person.initials()
            downloadImage(person: person, tableView: tableView, indexPath: indexPath)
        }
        //profileImageView.makeRounded()
*/
        downloadImage(person: person, tableView: tableView, indexPath: indexPath)
        
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func downloadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {

        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            let indexSelf = tableView.indexPath(for: self)
            if ((indexSelf == nil) || (indexSelf == indexPath)) {
                if (error == nil) {
                    self.profileImageView.image = image
                    //self.labelInitials.text = nil
                } else if (error  != nil) {
                    self.profileImageView.image = UIImage(named: "ic_default_profile")
                }
            }
        }
    }
    @IBAction func addFriendTapped(_ sender: Any) {
        callbackAddFriend?(index)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}


