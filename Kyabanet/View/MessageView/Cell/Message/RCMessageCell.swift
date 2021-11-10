//
// Copyright (c) 2020 Related Code 
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

//-------------------------------------------------------------------------------------------------------------------------------------------------
class RCMessageCell: UITableViewCell {

	var indexPath: IndexPath!
	var messagesView: ChatViewController!

	var viewBubble: UIView!
    private var objectionableMark: UIImageView!
	private var imageAvatar: UIImageView!
	private var labelAvatar: UILabel!
    private var labelText: UILabel!
    private var statusImageView: UIImageView!
    private var labelName: UILabel!
    var labelHeight: CGFloat = 0
    var nameHeight: CGFloat = 0
    private var labelTimeText: UILabel!
    var type = 0
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(_ messagesView: ChatViewController, at indexPath: IndexPath) {

		self.indexPath = indexPath
		self.messagesView = messagesView
        let rcmessage = messagesView.rcmessageAt(indexPath)
        backgroundColor = UIColor.clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionContentView))
        contentView.addGestureRecognizer(tapGesture)
        
        
		if (viewBubble == nil) {
			viewBubble = UIView()
            viewBubble.backgroundColor = rcmessage.incoming ? RCDefaults.textBubbleColorIncoming : RCDefaults.textBubbleColorOutgoing
			//viewBubble.layer.cornerRadius = RCDefaults.bubbleRadius
			contentView.addSubview(viewBubble)
			bubbleGestureRecognizer()
		}

		if (imageAvatar == nil) {
			imageAvatar = UIImageView()
			imageAvatar.layer.masksToBounds = true
			imageAvatar.layer.cornerRadius = RCDefaults.avatarDiameter / 2
			imageAvatar.backgroundColor = RCDefaults.avatarBackColor
			imageAvatar.isUserInteractionEnabled = true
			contentView.addSubview(imageAvatar)
			avatarGestureRecognizer()
		}
        
		imageAvatar.image = messagesView.avatarImage(indexPath)

		if (labelAvatar == nil) {
			labelAvatar = UILabel()
			labelAvatar.font = RCDefaults.avatarFont
			labelAvatar.textColor = RCDefaults.avatarTextColor
			labelAvatar.textAlignment = .center
			contentView.addSubview(labelAvatar)
		}
		labelAvatar.text = (imageAvatar.image == nil) ? messagesView.avatarInitials(indexPath) : nil
        if (labelText == nil) {
            labelText = UILabel()
            labelText.font = RCDefaults.headerUpperFont
            labelText.textColor = RCDefaults.headerUpperColor
            
            contentView.addSubview(labelText)
        }

        labelText.textAlignment = rcmessage.incoming ? .center : .center
        labelText.text = messagesView.textHeaderUpper(indexPath)
        
        if (statusImageView == nil) {
            statusImageView = UIImageView()
            contentView.addSubview(statusImageView)
        }

        
        statusImageView.image = messagesView.textFooterLower(indexPath)
        
        if (labelTimeText == nil) {
            labelTimeText = UILabel()
            labelTimeText.font = RCDefaults.headerLowerFont
            labelTimeText.textColor = RCDefaults.headerLowerColor
            contentView.addSubview(labelTimeText)
        }

        labelTimeText.textAlignment = rcmessage.incoming ? .left : .right
        labelTimeText.text = messagesView.textHeaderLower(indexPath)
        
        if(labelName == nil){
            labelName = UILabel()
            labelName.font = RCDefaults.headerLowerFont
            labelName.textColor = RCDefaults.headerLowerColor
            labelName.textAlignment = .left
            contentView.addSubview(labelName)
            
        }
        labelName.text = (messagesView.recipientId == "" && rcmessage.incoming==true) ?  rcmessage.userFullname : nil
        nameHeight = (labelName.text != nil) ? RCDefaults.headerLowerHeight : 0
        
        print(rcmessage.isObjectionalbe)
        if(objectionableMark == nil && rcmessage.isObjectionalbe){
            print("create mark")
            objectionableMark = UIImageView()
            objectionableMark.image = UIImage(named: "ic_pay_fail")
            contentView.addSubview(objectionableMark)
        }else if (objectionableMark != nil && rcmessage.isObjectionalbe == false){
            objectionableMark.removeFromSuperview()
            objectionableMark = nil
        }
        
	}
    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func layoutSubviews(_ size: CGSize) {

		super.layoutSubviews()

		let rcmessage = messagesView.rcmessageAt(indexPath)

		let widthTable = messagesView.tableView.frame.size.width

		
        
        let label_width = widthTable - RCDefaults.headerUpperLeft - RCDefaults.headerUpperRight
        labelHeight = (labelText.text != nil) ? RCDefaults.headerUpperHeight : 0

        labelText.frame = CGRect(x: RCDefaults.headerUpperLeft, y: 0, width: label_width, height: labelHeight)
        
        
        if labelName != nil{
            let name_width = CGFloat(200)
            
            let xName = rcmessage.incoming ? RCDefaults.avatarMarginLeft + RCDefaults.bubbleMarginLeft : (widthTable - RCDefaults.avatarMarginRight - name_width)
            
            labelName.frame = CGRect(x: xName, y: labelHeight , width: name_width, height: nameHeight)
        }
        
        let xBubble = rcmessage.incoming ? RCDefaults.bubbleMarginLeft : (widthTable - RCDefaults.bubbleMarginRight - size.width)
        viewBubble.frame = CGRect(x: xBubble, y: labelHeight+RCDefaults.viewBubbleMarginTop+nameHeight, width: size.width, height: size.height-labelHeight-RCDefaults.viewBubbleMarginTop-nameHeight)
        let xMark = rcmessage.incoming ? RCDefaults.bubbleMarginLeft + size.width + 10 : (widthTable - RCDefaults.bubbleMarginRight - size.width - 20 - 10)
        if(objectionableMark != nil){
            print("display mark")
            objectionableMark.frame = CGRect(x: xMark, y:labelHeight+RCDefaults.viewBubbleMarginTop+nameHeight + 5, width: 18, height: 18 )
        }
        let diameter = RCDefaults.avatarDiameter
        let xAvatar = rcmessage.incoming ? RCDefaults.avatarMarginLeft : (widthTable - RCDefaults.avatarMarginRight - diameter)
        imageAvatar.frame = CGRect(x: xAvatar, y: labelHeight, width: diameter, height: diameter)
        labelAvatar.frame = CGRect(x: xAvatar, y: labelHeight, width: diameter, height: diameter)
        
        let height = (statusImageView != nil) ? RCDefaults.footerLowerHeight : 0

        statusImageView.frame = CGRect(x: widthTable - 15 - RCDefaults.footerLowerRight, y: labelHeight+diameter, width: 20, height: height)
        
        let time_width = CGFloat(60)
        let time_height = (labelTimeText.text != nil) ? RCDefaults.headerLowerHeight : 0
        let xTime = rcmessage.incoming ? xBubble + size.width + 10 : xBubble - time_width-10
        
        labelTimeText.frame = CGRect(x: xTime, y: size.height-time_height , width: time_width, height: time_height)
        
        
        if(type == 0){
            let imageName = rcmessage.incoming ? "chat_incoming_mask" : "chat_outgoing_mask"
            guard let image = UIImage(named: imageName) else { return }
            let maskView = UIImageView()
            maskView.image = image.resizableImage(withCapInsets:UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),resizingMode: .stretch)
            maskView.frame = CGRect(x: 0, y: 0, width: viewBubble.frame.size.width, height: viewBubble.frame.size.height)
            //contentView.addSubview(maskView)
            viewBubble.mask = maskView
        }
        
    }

	// MARK: - Gesture recognizer methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bubbleGestureRecognizer() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapBubble))
		viewBubble.addGestureRecognizer(tapGesture)
		tapGesture.cancelsTouchesInView = false

		let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(actionLongBubble(_:)))
		viewBubble.addGestureRecognizer(longGesture)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func avatarGestureRecognizer() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapAvatar))
		imageAvatar.addGestureRecognizer(tapGesture)
		tapGesture.cancelsTouchesInView = false
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
			menuController.showMenu(from: contentView, rect: viewBubble.frame)
		} else {
			messagesView.messageInputBar.inputTextView.resignFirstResponder()
		}
	}
}
