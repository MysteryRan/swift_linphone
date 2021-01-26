//
//  SwiftLinphone.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/20.
//

import UIKit
import linphonesw
import AVFoundation
import os.log
import CallKit

/*
 自己的账号 cotcot
 对方的账号 peche5
 */

class SwiftLinphone {
    
    var backgroundTaskID: UIBackgroundTaskIdentifier?
    var lc: Core!
    var proxy_cfg: ProxyConfig!
    var call: Call!
    var mIterateTimer: Timer?
    var coreManager = LinphoneCoreManager()
    var logManager = LinphoneLoggingServiceManager()
    var callManager = LinphoneCallManager()
    
    var chatRoomManager: ChatRoom!
    var chatroomDelegate = LinphoneChatRoomManager()
    
    var from: Address?
    
//    typealias StatusCall = (_ status: RegistrationState) -> ()
    
    var statusCallBack: (() -> ())?
    
    // 登录sip服务器状态监听
    var registStatusCallBack: ((_ registatus: RegistrationState) -> ())?
    
    // 拨打sip电话状态监听
    var sipStatusCallBack: ((_ sipstatus: Call.State) -> ())?
    
    // 接收文本信息监听
    var textMsgStatusCallBack: ((_ msg: ChatMessage) -> ())?
    
    var localView: UIView? {
        didSet {
            if let show = localView {
                SwiftLinphone.shared.lc.nativeVideoWindowId = UnsafeMutableRawPointer(Unmanaged.passRetained(localView!).toOpaque())
            }
        }
    }
    
    var remoteView: UIView? {
        didSet {
            if let show = remoteView {
                SwiftLinphone.shared.lc.nativePreviewWindowId = UnsafeMutableRawPointer(Unmanaged.passRetained(remoteView!).toOpaque())
            }
        }
    }
    
    public static let shared = { () -> SwiftLinphone in
        return SwiftLinphone()
    }()
    
    func sipInit() {
        let factory = Factory.Instance
        do {
            // 初始化linphone core
            lc = try Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
            // 允许修改sip状态(用来语音转视频)
            lc.enableSipUpdate = 1
            // 创建本地视频的宽高约束
            let videoSize = try Factory.Instance.createVideoDefinition(width: 120, height: 120)
            lc.preferredVideoDefinition = videoSize
            // 视频的帧率
            lc.preferredFramerate = 10
            
            /* 是否默认视频通话
            let videoPlicy = try Factory.Instance.createVideoActivationPolicy()
            videoPlicy.automaticallyAccept = true
            videoPlicy.automaticallyInitiate = true
            lc.videoActivationPolicy = videoPlicy
            */
            
            lc.addDelegate(delegate: coreManager)
            
            try! lc.start()
            
            // 可以进行文本聊天
            joinMessageRoom()
            
            /*用户信息配置*/
            proxy_cfg = try self.lc.createProxyConfig()
            var info: AuthInfo?
            from = try factory.createAddress(addr: "sip:cotcot@sip.linphone.org")
            info = try factory.createAuthInfo(username: from!.username, userid: "", passwd: "cotcot", ha1: "", realm: "", domain: "")
            
            self.lc!.addAuthInfo(info: info!)
            
            // 默认视频接收状态
            if let videoPlicy = lc.videoActivationPolicy {
//                videoPlicy.automaticallyAccept = true
//                videoPlicy.automaticallyInitiate = true
//                lc.videoActivationPolicy = videoPlicy
            }
            
            // 预览本地视频
//            lc.videoPreviewEnabled = true
            // 视频采集
//            lc.videoCaptureEnabled = true
            
            // 配置连接代理
            try proxy_cfg.setIdentityaddress(newValue: from!)
            let server_addr = from!.domain
            try proxy_cfg.setServeraddr(newValue: server_addr)
            proxy_cfg.registerEnabled = true

            try lc.addProxyConfig(config: proxy_cfg!)
            lc.defaultProxyConfig = proxy_cfg

            // 接收消息(视频)
            receiveTime()
            // 开启定时器 保证linphone后台一直运行
            startIterateTimer()
            
//            statusCallBack(.None)
            
        } catch {
            print(error)
        }
    }
    
