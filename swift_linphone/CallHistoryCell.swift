//
//  CallHistoryCell.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/28.
//

import UIKit
import linphonesw

class CallHistoryCell: UITableViewCell {

    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func audioChatClick(_ sender: UIButton) {
    
    }
    
    @IBAction func videoChatClick(_ sender: UIButton) {
        if let currentCall = callMessage {
            if let currentLog = currentCall.callLog {
                SwiftLinphone.shared.createMeeting()
//                if currentLog.dir == .Incoming {
//                    if let callAddress = currentLog.fromAddress {
////                        SwiftLinphone.shared.VideoChat(remoteAddress: callAddress)
//
//                    }
//                } else {
//                    if let callAddress = currentLog.toAddress {
////                        SwiftLinphone.shared.VideoChat(remoteAddress: callAddress)
//                    }
//                }
            }
        }
    }
    
    var callMessage: CallMessage? {
        didSet {
            if let result = callMessage {
                if let log = result.callLog {
                    if let friend = log.remoteAddress {
                        nameLab.text = friend.username + "(" + "\(result.callCount)" + ")"
                    }
                    
                    if log.dir == .Outgoing {
                        statusImageView.image = UIImage(named: "call_status_outgoing")
                    } else {
                        statusImageView.image = UIImage(named: "call_status_incoming")
                    }
                }
                
            }
        }
    }
}
