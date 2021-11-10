//
//  MessageVideoCell.swift
//  Life
//
//  Created by top Dev on 30.08.2021.
//  Copyright © 2021 Zed. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MessageVideoCell: UITableViewCell {
    @IBOutlet weak var uivContent: UIView!
    @IBOutlet weak var uivYou: UIView!
    @IBOutlet weak var uivMe: UIView!
    
    @IBOutlet weak var imvPartner: UIImageView!
    @IBOutlet weak var imvMe: UIImageView!
    
    @IBOutlet weak var uivYouTxt: UIView!
    @IBOutlet weak var uivMeTxt: UIView!
    
    @IBOutlet weak var lblYouTime: UILabel!
    @IBOutlet weak var lblMeTime: UILabel!
    
    @IBOutlet weak var imvMeTick: UIImageView!
    
    @IBOutlet weak var uivYouStatus: UIView!
    @IBOutlet weak var uivMeStatus: UIView!
    
    @IBOutlet weak var imageViewMeThumb: UIImageView!
    @IBOutlet weak var imageViewYouThumb: UIImageView!
    
    var indexPath: IndexPath!
    var messagesView: ChatViewController!
    var type = 0
    var searchString = ""
    
    func bindData(_ messagesView: ChatViewController, at indexPath: IndexPath) {

        self.indexPath = indexPath
        self.messagesView = messagesView
        let rcmessage = messagesView.rcmessageAt(indexPath)
        uivMe.isHidden = rcmessage.incoming
        uivYou.isHidden = !rcmessage.incoming
        
        uivYouStatus.layer.cornerRadius = 6
        uivYouStatus.layer.borderWidth = 2
        uivYouStatus.layer.borderColor = UIColor.white.cgColor
        
        uivMeStatus.layer.cornerRadius = 6
        uivMeStatus.layer.borderWidth = 2
        uivMeStatus.layer.borderColor = UIColor.white.cgColor
        
        
        imageViewMeThumb.layer.cornerRadius = 80
        imageViewMeThumb.layer.borderWidth = 1
        imageViewMeThumb.layer.borderColor = COLORS.PRIMARY?.cgColor
        
        imageViewYouThumb.layer.cornerRadius = 80
        imageViewYouThumb.layer.borderWidth = 1
        imageViewYouThumb.layer.borderColor = COLORS.PRIMARY?.cgColor
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionContentView))
        uivContent.addGestureRecognizer(tapGesture)
        
        let bubbleGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapBubble))
        rcmessage.incoming ? uivYouTxt.addGestureRecognizer(bubbleGesture) : uivMeTxt.addGestureRecognizer(bubbleGesture)
        bubbleGesture.cancelsTouchesInView = false

        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(actionLongBubble(_:)))
        rcmessage.incoming ? uivYouTxt.addGestureRecognizer(longGesture) : uivMeTxt.addGestureRecognizer(longGesture)
        
        imvMe.image = messagesView.avatarImage(indexPath)
        imvPartner.image = messagesView.avatarImage(indexPath)

        if let image = messagesView.textFooterLower(indexPath){
            imvMeTick.isHidden = false
            imvMeTick.image = image
        }else{
            imvMeTick.isHidden = true
            imvMeTick.image = nil
        }
        
        
        lblYouTime.textAlignment = rcmessage.incoming ? .left : .right
        lblMeTime.textAlignment = rcmessage.incoming ? .right : .left
        lblYouTime.text = messagesView.textHeaderLower(indexPath)
        lblMeTime.text = messagesView.textHeaderLower(indexPath)
        
        if rcmessage.incoming{
            if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_UNKNOWN) {
                imageViewYouThumb.image = nil
            }

            if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_LOADING) {
                imageViewYouThumb.image = nil
            }

            if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_SUCCEED) {
                imageViewYouThumb.image = rcmessage.videoThumbnail
            }

            if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_MANUAL) {
                imageViewYouThumb.image = nil
            }
        }else{
            if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_UNKNOWN) {
                imageViewMeThumb.image = nil
            }

            if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_LOADING) {
                imageViewMeThumb.image = nil
            }

            if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_SUCCEED) {
                imageViewMeThumb.image = rcmessage.videoThumbnail
            }

            if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_MANUAL) {
                imageViewMeThumb.image = nil
            }
        }
    }

    // MARK: - User actions
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionTapBubble() {
        messagesView.dismissKeyboard()
        messagesView.actionTapBubble(indexPath)
    }
    
    @objc func actionContentView() {
        messagesView.dismissKeyboard()
        //messagesView.actionTapBubble(indexPath)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionTapAvatar() {
        messagesView.dismissKeyboard()
        messagesView.actionTapAvatar(indexPath)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionLongBubble(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
            case .began:
                actionMenu()
                break
            case .changed:
                break
            case .ended:
                break
            case .possible:
                break
            case .cancelled:
                break
            case .failed:
                break
            default:
                break
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionMenu() {
        if (messagesView.messageInputBar.inputTextView.isFirstResponder == false) {
            let menuController = UIMenuController.shared
            menuController.menuItems = messagesView.menuItems(indexPath)
            menuController.showMenu(from: contentView, rect: uivMeTxt.frame)
        } else {
            messagesView.messageInputBar.inputTextView.resignFirstResponder()
        }
    }
}

