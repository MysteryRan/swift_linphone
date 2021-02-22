//
//  AppDelegate.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/19.
//

import UIKit
import PushKit
import CallKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate {

    var request: UNNotificationRequest?
    
    var bgTaskId: UIBackgroundTaskIdentifier?
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        
        SwiftLinphone.shared.sipInit()
        SwiftLinphone.shared.requestBgTaskTime()
        
        setRootViewController()
        
        return true
    }
    
    // MARK:设置根视图控制器
    func setRootViewController() {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        let rootVC = LoginViewController()
//        let rootVC = CFBaseTabBarController()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        
//        let topInset: CGFloat = UIDevice.isiPhoneXSierra ? 40 : 25
//        UIApplication.shared.keyWindow?.addSubview(InComingView(frame: CGRect(x: 0, y: 0, width: UIDevice.screenWidth, height: (UIDevice.screenWidth - 20) / 5.0 * 2.0)))
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SwiftLinphone.shared.enterBackground()
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        var deviceTokenString = String()
        let bytes = [UInt8](pushCredentials.token)
        for item in bytes {
            deviceTokenString += String(format:"%02x", item&0x000000FF)
        }
       print("deviceToken：\(deviceTokenString)")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        self.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type)
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        guard type == .voIP else {
            print("Not VoIP")
            return
        }
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.body = "11111"
        content.sound = nil
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        request = UNNotificationRequest(identifier: "voip", content: content, trigger: trigger)
        center.add(request!) { (error) in
            
        }
        
        print("VoIP\(payload.dictionaryPayload)")
//        if let uuidString = payload.dictionaryPayload["UUID"] as? String,
//        let handle = payload.dictionaryPayload["handle"] as? String,
//        let hasVideo = payload.dictionaryPayload["hasVideo"] as? Bool,
//        let uuid = UUID(uuidString: uuidString){
//            if #available(iOS 10.0, *) {
//                ProviderDelegate.shared.reportIncomingCall(uuid: UUID(), handle: "handle", hasVideo: true, completion: { (error) in
//                    if let e = error {
//                        print("Error \(e)")
//                    }
//                })
//            } else {
//                // Fallback on earlier versions
//            }
//        }
        
    }

}

