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
class RCMessagePhotoCell: RCMessageCell {

	private var imageViewPhoto: UIImageView!
	private var imageViewManual: UIImageView!
	private var activityIndicator: UIActivityIndicatorView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func bindData(_ messagesView: ChatViewController, at indexPath: IndexPath) {

		super.bindData(messagesView, at: indexPath)

		let rcmessage = messagesView.rcmessageAt(indexPath)

		viewBubble.backgroundColor = rcmessage.incoming ? RCDefaults.photoBubbleColorIncoming : RCDefaults.photoBubbleColorOutgoing

		if (imageViewPhoto == nil) {
			imageViewPhoto = UIImageView()
			
			viewBubble.addSubview(imageViewPhoto)
		}

		if (activityIndicator == nil) {
			activityIndicator = UIActivityIndicatorView(style: .large)
			viewBubble.addSubview(activityIndicator)
		}

		if (imageViewManual == nil) {
			imageViewManual = UIImageView(image: RCDefaults.photoImageManual)
			viewBubble.addSubview(imageViewManual)
		}

        if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_UNKNOWN) {
			imageViewPhoto.image = nil
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = true
		}

        if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_LOADING) {
			imageViewPhoto.image = nil
			activityIndicator.startAnimating()
			imageViewManual.isHidden = true
		}

        if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_SUCCEED) {
			imageViewPhoto.image = rcmessage.photoImage
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_MANUAL) {
			imageViewPhoto.image = nil
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = false
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		let size = RCMessagePhotoCell.size(messagesView, at: indexPath)

		super.layoutSubviews(size)

		imageViewPhoto.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height-labelHeight-nameHeight)

		let widthActivity = activityIndicator.frame.size.width
		let heightActivity = activityIndicator.frame.size.height
		let xActivity = (size.width - widthActivity) / 2
		let yActivity = (size.height - heightActivity) / 2
		activityIndicator.frame = CGRect(x: xActivity, y: yActivity, width: widthActivity, height: heightActivity)

		let widthManual = imageViewManual.image?.size.width ?? 0
		let heightManual = imageViewManual.image?.size.height ?? 0
		let xManual = (size.width - widthManual) / 2
		let yManual = (size.height - heightManual) / 2
		imageViewManual.frame = CGRect(x: xManual, y: yManual, width: widthManual, height: heightManual)
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

		let photoWidth = CGFloat(rcmessage.photoWidth)
        let labelHeight = (messagesView.textHeaderUpper(indexPath) != nil) ? RCDefaults.headerUpperHeight : 0
        let nameHeight = (messagesView.recipientId=="" && rcmessage.incoming) ? RCDefaults.headerLowerHeight : 0
		let photoHeight = CGFloat(rcmessage.photoHeight)+labelHeight+RCDefaults.viewBubbleMarginTop + nameHeight
        

		let width = CGFloat.minimum(RCDefaults.photoBubbleWidth, photoWidth)
		return CGSize(width: width, height: photoHeight * width / photoWidth)
	}
}
