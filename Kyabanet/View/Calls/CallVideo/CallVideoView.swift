
import Sinch
import SwiftyAvatar
import UIKit
import AgoraRtcKit
import FirebaseDatabase
import FirebaseFirestore
import RealmSwift

class CallVideoView: UIViewController {
    
	@IBOutlet var viewBackground: UIView!
	@IBOutlet var viewDetails: UIView!
	@IBOutlet var imageUser: SwiftyAvatar!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelStatus: UILabel!
	@IBOutlet var uiv_anwserhangup: UIView!
	@IBOutlet var uiv_muteswitch: UIView!
    @IBOutlet var uiv_power: UIView!
    @IBOutlet weak var uiv_request: UIView!
    
    let ref = Database.database().reference()
    
	private var person: Person!

	 var incoming = false
	 var outgoing = false
	private var muted = false
	private var switched = false
    
    private var personsFullName:String?
    private var callString = ""
    private var type = 0
    private var group: Group?
    
    // agora module
    @IBOutlet weak var localContainer: UIView!
    @IBOutlet weak var remoteContainer: UIView!
    
    //@IBOutlet weak var remoteVideoMutedIndicator: UIImageView!
    //@IBOutlet weak var localVideoMutedIndicator: UIView!
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    var videoStatusHandle: UInt?
    var videoStatusRemoveHandle: UInt?
    
    var agoraKit: AgoraRtcEngineKit?
    var localVideo: AgoraRtcVideoCanvas?
    var remoteVideo: AgoraRtcVideoCanvas?
    var roomID: String = ""
    var receiver: String = ""
    var isRemoteVideoRender: Bool = true {
        didSet {
            if let it = localVideo, let view = it.view {
                if view.superview == localContainer {
                    //remoteVideoMutedIndicator.isHidden = isRemoteVideoRender
                    remoteContainer.isHidden = !isRemoteVideoRender
                } else if view.superview == remoteContainer {
                    //localVideoMutedIndicator.isHidden = isRemoteVideoRender
                }
            }
        }
    }
    
    var isLocalVideoRender: Bool = false {
        didSet {
            if let it = localVideo, let view = it.view {
                if view.superview == localContainer {
                    //localVideoMutedIndicator.isHidden = isLocalVideoRender
                } else if view.superview == remoteContainer {
                    //remoteVideoMutedIndicator.isHidden = isLocalVideoRender
                }
            }
        }
    }
    
    var isStartCalling: Bool = true {
        didSet {
            if isStartCalling {
                micButton.isSelected = false
            }
            micButton.isHidden = !isStartCalling
            cameraButton.isHidden = !isStartCalling
        }
    }
    
    private var audioController: SINAudioController?
    
    var transactionObjectId = ""
    
    private var tokenTransactions: NotificationToken? = nil
    private var transactions = realm.objects(ZEDPay.self).filter(falsepredicate)
    
    var call_min_duration: Float = 0
    private var timer: Timer?
    
	init(userId: String) {
		super.init(nibName: nil, bundle: nil)
        let recipentUser = realm.object(ofType: Person.self, forPrimaryKey: userId)
        callString = recipentUser!.fullname
		self.isModalInPresentation = true
		self.modalPresentationStyle = .fullScreen
        let app = UIApplication.shared.delegate as? AppDelegate
        audioController = app?.client?.audioController()
        outgoing = true
	}
    
