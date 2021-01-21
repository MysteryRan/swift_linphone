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

class SwiftLinphone: NSObject {
    
    static var lc: Core!
    static var proxy_cfg: ProxyConfig!
    var call: Call!
    var mIterateTimer: Timer?
    static var coreManager = LinphoneCoreManager()
    static var logManager = LinphoneLoggingServiceManager()
    static var callManager = LinphoneCallManager()
    
    public static let shared2 = { () -> SwiftLinphone in
        // 初始化一些其他的东西
        let factory = Factory.Instance
        do {
//            LoggingService.Instance.addDelegate(delegate: logManager)
//            LoggingService.Instance.logLevel = LogLevel.Debug
//            Factory.Instance.enableLogCollection(state: LogCollectionState.Enabled)
            
            lc = try Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
            lc.addDelegate(delegate: coreManager)
            try! lc.start()
            
            /*create proxy config*/
            proxy_cfg = try SwiftLinphone.lc.createProxyConfig()
            /*parse identity*/
//            let from = try factory.createAddress(addr: "sip:1008@fs.53kf.com:6669")
//            let info = try factory.createAuthInfo(username: from.username, userid: "", passwd: "54321", ha1: "", realm: "", domain: "") /*create authentication structure from identity*/
            var from: Address?
            var info: AuthInfo?
            if #available(iOS 12.0, *) {
                from = try factory.createAddress(addr: "sip:1009@fs.53kf.com:6669")
                info = try factory.createAuthInfo(username: from!.username, userid: "", passwd: "54321", ha1: "", realm: "", domain: "") /*create authentication structure from identity*/
            } else {
                from = try factory.createAddress(addr: "sip:1008@fs.53kf.com:6669")
                info = try factory.createAuthInfo(username: from!.username, userid: "", passwd: "54321", ha1: "", realm: "", domain: "") /*create authentication structure from identity*/
            }
            
            SwiftLinphone.lc!.addAuthInfo(info: info!) /*add authentication info to LinphoneCore*/

            // configure proxy entries
            try proxy_cfg.setIdentityaddress(newValue: from!) /*set identity with user name and domain*/
            let server_addr = from!.domain + ":6669" /*extract domain address from identity*/
//            let server_addr = from?.domain
            try proxy_cfg.setServeraddr(newValue: server_addr) /* we assume domain = proxy server address*/
            proxy_cfg.registerEnabled = true /*activate registration for this proxy config*/

            try lc.addProxyConfig(config: proxy_cfg!) /*add proxy config to linphone core*/
            lc.defaultProxyConfig = proxy_cfg /*set to default proxy*/

            if #available(iOS 12.0, *) {
                receiveTime()
            }
            /* main loop for receiving notifications and doing background linphonecore work: */
            startIterateTimer()
            
        } catch {
            print(error)
        }
        return SwiftLinphone()
    }()
    
    private override init() { }
    
    private static func receiveTime() {
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: AVAudioSession.CategoryOptions(rawValue: AVAudioSession.CategoryOptions.allowBluetooth.rawValue | AVAudioSession.CategoryOptions.allowBluetoothA2DP.rawValue))
        try! AVAudioSession.sharedInstance().setPreferredSampleRate(48000.0)
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if let incomingCall = lc.currentCall {
                if incomingCall.dir == .Incoming {
                    incomingCall.addDelegate(delegate:  callManager)
                    try! incomingCall.accept()
                    timer.invalidate();

                    lc.activateAudioSession(actived: true)
                }

            }
        }
    }
    
    private static func startIterateTimer() {
        if (SwiftLinphone().mIterateTimer?.isValid ?? false) {
            print("Iterate timer is already started, skipping ...")
            return
        }
        SwiftLinphone().mIterateTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.iterate), userInfo: nil, repeats: true)
    }
    
    @objc static func iterate() {
        SwiftLinphone.lc.iterate()
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
            
        SwiftLinphone.lc.removeDelegate(delegate: SwiftLinphone.coreManager)
        SwiftLinphone.lc.stop()
    }
    
    func sipCall(to sipUrl: String) {
//        SwiftLinphone().call = SwiftLinphone.lc.invite(url: "sip:1009@fs.53kf.com:6660")
        SwiftLinphone().call = SwiftLinphone.lc.invite(url: "sip:1008@fs.53kf.com:6669")
        if (SwiftLinphone().call == nil) {
            print("Could not place call to")
        } else {
            print("Call to is in progress...")
        }
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
//        print(message!)
    }
    
    override func onCallLogUpdated(lc: Core, newcl: CallLog) {
        
    }
    
    override func onCallStatsUpdated(lc: Core, call: Call, stats: CallStats) {
//        print(call)
//        print(stats)
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
        default:
            print("Unhandled notification \(cstate)\n")
        }
    }
}
