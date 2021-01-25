//
//  ViewController.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/19.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var sipmanager = SwiftLinphone.shared2
    
    let chatBar = UIView(frame: CGRect(x: 0, y: UIDevice.screenHeight - 100 - 20, width: UIDevice.screenWidth, height: 44))
    let chatTextView = ChatTextView(frame: CGRect(x: 40, y: 0, width: UIDevice.screenWidth - 136, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        initializeObserve()
        
       
    }
    
    func initializeObserve() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: ViewController.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: ViewController.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: ViewController.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: ViewController.keyboardDidHideNotification, object: nil)
    }
    
    func setupUI() {
        // 底部工具条
        // 输入文字
        chatBar.addSubview(chatTextView)
        
        chatBar.backgroundColor = .red
        self.view.addSubview(chatBar)
        
        // 发送按钮
        let sendButton = UIButton()
        sendButton.backgroundColor = .orange
        sendButton.frame = CGRect(x: UIDevice.screenWidth - 44, y: 0, width: 44, height: 44)
        chatBar.addSubview(sendButton)
    }
    
    @objc func handleKeyboard(notification: NSNotification) {
        print(notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey])
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            let cg: CGRect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            self.chatBar.frame.origin.y = UIScreen.main.bounds.height - cg.height - 44
            if cg.origin.y == UIDevice.screenHeight {
                self.chatBar.frame.origin.y = UIDevice.screenHeight - 44 - 20
            }
        }
        
//        print(UIDevice.isiPhoneXSierra)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func chatClick(_ sender: UIButton) {
//        SwiftLinphone.shared2.openCamera()
        self.performSegue(withIdentifier: "chat", sender: nil)
    }
    
    @IBAction func sipCallClick(_ sender: UIButton) {
//        sipmanager.sipCall(to: "10010")
        sipmanager.joinMessageRoom()
    }
}