    init(group: Group, persons: [String]) {
        
        super.init(nibName: nil, bundle: nil)
        type = 1
        self.group = group
        callString = group.name
        self.isModalInPresentation = true
        self.modalPresentationStyle = .fullScreen
    }
	
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
        call_min_duration = Float(interval / 60)
        print("total call duration===>",call_min_duration)
    }
    
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	
	override func viewDidLoad() {
		super.viewDidLoad()
		micButton.setImage(UIImage(named: "callvideo_mute1"), for: .normal)
        micButton.setImage(UIImage(named: "callvideo_mute1"), for: .highlighted)

		cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .normal)
        cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .highlighted)

        if (incoming) { setIncomingUI() }
        if (outgoing) { setOutGoingUI() }
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCallStatusListner(self.roomID)
        if(type == 0){
            loadPerson()
        }else{
            loadGroup(self.group!)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let videoStatusHandle = videoStatusHandle{
            FirebaseAPI.removeVideoCallListnerObserver(self.roomID, videoStatusHandle)
        }
        if let videoStatusRemoveHandle = videoStatusRemoveHandle{
            FirebaseAPI.removeVideoCallRemoveListnerObserver(self.roomID, videoStatusRemoveHandle)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    func videoCallStatusListner(_ roomId : String)  {
        self.videoStatusHandle = FirebaseAPI.setVideoCallChangeListener(roomId){ [self] (status) in
            if status == Status.accept.rawValue{
                joinAction()
            }
        }
        
        self.videoStatusRemoveHandle = FirebaseAPI.setVideoCallRemoveListener(roomId){ [self] (receiverid) in
            if receiverid == AuthUser.userId(){
                timerStop()
                print("call duration==>", call_min_duration)
                self.reduceCallFee(call_min_duration)
                self.leaveChannel()
                self.dismiss(animated: true, completion: nil)
            }else{
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
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppConstant.agoraAppID, delegate: self)
        setupVideo()
        self.viewDetails.isHidden = true
        self.uiv_anwserhangup.isHidden = true
        self.uiv_muteswitch.isHidden = false
        self.uiv_power.isHidden = false
        self.uiv_request.isHidden = false
        self.localContainer.isHidden = false
        self.remoteContainer.isHidden = false
        //self.viewEnded.isHidden = true
        setupLocalVideo()
        joinChannel()
        if Persons.currentPerson()!.userType == UserType.generalUser.rawValue{
            timerStart(Date())
        }
    }
    
    func reduceCallFee(_ duration: Float) {
        if Persons.currentPerson()!.userType == UserType.generalUser.rawValue{
            self.transactionObjectId = ZEDPays.callFeecreate(fromUserId: (Persons.currentPerson()?.objectId)!, toUserId: receiver, quantity: duration * Float(AppConstant.VIDEO_CALL_FEE))
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
    
    //------- Agora module setup
    //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    func setupVideo() {
        if let agoraKit = self.agoraKit{
            agoraKit.enableVideo()
            // Set video configuration
            agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360,
                                                                                 frameRate: .fps15,
                                                                                 bitrate: AgoraVideoBitrateStandard,
                                                                                 orientationMode: .adaptative))
        }
    }
    
    func setupLocalVideo() {
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: localContainer.frame.size))
        localVideo = AgoraRtcVideoCanvas()
        localVideo!.view = view
        localVideo!.renderMode = .hidden
        localVideo!.uid = 0
        localContainer.addSubview(localVideo!.view!)
        if let agoraKit = self.agoraKit{
            agoraKit.setupLocalVideo(localVideo)
        }
    }
    
    func joinChannel() {
        audioController?.stopPlayingSoundFile()
        if let agoraKit = self.agoraKit{
            agoraKit.setDefaultAudioRouteToSpeakerphone(true)
            agoraKit.joinChannel(byToken: "", channelId: self.roomID, info: nil, uid: 0) { [unowned self] (channel, uid, elapsed) -> Void in
                self.isLocalVideoRender = true
            }
            isStartCalling = true
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    func leaveChannel() {
        if let agoraKit = self.agoraKit{
            // leave channel and end chat
            agoraKit.leaveChannel(nil)
            isRemoteVideoRender = false
            isLocalVideoRender = false
            isStartCalling = false
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    @IBAction func actionHangup(_ sender: Any) {
        timerStop()
        print("call duration==>", call_min_duration)
        self.reduceCallFee(call_min_duration)
        ref.child("video_call").child(self.roomID).removeValue()
        self.leaveChannel()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionRequestHangup(_ sender: Any) {
        DispatchQueue.main.async {
            self.audioController?.stopPlayingSoundFile()
        }
        
        ref.child("video_call").child(self.roomID).removeValue()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func decline(_ sender: Any) {
        DispatchQueue.main.async {
            self.audioController?.stopPlayingSoundFile()
        }
        ref.child("video_call").child(self.roomID).removeValue()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionMute(_ sender: Any) {
        let sender = sender as! UIButton
        sender.isSelected.toggle()
        if let agoraKit = self.agoraKit{
            agoraKit.muteLocalAudioStream(sender.isSelected)
        }
        if (muted) {
            muted = false
            micButton.setImage(UIImage(named: "callvideo_mute1"), for: .normal)
            micButton.setImage(UIImage(named: "callvideo_mute1"), for: .highlighted)
        } else {
            muted = true
            micButton.setImage(UIImage(named: "callvideo_mute2"), for: .normal)
            micButton.setImage(UIImage(named: "callvideo_mute2"), for: .highlighted)
        }
    }
    
    @IBAction func actionSwitch(_ sender: Any) {
        let sender = sender as! UIButton
        sender.isSelected.toggle()
        if let agoraKit = self.agoraKit{
            agoraKit.switchCamera()
        }
        if (switched) {
            switched = false
            cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .normal)
            cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .highlighted)
        } else {
            switched = true
            cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .normal)
            cameraButton.setImage(UIImage(named: "callvideo_switch1"), for: .highlighted)
        }
    }
    
    @IBAction func didClickLocalContainer(_ sender: Any) {
        switchView(localVideo)
        switchView(remoteVideo)
    }
    
    func removeFromParent(_ canvas: AgoraRtcVideoCanvas?) -> UIView? {
        if let it = canvas, let view = it.view {
            let parent = view.superview
            if parent != nil {
                view.removeFromSuperview()
                return parent
            }
        }
        return nil
    }
    
    func switchView(_ canvas: AgoraRtcVideoCanvas?) {
        let parent = removeFromParent(canvas)
        if parent == localContainer {
            canvas!.view!.frame.size = remoteContainer.frame.size
            remoteContainer.addSubview(canvas!.view!)
        } else if parent == remoteContainer {
            canvas!.view!.frame.size = localContainer.frame.size
            localContainer.addSubview(canvas!.view!)
        }
    }
    
    //------- Agora module setup end
    //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
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
                self.labelInitials.text = nil
            }
            else {
                self.imageUser.image = UIImage(named: "ic_default_profile")
            }
        }

        labelName.text = callString
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
        labelName.text = callString
        
        
    }
	// MARK: - User actions
	
	@objc func actionTap() {
		uiv_muteswitch.isHidden = !uiv_muteswitch.isHidden
	}
	
	@IBAction func actionAnswer(_ sender: Any) {
        self.joinAction()
        var status = [String: Any]()
        status["receiver"]   = self.receiver
        status["status"]   = Status.accept.rawValue
        
        FirebaseAPI.sendVideoCallStatus(status, self.roomID) { (isSuccess, data) in
            
        }
		//call?.answer()
	}

	// MARK: - Helper methods
	
	func setOutGoingUI() {
		viewDetails.isHidden = false
        labelStatus.text = "発信中"
        labelStatus.textColor = .white
		uiv_anwserhangup.isHidden = true
		uiv_muteswitch.isHidden = true
        uiv_power.isHidden = true
        uiv_request.isHidden = false
        localContainer.isHidden = true
        var status = [String: Any]()
        status["receiver"]   = self.receiver
        status["status"]   = Status.outgoing.rawValue
        FirebaseAPI.sendVideoCallStatus(status, self.roomID) { (isSuccess, data) in
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.audioController?.enableSpeaker()
            self.audioController?.startPlayingSoundFile(Dir.application("call_ringback.wav"), loop: true)
        }
	}

	
	func setIncomingUI() {
		viewDetails.isHidden = false
		labelStatus.text = "着信中"
        labelStatus.textColor = .white
        localContainer.isHidden = true
		uiv_anwserhangup.isHidden = false // answer , hangout
		uiv_muteswitch.isHidden = true // mute, switch
        uiv_power.isHidden = true //one call hangout
        uiv_request.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.audioController?.enableSpeaker()
            self.audioController?.startPlayingSoundFile(Dir.application("call_ringback.wav"), loop: true)
        }
	}

    
    func updateEnd() {
        self.viewDetails.isHidden = false
        self.labelStatus.text = "End"
        labelStatus.textColor = .white
        self.uiv_muteswitch.isHidden = true
        self.uiv_anwserhangup.isHidden = true
        self.uiv_power.isHidden = false
        self.uiv_request.isHidden = true
        self.remoteContainer.isHidden = true
        //self.remoteVideoMutedIndicator.isHidden = true
        //self.localVideoMutedIndicator.isHidden = true
        self.localContainer.isHidden = true
    }
}

