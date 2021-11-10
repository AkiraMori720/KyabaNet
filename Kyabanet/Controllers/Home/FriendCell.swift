//
//  FriendCell.swift
//  Life
//
//  Created by Jaelhorton on 6/26/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import SwiftyAvatar
import SwipeCellKit

class FriendCell: SwipeTableViewCell {
    
    var homeViewController: ChatViewControllerProtocol!
    var indexPath: IndexPath!
    var group: Group!
    @IBOutlet weak var profileImageView: SwiftyAvatar!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var removeFriend: UIImageView!
    var cellType = 0
    
    
    func bindData(person: Person, indexPath: IndexPath) {

        userNameLabel.text = person.fullname
        cellType = 0
        removeFriend.image = UIImage(named: "remove_friend")
        self.indexPath = indexPath
        //homeViewController.singleChatView(indexPath)
        //removeGestureRecognizer()
        //cellGestureRecognizer()
        self.removeFriend.isHidden = true
        
    }

    func bindGroupData(group: Group, indexPath: IndexPath) {

        userNameLabel.text = group.name
        cellType = 1
        removeFriend.image = UIImage(named: "config_group")
        self.indexPath = indexPath
        self.group = group
        //homeViewController.groupChatView(indexPath)
        //removeGestureRecognizer()
        //cellGestureRecognizer()
        self.removeFriend.isHidden = false
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
*/
        downloadImage(person: person, tableView: tableView, indexPath: indexPath)
    }
    func loadGroupImage(group: Group, tableView: UITableView, indexPath: IndexPath) {
    /*
            if let path = MediaDownload.pathUser(person.objectId) {
                profileImageView.image = UIImage.image(path, size: 40)
                //labelInitials.text = nil
            } else {
                profileImageView.image = nil
                //labelInitials.text = person.initials()
                downloadImage(person: person, tableView: tableView, indexPath: indexPath)
            }
    */
            downloadGroupImage(group: group, tableView: tableView, indexPath: indexPath)
        }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func downloadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {

        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            let indexSelf = tableView.indexPath(for: self)
            if ((indexSelf == nil) || (indexSelf == indexPath)) {
                if (error == nil) {
                    self.profileImageView.image = image
                    //self.labelInitials.text = nil
                } else{
                    self.profileImageView.image = UIImage(named: "ic_default_profile")
                }
            }
        }
    }
    
    func downloadGroupImage(group: Group, tableView: UITableView, indexPath: IndexPath) {

        MediaDownload.startGroup(group.objectId, pictureAt: group.pictureAt) { image, error in
            let indexSelf = tableView.indexPath(for: self)
            if ((indexSelf == nil) || (indexSelf == indexPath)) {
                if (error == nil) {
                    self.profileImageView.image = image
                    //self.labelInitials.text = nil
                } else{
                    self.profileImageView.image = UIImage(named: "ic_default_profile")
                }
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        removeGestureRecognizer()
        //cellGestureRecognizer()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    class func GetCellReuseIdentifier() -> String {
        return "friendCell"
    }
    
    class func Register(withTableView tableView:UITableView) {
        tableView.register(self.GetCellNib(), forCellReuseIdentifier: self.GetCellReuseIdentifier())
    }
    
    class func GetCellNib() -> UINib {
        let aNib = UINib.init(nibName: "FriendCell",bundle: Bundle.main);
        return aNib
    }
    
    func removeGestureRecognizer() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapRemove))
        
        removeFriend.isUserInteractionEnabled = true
        removeFriend.addGestureRecognizer(tapGesture)
        //contentView.addGestureRecognizer(tapGesture)
        //tapGesture.cancelsTouchesInView = false
    }
    func cellGestureRecognizer() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapCell))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(actionTapCell))
        userNameLabel.isUserInteractionEnabled = true
        userNameLabel.addGestureRecognizer(tapGesture1)
        
        
    }
    
    
    @objc func actionTapRemove() {
        
        if(cellType == 0){
            homeViewController.removeFriend(indexPath)
        }else if cellType == 1{
            homeViewController.groupInfo(group)
        }
    }
    
    @objc func actionTapCell() {
        if(cellType == 0){
            homeViewController.singleChatView(indexPath)
        }else if cellType == 1{
            homeViewController.groupChatView(indexPath)
        }
    }
    
    
    
}
