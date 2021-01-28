//
//  CallChatView.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/28.
//

import UIKit
import linphonesw

class CallChatView: UIView {
    // 姓名
    let nameLab = UILabel()
    // 时间
    let timeLab = UILabel()
    // 头像
    let headerImageView = UIImageView(image: UIImage(named: "avatar"))
    // 本地
    let localView = UIView()
    // 远程
    let remoteView = UIView()
    // 控制view
    let settingView = UIView()
    
    fileprivate lazy var cameraBtn: UIButton = {
        let cameraBtn = UIButton()
        cameraBtn.setImage(UIImage(named: "camera_default"), for: .normal)
        return cameraBtn
    }()
    
    fileprivate lazy var micBtn: UIButton = {
        let micBtn = UIButton()
        micBtn.setImage(UIImage(named: "micro_default"), for: .normal)
        return micBtn
    }()
    
    fileprivate lazy var audioBtn: UIButton = {
        let audioBtn = UIButton()
        audioBtn.setImage(UIImage(named: "routes_default"), for: .normal)
        return audioBtn
    }()
    
    fileprivate lazy var settingBtn: UIButton = {
        let settingBtn = UIButton()
        settingBtn.setImage(UIImage(named: "options_default"), for: .normal)
        return settingBtn
    }()
    
    fileprivate lazy var receiveBtn: UIButton = {
        let receiveBtn = UIButton()
        receiveBtn.setBackgroundImage(UIImage(named: "color_A"), for: .normal)
        receiveBtn.setImage(UIImage(named: "call_audio_start_default"), for: .normal)
        return receiveBtn
    }()
    
    fileprivate lazy var refuseBtn: UIButton = {
        let refuseBtn = UIButton()
        refuseBtn.setBackgroundImage(UIImage(named: "color_D"), for: .normal)
        refuseBtn.setImage(UIImage(named: "call_hangup_default"), for: .normal)
        
//        call_video_start_default.png color_A.png
//        call_audio_start_default.png color_D.png
        return refuseBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.addSubview(nameLab)
        nameLab.text = "xxxxxxx"
        self.addSubview(timeLab)
        self.addSubview(headerImageView)
        
        // 本地远程摄像头
//        localView.backgroundColor = .red
        self.addSubview(localView)
//        remoteView.backgroundColor = .blue
        self.addSubview(remoteView)
        
        // 视频开关  麦克风开关  扬声器开关  设置开关
        settingView.backgroundColor = .red
        self.addSubview(settingView)
        settingView.addSubview(cameraBtn)
        settingView.addSubview(micBtn)
        settingView.addSubview(audioBtn)
        settingView.addSubview(settingBtn)
        
        settingBtn.addTarget(self, action: #selector(stopRecordClcik), for: .touchUpInside)
        
        // 接听 拒绝
        self.addSubview(receiveBtn)
        receiveBtn.addTarget(self, action: #selector(receiveClick), for: .touchUpInside)
        self.addSubview(refuseBtn)
        refuseBtn.addTarget(self, action: #selector(refuseClick), for: .touchUpInside)
        
        SwiftLinphone.shared.sipStatusCallBack = { status in
            print("heree", status)
            if status == .End {
                self.removeFromSuperview()
            }
            
            if status == .StreamsRunning {
            
            }
        }
        
        refuseBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            let t = UIDevice.screenWidth / 2.0
            make.left.equalToSuperview().offset(t)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(44)
        }
    }
    
    @objc func stopRecordClcik() {
        SwiftLinphone.shared.stopCall()
    }
    
    @objc func receiveClick() {
        SwiftLinphone.shared.sipReceiveCall()
//        self.removeFromSuperview()
        self.needsUpdateConstraints()
        self.updateConstraintsIfNeeded()
        receiveBtn.isHidden = true
        refuseBtn.snp.remakeConstraints { (make) in
            make.left.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(20)
            make.right.equalToSuperview()
        }
        
//        receiveBtn.snp.updateConstraints { (make) in
//            make.width.equalTo(0)
//        }
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func refuseClick() {
//        SwiftLinphone.shared.sipDeclineCall()
//        self.removeFromSuperview()
    }
    
    var currentCall: Call? {
        didSet {
            if let result = currentCall {
//                result.cameraEnabled remoteaddress
                if result.dir == .Outgoing {
                    if result.cameraEnabled {
                        SwiftLinphone.shared.lc.nativeVideoWindowId = UnsafeMutableRawPointer(Unmanaged.passRetained(self.localView).toOpaque())
                        SwiftLinphone.shared.lc.nativePreviewWindowId = UnsafeMutableRawPointer(Unmanaged.passRetained(self.remoteView).toOpaque())
                    }
                } else {
                    if result.cameraEnabled {
                        receiveBtn.setImage(UIImage(named: "call_video_start_default"), for: .normal)
                    }
                    
                    if let friend = result.remoteAddress {
                        nameLab.text = friend.username
                    }
                }
            }
        }
    }
    
    override func layoutSubviews() {
        nameLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40)
        }
        
        headerImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.top.equalTo(nameLab.snp.bottom).offset(40)
            make.height.equalTo(headerImageView.snp.width).multipliedBy(1)
        }
        
        receiveBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(44)
        }
        

        
        localView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(remoteView.snp.top)
            make.height.equalTo(remoteView)
        }
        
        remoteView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(localView)
        }
        
        settingView.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(receiveBtn.snp.top).offset(-20)
        }
        
        cameraBtn.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.25)
        }
        
        micBtn.snp.makeConstraints { (make) in
            make.left.equalTo(cameraBtn.snp.right)
            make.top.equalToSuperview()
            make.height.equalTo(cameraBtn)
            make.width.equalTo(cameraBtn)
        }
        
        audioBtn.snp.makeConstraints { (make) in
            make.left.equalTo(micBtn.snp.right)
            make.top.equalToSuperview()
            make.height.equalTo(cameraBtn)
            make.width.equalTo(cameraBtn)
        }
        
        settingBtn.snp.makeConstraints { (make) in
            make.left.equalTo(audioBtn.snp.right)
            make.top.equalToSuperview()
            make.height.equalTo(cameraBtn)
            make.width.equalTo(cameraBtn)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
