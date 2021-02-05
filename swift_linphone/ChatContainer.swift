//
//  ChatContainer.swift
//  swift_linphone
//
//  Created by zouran on 2021/2/3.
//

import UIKit

class ChatContainer: UIWindow {
    
    var bubbleManager = [String:ChatContainer]()
    
    var lastKeyWindow: UIWindow?
    
    var r_canAffectStatusBarAppearance: Bool = true
    
    var r_canBecomeKeyWindow: Bool = true
    
    var isMinSize = false
    
    var contentView: UIView {
        get {
            self.rootViewController!.view
        }
    }
    
    var miniSizeButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        if #available(iOS 13.0, *) {
//            self.windowScene = dg_mainWindowScene()
//        } else {
//            // Fallback on earlier versions
//        }
        
        self.windowLevel = UIWindow.Level(rawValue: 100000)
        self.rootViewController = UIViewController()
        self.clipsToBounds = true
        self.backgroundColor = .red
        
        self.frame = frame
    
        //缩小事件按钮
        miniSizeButton.isUserInteractionEnabled = true
        self.contentView.addSubview(miniSizeButton)
        miniSizeButton.backgroundColor = .blue
        miniSizeButton.frame = CGRect(x: 0, y: 100, width: 40, height: 40)
        miniSizeButton.addTarget(self, action: #selector(minSizeClick), for: .touchUpInside)
        
        //点击事件
        
        //拖拽事件
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        pan.delaysTouchesBegan = true
        self.addGestureRecognizer(pan)
        
        
    }
    
    @objc func minSizeClick(sender: UIButton) {
        isMinSize = !isMinSize
        if isMinSize {
            self.frame = CGRect(x: 0, y: 100, width: 55, height: 55)
            sender.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        } else {
            self.frame = CGRect(x: 0, y: 0, width: UIDevice.screenWidth, height: UIDevice.screenHeight)
            sender.frame = CGRect(x: 0, y: 100, width: 55, height: 55)
        }
    }
    
    @objc func handlePanGesture(p: UIPanGestureRecognizer) {
        if !isMinSize {
            return
        }
        let appWindow = UIApplication.shared.delegate?.window
        let panPoint = p.location(in: (appWindow as! UIView))
        
        if p.state == .began {
            self.alpha = 1
        } else if p.state == .changed {
            self.center = CGPoint(x: panPoint.x, y: panPoint.y)
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
            
            var minSpace: CGFloat = 0
            
            minSpace = min(left, right)
            
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
                self.center = newCenter
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(iOS 13.0, *)
    func dg_mainWindowScene() -> UIWindowScene? {
        var scene: UIWindowScene?
            for (_, c) in UIApplication.shared.connectedScenes.enumerated() {
                if c.isKind(of: UIWindowScene.self) {
                    let win = c as? UIWindowScene
                    if win?.screen == UIScreen.main {
                        scene = c as? UIWindowScene
                        return scene
                    }
                }
            }
        return nil
    }
    
    func show() {
        bubbleManager["1"] = self
        self.isHidden = false
    }
    
}
