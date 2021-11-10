//
//  GroupVideoCallViewController.swift
//  OpenVideoCall
//
//  Created by GongYuhua on 16/8/22.
//  Copyright © 2016年 Agora. All rights reserved.
//

import UIKit
import AgoraRtcKit

class GroupVideoCallViewController: UIViewController {
    
    var roomName: String = ""
    @IBOutlet weak var containerView: AGEVideoContainer!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var audioMixingButton: UIButton!
    @IBOutlet weak var speakerPhoneButton: UIButton!
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var muteVideoButton: UIButton!
    @IBOutlet weak var muteAudioButton: UIButton!
    
    // The agora engine
    private lazy var agoraKit: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: AppConstant.agoraAppID, delegate: nil)
        return engine
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var settings = Settings()
    
    private var isSwitchCamera = true {
        didSet {
            agoraKit.switchCamera()
        }
    }
    
    private var isAudioMixing = false {
        didSet {
            guard oldValue != isAudioMixing else {
                return
            }
            audioMixingButton?.isSelected = isAudioMixing
            if isAudioMixing {
                // play music file
                agoraKit.startAudioMixing(
                    FileCenter.audioFilePath(),
                    loopback: false,
                    replace: false,
                    cycle: 1
                )
            } else {
                // stop play
                agoraKit.stopAudioMixing()
            }
        }
    }
    
    private var isBeauty = false {
        didSet {
            guard oldValue != isBeauty else {
                return
            }
            beautyButton?.isSelected = isBeauty
            var options: AgoraBeautyOptions? = nil
            if isBeauty {
                options = AgoraBeautyOptions()
                options?.lighteningContrastLevel = .normal
                options?.lighteningLevel = 0.7
                options?.smoothnessLevel = 0.5
                options?.rednessLevel = 0.1
            }
            // improve local render view
            agoraKit.setBeautyEffectOptions(isBeauty, options: options)
        }
    }
    
    private var isSpeakerPhone = true {
        didSet {
            guard oldValue != isSpeakerPhone else {
                return
            }
            speakerPhoneButton.isSelected = !isSpeakerPhone
            // switch playout audio route
            agoraKit.setEnableSpeakerphone(isSpeakerPhone)
        }
    }
    
    private var isVideoMuted = false {
        didSet {
            guard oldValue != isVideoMuted else {
                return
            }
            muteVideoButton?.isSelected = isVideoMuted
            setVideoMuted(isVideoMuted, forUid: 0)
            updateSelfViewVisiable()
            // mute local video
            agoraKit.muteLocalVideoStream(isVideoMuted)
        }
    }
    
    private var isAudioMuted = false {
        didSet {
            guard oldValue != isAudioMuted else {
                return
            }
            muteAudioButton?.isSelected = isAudioMuted
            // mute local audio
            agoraKit.muteLocalAudioStream(isAudioMuted)
        }
    }
    
    private var isDebugMode = false {
        didSet {
            guard oldValue != isDebugMode else {
                return
            }
            //options.isDebugMode = isDebugMode
            //messageTableContainerView.isHidden = !isDebugMode
        }
    }
    
    private var videoSessions = [VideoSession]() {
        didSet {
            updateBroadcastersView()
        }
    }
    
    private let maxVideoSession = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settings.roomName = self.roomName
        settings.encryptionType = nil
        settings.dimension = CGSize.defaultDimension()
        settings.frameRate = AgoraVideoFrameRate.defaultValue
        loadAgoraKit()
    }
    
    deinit {
        leaveChannel()
    }
    
    @IBAction func powerBtnClicked(_ sender: Any) {
        self.leaveChannel()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doAudioMixingPressed(_ sender: UIButton) {
        isAudioMixing.toggle()
    }
    
    @IBAction func doBeautyPressed(_ sender: UIButton) {
        isBeauty.toggle()
    }
    
    @IBAction func doSpeakerPhonePressed(_ sender: UIButton) {
        isSpeakerPhone.toggle()
    }
    
    @IBAction func doMuteVideoPressed(_ sender: UIButton) {
        isVideoMuted.toggle()
    }
    
    @IBAction func doMuteAudioPressed(_ sender: UIButton) {
        isAudioMuted.toggle()
    }
    
    @IBAction func doCameraPressed(_ sender: UIButton) {
        isSwitchCamera.toggle()
    }
}

// MARK: - AgoraRtcEngineKit
private extension GroupVideoCallViewController {
    func loadAgoraKit() {
        agoraKit.delegate = self
        agoraKit.setChannelProfile(.communication)
        agoraKit.enableVideo()
        agoraKit.setVideoEncoderConfiguration(
            AgoraVideoEncoderConfiguration(
                size: settings.dimension,
                frameRate: settings.frameRate,
                bitrate: AgoraVideoBitrateStandard,
                orientationMode: .adaptative
            )
        )
        addLocalSession()
        agoraKit.startPreview()
        if let type = settings.encryptionType, let text = type.text, !text.isEmpty {
            let config = AgoraEncryptionConfig()
            config.encryptionKey = text
            config.encryptionMode = type.modeValue()
            agoraKit.enableEncryption(true, encryptionConfig: config)
        }
        agoraKit.joinChannel(byToken: nil, channelId: self.roomName, info: nil, uid: 0, joinSuccess: nil)
        setIdleTimerActive(false)
    }
    
