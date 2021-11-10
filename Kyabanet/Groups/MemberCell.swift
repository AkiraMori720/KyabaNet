//
//  MemberCell.swift
//  Life
//
//  Created by mac on 2021/6/16.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit

class MemberCell: UITableViewCell {

    @IBOutlet weak var imgPerson: UIImageView!
    
    @IBOutlet weak var laberPersonName: UILabel!
    
    @IBOutlet weak var labelPhone: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindData(person: Person) {
        laberPersonName.text = person.fullname
        labelPhone.text = person.phone
        
    }

    func loadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {

        downloadImage(person: person, tableView: tableView, indexPath: indexPath)
    }
    
    func downloadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {

        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            let indexSelf = tableView.indexPath(for: self)
            if ((indexSelf == nil) || (indexSelf == indexPath)) {
                if (error == nil) {
                    self.imgPerson.image = image
                    
                    //self.labelInitials.text = nil
                } else{
                    self.imgPerson.image = UIImage(named: "ic_default_profile")
                }
                self.imgPerson.makeRounded()
            }
        }
    }
    
    
}
