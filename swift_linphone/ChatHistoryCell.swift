//
//  ChatHistoryCell.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/27.
//

import UIKit
import linphonesw

class ChatHistoryCell: UITableViewCell {

    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var friendNameLab: UILabel!
    @IBOutlet weak var lastChatLab: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //定义模型属性
    var chatHistory: ChatRoom? {
        didSet {
            if let result = chatHistory {
                timeLab.text = timeCover(time: result.lastUpdateTime)
                if let lastMessage = result.lastMessageInHistory {
                    if let from = lastMessage.fromAddress {
                        let messageFrom = from.username
                        let message = lastMessage.textContent
                        lastChatLab.text = messageFrom + ":" + message
                    }
                }
                
                for friend in result.participants {
                    friendNameLab.text = friend.address?.username ?? "unknow"
                }
            }
        }
    }
    
    func timeCover(time: time_t) -> String {
        // 文字的时间
        var formatstr: String = ""
        let todayDate = Date()
        let messageDate = Date(timeIntervalSince1970: TimeInterval(time))
        let todayComponents = Calendar.current.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: todayDate)
        let dateComponents = Calendar.current.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: messageDate)
        
        let sameYear = todayComponents.year == dateComponents.year
        let sameMonth = (sameYear && todayComponents.month == dateComponents.month)
        let sameDay =  (sameMonth && todayComponents.day == dateComponents.day)
        
        if sameDay {
            formatstr = "HH:mm"
        } else {
            formatstr = "MM/dd"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatstr
        return dateFormatter.string(from: messageDate)
    }
    
}
