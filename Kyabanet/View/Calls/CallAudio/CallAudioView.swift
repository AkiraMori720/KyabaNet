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

import Sinch
import MediaPlayer
import SwiftyAvatar
import UIKit
import AgoraRtcKit
import FirebaseDatabase
import FirebaseFirestore
import RealmSwift

//----
class CallAudioView: UIViewController {
    
    @IBOutlet var imageUser: UIImageView!
    @IBOutlet var labelInitials: UILabel!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelStatus: UILabel!
    @IBOutlet var uiv_mutespeaker: UIView!
    @IBOutlet var buttonMute: UIButton!
    @IBOutlet var buttonSpeaker: UIButton!
    @IBOutlet var buttonVideo: UIButton!
    @IBOutlet var uiv_answerdecline: UIView!
    @IBOutlet var uiv_power: UIView!
    
    @IBOutlet weak var uiv_requst: UIView!
    @IBOutlet weak var dottedProgressView: UIView!
    
    var transactionObjectId = ""
    
    private var tokenTransactions: NotificationToken? = nil
    private var transactions = realm.objects(ZEDPay.self).filter(falsepredicate)
    
    var call_min_duration: Float = 0
    
    let ref = Database.database().reference()
    private var dottedProgressBar:DottedProgressBar?
    
    private var person: Person!
    private var timer: Timer?

    var incoming = false
    var outgoing = false
    private var muted = false
    private var speaker = false

    private var personsFullName:String?
    private var type = 0
    private var group:Group?
    private var callString = ""
    
    var roomID = ""
    var receiver: String = ""
    var agoraKit: AgoraRtcEngineKit?
    
    var voiceStatusHandle: UInt?
    var voiceStatusRemoveHandle: UInt?
    
    private var audioController: SINAudioController?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let voiceStatusHandle = voiceStatusHandle{
            FirebaseAPI.removeVoiceCallListnerObserver(self.roomID, voiceStatusHandle)
        }
        if let voiceStatusRemoveHandle = voiceStatusRemoveHandle{
            FirebaseAPI.removeVoiceCallRemoveListnerObserver(self.roomID, voiceStatusRemoveHandle)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    init(userId: String) {
        super.init(nibName: nil, bundle: nil)
        let recipentUser = realm.object(ofType: Person.self, forPrimaryKey: userId)
        callString = recipentUser!.fullname
        let app = UIApplication.shared.delegate as? AppDelegate
        audioController = app?.client?.audioController()
        
        self.isModalInPresentation = true
        self.modalPresentationStyle = .fullScreen
    }
    
    init(group: Group, persons: [String]) {
        
        super.init(nibName: nil, bundle: nil)
        type = 1
        self.group = group
        callString = group.name
        
        self.isModalInPresentation = true
        self.modalPresentationStyle = .fullScreen

        _ = UIApplication.shared.delegate as? AppDelegate
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Timer methods
    
    func timerStart(_ now: Date) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.updateStatus(now)
        }
    }

    func timerStop() {
        timer?.invalidate()
        timer = nil
    }

