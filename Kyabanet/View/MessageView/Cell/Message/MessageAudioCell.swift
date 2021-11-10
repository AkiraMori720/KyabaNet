//
//  MessageAudioCell.swift
//  Life
//
//  Created by top Dev on 30.08.2021.
//  Copyright © 2021 Zed. All rights reserved.
//


import Foundation
import UIKit
import SwiftUI

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MessageAudioCell: UITableViewCell {
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
    
    @IBOutlet weak var imvMePlay: UIImageView!
    @IBOutlet weak var imvYouPlay: UIImageView!
    
    @IBOutlet weak var viewMeProgress: UIProgressView!
    @IBOutlet weak var viewYouProgress: UIProgressView!
    @IBOutlet weak var labelMeDuration: UILabel!
    @IBOutlet weak var labelYouDuration: UILabel!
    var indexPath: IndexPath!
    var messagesView: ChatViewController!
    var type = 0
    var searchString = ""
    
    func roundCorners4me(cornerRadius: Double) {
        self.uivMeTxt.layer.cornerRadius = CGFloat(cornerRadius)
        self.uivMeTxt.clipsToBounds = true
        self.uivMeTxt.layer.borderWidth = 1
        self.uivMeTxt.layer.borderColor = COLORS.MSG_OUTGOING?.cgColor
        if #available(iOS 11.0, *) {
            self.uivMeTxt.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    func roundCorners4you(cornerRadius: Double) {
        self.uivYouTxt.layer.cornerRadius = CGFloat(cornerRadius)
        self.uivYouTxt.clipsToBounds = true
        self.uivYouTxt.layer.borderWidth = 1
        self.uivYouTxt.layer.borderColor = COLORS.MSG_INCOMING_BORDER?.cgColor
        if #available(iOS 11.0, *) {
            self.uivYouTxt.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    func bindData(_ messagesView: ChatViewController, at indexPath: IndexPath) {

        self.indexPath = indexPath
        self.messagesView = messagesView
        let rcmessage = messagesView.rcmessageAt(indexPath)
        uivMe.isHidden = rcmessage.incoming
        uivYou.isHidden = !rcmessage.incoming
        roundCorners4me(cornerRadius: 12)
        roundCorners4you(cornerRadius: 12)
        
        uivYouStatus.layer.cornerRadius = 6
        uivYouStatus.layer.borderWidth = 2
        uivYouStatus.layer.borderColor = UIColor.white.cgColor
        
        uivMeStatus.layer.cornerRadius = 6
        uivMeStatus.layer.borderWidth = 2
        uivMeStatus.layer.borderColor = UIColor.white.cgColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionContentView))
        uivContent.addGestureRecognizer(tapGesture)
        
        let bubbleGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapBubble))
        rcmessage.incoming ? uivYouTxt.addGestureRecognizer(bubbleGesture) : uivMeTxt.addGestureRecognizer(bubbleGesture)
        bubbleGesture.cancelsTouchesInView = false

        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(actionLongBubble(_:)))
        rcmessage.incoming ? uivYouTxt.addGestureRecognizer(longGesture) : uivMeTxt.addGestureRecognizer(longGesture)
        
        imvMe.image = messagesView.avatarImage(indexPath)
        imvPartner.image = messagesView.avatarImage(indexPath)

        let avatartapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapAvatar))
        rcmessage.incoming ? imvPartner.addGestureRecognizer(avatartapGesture) : imvMe.addGestureRecognizer(avatartapGesture)
        avatartapGesture.cancelsTouchesInView = false
        
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
            if (rcmessage.audioStatus == AudioStatus.AUDIOSTATUS_STOPPED)    {
                imvYouPlay.image = RCDefaults.audioImagePlay
            }
            if (rcmessage.audioStatus == AudioStatus.AUDIOSTATUS_PLAYING)    { imvYouPlay.image = RCDefaults.audioImagePause    }
            if (rcmessage.audioStatus == AudioStatus.AUDIOSTATUS_PAUSED)    { imvYouPlay.image = RCDefaults.audioImagePlay     }
        }else{
            if (rcmessage.audioStatus == AudioStatus.AUDIOSTATUS_STOPPED)    {
                imvMePlay.image = RCDefaults.audioImagePlay
            }
            if (rcmessage.audioStatus == AudioStatus.AUDIOSTATUS_PLAYING)    { imvMePlay.image = RCDefaults.audioImagePause    }
            if (rcmessage.audioStatus == AudioStatus.AUDIOSTATUS_PAUSED)    { imvMePlay.image = RCDefaults.audioImagePlay     }
        }
        updateProgress(rcmessage)
        updateDuration(rcmessage)
        
        if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_UNKNOWN) {
            if rcmessage.incoming{
                imvYouPlay.isHidden = true
                viewYouProgress.isHidden = true
                labelYouDuration.isHidden = true
            }else{
                imvMePlay.isHidden = true
                viewMeProgress.isHidden = true
                labelMeDuration.isHidden = true
            }
        }

        if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_LOADING) {
            if rcmessage.incoming{
                imvYouPlay.isHidden = true
                viewYouProgress.isHidden = true
                labelYouDuration.isHidden = true
            }else{
                imvMePlay.isHidden = true
                viewMeProgress.isHidden = true
                labelMeDuration.isHidden = true
            }
        }

        if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_SUCCEED) {
            if rcmessage.incoming{
                imvYouPlay.isHidden = false
                viewYouProgress.isHidden = false
                labelYouDuration.isHidden = false
            }else{
                imvMePlay.isHidden = false
                viewMeProgress.isHidden = false
                labelMeDuration.isHidden = false
            }
        }

        if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_MANUAL) {
            if rcmessage.incoming{
                imvYouPlay.isHidden = true
                viewYouProgress.isHidden = true
                labelYouDuration.isHidden = true
            }else{
                imvMePlay.isHidden = true
                viewMeProgress.isHidden = true
                labelMeDuration.isHidden = true
            }
        }
    }
    
    func updateProgress(_ rcmessage: RCMessage) {

        let progress = Float(rcmessage.audioCurrent) / Float(rcmessage.audioDuration)
        rcmessage.incoming ? (viewYouProgress.progress = (progress > 0.05) ? progress : 0) : (viewMeProgress.progress = (progress > 0.05) ? progress : 0)
        
    }
    
    func updateDuration(_ rcmessage: RCMessage) {

        if (rcmessage.audioStatus == AudioStatus.AUDIOSTATUS_STOPPED)    { updateDuration(rcmessage.audioDuration, rcmessage: rcmessage)}
        if (rcmessage.audioStatus == AudioStatus.AUDIOSTATUS_PLAYING)    { updateDuration(Int(rcmessage.audioDuration), rcmessage: rcmessage)    }
        if (rcmessage.audioStatus == AudioStatus.AUDIOSTATUS_PAUSED)    { updateDuration(Int(rcmessage.audioCurrent), rcmessage: rcmessage)    }
    }
    
    private func updateDuration(_ duration: Int, rcmessage: RCMessage ) {
        if rcmessage.incoming{
            if (duration < 60) {
                labelYouDuration.text = String(format: "0:%02ld", duration)
            } else {
                labelYouDuration.text = String(format: "%ld:%02ld", duration / 60, duration % 60)
            }
        }else{
            if (duration < 60) {
                labelMeDuration.text = String(format: "0:%02ld", duration)
            } else {
                labelMeDuration.text = String(format: "%ld:%02ld", duration / 60, duration % 60)
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
