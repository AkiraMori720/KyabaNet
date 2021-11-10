//
//  MessageTextCell.swift
//  Life
//
//  Created by top Dev on 30.08.2021.
//  Copyright © 2021 Zed. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MessageTextCell: UITableViewCell {
    @IBOutlet weak var uivContent: UIView!
    @IBOutlet weak var uivYou: UIView!
    @IBOutlet weak var uivMe: UIView!
    
    @IBOutlet weak var imvPartner: UIImageView!
    @IBOutlet weak var imvMe: UIImageView!
    
    @IBOutlet weak var uivYouTxt: UIView!
    @IBOutlet weak var uivMeTxt: UIView!
    
    @IBOutlet weak var lblYouTxt: UILabel!
    @IBOutlet weak var lblMeTxt: UILabel!
    
    @IBOutlet weak var lblYouTime: UILabel!
    @IBOutlet weak var lblMeTime: UILabel!
    
    @IBOutlet weak var imvMeTick: UIImageView!
    
    @IBOutlet weak var uivYouStatus: UIView!
    @IBOutlet weak var uivMeStatus: UIView!
    
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
        
        if  messagesView.searchBar.text != nil  {
            searchString = messagesView.searchBar.text!
        }
        let baseString = rcmessage.text

        let attributed = NSMutableAttributedString(string: baseString)
        if(searchString == ""){
            lblMeTxt.text = rcmessage.text
            lblYouTxt.text = rcmessage.text
            return
        }
        
        do{
            let regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            attributed.addAttribute(.font, value: RCDefaults.textFont, range:NSRange(location: 0, length: baseString.utf16.count))
            attributed.addAttribute(.backgroundColor, value: rcmessage.incoming ? uivYou.backgroundColor : uivMe.backgroundColor as Any, range:NSRange(location: 0, length: baseString.utf16.count))
            for match in regex.matches(in: baseString, options: [], range: NSRange(location: 0, length: baseString.utf16.count)) as [NSTextCheckingResult] {
                attributed.addAttribute(.backgroundColor, value: UIColor.yellow, range: match.range)
                attributed.addAttribute(.foregroundColor, value: UIColor.black, range: match.range)
            }

            lblMeTxt.attributedText = attributed
            lblYouTxt.attributedText = attributed
        }catch {
            lblMeTxt.text = rcmessage.text
            lblYouTxt.text = rcmessage.text
            return
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
