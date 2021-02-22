//
//  CFBaseTabBarController.swift
//  coffee
//
//  Created by zouran on 2020/11/13.
//

import UIKit

class CFBaseTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //设置tabbar的文字属性
        setUpTabbarItemTextArrtibutes()
        
        //添加子控制器
        setUpChildController(vc: CFBaseNavigationController(rootViewController: TextChatViewController()), title: "文本", image: UIImage.init(named: "order_unselected")!, selectedImage: UIImage.init(named: "order_selected")!)
        setUpChildController(vc: CFBaseNavigationController(rootViewController: FaceTimeController()), title: "通话", image: UIImage.init(named: "me_unselected")!, selectedImage: UIImage.init(named: "me_selected")!)
        setUpChildController(vc: CFBaseNavigationController(rootViewController: FriendViewController()), title: "通话", image: UIImage.init(named: "me_unselected")!, selectedImage: UIImage.init(named: "me_selected")!)
        setUpChildController(vc: CFBaseNavigationController(rootViewController: FuncViewController()), title: "功能", image: UIImage.init(named: "me_unselected")!, selectedImage: UIImage.init(named: "me_selected")!)
    }
}

// MARK:设置tabbar
extension CFBaseTabBarController {
    // MARK:设置item的文字属性
    fileprivate func setUpTabbarItemTextArrtibutes() {
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            let normal = appearance.stackedLayoutAppearance.normal
            normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.color("#666666")]
            
            let selected = appearance.stackedLayoutAppearance.selected
            selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.color("#cca77e")]
//            appearance.shadowColor = .white
            
//            appearance.shadowImage = UIImage()
            appearance.backgroundImage = UIImage(named: "navigationbar_bg_white")
            
            
            self.tabBar.standardAppearance = appearance
        } else {
            let item = UITabBarItem.appearance()
            //普通状态下
            var normalAttrs = [NSAttributedString.Key : Any]()
            self.tabBar.isTranslucent = false

            normalAttrs[NSAttributedString.Key.foregroundColor] = UIColor.color("#666666")
            item.setTitleTextAttributes(normalAttrs, for: .normal)
            //选中状态下的文字
            var selectAttrs = [NSAttributedString.Key : Any]()
            selectAttrs[NSAttributedString.Key.foregroundColor] = UIColor.color("#cca77e")
            item.setTitleTextAttributes(selectAttrs, for: .selected)
            
            self.tabBar.backgroundColor = .white
            self.tabBar.backgroundImage = UIImage(named: "navigationbar_bg_white")
//            self.tabBar.shadowImage = UIImage()
        }
    }
    
    // MARK:初始化子控制器
    fileprivate func setUpChildController(vc: UIViewController, title: String, image: UIImage, selectedImage: UIImage) {
        vc.tabBarItem.title = title
        vc.tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
        vc.tabBarItem.selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
        addChild(vc)
    }
}