extension CallVideoView: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt, state: AgoraVideoRemoteState, reason: AgoraVideoRemoteStateReason, elapsed: Int) {
        print("remotestatechagne==>",state.rawValue)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let parent: UIView = remoteContainer
        if remoteVideo != nil {
            return
        }

        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: parent.frame.size))
        remoteVideo = AgoraRtcVideoCanvas()
        remoteVideo!.view = view
        remoteVideo!.renderMode = .hidden
        remoteVideo!.uid = uid
        parent.addSubview(remoteVideo!.view!)
        if let agoraKit = self.agoraKit{
            agoraKit.setupRemoteVideo(remoteVideo!)
        }
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid:UInt, size:CGSize, elapsed:Int) {
        isRemoteVideoRender = true
        
        var parent: UIView = remoteContainer
        if let it = localVideo, let view = it.view {
            if view.superview == parent {
                parent = localContainer
            }
        }
        if remoteVideo != nil {
            return
        }
        
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: parent.frame.size))
        remoteVideo = AgoraRtcVideoCanvas()
        remoteVideo!.view = view
        remoteVideo!.renderMode = .hidden
        remoteVideo!.uid = uid
        parent.addSubview(remoteVideo!.view!)
        if let agoraKit = self.agoraKit{
            agoraKit.setupRemoteVideo(remoteVideo!)
        }
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        isRemoteVideoRender = false
        if let it = remoteVideo, it.uid == uid {
            removeFromParent(it)
            remoteVideo = nil
        }
        // dismisss action
        DispatchQueue.main.async {
            self.updateEnd()
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted:Bool, byUid:UInt) {
        isRemoteVideoRender = !muted
    }
}
