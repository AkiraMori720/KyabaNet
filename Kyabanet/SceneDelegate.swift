//
//  SceneDelegate.swift
//  Life
//
//  Created by Yun Li on 2020/6/24.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import OneSignal
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        LocationManager.start()
        MediaManager.cleanupExpired()
        
        //NotificationCenter.default.post(name: Notification.Name(NotificationStatus.NOTIFICATION_APP_STARTED), object: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Persons.update(lastActive: Date().timestamp())
            Persons.update(oneSignalId: PrefsManager.getFCMToken())
        }
        
        let osNotificationOpenedBlock: OSNotificationOpenedBlock = { result in
            if let additionalData = result.notification.additionalData {
                print("additionalData: ", additionalData)
                //print(additionalData["postId"] as! String)
                guard let chatId = additionalData["chatId"] as? String else{
                    return
                }
                guard let recipientId = additionalData["recipientId"] as? String else{
                    return
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let vc =  storyboard.instantiateViewController(identifier: "chatViewController") as! ChatViewController
                vc.setParticipant(chatId: chatId, recipientId: recipientId)
                vc.modalPresentationStyle = .fullScreen
                vc.hidesBottomBarWhenPushed = true
                guard let tabBarController = self.window?.rootViewController as? UITabBarController else{
                    return
                }
                guard let navController = tabBarController.selectedViewController as? UINavigationController else {
                    return
                    
                }
                navController.pushViewController(vc, animated: true)
                
            }
        }
        OneSignal.setNotificationOpenedHandler(osNotificationOpenedBlock)

        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        LocationManager.stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Persons.update(lastTerminate: Date().timestamp())
        }
        
    }


}

