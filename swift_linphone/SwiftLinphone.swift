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

class SwiftLinphone {
    
    var backgroundTaskID: UIBackgroundTaskIdentifier?
    var lc: Core!
    var proxy_cfg: ProxyConfig!
    var call: Call!
    var mIterateTimer: Timer?
    var coreManager = LinphoneCoreManager()
    var logManager = LinphoneLoggingServiceManager()
    var callManager = LinphoneCallManager()
    
    public static let shared2 = { () -> SwiftLinphone in
        return SwiftLinphone()
    }()
    
    func sipInit() {
        let factory = Factory.Instance
        do {
            
            lc = try Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
            lc.enableSipUpdate = 1
            let videoSize = try Factory.Instance.createVideoDefinition(width: 120, height: 120)
            lc.preferredVideoDefinition = videoSize
            lc.preferredFramerate = 10
//            let videoPlicy = try Factory.Instance.createVideoActivationPolicy()
//            videoPlicy.automaticallyAccept = true
//            videoPlicy.automaticallyInitiate = true
//            lc.videoActivationPolicy = videoPlicy
            lc.addDelegate(delegate: coreManager)
            try! lc.start()
            
            /*create proxy config*/
            proxy_cfg = try self.lc.createProxyConfig()
            /*parse identity*/
//            let from = try factory.createAddress(addr: "sip:1008@fs.53kf.com:6669")
//            let info = try factory.createAuthInfo(username: from.username, userid: "", passwd: "54321", ha1: "", realm: "", domain: "") /*create authentication structure from identity*/
            var from: Address?
            var info: AuthInfo?
            if #available(iOS 12.0, *) {
//                from = try factory.createAddress(addr: "sip:1009@fs.53kf.com:6669")
//                info = try factory.createAuthInfo(username: from!.username, userid: "", passwd: "54321", ha1: "", realm: "", domain: "") /*create authentication structure from identity*/
                from = try factory.createAddress(addr: "sip:cotcot@sip.linphone.org")
                info = try factory.createAuthInfo(username: from!.username, userid: "", passwd: "cotcot", ha1: "", realm: "", domain: "") /*create authentication structure from identity*/
            } else {
                from = try factory.createAddress(addr: "sip:1008@fs.53kf.com:6669")
                info = try factory.createAuthInfo(username: from!.username, userid: "", passwd: "54321", ha1: "", realm: "", domain: "") /*create authentication structure from identity*/
            }
            
            self.lc!.addAuthInfo(info: info!) /*add authentication info to LinphoneCore*/
            
            if let videoPlicy = lc.videoActivationPolicy {
//                videoPlicy.automaticallyAccept = true
//                videoPlicy.automaticallyInitiate = true
//                lc.videoActivationPolicy = videoPlicy
            }
            
//            lc.videoPreviewEnabled = true
//            lc.videoCaptureEnabled = true
            
            // configure proxy entries
            try proxy_cfg.setIdentityaddress(newValue: from!) /*set identity with user name and domain*/
            let server_addr = from!.domain + ":6669" /*extract domain address from identity*/
//            let server_addr = from?.domain
            try proxy_cfg.setServeraddr(newValue: server_addr) /* we assume domain = proxy server address*/
            proxy_cfg.registerEnabled = true /*activate registration for this proxy config*/

            try lc.addProxyConfig(config: proxy_cfg!) /*add proxy config to linphone core*/
            lc.defaultProxyConfig = proxy_cfg /*set to default proxy*/

//            if #available(iOS 12.0, *) {
                receiveTime()
//            }
            /* main loop for receiving notifications and doing background linphonecore work: */
            startIterateTimer()
            
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
            print("Iterate timer is already started, skipping ...")
            return
        }
        self.mIterateTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.iterate), userInfo: nil, repeats: true)
    }
    
    @objc func iterate() {
        if self.lc == nil {
            return
        }
        DispatchQueue.global().async {
              // Request the task assertion and save the ID.
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "Finish Network Tasks") {
                 // End the task if time expires.
                 UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
              }
                    
              // Send the data synchronously.
            self.lc.iterate()
                    
              // End the task assertion.
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
        
    }
    
    private func stopIterateTimer() {
        if let timer = SwiftLinphone().mIterateTimer {
            print("stop iterate timer")
            timer.invalidate()
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
            param.videoEnabled = false
            param.audioEnabled = true
           
            if #available(iOS 12.0, *) {
//                call = lc.inviteWithParams(url: "sip:1008@fs.53kf.com:6669", params: param)
                call = lc.inviteWithParams(url: "sip:peche5@sip.linphone.org", params: param)
            } else {
                call = lc.inviteWithParams(url: "sip:1009@fs.53kf.com:6669", params: param)
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
        
        lc.micEnabled = !lc.micEnabled
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
        } catch {
            
        }
        
        
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

class LinphoneLoggingServiceManager: LoggingServiceDelegate {
    override func onLogMessageWritten(logService: LoggingService, domain: String, lev: LogLevel, message: String) {
        if lev.rawValue >= 4 {
            print("Logging service log: \(message)\n")
        }
    }
}


class LinphoneCoreManager: CoreDelegate {
    override func onRegistrationStateChanged(lc: Core, cfg: ProxyConfig, cstate: RegistrationState, message: String?) {
//        print("New registration state \(cstate) for user id \( String(describing: cfg.identityAddress?.asString()))\n")
//        print(cstate)
        print(message!)
    }
    
    override func onCallLogUpdated(lc: Core, newcl: CallLog) {
        
    }
    
    override func onCallStatsUpdated(lc: Core, call: Call, stats: CallStats) {
    }
    
    override func onCallStateChanged(lc: Core, call: Call, cstate: Call.State, message: String) {
        switch cstate {
        case .Idle:
            print("909090")
        case .IncomingReceived:
            print("来点")
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
