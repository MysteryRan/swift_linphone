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

enum UserAccount {
    case ABC
    case XYZ
}

class SwiftLinphone {
    
    var backgroundTaskID: UIBackgroundTaskIdentifier?
    var lc: Core!
    var proxy_cfg: ProxyConfig!
    var call: Call!
    var mIterateTimer: Timer?
    var coreManager = LinphoneCoreManager()
    var logManager = LinphoneLoggingServiceManager()
    var callManager = LinphoneCallManager()
    
    var sipChatRoom: ChatRoom?
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
    
    // 正在输入信息监听
    var writingCallBack: ((_ composing: Bool) -> ())?
    
    var globalMsgCallBack: ((_ msg: ChatMessage) -> ())?
    
    public static let shared = { () -> SwiftLinphone in
        return SwiftLinphone()
    }()
    
    func sipInit() {
        do {
            // 初始化linphone core
            lc = try Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
//            Core.setLogCollectionPath(path: Factory.Instance.getDownloadDir(context: UnsafeMutablePointer<Int8>(mutating: (Config.appGroupName as NSString).utf8String)))
            let dataPath: NSString = Factory.Instance.getDataDir(context: nil) as NSString
//            "linphone_chats.db"
            lc.callLogsDatabasePath = dataPath.appendingPathComponent("linphone_chats.db")
            // 允许修改sip状态(用来语音转视频)
            lc.enableSipUpdate = 1
            // 创建本地视频的宽高约束
            let videoSize = try Factory.Instance.createVideoDefinition(width: 120, height: 120)
            lc.preferredVideoDefinition = videoSize
            // 视频的帧率
            lc.preferredFramerate = 10
            
//            lc.conferenceServerEnabled = true
//            lc.conferenceLocalInputVolume
            
//            print(lc.videoDevicesList)
//            print(lc.videoDevice)
            
//            lc.setVideodevice(newValue: "")
//            call.update(params: <#T##CallParams?#>)
//            lc.currentCall?.pause()
//            lc.currentCall?.resume()
//            lc.leaveConference()
            
            // 是否默认接听视频通话
            let videoPlicy = try Factory.Instance.createVideoActivationPolicy()
            videoPlicy.automaticallyAccept = true
            videoPlicy.automaticallyInitiate = true
            lc.videoActivationPolicy = videoPlicy
            
            
            
            
            try! lc.start()
            

            
        } catch {
            print(error)
        }
    }
    
    func createMeeting(address: Address? = nil) {
        // 预览本地视频
        lc.videoPreviewEnabled = true
        // 视频采集
        lc.videoCaptureEnabled = true
        
        do {
            print("join meeting ")
            let first = try Factory.Instance.createAddress(addr: "sip:wizard15@sip.linphone.org")
//            let joinMeeting = try Factory.Instance.createAddress(addr: "sip:testios@sip.linphone.org")
//            let param = try lc.createCallParams(call: nil)
//            print(lc.conference)
            
//            lc.createConferenceWithParams(params: <#T##ConferenceParams#>)
            
//            try lc.conference?.inviteParticipants(addresses: [joinMeeting], params: param)
            
            let conParam = try lc.createConferenceParams()
            conParam.videoEnabled = true
            conParam.localParticipantEnabled = true
            let callParam = try lc.createCallParams(call: nil)
            callParam.audioEnabled = true
            callParam.videoEnabled = true
            let conference = try lc.createConferenceWithParams(params: conParam)
            
            try conference.inviteParticipants(addresses: [first], params: callParam)
            
            let callView = CallChatView(frame: CGRect(x: 0, y: 0, width: UIDevice.screenWidth, height: UIDevice.screenHeight))
//            callView.currentCall = call
            UIApplication.shared.keyWindow?.addSubview(callView)
            
        } catch {
            print(error)
        }
    }
    
