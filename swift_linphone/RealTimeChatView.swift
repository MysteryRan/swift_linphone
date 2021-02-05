//
//  RealTimeChatView.swift
//  swift_linphone
//
//  Created by zouran on 2021/2/3.
//

import UIKit

enum UserAccountTest {
    case ABC
    case XYZ
}

protocol ClickToFinishDelegate: class {
    func aa()
}



class RealTimeChatView: UIView {
    
    weak var delegate: ClickToFinishDelegate?

    var leanType: UserAccountTest?
    
    var containerWindow: ChatContainer?
    
    init(frame: CGRect, color: UIColor, delegate: ClickToFinishDelegate) {
        super.init(frame: frame)
        
        self.delegate = delegate
        self.isUserInteractionEnabled = true
        self.backgroundColor = color
        self.alpha = 0.7
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.red.cgColor
        self.clipsToBounds = true
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        pan.delaysTouchesBegan = true
        self.addGestureRecognizer(pan)
        
    }
    
    func show(vc: UIViewController) {
        let backWindow = ChatContainer(frame: self.frame)
//        let tabar: UITabBarController = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
//        print(tabar.selectedViewController)
//        backWindow.rootViewController = vc
        self.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.layer.cornerRadius = 10
        
//        backWindow.rootViewController?.view.addSubview(self)
        backWindow.isHidden = false
    }
    
    @objc func handlePanGesture(p: UIPanGestureRecognizer) {
        let appWindow = UIApplication.shared.delegate?.window
        let panPoint = p.location(in: appWindow as! UIView)
        
        if p.state == .began {
            self.alpha = 1
        } else if p.state == .changed {
            self.containerWindow?.center = CGPoint(x: panPoint.x, y: panPoint.y)
        } else if (p.state == .ended || p.state == .cancelled) {
            self.alpha = 0.7
            
            let ballWidth = self.frame.size.width
            let ballHeight = self.frame.size.height
            let screenWidth = UIDevice.screenWidth
            let screentHeight = UIDevice.screenHeight
            
            let left: CGFloat = fabs(panPoint.x)
            let right = fabs(screenWidth - left)
            let top = fabs(panPoint.y)
            let bottom = fabs(screentHeight - top)
            
            let minSpace: CGFloat = 0
            
            var newCenter = CGPoint.zero
            var targetY: CGFloat = 0
            
            if panPoint.y < 15 + ballHeight / 2.0 {
                targetY = 15 + ballHeight / 2.0
            } else if panPoint.y > (screentHeight - ballHeight / 2.0 - 15) {
                targetY = screentHeight - ballHeight / 2.0 - 15
            } else {
                targetY = panPoint.y
            }
            
            let centerXSpace = (0.5 - 8 / 55.0) * ballWidth
            let centerYSpace = (0.5 - 8 / 55.0) * ballHeight
            
            if minSpace == left {
                newCenter = CGPoint(x: centerXSpace, y: targetY)
            } else if minSpace == right {
                newCenter = CGPoint(x: screenWidth - centerXSpace, y: targetY)
            } else if minSpace == top {
                newCenter = CGPoint(x: panPoint.x, y: centerYSpace)
            } else {
                newCenter = CGPoint(x: panPoint.x, y: screentHeight - centerYSpace)
            }
            
            UIView.animate(withDuration: 0.25) {
                self.containerWindow?.center = newCenter
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func defaultChatViewWithDelegate(delegate: ClickToFinishDelegate) -> RealTimeChatView {
        let sus = RealTimeChatView(frame: CGRect(x: 8, y: 100, width: 55, height: 55), color: .red, delegate: delegate)
        return sus
    }
    
    static func suggestXWithWidth(width: CGFloat) -> CGFloat {
        return (-width * (8 / 55.0))
    }
}