    private init() { }
    
    private func receiveTime() {
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: AVAudioSession.CategoryOptions(rawValue: AVAudioSession.CategoryOptions.allowBluetooth.rawValue | AVAudioSession.CategoryOptions.allowBluetoothA2DP.rawValue))
        try! AVAudioSession.sharedInstance().setPreferredSampleRate(48000.0)
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            if let incomingCall = lc.currentCall {
                if incomingCall.dir == .Incoming {
                    self.call = lc.currentCall
                    incomingCall.addDelegate(delegate:  callManager)
                    try! incomingCall.accept()
                    timer.invalidate();
                    

                    lc.activateAudioSession(actived: true)
                }

            }
        }
    }
    
    private func startIterateTimer() {
        if (self.mIterateTimer?.isValid ?? false) {
            return
        }
        if (self.lc == nil) {
            return
        }
        self.mIterateTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.iterate), userInfo: nil, repeats: true)
    }
    
    @objc func iterate() {
        if self.lc == nil {
            return
        }
//        DispatchQueue.global().async {
//              // Request the task assertion and save the ID.
//            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "Finish Network Tasks") {
//                 // End the task if time expires.
//                 UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
//                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
//              }
                    
              // Send the data synchronously.
            self.lc.iterate()
                    
              // End the task assertion.
//            UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
//            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
//        }
        
    }
    
    private func stopIterateTimer() {
        if let timer = SwiftLinphone().mIterateTimer {
            print("stop iterate timer")
            timer.invalidate()
        }
    }
    
    func getChatList() -> [ChatMessage] {
        let evss = chatRoomManager.getHistoryMessageEvents(nbEvents: 0)
        return evss.compactMap { $0.chatMessage }
    }
    
    func joinMessageRoom() {
        do {
            let toUser = try Factory.Instance.createAddress(addr: "sip:peche5@sip.linphone.org")
            chatRoomManager = lc.getChatRoom(addr: toUser)
            chatRoomManager.addDelegate(delegate: chatroomDelegate)
            let evs = chatRoomManager.getHistoryEvents(nbEvents: 0)
            //标记已读
//            chatRoomManager.markAsRead()
//            for i in evs {
//                print(i.chatMessage?.textContent)
//                print(i.creationTime)
//                print(i.participantAddress?.username)
//                print(i.type)
//            }
            let evss = chatRoomManager.getHistoryMessageEvents(nbEvents: 0)
            for i in evss {
//                print(i.chatMessage?.textContent)
//                print(i.chatMessage?.time)
//                print(i.chatMessage?.state)
//                print(i.participantAddress?.username)
//                print(i.type)
            }
            
//            print(evs,evss)
        } catch {
            print(error)
        }
    }
    
    func sendMessage(msg: String) {
        do {
            let chatmessage = try chatRoomManager.createMessage(message: msg)
            chatRoomManager.sendChatMessage(msg: chatmessage)
        } catch {
            
        }
    }
    
    
    func stopCall() {
        stopIterateTimer()
        if (SwiftLinphone().call != nil && SwiftLinphone().call!.state != Call.State.End){
            /* terminate the call */
            print("Terminating the call...\n")
            do {
                try SwiftLinphone().call?.terminate()
            } catch {
                print(error)
            }
        }
            
        lc.removeDelegate(delegate: coreManager)
        lc.stop()
    }
    
    func sipCall(to sipUrl: String) {
//        SwiftLinphone().call = SwiftLinphone.lc.invite(url: "sip:1009@fs.53kf.com:6660")
//        call = lc.invite(url: "sip:1009@fs.53kf.com:6669")
//        if (call == nil) {
//            print("Could not place call to")
//        } else {
//            print("Call to is in progress...")
//        }
        do {
//            lc.invite(url: "sip:1008@fs.53kf.com:6669")
            let param = try lc.createCallParams(call: nil)
            param.videoEnabled = true
            param.audioEnabled = true
           
            if #available(iOS 12.0, *) {
//                call = lc.inviteWithParams(url: "sip:1008@fs.53kf.com:6669", params: param)
                call = lc.inviteWithParams(url: "sip:peche5@sip.linphone.org", params: param)
            } else {
//                call = lc.inviteWithParams(url: "sip:1009@fs.53kf.com:6669", params: param)
            }
            
            if (call == nil) {
                print("Could not place call to")
            } else {
                print("Call to is in progress...")
            }
        } catch {
            print("call error")
        }
    }
    
    func openCamera() {
        
//        lc.micEnabled = !lc.micEnabled
//        do {
//            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
//
//            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
//        } catch {
//
//        }
        
        
        if let myCall = lc.currentCall {
            do {
                if let params = myCall.params {
                    params.videoEnabled = true
                    try myCall.update(params: params)
                }
            } catch {
                print(error)
            }
        } else {
            print("error")
        }
    }
    

    
    func sipReceiveCall() {
        if let incomingCall = lc.currentCall {
            if incomingCall.dir == .Incoming {
                try! incomingCall.accept()
                lc.activateAudioSession(actived: true)
            }
        }
    }
    
    func requestBgTaskTime() {
        DispatchQueue.global().async {
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "Finish Network Tasks") {
                 UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
              }
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
    }
    
    deinit {
        print("释放")
    }
}

