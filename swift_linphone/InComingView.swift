//
//  InComingView.swift
//  swift_linphone
//
//  Created by zouran on 2021/2/2.
//

import UIKit

class InComingView: UIView {
    
    let blackBg = UIView()
    let titleLab = UILabel()
    let subTitle = UILabel()
    let headerImage = UIImageView(image: UIImage(named: "avatar"))
    fileprivate lazy var acceptButton: UIButton = {
        let acceptButton = UIButton()
        acceptButton.backgroundColor = UIColor.init(red: 249/255.0, green: 32/255.0, blue: 38/255.0, alpha: 1)
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.layer.masksToBounds = true;
        acceptButton.layer.cornerRadius = 10;
        return acceptButton
    }()
    fileprivate lazy var declineButton: UIButton = {
        let declineButton = UIButton()
        declineButton.backgroundColor = UIColor.init(red: 51/255.0, green: 152/255.0, blue: 254/255.0, alpha: 1)
        declineButton.setTitle("Decline", for: .normal)
        declineButton.layer.masksToBounds = true;
        declineButton.layer.cornerRadius = 10;
        return declineButton
    }()
    
    let centerImageView = UIImageView(image: UIImage(named: "avatar"))
    fileprivate lazy var termainButton: UIButton = {
        let termainButton = UIButton()
        termainButton.backgroundColor = UIColor.init(red: 249/255.0, green: 32/255.0, blue: 38/255.0, alpha: 1)
        termainButton.setTitle("Ter", for: .normal)
        termainButton.layer.masksToBounds = true;
        termainButton.layer.cornerRadius = 30;
        return termainButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        blackBg.backgroundColor = UIColor.init(red: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1)
        self.addSubview(blackBg)
        blackBg.layer.masksToBounds = true;
        blackBg.layer.cornerRadius = 10;
        let topInset: CGFloat = UIDevice.isiPhoneXSierra ? 35 : 15
        blackBg.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(topInset)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().inset(10)
        }
        
        titleLab.text = "Medrith"
        titleLab.textColor = .white
        subTitle.text = "InComing call"
        subTitle.textColor = UIColor(red: 129/255.0, green: 129/255.0, blue: 129/255.0, alpha: 1)

        acceptButton.addTarget(self, action: #selector(acceptButtonClick), for: .touchUpInside)
        
        blackBg.addSubview(titleLab)
        blackBg.addSubview(subTitle)
        blackBg.addSubview(headerImage)
        blackBg.addSubview(acceptButton)
        blackBg.addSubview(declineButton)
        
        titleLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(20)
        }
        
        subTitle.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(5)
        }
        
        headerImage.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(60)
        }
        
        declineButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(40)
            make.width.equalTo(acceptButton)
        }
        
        acceptButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(10)
            make.width.equalTo(declineButton)
            make.left.equalTo(declineButton.snp.right).offset(15)
            make.height.equalTo(40)
        }
        
        self.addSubview(self.centerImageView)
        self.addSubview(self.termainButton)
        termainButton.addTarget(self, action: #selector(termainButtonClick), for: .touchUpInside)
        
        centerImageView.isHidden = true
        termainButton.isHidden = true
        
        self.centerImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(60)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        self.termainButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
    }
    
    @objc func termainButtonClick(sender: UIButton) {
        self.centerImageView.isHidden = true
        UIView.animate(withDuration: 0.45) {
            self.frame = CGRect(x: 0, y: 0, width: UIDevice.screenWidth, height: 0)
        } completion: { (animated) in
            self.removeFromSuperview()
        }
    }
    
    @objc func acceptButtonClick(sender: UIButton) {
        self.backgroundColor = .black
        blackBg.isHidden = true
    
        UIView.animate(withDuration: 0.45) {
            self.frame = CGRect(x: 0, y: 0, width: UIDevice.screenWidth, height: UIDevice.screenHeight)
        } completion: { (animated) in
            self.centerImageView.isHidden = false
            self.termainButton.isHidden = false
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
