//
//  CreateGroupTableViewCell.swift
//  Life
//
//  Created by mac on 2021/6/15.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit

class CreateGroupTableViewCell: UITableViewCell {

    var homeViewController: HomeViewController!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapCreate))
        contentView.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }
    
    @objc func actionTapCreate() {

        //print("action tap create")
        homeViewController.createGroupView()
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
