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
class RCMessageEmojiCell: RCMessageCell {

	private var textView: UITextView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func bindData(_ messagesView: ChatViewController, at indexPath: IndexPath) {

		super.bindData(messagesView, at: indexPath)

		let rcmessage = messagesView.rcmessageAt(indexPath)

		
		if (textView == nil) {
			textView = UITextView()
			textView.font = RCDefaults.emojiFont
			textView.isEditable = false
			textView.isSelectable = false
			textView.isScrollEnabled = false
			textView.isUserInteractionEnabled = false
			textView.backgroundColor = UIColor.clear
			textView.textContainer.lineFragmentPadding = 0
            textView.textContainerInset = rcmessage.incoming == true ? RCDefaults.emojiInsetIncomming : RCDefaults.emojiInsetOutgoing
			viewBubble.addSubview(textView)
		}

		textView.text = rcmessage.text
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		let size = RCMessageEmojiCell.size(messagesView, at: indexPath)

		super.layoutSubviews(size)

		textView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height-labelHeight-nameHeight)
	}

	// MARK: - Size methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func height(_ messagesView: ChatViewController, at indexPath: IndexPath) -> CGFloat {

		let size = self.size(messagesView, at: indexPath)
		return size.height
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func size(_ messagesView: ChatViewController, at indexPath: IndexPath) -> CGSize {

		let rcmessage = messagesView.rcmessageAt(indexPath)

		let widthTable = messagesView.tableView.frame.size.width

		let maxwidth = (0.6 * widthTable) - RCDefaults.emojiInsetLeft - RCDefaults.emojiInsetRight

		let rect = rcmessage.text.boundingRect(with: CGSize(width: maxwidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: RCDefaults.emojiFont], context: nil)

		let width = rect.size.width + RCDefaults.emojiInsetLeft + RCDefaults.emojiInsetRight
		
        let labelHeight = (messagesView.textHeaderUpper(indexPath) != nil) ? RCDefaults.headerUpperHeight : 0
        
        let nameHeight = (messagesView.recipientId=="" && rcmessage.incoming) ? RCDefaults.headerLowerHeight : 0
        let height = rect.size.height + RCDefaults.emojiInsetTop + RCDefaults.emojiInsetBottom + labelHeight+RCDefaults.viewBubbleMarginTop + nameHeight
		return CGSize(width: CGFloat.maximum(width, RCDefaults.emojiBubbleWidthMin), height: CGFloat.maximum(height, RCDefaults.emojiBubbleHeightMin))
	}
}
