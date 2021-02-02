//
//  ChatDetailViewController.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/27.
//

import UIKit
import linphonesw

class ChatDetailViewController: UIViewController {
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        return tableView
    }()
    
    let chatBar = UIView()
    let chatTextView = UITextView()
    
    var dataSource = [ChatMessage]()
    
    var selectedChatRoom: ChatRoom?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        initializeObserve()
        
        
 
        
        SwiftLinphone.shared.registStatusCallBack = { cstatus in
//            print(cstatus)
        }
        
        
        SwiftLinphone.shared.sipStatusCallBack = { status in
//            print(status)
        }
        
        SwiftLinphone.shared.textMsgStatusCallBack = { message in
            self.dataSource.append(message)
            self.tableView.insertRows(at: [IndexPath(row: (self.dataSource.count - 1), section: 0)], with: .none)
            self.scrollToBottom()
            if let chatRoom = self.selectedChatRoom {
                if let friend = chatRoom.peerAddress {
                    SwiftLinphone.shared.messageRead(address: friend)
                }
            }
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(chatBar.snp.top)
        }
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(UINib.init(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.reloadData()
        
        let exitKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(exitKeyboard))
        exitKeyboardTap.delegate = self
        exitKeyboardTap.numberOfTapsRequired = 1
        tableView.addGestureRecognizer(exitKeyboardTap)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollToBottom()
    }
    
    func scrollToBottom() {
        self.tableView.reloadData()
        let rows = tableView.numberOfRows(inSection: 0)
        let bottomIndexPath = IndexPath(row: rows - 1, section: 0)
        tableView.scrollToRow(at: bottomIndexPath, at: .bottom, animated: false)
    }
    
    @objc func exitKeyboard() {
        self.view.endEditing(true)
    }
    
    func initializeObserve() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: ViewController.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: ViewController.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: ViewController.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: ViewController.keyboardDidHideNotification, object: nil)
    }
    
    func setupUI() {
        // 底部工具条
        self.view.backgroundColor = .white

        self.view.addSubview(chatBar)
        chatBar.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        
        // 输入文字
        chatTextView.delegate = self
        chatBar.addSubview(chatTextView)
        chatTextView.backgroundColor = .red
        chatTextView.returnKeyType = .send
        chatTextView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        // 发送按钮
        let sendButton = UIButton()
        sendButton.setTitle("功能", for: .normal)
        sendButton.backgroundColor = .orange
        sendButton.frame = CGRect(x: UIDevice.screenWidth - 44, y: 0, width: 44, height: 44)
        chatBar.addSubview(sendButton)
        
        if let chatRoom = selectedChatRoom {
            if let friend = chatRoom.peerAddress {
                self.navigationItem.title = friend.username
                SwiftLinphone.shared.messageRead(address: friend)
            }
            dataSource = chatRoom.getHistory(nbMessage: 0)
            self.tableView.reloadData()
        }
        
    }
    
    @objc func handleKeyboard(notification: NSNotification) {
        self.scrollToBottom()
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            let cg: CGRect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
//            self.chatBar.frame.origin.y = UIScreen.main.bounds.height - cg.height - 44
            if cg.origin.y == UIDevice.screenHeight {
                self.chatBar.snp.remakeConstraints { (make) in
                    make.left.right.bottom.equalToSuperview()
                    make.height.equalTo(44)
                }
                return
            }

            self.chatBar.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(44)
                make.bottom.equalToSuperview().offset(-cg.height)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ChatDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChatTableViewCell
        cell.selectionStyle = .none
        cell.message = dataSource[indexPath.row]
        return cell
    }
}

extension ChatDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChatTableViewCell.ViewHeightForMessageText(chat: dataSource[indexPath.row])
    }
}

extension ChatDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let isTableView = touch.view?.isKind(of: UITableView.self)
        let isContentView = touch.view?.isKind(of: NSClassFromString("UITableViewCellContentView")!)
        return (isTableView != nil) || (isContentView != nil)
    }
}

extension ChatDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if let message = textView.text {
                SwiftLinphone.shared.sendMessage(msg: message)
                
                if let sipMessage = SwiftLinphone.shared.createMessage(msg: message) {
                    self.dataSource.append(sipMessage)
                    self.tableView.insertRows(at: [IndexPath(row: (self.dataSource.count - 1), section: 0)], with: .none)
                    self.scrollToBottom()
                }
                textView.text = ""
            }
            return false
        }
        return true
    }
}
