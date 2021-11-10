//
//  AppDelegate.swift
//  Life
//
//  Created by Yun Li on 2020/6/24.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import RealmSwift
import OneSignal
import Sinch
import FittedSheets

//-------------------------------------------------------------------------------------------------------------------------------------------------
var realm = try! Realm()
let falsepredicate = NSPredicate(value: false)
//-------------------------------------------------------------------------------------------------------------------------------------------------

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var client: SINClient?
    var push: SINManagedPush?
    var callKitProvider: CallKitProvider?
    let gcmMessageIDKey = "gcm.message_id"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
       
        
        let configuration = Realm.Configuration(
            schemaVersion: 11,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 11 {
                    // if you added a new property or removed a property you don't
                    // have to do anything because Realm automatically detects that
                }
            }
        )
        Realm.Configuration.defaultConfiguration = configuration
        realm = try! Realm()
         
    //-----------------------------------------------------------------------------------------------------------------------------------------
        // SyncEngine initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        SyncEngine.initBackend()
        SyncEngine.initUpdaters()
        SyncEngine.initObservers()
        //-----------------------------------------------------------------------------------------------------------------------------------------
        // Push notification initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        let authorizationOptions: UNAuthorizationOptions = [.sound, .alert, .badge]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authorizationOptions, completionHandler: { granted, error in
            if (error == nil) {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    //UIApplication.shared.regis
                }
            }
        })
        //-----------------------------------------------------------------------------------------------------------------------------------------
        // OneSignal initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        /*OneSignal.initWithLaunchOptions(launchOptions, appId: ONESIGNAL.ONESIGNAL_APPID, handleNotificationReceived: nil,
                                        handleNotificationAction: nil, settings: [kOSSettingsKeyAutoPrompt: false])*/
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId(ONESIGNAL.ONESIGNAL_APPID)
        OneSignal.setLogLevel(ONE_S_LOG_LEVEL.LL_NONE, visualLevel: ONE_S_LOG_LEVEL.LL_NONE)
        
        
        
       // OneSignal.inFocusDisplayType = OSNotificationDisplayType.none
        //-----------------------------------------------------------------------------------------------------------------------------------------
        // Manager initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        _ = ChatManager.shared
        _ = Connectivity.shared
        _ = LocationManager.shared
        
        //-----------------------------------------------------------------------------------------------------------------------------------------
        // MediaUploader initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        _ = MediaUploader.shared
        
        //-----------------------------------------------------------------------------------------------------------------------------------------
        // Sinch initialization
        //-----------------------------------------------------------------------------------------------------------------------------------------
        push = Sinch.managedPush(with: .development)
        push?.delegate = self
        push?.setDesiredPushType(SINPushTypeVoIP)

        callKitProvider = CallKitProvider()
        
        NotificationCenter.default.addObserver(self, selector: #selector(sinchLogInUser), name: NSNotification.Name(rawValue: NotificationStatus.NOTIFICATION_APP_STARTED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sinchLogInUser), name: NSNotification.Name(rawValue: NotificationStatus.NOTIFICATION_USER_LOGGED_IN), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sinchLogOutUser), name: NSNotification.Name(rawValue: NotificationStatus.NOTIFICATION_USER_LOGGED_OUT), object: nil)
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //let firebaseAuth = Auth.auth()
        // print("device token: \(deviceToken.toHexString())")
        //firebaseAuth.setAPNSToken(deviceToken, type: .sandbox)
        //firebaseAuth.setAPNSToken(deviceToken, type: .prod)
        //firebaseAuth.setAPNSToken(deviceToken, type: .unknown)
        /*DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        }*/
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let firebaseAuth = Auth.auth()
        if (firebaseAuth.canHandleNotification(userInfo)){
            print(userInfo)
            return
        }
        //print("did not")
        completionHandler(.newData)
        //let state = UIApplication.shared.applicationState
        //if(state == .background){
            
        //}else if(state == .inactive){
        //    completionHandler(.newData)
        //}
        
    }
 
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Sinch user methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func sinchLogInUser() {

        let userId = AuthUser.userId()

        if (userId == "")    { return }
        if (client != nil)    { return }

        client = Sinch.client(withApplicationKey: SINCHINFO.SINCH_KEY, applicationSecret: SINCHINFO.SINCH_SECRET, environmentHost: SINCHINFO.SINCH_HOST, userId: userId)
        client?.delegate = self
        client?.call().delegate = self
        client?.setSupportCalling(true)
        client?.enableManagedPushNotifications()
        callKitProvider?.setClient(client)
        client?.start()
        client?.startListeningOnActiveConnection()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func sinchLogOutUser() {

        client?.terminateGracefully()
        client = nil
    }

}
// MARK: - SINClientDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension AppDelegate: SINClientDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func clientDidStart(_ client: SINClient!) {
        // print("Sinch client started successfully \(client.userId)")
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func clientDidFail(_ client: SINClient!, error: Error!) {
        // print("Sinch client error: \(error.localizedDescription)")
    }
}