class LinphoneCallManager: CallDelegate {
    override func onStateChanged(call: Call, cstate: Call.State, message: String) {
        print(cstate)
    }
}

class LinphoneChatRoomManager: ChatRoomDelegate {
    override func onStateChanged(cr: ChatRoom, newState: ChatRoom.State) {
        print("chat room")
    }
    
    override func onMessageReceived(cr: ChatRoom, msg: ChatMessage) {
        SwiftLinphone.shared.textMsgStatusCallBack?(msg)
    }
    
    override func onChatMessageSent(cr: ChatRoom, eventLog: EventLog) {
        
    }
    
    override func onParticipantAdded(cr: ChatRoom, eventLog: EventLog) {
        
    }
    
    
}

class LinphoneLoggingServiceManager: LoggingServiceDelegate {
    override func onLogMessageWritten(logService: LoggingService, domain: String, lev: LogLevel, message: String) {
        if lev.rawValue >= 4 {
            print("Logging service log: \(message)\n")
        }
    }
}


class LinphoneCoreManager: CoreDelegate {
    var registStatus: RegistrationState = .None
    
    var addCallBack: ((_ num1: Int) -> ())?

    override func onRegistrationStateChanged(lc: Core, cfg: ProxyConfig, cstate: RegistrationState, message: String?) {
//        print("New registration state \(cstate) for user id \( String(describing: cfg.identityAddress?.asString()))\n")
//        print(cstate)
//        print(message!)
//        SwiftLinphone.shared.statusCallBack(cstate)
//        registStatus = cstate
//        addCallBack?(cstate.rawValue)
        SwiftLinphone.shared.registStatusCallBack?(cstate)
        
    }
    
    override func onCallLogUpdated(lc: Core, newcl: CallLog) {
        
    }
    
    override func onCallStatsUpdated(lc: Core, call: Call, stats: CallStats) {
    }
    
    override func onCallStateChanged(lc: Core, call: Call, cstate: Call.State, message: String) {
        SwiftLinphone.shared.sipStatusCallBack?(cstate)
        
        switch cstate {
        case .Idle:
            print("初始化")
        case .IncomingReceived:
            print("来电")
        case .OutgoingRinging:
            print("It is now ringing remotely !\n")
        case .OutgoingEarlyMedia:
            print("Receiving some early media\n")
        case .Connected:
            print("We are connected !\n")
        case .StreamsRunning:
            print("Media streams established !\n")
        case .End:
            print("Call is terminated.\n")
        case .Error:
            print("Call failure !")
        case .Referred:
            print("拒绝")
        case .UpdatedByRemote:
                do {
                    if let params = call.remoteParams {
//                        print(params.videoEnabled)
                        
                        try call.acceptUpdate(params: params)
                    }
                } catch {
                    print(error)
                }
        case .Updating:
            print("自己修改了")
        default:
            print("Unhandled notification \(cstate)\n")
        }
    }
}
