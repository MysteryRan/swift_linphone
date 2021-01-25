//
//  ChatViewController.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/21.
//

import UIKit

class ChatViewController: UIViewController {
    
    var sipmanager = SwiftLinphone.shared

    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var remoteView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        sipmanager.sipInit()
        
//        let ptr3 = withUnsafeMutablePointer(to: &localView) { UnsafeMutableRawPointer($0)//将泛型类指针转换成非泛型类指针
//        }
//        let ptr4 = withUnsafeMutablePointer(to: &remoteView) { UnsafeMutableRawPointer($0)//将泛型类指针转换成非泛型类指针
//        }
        
        SwiftLinphone.shared.lc.nativeVideoWindowId = UnsafeMutableRawPointer(Unmanaged.passRetained(self.localView).toOpaque())
        SwiftLinphone.shared.lc.nativePreviewWindowId = UnsafeMutableRawPointer(Unmanaged.passRetained(self.remoteView).toOpaque())
        
    }
    
    @IBAction func sipCall(_ sender: UIButton) {
        sipmanager.sipCall(to: "10010")
    }
    
    @IBAction func openSipCamera(_ sender: UIButton) {
//        print(SwiftLinphone.shared2.lc.videoDisplayEnabled)
//        do {
//            let params = try SwiftLinphone.shared2.lc.createCallParams(call: SwiftLinphone.shared2.lc.currentCall)
//            params.videoEnabled = true
//            try SwiftLinphone.shared2.lc.currentCall?.update(params: params)
//        } catch {
//            print("error")
//        }
        sipmanager.openCamera()
        
        
    }
}
