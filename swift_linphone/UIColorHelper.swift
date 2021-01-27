//
//  AppConfiguration.swift
//  CheYiXing
//
//  Created by rainedAllNight on 2017/12/26.
//  Copyright © 2017年 luowei. All rights reserved.
//

import UIKit

extension UIColor {

    /**
     将16进制的RGB或ARGB转换成UIColor对象
     
     - parameter hex: #AARRGGBB 或 #RRGGBB 或 AARRGGBB 或 RRGGBB
     
     - returns: UIColor对象
     */
    public static func color(_ hex: String) -> (UIColor) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        guard cString.count == 6 || cString.count == 8 else {
            return UIColor.white
        }
        
        var aString = "1"
        var rString = "0"
        var gString = "0"
        var bString = "0"
        
        if cString.count == 6 {
            rString = (cString as NSString).substring(to: 2)
            gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
            bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        } else {
            aString = (cString as NSString).substring(to: 2)
            rString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
            gString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
            bString = ((cString as NSString).substring(from: 6) as NSString).substring(to: 2)
        }
        
        var a:CUnsignedInt = 0, r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0
        Scanner(string: aString).scanHexInt32(&a)
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a))
    }
    
    public convenience init(hex: String) {
        let color = UIColor.color(hex)
        self.init(cgColor: color.cgColor)
    }
}
