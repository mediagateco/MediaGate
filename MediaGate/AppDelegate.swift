//
//  AppDelegate.swift
//  MediaGate
//
//  Created by Nouha Nouman on 11/02/2020.
//  Copyright © 2020 Nouha Nouman. All rights reserved.
//

import UIKit
import Firebase
import UserNotificationsUI
import Foundation
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate{


    var window: UIWindow?
    var restrictRotation:UIInterfaceOrientationMask = .portrait
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //From the Class
        FirebaseApp.configure()
        
        attempToRegisterForNotification(application: application)
        attempToRegisterForCamera(application: application)
        
        return true

    }
    
    func attempToRegisterForCamera(application: UIApplication) {
        AVCaptureDevice.requestAccess(for: .video) { success in
            if success {
                print("Permission granted, proceed")
            } else {
                print("Permission denied")
            }
        }
    }
    
    
    //From the Class
    func attempToRegisterForNotification(application: UIApplication) {
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) {(authorized, error) in
            if authorized {
                print("SUCCESSFULLY REGISTERED!")
            }
        }
        
        application.registerForRemoteNotifications()
    }
    
    //From the Class
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("DEBUG: Registered for notifications with device token: ", deviceToken)
    }
    
    
    //From the Class
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("REGISTERED WITH FCM TOKEN: ", fcmToken)
        UserDefaults.standard.setValue("fcmToken", forKey: fcmToken)
        if let userUid = Auth.auth().currentUser?.uid {
            print("User ID is: ", userUid)
            let deviceUid = UIDevice.current.identifierForVendor!.uuidString
            let fcmStore = ["fcmToken" : fcmToken] as [String : Any]
            Firestore.firestore().collection("Fcm").document(deviceUid).setData(fcmStore, merge: true)
        }
    }
    
    //From the class
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
           if let messageID = userInfo[gcmMessageIDKey] {
               print("Message ID: \(messageID)")
           }
            
           // Print full message.
           print(userInfo)
       }
    
       func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
           print("Unable to register for remote notifications: \(error.localizedDescription)")
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
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.restrictRotation
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }

}

