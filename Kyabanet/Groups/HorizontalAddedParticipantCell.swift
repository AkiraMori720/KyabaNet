//
//  HorizontalAddedParticipantCell.swift
//  Life
//
//  Created by Yun Li on 2020/7/9.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import Foundation
import UIKit
import SwiftyAvatar
class HorizontalAddedParticipantCell : UICollectionViewCell{
    
    @IBOutlet weak var profileImageView: SwiftyAvatar!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var roundRemove: RoundedCornerBorderView!
    var index: Int!
    var callbackCancelTapped: ((_ index: Int) -> ())?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        roundRemove.isHidden = true
    }
    
    func loadImage(person: Person, collectionView: UICollectionView, indexPath: IndexPath) {

        if let path = MediaDownload.pathUser(person.objectId) {
            profileImageView.image = UIImage.image(path, size: 40)
            //labelInitials.text = nil
        } else {
            profileImageView.image = nil
            //labelInitials.text = person.initials()
            downloadImage(person: person, collectionView: collectionView, indexPath: indexPath)
        }
        profileImageView.makeRounded()
    }
    
    func downloadImage(person: Person, collectionView: UICollectionView, indexPath: IndexPath) {

        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            let indexSelf = collectionView.indexPath(for: self)
            if ((indexSelf == nil) || (indexSelf == indexPath)) {
                if (error == nil) {
                    self.profileImageView.image = image?.square(to: 60)
                    //self.labelInitials.text = nil
                } else if (error  != nil) {
                    self.profileImageView.image = UIImage(named: "ic_default_profile")
                }
            }
        }
    }
    
    func bindData(person: Person) {
        name.text = person.fullname
        
    }
    @IBAction func onCancelTapped(_ sender: Any) {
        callbackCancelTapped?(index)
    }
    
}