    func loginIn(account: UserAccount) {
        
        do {
            /*用户信息配置*/
            proxy_cfg = try self.lc.createProxyConfig()
            var info: AuthInfo?
            
            if account == .ABC {
                from = try Factory.Instance.createAddress(addr: "sip:wizard15@sip.linphone.org")
                info = try Factory.Instance.createAuthInfo(username: from!.username, userid: "", passwd: "wizard15", ha1: "", realm: "", domain: "")
            } else {
                from = try Factory.Instance.createAddress(addr: "sip:kenyrim@sip.linphone.org")
                info = try Factory.Instance.createAuthInfo(username: from!.username, userid: "", passwd: "wsadwsad", ha1: "", realm: "", domain: "")
            }
                
            self.lc!.addAuthInfo(info: info!)
            
            // 默认视频接收状态
            if let videoPlicy = lc.videoActivationPolicy {
//                videoPlicy.automaticallyAccept = true
//                videoPlicy.automaticallyInitiate = true
//                lc.videoActivationPolicy = videoPlicy
            }
            // 配置连接代理
            try proxy_cfg.setIdentityaddress(newValue: from!)
            let server_addr = from!.domain
            try proxy_cfg.setServeraddr(newValue: server_addr)
            proxy_cfg.registerEnabled = true

            try lc.addProxyConfig(config: proxy_cfg!)
            lc.defaultProxyConfig = proxy_cfg
            
            lc.addDelegate(delegate: coreManager)
            
//            print(lc.authInfoList)
        } catch {
            print(error)
        }
        
        // 可以进行文本聊天
        joinMessageRoom()
        // 接收消息(视频)
        receiveTime()
        // 开启定时器 保证linphone后台一直运行
        startIterateTimer()
    }
    
    private init() { }
    
    private func receiveTime() {
//        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: AVAudioSession.CategoryOptions(rawValue: AVAudioSession.CategoryOptions.allowBluetooth.rawValue | AVAudioSession.CategoryOptions.allowBluetoothA2DP.rawValue))
//        try! AVAudioSession.sharedInstance().setPreferredSampleRate(48000.0)
//        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
//            if let incomingCall = lc.currentCall {
//                if incomingCall.dir == .Incoming {
//
//
////                    try! incomingCall.accept()
//                    timer.invalidate();
////
////
////                    lc.activateAudioSession(actived: true)
//                }
//
//            }
//        }
    }
    
    func comingCallShowView() {
        let callView = CallChatView(frame: CGRect(x: 0, y: 0, width: UIDevice.screenWidth, height: UIDevice.screenHeight))
        callView.currentCall = lc.currentCall
        UIApplication.shared.keyWindow?.addSubview(callView)
        if let incomingCall = lc.currentCall {
            if incomingCall.dir == .Incoming {
                incomingCall.addDelegate(delegate:  callManager)
            }
        }
    }
    
    func recordingFilePathFromCall(address: String) -> String {
        var filePath = "recording_"
        filePath = filePath.appending(address.isEmpty ? "unknow" : address)
        let now = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "E-d-MMM-yyyy-HH-mm-ss"
        let date = dateFormat.string(from: now)
        
        filePath = filePath.appending("_\(date).mkv")
        
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        var writablePath = paths[0]
        writablePath = writablePath.appending("/\(filePath)")
        return writablePath
    }
    
