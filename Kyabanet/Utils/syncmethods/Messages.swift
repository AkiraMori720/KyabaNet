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

import RealmSwift
import ProgressHUD

//-------------------------------------------------------------------------------------------------------------------------------------------------
class Messages: NSObject {

    class func sendMoney(chatId: String, recipientId:String, payId: String, failed: Bool){
        let message = Message()

        message.chatId = chatId

        message.userId = AuthUser.userId()
        message.userFullname = Persons.fullname()
        message.userInitials = Persons.initials()
        message.userPictureAt = Persons.pictureAt()
        message.type = MESSAGE_TYPE.MESSAGE_MONEY
        message.text = payId + "$" + AuthUser.userId()
        message.isMediaFailed = failed
        createMessage(message: message, recipientId: recipientId)
    }
    
    class func sendCalling(chatId: String, recipientId:String, type: CallStatus){
        let message = Message()

        message.chatId = chatId

        message.userId = AuthUser.userId()
        message.userFullname = Persons.fullname()
        message.userInitials = Persons.initials()
        message.userPictureAt = Persons.pictureAt()
        if type == .MISSED_CALL{
            message.text = "Missed call".localized
            message.type = MESSAGE_TYPE.MISSED_CALL
        }else{
            message.text = "Cancelled call".localized
            message.type = MESSAGE_TYPE.CANCELLED_CALL
        }
        
        createMessage(message: message, recipientId: recipientId)
    }
    
    class func send(chatId: String, recipientId:String, text: String?, photo: UIImage?, video: URL?, audio: String?) {

		let message = Message()

		message.chatId = chatId

		message.userId = AuthUser.userId()
		message.userFullname = Persons.fullname()
		message.userInitials = Persons.initials()
		message.userPictureAt = Persons.pictureAt()

