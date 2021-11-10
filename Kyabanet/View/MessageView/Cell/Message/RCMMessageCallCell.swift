//
//  RCMMessageCallCell.swift
//  Life
//
//  Created by top Dev on 17.08.2021.
//  Copyright © 2021 Zed. All rights reserved.
//


import UIKit

//-------------------------------------------------------------------------------------------------------------------------------------------------
class RCMMessageCallCell: RCMessageCell {

    private var imvCall: UIImageView!
    private var labelContent: UILabel!
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func bindData(_ messagesView: ChatViewController, at indexPath: IndexPath) {
        super.bindData(messagesView, at: indexPath)
        let rcmessage = messagesView.rcmessageAt(indexPath)
        viewBubble.backgroundColor = rcmessage.incoming ? RCDefaults.audioBubbleColorIncoming : RCDefaults.audioBubbleColorOutgoing

        if (imvCall == nil) {
            imvCall = UIImageView()
            viewBubble.addSubview(imvCall)
        }

        if (labelContent == nil) {
            labelContent = UILabel()
            labelContent.font = RCDefaults.audioFont
            labelContent.textAlignment = .right
            viewBubble.addSubview(labelContent)
        }

        if (rcmessage.callStatus == .MISSED_CALL) { imvCall.image = RCDefaults.callMissed        }
        if (rcmessage.callStatus == .CANCELLED_CALL) { imvCall.image = RCDefaults.callCancelled    }

        labelContent.textColor = rcmessage.incoming ? RCDefaults.audioTextColorIncoming : RCDefaults.audioTextColorOutgoing
        labelContent.text = rcmessage.incoming ? "Cancelled call".localized : "Missed call".localized
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func layoutSubviews() {
        let size = RCMMessageCallCell.size(messagesView, at: indexPath)
        super.layoutSubviews(size)
        let widthCall = imvCall.image?.size.width ?? 0
        let heightCall = imvCall.image?.size.height ?? 0
        let yCall = (size.height - heightCall) / 2
        imvCall.frame = CGRect(x: 10, y: 5, width: 20, height: 20)
        labelContent.frame = CGRect(x: 40, y: 5, width: 90, height: 20)
    }

    // MARK: - Size methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    class func height(_ messagesView: ChatViewController, at indexPath: IndexPath) -> CGFloat {
        let size = self.size(messagesView, at: indexPath)
        return 60
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    class func size(_ messagesView: ChatViewController, at indexPath: IndexPath) -> CGSize {
        return CGSize(width: RCDefaults.callBubbleWidht, height: RCDefaults.callBubbleHeight)
    }
}

