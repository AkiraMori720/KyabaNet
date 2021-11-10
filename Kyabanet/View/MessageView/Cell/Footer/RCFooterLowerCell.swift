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
class RCFooterLowerCell: UITableViewCell {

	private var indexPath: IndexPath!
	private var messagesView: ChatViewController!

	private var statusImageView: UIImageView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(_ messagesView: ChatViewController, at indexPath: IndexPath) {

		self.indexPath = indexPath
		self.messagesView = messagesView

		let rcmessage = messagesView.rcmessageAt(indexPath)

		backgroundColor = UIColor.clear

		if (statusImageView == nil) {
			statusImageView = UIImageView()
			contentView.addSubview(statusImageView)
		}

		//statusImageView.textAlignment = rcmessage.incoming ? .left : .right
		statusImageView.image = messagesView.textFooterLower(indexPath)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		super.layoutSubviews()

		let widthTable = messagesView.tableView.frame.size.width

		let width = widthTable - RCDefaults.footerLowerLeft - RCDefaults.footerLowerRight
		let height = (statusImageView != nil) ? RCDefaults.footerLowerHeight : 0

		statusImageView.frame = CGRect(x: widthTable - 15 - RCDefaults.footerLowerRight, y: 0, width: 20, height: height)
	}

	// MARK: - Size methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func height(_ messagesView: ChatViewController, at indexPath: IndexPath) -> CGFloat {

		return (messagesView.textFooterLower(indexPath) != nil) ? RCDefaults.footerLowerHeight : 0
	}
}
