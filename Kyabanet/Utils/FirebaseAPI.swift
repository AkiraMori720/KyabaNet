
import Foundation
import Firebase
import FirebaseDatabase
import FirebaseFirestore

class FirebaseAPI {
    
    static let ref = Database.database().reference()
    
    static let VIDEO_CALL = "video_call"
    static let VOICE_CALL = "voice_call"
    static let USERNAME = "username"
    
    
     //MARK: - Set Add, Change, Remove for Video call branch
    static func setVideoCallAddListener(_ roomId: String, handler:@escaping (_ msg: String)->()) -> UInt {
        return ref.child(VIDEO_CALL).child(roomId).observe(.childAdded) { (snapshot, error) in

            let childref = snapshot.value as? String
            //print(childref)
            if let childRef = childref {
                handler(childRef)
            }
        }
    }
    
    static func setVideoCallChangeListener(_ roomId: String, handler:@escaping (_ msg: Int)->()) -> UInt {
        return ref.child(VIDEO_CALL).child(roomId).observe(.childChanged) { (snapshot, error) in

            if let childref = snapshot.value as? Int{
                handler(childref)
            }
        }
    }
    
    static func setVideoCallRemoveListener(_ roomId: String, handler:@escaping (_ msg: String)->()) -> UInt {
        return ref.child(VIDEO_CALL).child(roomId).observe(.childRemoved) { (snapshot, error) in

            if let childref = snapshot.value as? String{
                handler(childref)
            }
        }
    }
    
    //MARK: - Set username branch
    static func setUsername(_ username:String,completion: @escaping (_ status: Bool, _ message: String) -> ()) {
        ref.child(USERNAME).child(AuthUser.userId()).setValue(username) { (error, dataRef) in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                print(dataRef)
                let totalPath: String = "\(dataRef)"
                completion(true, totalPath)
            }
        }
    }
    
   static func setUsernameListener( handler:@escaping (_ msg: [Any]?)->()) -> UInt {
    return ref.child(USERNAME).observe(.value) { (snapshot, error) in
           let childref = snapshot.value as? NSDictionary
           //print(childref)
           if let childref = childref {
                handler(childref.allValues)
           }
       }
   }
    
    static func removeUsername() {
        ref.child(USERNAME).child(AuthUser.userId()).removeValue()
    }
    
    //MARK: - Set Add, Change, Remove for Voice call branch
    static func setVoiceCallChangeListener(_ roomId: String, handler:@escaping (_ msg: Int)->()) -> UInt {
        return ref.child(VOICE_CALL).child(roomId).observe(.childChanged) { (snapshot, error) in

            if let childref = snapshot.value as? Int{
                handler(childref)
            }
        }
    }
    
    static func setVoiceCallRemoveListener(_ roomId: String, handler:@escaping (_ msg: String)->()) -> UInt {
        return ref.child(VOICE_CALL).child(roomId).observe(.childRemoved) { (snapshot, error) in

            if let childref = snapshot.value as? String{
                handler(childref)
            }
        }
    }
    
    static func setVoiceCallListener(_ roomId: String, handler:@escaping (_ msg: String)->()) -> UInt {
        return ref.child(VOICE_CALL).child(roomId).observe(.childAdded) { (snapshot, error) in

            let childref = snapshot.value as? String
            if let childRef = childref {
                handler(childRef)
            }
        }
    }
    
    static func removeVideoCallListnerObserver(_ roomId: String, _ handle : UInt) {
        ref.child(VIDEO_CALL).child(roomId).removeObserver(withHandle: handle)
    }
    
    static func removeVideoCallRemoveListnerObserver(_ roomId: String, _ handle : UInt) {
        ref.child(VIDEO_CALL).child(roomId).removeObserver(withHandle: handle)
    }
    
    static func removeVoiceCallListnerObserver(_ roomId: String, _ handle : UInt) {
        ref.child(VOICE_CALL).child(roomId).removeObserver(withHandle: handle)
    }
    
    static func removeVoiceCallRemoveListnerObserver(_ roomId: String, _ handle : UInt) {
        ref.child(VOICE_CALL).child(roomId).removeObserver(withHandle: handle)
    }
    
    static func removeUsernameListnerObserver(_ handle : UInt) {
        ref.child(USERNAME).removeObserver(withHandle: handle)
    }
    
    // MARK: - send Statusmodel
    static func sendVoiceCallStatus(_ voiceCallStatus:[String:Any], _ roomId: String, completion: @escaping (_ status: Bool, _ message: String) -> ()) {
        ref.child(VOICE_CALL).child(roomId).setValue(voiceCallStatus) { (error, dataRef) in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                print(dataRef)
                let totalPath: String = "\(dataRef)"
                completion(true, totalPath)
            }
        }
    }
    
    static func sendVideoCallStatus(_ videoCallStatus:[String:Any], _ roomId: String, completion: @escaping (_ status: Bool, _ message: String) -> ()) {
        ref.child(VIDEO_CALL).child(roomId).setValue(videoCallStatus) { (error, dataRef) in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                print(dataRef)
                let totalPath: String = "\(dataRef)"
                completion(true, totalPath)
            }
        }
    }
}

class StatusModel {
    
    var receiver: String = ""
    var status:Status = .null
    init() {
        self.receiver = ""
        self.status = .null
    }

    init(receiver: String, status: Status) {
        self.receiver = receiver
        self.status = status
    }
}

enum Status: Int {
    case outgoing = 1
    case incoming = 2
    case end = 3
    case accept = 4
    case reject = 5
    case null = 6
}
