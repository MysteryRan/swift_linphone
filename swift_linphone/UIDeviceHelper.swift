//
//  UIDeviceHelper.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/25.
//

import Foundation
import UIKit

extension UIDevice {
    public static let ScreenWidth = UIScreen.main.bounds.width
    public static let ScreenHeight = UIScreen.main.bounds.height
    
    public static let navigationHeight: CGFloat = UIDevice.isiPhoneXSierra ? 88 : 64
    
    public static let tabbarHeight: CGFloat = UIDevice.isiPhoneXSierra ? 83 : 49
    
    public static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    public static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    public static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        var identifier = String()
        #if targetEnvironment(simulator)
            identifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
            identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        #endif
        
        return identifier
    }
    
    public static var isiPhoneXSierra: Bool {
        if let window = UIApplication.shared.keyWindow {
            if #available(iOS 11.0, *) {
                return window.safeAreaInsets.bottom > 0
            } else {
                return false
            }
        } else {
            switch modelName {
            case "iPhone10,3":
                return true
            case "iPhone10,6":
                return true
            case "iPhone11,8":
                return true
            case "iPhone11,2":
                return true
            case "iPhone11,6":
                return true
            case "iPhone11,4":
                return true
            case "iPhone12,1":
                return true
            case "iPhone12,3":
                return true
            case "iPhone12,5":
                return true
            case "iPhone13,1":
                return true
            case "iPhone13,2":
                return true
            case "iPhone13,3":
                return true
            case "iPhone13,4":
                return true
            default:
                return false
            }
        }
    }
    
    
}
