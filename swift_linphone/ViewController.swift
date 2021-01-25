//
//  ViewController.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/19.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    @IBAction func chatClick(_ sender: UIButton) {
        self.performSegue(withIdentifier: "chat", sender: nil)
    }
    
    @IBAction func sipCallClick(_ sender: UIButton) {
        SwiftLinphone.shared2.sipCall(to: "10010")
    }
}