        if (text != nil)		{ sendMessageText(message: message, text: text!, recipientId: recipientId)		}
		else if (photo != nil)	{ sendMessagePhoto(message: message, photo: photo!, recipientId: recipientId)		}
		else if (video != nil)	{ sendMessageVideo(message: message, video: video!, recipientId: recipientId)		}
		else if (audio != nil)	{ sendMessageAudio(message: message, audio: audio!, recipientId: recipientId)		}
		else					{ sendMessageLoaction(message: message, recipientId: recipientId)					}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func forward(chatId: String, message source: Message) {

		let message = Message()

		message.chatId = chatId

		message.userId = AuthUser.userId()
		message.userFullname = Persons.fullname()
		message.userInitials = Persons.initials()
		message.userPictureAt = Persons.pictureAt()

		message.type = source.type
		message.text = source.text

		message.photoWidth = source.photoWidth
		message.photoHeight = source.photoHeight
		message.videoDuration = source.videoDuration
		message.audioDuration = source.audioDuration

		message.latitude = source.latitude
		message.longitude = source.longitude

        if (message.type == MESSAGE_TYPE.MESSAGE_TEXT)		{ createMessage(message: message, recipientId: "")	}
		if (message.type == MESSAGE_TYPE.MESSAGE_EMOJI)		{ createMessage(message: message, recipientId: "")	}
		if (message.type == MESSAGE_TYPE.MESSAGE_LOCATION)	{ createMessage(message: message, recipientId: "")	}

		if (message.type == MESSAGE_TYPE.MESSAGE_PHOTO)		{ forwardMessagePhoto(message: message, source: source)	}
		if (message.type == MESSAGE_TYPE.MESSAGE_VIDEO)		{ forwardMessageVideo(message: message, source: source)	}
		if (message.type == MESSAGE_TYPE.MESSAGE_AUDIO)		{ forwardMessageAudio(message: message, source: source)	}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func forwardMessagePhoto(message: Message, source: Message) {

		message.isMediaQueued = true

		if let path = MediaDownload.pathPhoto(source.objectId) {
			if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
				MediaDownload.savePhoto(message.objectId, data: data)
				createMessage(message: message, recipientId: "")
			}
		} else {
			ProgressHUD.showError("Missing media file.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func forwardMessageVideo(message: Message, source: Message) {

		message.isMediaQueued = true

		if let path = MediaDownload.pathVideo(source.objectId) {
			if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
				MediaDownload.saveVideo(message.objectId, data: data)
				createMessage(message: message, recipientId: "recipientId")
			}
		} else {
			ProgressHUD.showError("Missing media file.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func forwardMessageAudio(message: Message, source: Message) {

		message.isMediaQueued = true

		if let path = MediaDownload.pathAudio(source.objectId) {
			if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
				MediaDownload.saveAudio(message.objectId, data: data)
				createMessage(message: message, recipientId: "")
			}
		} else {
			ProgressHUD.showError("Missing media file.")
		}
	}

	// MARK: -
	
   
    
	private class func sendMessageText(message: Message, text: String, recipientId:String) {

        message.type = Emoji.isEmoji(text: text) ? MESSAGE_TYPE.MESSAGE_EMOJI : MESSAGE_TYPE.MESSAGE_TEXT
		message.text = text

		createMessage(message: message, recipientId: recipientId)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessagePhoto(message: Message, photo: UIImage, recipientId:String) {

		message.type = MESSAGE_TYPE.MESSAGE_PHOTO
		message.text = "Photo message"

		message.photoWidth = Int(photo.size.width)
		message.photoHeight = Int(photo.size.height)
		message.isMediaQueued = true

		if let data = photo.jpegData(compressionQuality: 0.6) {
			MediaDownload.savePhoto(message.objectId, data: data)
			createMessage(message: message, recipientId: recipientId)
		} else {
			ProgressHUD.showError("Photo data error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessageVideo(message: Message, video: URL, recipientId:String) {

		message.type = MESSAGE_TYPE.MESSAGE_VIDEO
		message.text = "Video message"

		message.videoDuration = Video.duration(path: video.path)
		message.isMediaQueued = true

		if let data = try? Data(contentsOf: video) {
			MediaDownload.saveVideo(message.objectId, data: data)
			createMessage(message: message, recipientId: recipientId)
		} else {
			ProgressHUD.showError("Video data error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessageAudio(message: Message, audio: String, recipientId:String) {

		message.type = MESSAGE_TYPE.MESSAGE_AUDIO
		message.text = "Audio message"

		message.audioDuration = Audio.duration(path: audio)
		message.isMediaQueued = true

		if let data = try? Data(contentsOf: URL(fileURLWithPath: audio)) {
			MediaDownload.saveAudio(message.objectId, data: data)
			createMessage(message: message, recipientId: recipientId)
		} else {
			ProgressHUD.showError("Audio data error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessageLoaction(message: Message, recipientId:String) {

		message.type = MESSAGE_TYPE.MESSAGE_LOCATION
		message.text = "Location message"

		message.latitude = LocationManager.latitude()
		message.longitude = LocationManager.longitude()

		createMessage(message: message, recipientId: recipientId)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func createMessage(message: Message, recipientId:String) {

		let realm = try! Realm()
		try! realm.safeWrite {
			realm.add(message, update: .modified)
		}

        let recipient = realm.object(ofType: Person.self, forPrimaryKey: recipientId)
        
		Audio.playMessageOutgoing()
        //Audio.playMessageIncoming()
		Details.updateAll(chatId: message.chatId, isDeleted: false)
		Details.updateAll(chatId: message.chatId, isArchived: false)
        switch message.type {
        case MESSAGE_TYPE.MESSAGE_TEXT:
            PushNotification.send(token: recipient?.oneSignalId ?? "", title: "New message", body: Persons.fullname() + " " + "sent you a new message", type: .sendText, chatId: message.chatId)
        case MESSAGE_TYPE.MESSAGE_EMOJI:
            PushNotification.send(token: recipient?.oneSignalId ?? "", title: "New emoji", body: Persons.fullname() + " " + "sent new emoji", type: .sendText, chatId: message.chatId)
        case MESSAGE_TYPE.MESSAGE_PHOTO:
            PushNotification.send(token: recipient?.oneSignalId ?? "", title: "New photo", body: Persons.fullname() + " " + "sent new photo", type: .sendText, chatId: message.chatId)
        case MESSAGE_TYPE.MESSAGE_VIDEO:
            PushNotification.send(token: recipient?.oneSignalId ?? "", title: "New video", body: Persons.fullname() + " " + "sent new video", type: .sendText, chatId: message.chatId)
        case MESSAGE_TYPE.MESSAGE_AUDIO:
            PushNotification.send(token: recipient?.oneSignalId ?? "", title: "New audio", body: Persons.fullname() + " " + "sent new audio", type: .sendText, chatId: message.chatId)
        case MESSAGE_TYPE.MESSAGE_LOCATION:
            PushNotification.send(token: recipient?.oneSignalId ?? "", title: "Location received", body: Persons.fullname() + " " + "sent location", type: .sendText, chatId: message.chatId)
        case MESSAGE_TYPE.MESSAGE_MONEY:
            PushNotification.send(token: recipient?.oneSignalId ?? "", title: "Balance received", body: "You have received Balance from" + " " + Persons.fullname(), type: .sendText, chatId: message.chatId)
        default:
            print("default")
        }
	}
}
