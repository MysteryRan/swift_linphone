//
//  ChatTableViewCell.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/26.
//

import UIKit
import linphonesw
import SnapKit

let CELL_IMAGE_X_MARGIN = 100
let CELL_MIN_HEIGHT = 65.0
let CELL_MIN_WIDTH = 190.0
let CELL_MESSAGE_X_MARGIN = 68 + 10.0
let CELL_MESSAGE_Y_MARGIN = 44

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageStatusIcon: UIImageView!
    @IBOutlet weak var messageTimeLab: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var textContentLab: UILabel!
    
    
    static var totalHeight: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //定义模型属性
    var message: ChatMessage? {
        didSet {
            if let result = message {
//                print(result)
                // 发出
                
//                var origin_x = 0
//                let availabel_width = self.frame.size.width
//                let bubbleFrame = ChatTableViewCell.ViewHeightForMessageText(chat: result, width: Int(availabel_width))
//                origin_x = result.isOutgoing ? Int(self.frame.size.width - bubbleFrame.width) : 0
                if result.isOutgoing {
                    headerImageView.isHidden = true
                    messageStatusIcon.isHidden = false
                    messageTimeLab.textAlignment = .right
                } else {
                    headerImageView.isHidden = false
                    messageStatusIcon.isHidden = true
                    messageTimeLab.textAlignment = .left
                }
                
                
                
                
//                print(bubbleFrame)
                self.messageTimeLab.text = ChatTableViewCell.timeCover(time: result.time)
                self.textContentLab.text = result.textContent
            }
        }
    }
    
    
    static func timeCover(time: time_t) -> String {
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
            formatstr = "MM/dd - HH:mm"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatstr
        return dateFormatter.string(from: messageDate)
    }
    
    static func getHeight() -> CGFloat {
        return totalHeight;
    }
    
    
//    static func ViewSizeForMessage(chat: ChatMessage, width: Int) -> CGSize {
//
//        let currentCell = ChatTableViewCell()
//        var dateFont = currentCell.messageTimeLab.font
//        var dateViewSize = currentCell.messageTimeLab.frame.size
//        dateViewSize.width = CGFloat.greatestFiniteMagnitude
//
//        var messageSize = ViewHeightForMessageText(chat: chat, width: width)
//        let dateSize = computeBoundingBox(text: "\(chat.time)", size: dateViewSize, font: dateFont!)
//        messageSize.width = CGFloat(max(max(Double(messageSize.width), min(currentCell.CELL_MESSAGE_X_MARGIN, Double(width))), currentCell.CELL_MIN_WIDTH));
//        return messageSize
//    }
    
    static func ViewHeightForMessageText(chat: ChatMessage) -> CGFloat {
        let timeSize = computeBoundingBox(text: timeCover(time: chat.time), size: CGSize(width: UIDevice.screenWidth, height: UIDevice.screenWidth), font: UIFont.systemFont(ofSize: 12))
        let messageSize = computeBoundingBox(text: chat.textContent, size: CGSize(width: UIDevice.screenWidth - 160, height: CGFloat.greatestFiniteMagnitude), font: UIFont.systemFont(ofSize: 13))
        return (timeSize.height + messageSize.height + 55)
    }
    
    
    static func computeBoundingBox(text: String, size: CGSize, font: UIFont) -> CGSize {
        if text.count == 0 {
            return CGSize.zero
        }
        
        let message: NSString = text as NSString
        return message.boundingRect(with: size, options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil).size
    }
    
    override func layoutSubviews() {
        if let result = message {
            if result.isOutgoing {
                
                self.messageTimeLab.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(10)
                    make.right.equalTo(self.messageStatusIcon.snp.left).offset(-5)
                }
                
                self.textContentLab.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.messageTimeLab.snp.bottom).offset(15)
                    make.right.equalTo(self.messageTimeLab).offset(-10)
                    make.left.greaterThanOrEqualToSuperview().offset(100)
                }
                
                self.bgImageView.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.textContentLab).offset(-5)
                    make.right.equalTo(self.messageTimeLab)
                    make.bottom.equalTo(self.textContentLab).offset(5)
                    make.left.equalTo(self.textContentLab).offset(-10)
                }
                
                self.messageStatusIcon.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(self.bgImageView.snp.bottom)
                    make.height.equalTo(15)
                    make.width.equalTo(15)
                    make.right.equalToSuperview().offset(-10)
                }
            } else {
                self.messageTimeLab.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(10)
                    make.left.equalToSuperview().offset(45)
                }
                
                self.headerImageView.snp.remakeConstraints { (make) in
                    make.height.equalTo(30)
                    make.width.equalTo(30)
                    make.top.equalTo(self.messageTimeLab.snp.bottom).offset(10)
                    make.left.equalToSuperview().offset(10)
                }
                
                self.textContentLab.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.messageTimeLab.snp.bottom).offset(15)
                    make.left.equalTo(self.messageTimeLab).offset(5)
                    make.right.lessThanOrEqualToSuperview().offset(-100)
                }
                
                self.bgImageView.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.messageTimeLab)
                    make.top.equalTo(self.textContentLab).offset(-5)
                    make.bottom.equalTo(self.textContentLab).offset(5)
                    make.right.equalTo(self.textContentLab).offset(10)
                }
            }
        }
    }
}
