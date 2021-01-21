//
//  ViewController.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/19.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var request: UNNotificationRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let linphone = SwiftLinphone.shared2
       
    }
    
    @IBAction func sipCallClick(_ sender: UIButton) {
        SwiftLinphone.shared2.sipCall(to: "10010")
    }
}