    func sipCallRecording() {
        if let myCall = lc.currentCall {
            if myCall.state == .StreamsRunning {
                myCall.startRecording()
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
    
    
    func AudioChat() -> Bool {
        do {
            let param = try lc.createCallParams(call: nil)
            param.videoEnabled = false
            param.audioEnabled = true
            call = lc.inviteWithParams(url: "sip:peche5@sip.linphone.org", params: param)
            if (call == nil) {
                print("Could not place call to")
                return false
            } else {
                print("Call to is in progress...")
                return true
            }
        } catch {
            print("call error")
            return false
        }
    }
    
    func VideoChat(remoteAddress: Address) -> Bool {
        // 预览本地视频
        lc.videoPreviewEnabled = true
        // 视频采集
        lc.videoCaptureEnabled = true
        do {
            let param = try lc.createCallParams(call: nil)
            param.videoEnabled = true
            param.audioEnabled = true
//            call = lc.inviteWithParams(url: "sip:peche5@sip.linphone.org", params: param) kenyrim
//            call = lc.inviteWithParams(url: "sip:kenyrim@sip.linphone.org", params: param)
            call = lc.inviteAddressWithParams(addr: remoteAddress, params: param)
            let callView = CallChatView(frame: CGRect(x: 0, y: 0, width: UIDevice.screenWidth, height: UIDevice.screenHeight))
            callView.currentCall = call
            UIApplication.shared.keyWindow?.addSubview(callView)
            if (call == nil) {
                print("Could not place call to")
                return false
            } else {
                print("Call to is in progress...")
                return true
            }
        } catch {
            print("call error")
            return false
        }
    }
    
    func enterBackground() {
        lc.enterBackground()
    }
    
//    func getChatList() -> [ChatMessage] {
//        let evss = chatRoomManager.getHistoryMessageEvents(nbEvents: 0)
//        return evss.compactMap { $0.chatMessage }
//    }
    
    func deleteChooseChatRoom(chatroom: ChatRoom) {
        if lc == nil {
            return
        }
        lc.deleteChatRoom(cr: chatroom)
    }
    
    func textChatList() -> [ChatRoom] {
        if lc == nil {
            return [ChatRoom]()
        }
//        for i in lc.chatRooms {
//            lc.deleteChatRoom(cr: i)
//        }
        return lc.chatRooms
    }
    
    func messageRead(address: Address) {
        sipChatRoom = lc.getChatRoom(addr: address)
        sipChatRoom?.markAsRead()
    }
    
    // 拒绝
    func sipDeclineCall() {
        if let incomingCall = lc.currentCall {
            if incomingCall.dir == .Incoming {
                do {
                    try incomingCall.decline(reason: .Declined)
                } catch  {
                    print(error)
                }
            }
        }
    }
    
    // 结束
    func sipTerminateCall() {
        if let incomingCall = lc.currentCall {
//            if incomingCall.dir == .Incoming {
                do {
                    try incomingCall.terminate()
                } catch  {
                    print(error)
                }
//            }
        }
    }
    
    func getCallLogs() -> [CallMessage] {
        
        var thisCallLogs = [CallMessage]()
        
//        lc.findCallLogFromCallId(callId: "ss") getCallHistory()
        
//        decline terminate
        
        var names = [String]()
        
        var callLogsDic = [String:CallMessage]()
        
        for i in lc.callLogs {
            
            if i.status != .EarlyAborted {
                if i.localAddress?.username == lc.defaultProxyConfig?.identityAddress?.username {
                    if let friend = i.remoteAddress {
                        let callMessage = CallMessage()
                        if !names.contains(friend.username) {
                            names.append(friend.username)
                            callMessage.callLog = i
                            callMessage.callCount = 1
                            callLogsDic[friend.username] = callMessage
                        } else {
                            let insideCallLog = callLogsDic[friend.username]
                            insideCallLog!.callCount = insideCallLog!.callCount + 1
                        }
                    }
                }
//                print(i.startDate,i.dir,i.callId)
            }
        }
        
        for i in callLogsDic.values {
            thisCallLogs.append(i)
            print(i)
        }
        return thisCallLogs
    }
    
    
    func ListenMessageRoom(address: Address) {
//        do {
//            let toUser = try Factory.Instance.createAddress(addr: "sip:peche5@sip.linphone.org")
            sipChatRoom = lc.getChatRoom(addr: address)
            sipChatRoom!.addDelegate(delegate: chatroomDelegate)
        
        
//        } catch {
//            print(error)
//        }
    }
    
    func joinMessageRoom() {
        do {
            let toUser = try Factory.Instance.createAddress(addr: "sip:peche5@sip.linphone.org")
            if let chatRoomManager = lc.getChatRoom(addr: toUser) {
                chatRoomManager.addDelegate(delegate: chatroomDelegate)
            }
        } catch {
            print(error)
        }
        
//        do {
//            let toUser = try Factory.Instance.createAddress(addr: "sip:peche5@sip.linphone.org")
//            chatRoomManager = lc.getChatRoom(addr: toUser)
//            chatRoomManager.addDelegate(delegate: chatroomDelegate)
//            let evs = chatRoomManager.getHistoryEvents(nbEvents: 0)
//            //标记已读
////            chatRoomManager.markAsRead()
////            for i in evs {
////                print(i.chatMessage?.textContent)
////                print(i.creationTime)
////                print(i.participantAddress?.username)
////                print(i.type)
////            }
//            let evss = chatRoomManager.getHistoryMessageEvents(nbEvents: 0)
//            for i in evss {
////                print(i.chatMessage?.textContent)
////                print(i.chatMessage?.time)
////                print(i.chatMessage?.state)
////                print(i.participantAddress?.username)
////                print(i.type)
//            }
//
////            print(lc.callLogs)
////            print(lc.callLogsDatabasePath)
//
//
////            print(lc.getCallHistoryForAddress(addr: toUser))
//
////            print(lc.chatRooms)
//            for i in lc.chatRooms {
//                print(i.me?.address?.username)
//                 print(i.lastUpdateTime)
//                print(i.lastMessageInHistory?.textContent)
//                for j in i.participants {
////                    lastMessageInHistory
//                    print(j.address?.displayName,j.address?.username)
////                    print(j.userData)
//                }
//
//
//            }
//
////            print(evs,evss)
//        } catch {
//            print(error)
//        }
    }
    
    func sendMessage(msg: String) {
        do {
            if let room = sipChatRoom {
                 let chatmessage = try room.createMessage(message: msg)
                chatmessage.send()
            }
            
//            chatRoomManager.sendChatMessage(msg: chatmessage)
        } catch {
            
        }
    }
    
    func createMessage(msg: String) -> ChatMessage? {
        do {
            if let room = sipChatRoom {
                let chatmessage = try room.createMessage(message: msg)
                return chatmessage
            }
            return nil
            
        } catch {
            print(error)
            return nil
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
    
    
    func createOne2OneChat(name: String) -> ChatRoom? {
        do {
            let toName = "sip:" + name + "@sip.linphone.org"
//            let personOne = try Factory.Instance.createAddress(addr: toName)
            let personOne = try Factory.Instance.createAddress(addr: "sip:kenyrim@sip.linphone.org")
            
//            var currentChatRoom: ChatRoom?
            
            sipChatRoom = lc.getChatRoom(addr: personOne)
            if sipChatRoom != nil {
                return sipChatRoom
            }
            
            sipChatRoom = lc.findOneToOneChatRoom(localAddr: lc.defaultProxyConfig!.contact!.clone()!, participantAddr: personOne, encrypted: false)
            if sipChatRoom != nil {
                return sipChatRoom
            }
            
            let chatRoomPa =  try lc.createDefaultChatRoomParams()
            chatRoomPa.groupEnabled = true
            chatRoomPa.encryptionEnabled = false
//            let groupChatRoom = try lc.createChatRoom(params: chatRoomPa,localAddr:lc.defaultProxyConfig!.identityAddress! ,subject: "群聊", participants: [personOne])
            sipChatRoom = try lc.createChatRoom(params: chatRoomPa, subject: "123", participants: [personOne])
//            if let room = try lc.createChatRoom(params: chatRoomPa, subject: "123", participants: [personOne]) {
            if let room = sipChatRoom {
                room.addDelegate(delegate: chatroomDelegate)
            }
//            }
            return sipChatRoom
        } catch {
            print(error)
        }
        return nil
    }
    
    func createGroupTextChat() -> ChatRoom? {
        do {
            let personOne = try Factory.Instance.createAddress(addr: "sip:wizard42@sip.linphone.org")
            let personTwo = try Factory.Instance.createAddress(addr: "sip:kenyrim@sip.linphone.org")
            let chatRoomPa =  try lc.createDefaultChatRoomParams()
            chatRoomPa.groupEnabled = true
            chatRoomPa.encryptionEnabled = false
            let groupChatRoom = try lc.createChatRoom(params: chatRoomPa,localAddr:lc.defaultProxyConfig!.identityAddress! ,subject: "群聊", participants: [personOne,personTwo])
            groupChatRoom.addDelegate(delegate: chatroomDelegate)
            return groupChatRoom
        } catch {
            print(error)
        }
        return nil
    }
    
    func changeMicEnable() {
        if lc.currentCall != nil {
            lc.micEnabled = !lc.micEnabled
        }
    }
    
    func changeAudioRoute(isSpeak: Bool) {
        // 听筒
        do {
            if isSpeak {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
            } else {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            }
        } catch {
            print(error)
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
                if let callParam = incomingCall.params {
                    callParam.recordFile = recordingFilePathFromCall(address: incomingCall.remoteAddress!.username)
                }
                do {
                    try incomingCall.accept()
                    lc.activateAudioSession(actived: true)
                } catch {
                    print(error)
                }
                
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
        print("call state change ",cstate)
    }
}

class LinphoneChatRoomManager: ChatRoomDelegate {
    override func onStateChanged(cr: ChatRoom, newState: ChatRoom.State) {
        print("chat room")
    }
    
    override func onMessageReceived(cr: ChatRoom, msg: ChatMessage) {
        print(msg.state)
//        SwiftLinphone.shared.textMsgStatusCallBack?(msg)
    }
    
    override func onChatMessageSent(cr: ChatRoom, eventLog: EventLog) {
        
    }
    
    override func onChatMessageReceived(cr: ChatRoom, eventLog: EventLog) {
        if let msg = eventLog.chatMessage {
            SwiftLinphone.shared.textMsgStatusCallBack?(msg)
        }
    }
    
    override func onParticipantAdded(cr: ChatRoom, eventLog: EventLog) {
        
    }
    
    override func onConferenceJoined(cr: ChatRoom, eventLog: EventLog) {
        
    }
    
    override func onSubjectChanged(cr: ChatRoom, eventLog: EventLog) {
        
    }
    
    override func onIsComposingReceived(cr: ChatRoom, remoteAddr: Address, isComposing: Bool) {
//        print(isComposing)
        SwiftLinphone.shared.writingCallBack?(isComposing)
    }
    
    override func onParticipantAdminStatusChanged(cr: ChatRoom, eventLog: EventLog) {
        
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
    
    override func onChatRoomRead(lc: Core, room: ChatRoom) {
        
    }
    


    override func onRegistrationStateChanged(lc: Core, cfg: ProxyConfig, cstate: RegistrationState, message: String?) {
//        print("New registration state \(cstate) for user id \( String(describing: cfg.identityAddress?.asString()))\n")
//        print(cstate)
        print(message!)
//        SwiftLinphone.shared.statusCallBack(cstate)
//        registStatus = cstate
//        addCallBack?(cstate.rawValue)
        if cstate == .Ok {
            SwiftLinphone.shared.registStatusCallBack?(cstate)
        }
        
        
    }
    
    override func onChatRoomStateChanged(lc: Core, cr: ChatRoom, state: ChatRoom.State) {
        print(state,"ddddd")
    }
    
    override func onMessageReceived(lc: Core, room: ChatRoom, message: ChatMessage) {
        
        
        SwiftLinphone.shared.globalMsgCallBack?(message)
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
            if call.callLog?.toAddress?.username == lc.defaultProxyConfig?.identityAddress?.username {
                SwiftLinphone.shared.comingCallShowView()
            }
            
        case .OutgoingRinging:
            print("It is now ringing remotely !\n")
        case .OutgoingEarlyMedia:
            print("Receiving some early media\n")
        case .Connected:
            print("We are connected !\n")
        case .StreamsRunning:
            print("Media streams established !\n")
            
//            SwiftLinphone.shared.recordingFilePathFromCall(address: call.remoteAddress!.username)
            
//            SwiftLinphone.shared.sipCallRecording()
            
        case .End:
            print("Call is terminated.\n")
        case .Error:
            print("Call failure !")
        case .Referred:
            print("拒绝")
        case .UpdatedByRemote:
            print("远程修改")
//                do {
//                    if let params = call.remoteParams {
////                        print(params.videoEnabled)
//
//                        try call.acceptUpdate(params: params)
//                    }
//                } catch {
//                    print(error)
//                }
        case .Updating:
            print("自己修改了")
        default:
            print("Unhandled notification \(cstate)\n")
        }
    }
}