    func updateStatus(_ now: Date) {
        let interval = Date().timeIntervalSince(now)
        let seconds = Int(interval) % 60
        let minutes = Int(interval) / 60
        if Persons.currentPerson()!.userType == UserType.generalUser.rawValue{
            call_min_duration = Float(interval / 60)
            print("total call duration===>",call_min_duration)
        }
        labelStatus.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .normal)
        buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .highlighted)

        buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .normal)
        buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .highlighted)

        buttonVideo.setImage(UIImage(named: "callaudio_video1"), for: .normal)
        buttonVideo.setImage(UIImage(named: "callaudio_video1"), for: .highlighted)
        
        if (incoming) { setIncomingUI() }
        if (outgoing) { setOutgoingUI() }
        // dotted progressview
        dottedProgressBar = DottedProgressBar()
        dottedProgressBar?.progressAppearance = DottedProgressBar.DottedProgressAppearance(dotRadius: 6.0, dotsColor: UIColor(hexString: "#33000000")!, dotsProgressColor: UIColor(hexString: "#00406E")!, backColor: UIColor.clear)
        dottedProgressBar?.frame = CGRect(x: 0, y: 0, width: 100, height: 24)
        dottedProgressView.addSubview(dottedProgressBar!)
        dottedProgressBar?.setNumberOfDots(6)
        
        // get audio volume
        let audioSession = AVAudioSession.sharedInstance()
        
        /// Volume View
        let volumeView = MPVolumeView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        volumeView.isHidden = false
        volumeView.alpha = 0.01
        view.addSubview(volumeView)
        /// Notification Observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.volumeDidChange(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        let progress = audioSession.outputVolume / 1.0 * 6
        dottedProgressBar?.setProgress(value: Int(progress))
        if type == 1{
            self.joinAction()
        }
    }
    
    // ------ call accept status listener
    func voiceCallStatusListner(_ roomId : String)  {
        self.voiceStatusHandle = FirebaseAPI.setVoiceCallChangeListener(roomId){ [self] (status) in
            if status == Status.accept.rawValue{
                self.joinAction()
                //
            }
        }
        
        self.voiceStatusRemoveHandle = FirebaseAPI.setVoiceCallRemoveListener(roomId){ [self] (receiverid) in
            if receiverid == AuthUser.userId(){
                timerStop()
                print("call duration==>", call_min_duration)
                self.reduceCallFee(call_min_duration)
                self.leaveChannel()
                self.dismiss(animated: true, completion: nil)
            }else{
                self.audioController?.stopPlayingSoundFile()
                if outgoing{
                    self.labelStatus.text = "失敗しました"
                    self.labelStatus.textColor = .red
                }else{
                    self.leaveChannel()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func joinAction() {
        //------ agora setup and join action
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppConstant.agoraAppID, delegate: self)
        // Allows a user to join a channel.
        if let agoraKit = self.agoraKit{
            agoraKit.joinChannel(byToken: "", channelId: roomID, info:nil, uid:0) {[unowned self] (sid, uid, elapsed) -> Void in
                // Joined channel "demoChannel"
                agoraKit.setEnableSpeakerphone(false)
                UIApplication.shared.isIdleTimerDisabled = true
            }
            self.setConnectedUI()
        }
    }
    
    @objc func volumeDidChange(notification: NSNotification) {
        let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float
        let progress = volume / 1.0 * 6
        dottedProgressBar?.setProgress(value: Int(progress))
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        if(type==0){
            loadPerson()
        }else{
            loadGroup(self.group!)
        }
        labelName.text = callString
        self.voiceCallStatusListner(self.roomID)
    }

    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    
    override var shouldAutorotate: Bool {
        return false
    }

    // MARK: - Realm methods
    
    func loadPerson() {
        person = realm.object(ofType: Person.self, forPrimaryKey: self.receiver)
        labelInitials.text = nil
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.imageUser.image = image
            }
            else {
                self.imageUser.image = UIImage(named: "ic_default_profile")
            }
        }
    }
    
    func loadGroup(_ group:Group) {
        self.labelInitials.text = nil
        MediaDownload.startGroup(group.objectId, pictureAt: group.pictureAt) { image, error in
            if (error == nil) {
                self.imageUser.image = image
            }
            else {
                self.imageUser.image = UIImage(named: "ic_default_profile")
            }
        }
    }
    
    // MARK: - User actions
    
    @IBAction func actionMute(_ sender: Any) {
        if (muted) {
            muted = false
            buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .normal)
            buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .highlighted)
        } else {
            muted = true
            buttonMute.setImage(UIImage(named: "callaudio_mute3"), for: .normal)
            buttonMute.setImage(UIImage(named: "callaudio_mute3"), for: .highlighted)
        }
        if let agoraKit = self.agoraKit{
            agoraKit.muteLocalAudioStream(muted)
        }
    }

    
    @IBAction func actionSpeaker(_ sender: Any) {
        if (speaker) {
            speaker = false
            buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .normal)
            buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .highlighted)
        } else {
            speaker = true
            buttonSpeaker.setImage(UIImage(named: "callaudio_speaker3"), for: .normal)
            buttonSpeaker.setImage(UIImage(named: "callaudio_speaker3"), for: .highlighted)
        }
        if let agoraKit = self.agoraKit{
            agoraKit.setEnableSpeakerphone(speaker)
        }
    }


    func leaveChannel() {
        if let agoraKit = self.agoraKit{
            agoraKit.leaveChannel(nil)
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    func reduceCallFee(_ duration: Float) {
        if Persons.currentPerson()!.userType == UserType.generalUser.rawValue{
            self.transactionObjectId = ZEDPays.callFeecreate(fromUserId: (Persons.currentPerson()?.objectId)!, toUserId: receiver, quantity: duration * Float(AppConstant.VOICE_CALL_FEE))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                let predicate = NSPredicate(format: "objectId == %@", self.transactionObjectId )
                self.transactions = realm.objects(ZEDPay.self).filter(predicate)
                self.tokenTransactions?.invalidate()
                self.transactions.safeObserve({ changes in
                    //self.callBack()
                    print("successfully done")
                }, completion: { token in
                    self.tokenTransactions = token
                })
            }
        }
    }
    
    
    @IBAction func actionHangup(_ sender: Any) {
        timerStop()
        print("call duration==>", call_min_duration)
        self.reduceCallFee(call_min_duration)
        self.leaveChannel()
        ref.child("voice_call").child(self.roomID).removeValue()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionRequestHangup(_ sender: Any) {
        DispatchQueue.main.async {
            self.audioController?.stopPlayingSoundFile()
        }
        ref.child("voice_call").child(self.roomID).removeValue()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionDecline(_ sender: Any) {
        DispatchQueue.main.async {
            self.audioController?.stopPlayingSoundFile()
        }
        ref.child("voice_call").child(self.roomID).removeValue()
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func actionAnswer(_ sender: Any) {
        self.joinAction()
        var status = [String: Any]()
        status["receiver"]   = self.receiver
        status["status"]   = Status.accept.rawValue
        FirebaseAPI.sendVoiceCallStatus(status, self.roomID) { (isSuccess, data) in
        }
        self.joinAction()
    }

    // MARK: - Helper methods
    
    func setOutgoingUI() {
        labelStatus.text = "発信中"
        labelStatus.textColor = .lightGray
        uiv_mutespeaker.isHidden = true
        uiv_answerdecline.isHidden = true
        uiv_power.isHidden = true
        uiv_requst.isHidden = false
        var status = [String: Any]()
        status["receiver"]   = self.receiver
        status["status"]   = Status.outgoing.rawValue
        FirebaseAPI.sendVoiceCallStatus(status, self.roomID) { (isSuccess, data) in
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.audioController?.enableSpeaker()
            self.audioController?.startPlayingSoundFile(Dir.application("call_ringback.wav"), loop: true)
        }
    }
    
    func setIncomingUI() {
        labelStatus.text = "Incoming..."
        labelStatus.textColor = .lightGray
        uiv_mutespeaker.isHidden = true
        uiv_answerdecline.isHidden = false
        uiv_power.isHidden = true
        uiv_requst.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.audioController?.enableSpeaker()
            self.audioController?.startPlayingSoundFile(Dir.application("call_ringback.wav"), loop: true)
        }
    }
    
    func setConnectedUI() {
        audioController?.stopPlayingSoundFile()
        timerStart(Date())
        //labelStatus.text = "Connected"
        //labelStatus.textColor = .green
        uiv_mutespeaker.isHidden = false
        uiv_answerdecline.isHidden = true
        uiv_power.isHidden = false
        uiv_requst.isHidden = true
    }

    
    func setEndUI() {
        labelStatus.text = "Ended"
        labelStatus.textColor = .lightGray
        uiv_mutespeaker.isHidden = true
        uiv_answerdecline.isHidden = true
        uiv_power.isHidden = false
        uiv_requst.isHidden = true
    }
}

extension CallAudioView: AgoraRtcEngineDelegate{
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStateChangedOfUid uid: UInt, state: AgoraAudioRemoteState, reason: AgoraAudioRemoteStateReason, elapsed: Int) {
        print("this is remoteaudiostatechage=====>",state.rawValue)
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, localAudioStateChange state: AgoraAudioLocalState, error: AgoraAudioLocalError) {
        print("this is localaudiostatechage=====>",state.rawValue)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        self.leaveChannel()
        setEndUI()
        timerStop()
        print("call duration==>", call_min_duration)
        
        self.reduceCallFee(call_min_duration)
    }
}

