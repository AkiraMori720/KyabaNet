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
class RCMessageTextCell: RCMessageCell {

	private var textView: UITextView!
    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func bindData(_ messagesView: ChatViewController, at indexPath: IndexPath) {

		super.bindData(messagesView, at: indexPath)

		let rcmessage = messagesView.rcmessageAt(indexPath)
        
		viewBubble.backgroundColor = rcmessage.incoming ? RCDefaults.textBubbleColorIncoming : RCDefaults.textBubbleColorOutgoing
        var searchString = ""
        if  messagesView.searchBar.text != nil  {
            
            searchString = messagesView.searchBar.text!
        }
        
        if(textView != nil && searchString == ""){
            textView.removeFromSuperview()
            textView = nil
        }
		if (textView == nil ) {
			textView = UITextView()
			textView.font = RCDefaults.textFont
			textView.isEditable = false
			textView.isSelectable = false
			textView.isScrollEnabled = false
			textView.isUserInteractionEnabled = false
			textView.backgroundColor = UIColor.clear
			textView.textContainer.lineFragmentPadding = 0
            textView.textContainerInset = rcmessage.incoming == true ? RCDefaults.textInsetIncoming : RCDefaults.textInsetOutgoing
			viewBubble.addSubview(textView)
		}

		textView.textColor = rcmessage.incoming ? RCDefaults.textTextColorIncoming : RCDefaults.textTextColorOutgoing
  
        let baseString = rcmessage.text

        let attributed = NSMutableAttributedString(string: baseString)
        if(searchString == ""){
            textView.text = rcmessage.text
            return
        }
        
        do{
            let regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            attributed.addAttribute(.font, value: RCDefaults.textFont, range:NSRange(location: 0, length: baseString.utf16.count))
            attributed.addAttribute(.backgroundColor, value: viewBubble.backgroundColor as Any, range:NSRange(location: 0, length: baseString.utf16.count))
            for match in regex.matches(in: baseString, options: [], range: NSRange(location: 0, length: baseString.utf16.count)) as [NSTextCheckingResult] {
                attributed.addAttribute(.backgroundColor, value: UIColor.yellow, range: match.range)
                attributed.addAttribute(.foregroundColor, value: UIColor.black, range: match.range)
            }

            textView.attributedText = attributed
        }catch {
            textView.text = rcmessage.text
            return
        }
        
        
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		let size = RCMessageTextCell.size(messagesView, at: indexPath)

		super.layoutSubviews(size)
        
		textView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height-labelHeight-nameHeight)
	}

	// MARK: - Size methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
    class func height(_ messagesView: ChatViewController, at indexPath: IndexPath) -> CGFloat {

		let size = RCMessageTextCell.size(messagesView, at: indexPath)
		return size.height
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
    class func size(_ messagesView: ChatViewController, at indexPath: IndexPath) -> CGSize {

		let rcmessage = messagesView.rcmessageAt(indexPath)

		let widthTable = messagesView.tableView.frame.size.width

		let maxwidth = (0.6 * widthTable) - RCDefaults.textInsetLeft - RCDefaults.textInsetRight

		let rect = rcmessage.text.boundingRect(with: CGSize(width: maxwidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: RCDefaults.textFont], context: nil)
        
		let width = rect.size.width + RCDefaults.textInsetLeft + RCDefaults.textInsetRight
        let labelHeight = (messagesView.textHeaderUpper(indexPath) != nil) ? RCDefaults.headerUpperHeight : 0
        
        let nameHeight = (messagesView.recipientId=="" && rcmessage.incoming) ? RCDefaults.headerLowerHeight : 0
        let height = rect.size.height + RCDefaults.textInsetTop + RCDefaults.textInsetBottom+labelHeight+RCDefaults.viewBubbleMarginTop + nameHeight
        
		return CGSize(width: CGFloat.maximum(width, RCDefaults.textBubbleWidthMin), height: CGFloat.maximum(height, RCDefaults.textBubbleHeightMin))
	}
}
