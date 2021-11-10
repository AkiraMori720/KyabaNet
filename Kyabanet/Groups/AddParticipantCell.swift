//
//  AddParticipantCell.swift
//  Life
//
//  Created by Yun Li on 2020/7/8.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import Foundation
import UIKit
import BEMCheckBox
class AddParticipantCell : UITableViewCell, BEMCheckBoxDelegate{
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var checkBox: BEMCheckBox!
    var index: Int!
    var callbackAddMember: ((_ index: Int, _ checked: Bool) -> ())?
    func loadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {

        if let path = MediaDownload.pathUser(person.objectId) {
            profileImageView.image = UIImage.image(path, size: 54)
            //labelInitials.text = nil
        } else {
            profileImageView.image = nil
            //labelInitials.text = person.initials()
            downloadImage(person: person, tableView: tableView, indexPath: indexPath)
        }
        profileImageView.makeRounded()

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
    
    func bindData(person: Person) {
        phoneNumber.text = person.phone
        name.text = person.fullname
        let selected : Bool = checkSelected(person: person)
        checkBox.setOn(selected, animated: false)
        
    }
    
    func checkSelected(person : Person) -> Bool{
        for item in selectedPersonsForGroup{
            if item == person{
                return true
            }
        }
        return false
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBox.delegate = self
        // Initialization code
    }
    func didTap(_ checkBox: BEMCheckBox) {
        let checked = checkBox.on
        callbackAddMember?(index, checked)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