// MARK: - SINCallClientDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension AppDelegate: SINCallClientDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func client(_ client: SINCallClient!, willReceiveIncomingCall call: SINCall!) {
        // print("Sinch client willReceiveIncomingCall \(call.callId)")
        callKitProvider?.insertCall(call: call)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        // print("Sinch client didReceiveIncomingCall \(call.callId)")
        callKitProvider?.insertCall(call: call)

        callKitProvider?.reportNewIncomingCall(call: call)
    }
}

// MARK: - SINManagedPushDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension AppDelegate: SINManagedPushDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable: Any]!, forType pushType: String!) {

        callKitProvider?.didReceivePush(withPayload: payload)

        DispatchQueue.main.async {
            self.sinchLogInUser()
            self.client?.relayRemotePushNotification(payload)
            self.push?.didCompleteProcessingPushPayload(payload)
        }
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    var localizedJA: String{
        let language = "ja"
        let path = Bundle.main.path(forResource: language, ofType: "lproj")!
        let bundle = Bundle(path: path)!
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
    

}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }
        // [END_EXCLUDE]
        // Print full message.
        print(userInfo)

        let aps = userInfo["aps"] as? [AnyHashable : Any]
        let alertMessage = aps!["alert"] as? [AnyHashable : Any]
        _  = alertMessage!["body"] as! String
        
        let userId = userInfo["userId"] as? String
        let chatId = userInfo["chatId"] as? String
        if let noti_type = userInfo["noti_type"] as? String{
            switch noti_type {
            case "0":
                // display alert for notification
                let vc = AppBoards.friend.viewController(withIdentifier: "AcceptDeclineViewController") as! AcceptDeclineViewController
                vc.userId = userId ?? ""
        
                let sheetController = SheetViewController(controller: vc, sizes: [.fixed(360), .fixed(360)])
                UIApplication.shared.windows.first?.rootViewController?.present(sheetController, animated: true, completion: nil)
                
                if #available(iOS 14.0, *) {
                    completionHandler([[.banner, .badge, .sound]])
                } else {
                    // Fallback on earlier versions
                    completionHandler([[.badge, .sound]])
                }
            
            default:
                if #available(iOS 14.0, *) {
                    completionHandler([[.banner, .badge, .sound]])
                } else {
                    // Fallback on earlier versions
                    completionHandler([[.badge, .sound]])
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }
        // [END_EXCLUDE]
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print full message.
        print(userInfo)
        
        let aps = userInfo["aps"] as? [AnyHashable : Any]
        let alertMessage = aps!["alert"] as? [AnyHashable : Any]
        _  = alertMessage!["body"] as! String
        
        let userId = userInfo["userId"] as? String
        let chatId = userInfo["chatId"] as? String
        if let noti_type = userInfo["noti_type"] as? String{
            switch noti_type {
            case "0":
                // display alert for notification
                let home = AppBoards.main.initialViewController
                let vc = AppBoards.friend.viewController(withIdentifier: "AcceptDeclineViewController") as! AcceptDeclineViewController
                vc.userId = userId ?? ""
        
                vc.modalPresentationStyle = .fullScreen
                let window = UIApplication.shared.keyWindow
                window?.rootViewController = home
                window?.makeKeyAndVisible()
                home.present(vc, animated: false, completion: nil)
            
            default:
                let home = AppBoards.main.initialViewController
                let vc = AppBoards.main.viewController(withIdentifier: "chatViewController") as! ChatViewController
                vc.recipientId = userId ?? ""
                vc.chatId = chatId ?? ""
                vc.fromNoti = true
                vc.modalPresentationStyle = .fullScreen
                let window = UIApplication.shared.keyWindow
                window?.rootViewController = home
                window?.makeKeyAndVisible()
                home.present(vc, animated: false, completion: nil)
            }
        }
        
        
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict:[String: String] = ["token": fcmToken ?? ""]

        NotificationCenter.default.post(name: .gotNewFCMToken, object: nil, userInfo: dataDict)
        
        Persons.update(oneSignalId: fcmToken ?? "")
        
        PrefsManager.setFCMToken(val: fcmToken ?? "")
    }
    
    func messaging(messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("TOKEN: ", fcmToken)
    }
    // [END refresh_token]
}

enum AppBoards: String {
    
    case login   = "Login"
    case main    = "Main"
    case group   = "Group"
    case friend  = "Friend"
    case setting = "Setting"
    case zedpay  = "ZedPay"
    
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }
    
    var initialViewController: UIViewController {
        return self.instance.instantiateInitialViewController()!
    }

    func viewController(withIdentifier identifier: String) -> UIViewController {
        return instance.instantiateViewController(withIdentifier: identifier)
    }
}

enum NotiType: Int {
    case friendRequest = 0
    case sendText = 1
    case sendImage = 2
    case sendPhoto = 3
    case sendMoney = 4
    case sendVideoCalling = 5
    case sendVoiceCalling = 6
}


