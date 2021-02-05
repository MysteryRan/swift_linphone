//
//  ChatHistoryCell.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/27.
//

import UIKit
import linphonesw

class ChatHistoryCell: UITableViewCell {

    @IBOutlet weak var contentBgView: UIView!
    
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var rightButtonWidthC: NSLayoutConstraint!
    @IBOutlet weak var middleButtonWidthC: NSLayoutConstraint!
    @IBOutlet weak var leftButtonWidthC: NSLayoutConstraint!
    
    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var friendNameLab: UILabel!
    @IBOutlet weak var lastChatLab: UILabel!
    
    var deleteChatRoomAction: (() -> ())?
    
    var beginPoint = CGPoint.zero
    
    var outTableView: UITableView?
    
    var rightExpand: Bool = false
    
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
                
                let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeFrom))
                self.contentView.addGestureRecognizer(recognizer)
            }
        }
    }
    
    @IBAction func rightButtonClick(_ sender: UIButton) {
        deleteChatRoomAction?()
    }
    
    func normalState() {
        self.contentBgView.snp.updateConstraints { (make) in
            make.left.equalToSuperview().offset(0)
        }
        
        self.needsUpdateConstraints()
        self.updateConstraintsIfNeeded()
        
        self.rightButtonWidthC.constant = 0
        self.leftButtonWidthC.constant = 0
        self.middleButtonWidthC.constant = 0
        
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superview = superview else { return false }
     
        let point = convert(point, to: superview)

        if !UIAccessibility.isVoiceOverRunning {
            for cell in outTableView?.visibleCells ?? [] {
                if let chatCell = cell as? ChatHistoryCell {
                    if rightExpand && !chatCell.cellContains(point: point) {
    //                    tableView?.hideSwipeCell()
                        print("-----ppp")
                        return false
                    }
                }
            }
        }

        return cellContains(point: point)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        var view: UIView = self
        while let superview = view.superview {
            view = superview

            if let tableView = view as? UITableView {
                self.outTableView = tableView

//                swipeController.scrollView = tableView;
//
                outTableView?.panGestureRecognizer.removeTarget(self, action: nil)
                outTableView?.panGestureRecognizer.addTarget(self, action: #selector(handleTablePan(gesture:)))
                return
            }
        }
    }
    
    @objc func handleTablePan(gesture: UIGestureRecognizer) {
        normalState()
    }
    
    func cellContains(point: CGPoint) -> Bool {
        return point.y > frame.minY && point.y < frame.maxY
    }
    
    @objc func handleSwipeFrom(recognizer: UIPanGestureRecognizer) {
            
            
            let panPoint = recognizer.location(in: self.contentView)
            if recognizer.state == .began {
                beginPoint = panPoint
//                print(beginPoint.x)
//                print("---------")
            } else if recognizer.state == .changed {
                let durationPoint = panPoint
                
                if durationPoint.x > beginPoint.x {
                    normalState()
                    return
                }
                

                
//                print(abs(durationPoint.x - beginPoint.x))
//                self.contentBgView.frame.origin.x = abs(durationPoint.x) - abs(beginPoint.x)
                self.contentBgView.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(-abs(abs(durationPoint.x) - abs(beginPoint.x)))
                }
                
//                self.rightButton.snp.updateConstraints { (make) in
//                    make.width.equalTo((abs(durationPoint.x) - abs(beginPoint.x)) / 3.0)
//                    make.width.equalTo(150)
//                }
                
                
                self.needsUpdateConstraints()
                self.updateConstraintsIfNeeded()
                
//                if abs(durationPoint.x - beginPoint.x) < 300 && abs(durationPoint.x - beginPoint.x) > 200 {
                    self.rightButtonWidthC.constant = abs(abs(durationPoint.x) - abs(beginPoint.x)) / 3.0
                    self.leftButtonWidthC.constant = abs(abs(durationPoint.x) - abs(beginPoint.x)) / 3.0
                    self.middleButtonWidthC.constant = abs(abs(durationPoint.x) - abs(beginPoint.x)) / 3.0
//                }
                
                UIView.animate(withDuration: 0.25) {
                    self.layoutIfNeeded()
                }
                
            } else if recognizer.state == .ended {
                let durationPoint = panPoint
                if abs(durationPoint.x - beginPoint.x) < 200 {
                    normalState()
                    return
                }
                
                if abs(durationPoint.x - beginPoint.x) < 300 {
                    rightExpand = true
                    
                    self.rightButtonWidthC.constant = 100
                    self.leftButtonWidthC.constant = 100
                    self.middleButtonWidthC.constant = 100
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
