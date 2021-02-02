//
//  LoginViewController.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/27.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        self.view.backgroundColor = .white
        
        let titleLab = UILabel()
        titleLab.text = "选择角色"
        titleLab.font = UIFont.init(name: "PingFang-SC-Medium", size: 18)
        self.view.addSubview(titleLab)
        titleLab.textAlignment = .center
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100)
        }
        
        let firstRoleView = UIButton()
        firstRoleView.backgroundColor = .init(red: 76/255.0, green: 129/255.0, blue: 233/255.0, alpha: 1)
        firstRoleView.layer.masksToBounds = true;
        firstRoleView.layer.cornerRadius = 10;
        self.view.addSubview(firstRoleView)
        firstRoleView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(firstRoleView.snp.width).multipliedBy(90/200.0)
        }
        firstRoleView.addTarget(self, action: #selector(firstGotoChat), for: .touchUpInside)
        
        let rightRow = UIImageView()
        rightRow.image = UIImage(named: "icon_more_3")
        firstRoleView.addSubview(rightRow)
        rightRow.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-5)
        }
        
        let tipOne = UILabel()
        tipOne.text = "我是ABC"
        tipOne.font = UIFont.init(name: "PingFang-SC-Medium", size: 16)
        tipOne.textColor = UIColor.white
        firstRoleView.addSubview(tipOne)
        tipOne.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(15)
        }
        
        let tipTwo = UILabel()
        tipTwo.text = "我有xxx,以这个身份登录"
        tipTwo.textColor = .init(red: 1, green: 1, blue: 1, alpha: 0.3)
        tipTwo.font = UIFont.systemFont(ofSize: 14)
        firstRoleView.addSubview(tipTwo)
        tipTwo.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(tipOne.snp.bottom).offset(10)
        }
        
        let bottomView = UIView()
        bottomView.backgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.3)
        bottomView.layer.masksToBounds = true;
        bottomView.layer.cornerRadius = 5;
        firstRoleView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(40)
            make.height.equalTo(5)
        }
        
        do {
            let secondRoleView = UIButton()
            secondRoleView.backgroundColor = .init(red: 76/255.0, green: 129/255.0, blue: 233/255.0, alpha: 1)
            secondRoleView.layer.masksToBounds = true;
            secondRoleView.layer.cornerRadius = 10
            self.view.addSubview(secondRoleView)
            secondRoleView.addTarget(self, action: #selector(secondGotoChat), for: .touchUpInside)
            
            secondRoleView.snp.makeConstraints { (make) in
                make.top.equalTo(firstRoleView.snp.bottom).offset(10)
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalTo(secondRoleView.snp.width).multipliedBy(90/200.0)
            }
            
            let rightRow = UIImageView()
            rightRow.image = UIImage(named: "icon_more_3")
            secondRoleView.addSubview(rightRow)
            rightRow.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-5)
            }
            
            let tipOne = UILabel()
            tipOne.text = "我是XYZ"
            tipOne.font = UIFont.init(name: "PingFang-SC-Medium", size: 16)
            tipOne.textColor = UIColor.white
            secondRoleView.addSubview(tipOne)
            tipOne.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(20)
                make.left.equalToSuperview().offset(15)
            }
            
            let tipTwo = UILabel()
            tipTwo.text = "我有qqq,以这个身份登录"
            tipTwo.textColor = .init(red: 1, green: 1, blue: 1, alpha: 0.3)
            tipTwo.font = UIFont.systemFont(ofSize: 14)
            secondRoleView.addSubview(tipTwo)
            tipTwo.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(15)
                make.top.equalTo(tipOne.snp.bottom).offset(10)
            }
            
            let bottomView = UIView()
            bottomView.backgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.3)
            bottomView.layer.masksToBounds = true;
            bottomView.layer.cornerRadius = 5;
            secondRoleView.addSubview(bottomView)
            bottomView.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-20)
                make.left.equalToSuperview().offset(15)
                make.width.equalTo(40)
                make.height.equalTo(5)
            }
        }
        
    }
    
    
    @objc func secondGotoChat() {
        SwiftLinphone.shared.loginIn(account: .XYZ)
        UIApplication.shared.keyWindow?.rootViewController = CFBaseTabBarController()
    }
    
    @objc func firstGotoChat() {
        SwiftLinphone.shared.loginIn(account: .ABC)
        UIApplication.shared.keyWindow?.rootViewController = CFBaseTabBarController()
    }

}
