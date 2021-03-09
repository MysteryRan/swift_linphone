//
//  CFBaseNavigationController.swift
//  coffee
//
//  Created by zouran on 2020/11/13.
//

import UIKit

class CFBaseNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
//    var cutomerBackAction: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        interactivePopGestureRecognizer?.delegate = self
//        self.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "bg"), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.color("#262626");
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.color("#262626")];
        self.navigationBar.shadowImage = UIImage();
        self.navigationBar.setBackgroundImage(UIImage(named: "navigationbar_bg_white"), for: UIBarMetrics.default);
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)], for: .normal)
        self.navigationBar.shadowImage = UIImage();
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            let backButton = UIButton(type: .custom)
            backButton.frame.size = CGSize(width: 26, height: 45)
            backButton.setImage(UIImage.init(named: "back_icon"), for: .normal)
            backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: true)
    }

}

// MARK:UIGestureRecognizerDelegate
extension CFBaseNavigationController {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return children.count > 1
    }
}

extension CFBaseNavigationController {
    @objc func back() {
//        if cutomerBackAction == nil {
            popViewController(animated: true)
//        } else {
//            self.cutomerBackAction?()
//        }
        
    }
}