    func addLocalSession() {
        let localSession = VideoSession.localSession()
        localSession.updateInfo(fps: settings.frameRate.rawValue)
        videoSessions.append(localSession)
        agoraKit.setupLocalVideo(localSession.canvas)
    }
    
    func leaveChannel() {
        agoraKit.setupLocalVideo(nil)
        agoraKit.leaveChannel(nil)
        agoraKit.stopPreview()
        for session in videoSessions {
            session.hostingView.removeFromSuperview()
        }
        videoSessions.removeAll()
        setIdleTimerActive(true)
    }
}

// MARK: - AgoraRtcEngineDelegate
extension GroupVideoCallViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        info(string: "Join channel: \(channel)")
    }
    func rtcEngineConnectionDidInterrupted(_ engine: AgoraRtcEngineKit) {
        alert(string: "Connection Interrupted")
    }
    func rtcEngineConnectionDidLost(_ engine: AgoraRtcEngineKit) {
        alert(string: "Connection Lost")
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        alert(string: "Occur error: \(errorCode.rawValue)")
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        guard videoSessions.count <= maxVideoSession else {
            return
        }
        
        let userSession = videoSession(of: uid)
        userSession.updateInfo(resolution: size)
        agoraKit.setupRemoteVideo(userSession.canvas)
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int) {
        if let selfSession = videoSessions.first {
            selfSession.updateInfo(resolution: size)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        var indexToDelete: Int?
        for (index, session) in videoSessions.enumerated() where session.uid == uid {
            indexToDelete = index
            break
        }
        
        if let indexToDelete = indexToDelete {
            let deletedSession = videoSessions.remove(at: indexToDelete)
            deletedSession.hostingView.removeFromSuperview()
            deletedSession.canvas.view = nil
            agoraKit.setupRemoteVideo(deletedSession.canvas)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted: Bool, byUid uid: UInt) {
        setVideoMuted(muted, forUid: uid)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
        if let session = getSession(of: stats.uid) {
            session.updateVideoStats(stats)
        }
    }
    func rtcEngineLocalAudioMixingDidFinish(_ engine: AgoraRtcEngineKit) {
        isAudioMixing = false
    }
}


// MARK: - Private
private extension GroupVideoCallViewController {
    // Update views
    func updateBroadcastersView() {
        // video views layout
        if videoSessions.count == maxVideoSession {
            containerView.reload(level: 0, animated: true)
        } else {
            var rank: Int
            var row: Int
            
            if videoSessions.count == 0 {
                containerView.removeLayout(level: 0)
                return
            } else if videoSessions.count == 1 {
                rank = 1
                row = 1
            } else if videoSessions.count == 2 {
                rank = 1
                row = 2
            } else {
                rank = 2
                row = Int(ceil(Double(videoSessions.count) / Double(rank)))
            }
            
            let itemWidth = CGFloat(1.0) / CGFloat(rank)
            let itemHeight = CGFloat(1.0) / CGFloat(row)
            let itemSize = CGSize(width: itemWidth, height: itemHeight)
            let layout = AGEVideoLayout(level: 0)
                        .itemSize(.scale(itemSize))
            
            containerView
                .listCount { [unowned self] (_) -> Int in
                    return self.videoSessions.count
                }.listItem { [unowned self] (index) -> UIView in
                    return self.videoSessions[index.item].hostingView
                }
            
            containerView.setLayouts([layout], animated: true)
        }
    }
    
    func getSession(of uid: UInt) -> VideoSession? {
        for session in videoSessions {
            if session.uid == uid {
                return session
            }
        }
        return nil
    }
    
    func videoSession(of uid: UInt) -> VideoSession {
        if let fetchedSession = getSession(of: uid) {
            return fetchedSession
        } else {
            let newSession = VideoSession(uid: uid)
            videoSessions.append(newSession)
            return newSession
        }
    }
    
    func updateSelfViewVisiable() {
        guard let selfView = videoSessions.first?.hostingView else {
            return
        }
        if videoSessions.count == 2 {
            selfView.isHidden = isVideoMuted
        } else {
            selfView.isHidden = false
        }
    }
    
    func setVideoMuted(_ muted: Bool, forUid uid: UInt) {
        getSession(of: uid)?.isVideoMuted = muted
    }
    
    func setIdleTimerActive(_ active: Bool) {
        UIApplication.shared.isIdleTimerDisabled = !active
    }
    
    func info(string: String) {
        guard !string.isEmpty else {
            return
        }
    }
    
    func alert(string: String) {
        guard !string.isEmpty else {
            return
        }
    }
}

