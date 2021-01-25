//
//  ChatTextView.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/25.
//

import UIKit

class ChatTextView: UITextView {
    
    var overrideNextResponder: UIResponder?
    
    override var next: UIResponder? {
        get {
            if overrideNextResponder == nil {
                return super.next
            } else {
                return overrideNextResponder
            }
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if overrideNextResponder != nil {
            return false
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    

}
