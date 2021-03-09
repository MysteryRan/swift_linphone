//
//  ChatDetailViewController.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/27.
//

import UIKit
import linphonesw
import InputBarAccessoryView

class ChatDetailViewController: UIViewController {
//    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
//
//    }
//
//    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
//
//        return ["InputBarAccessoryView", "iOS"].map { AutocompleteCompletion(text: $0) }
//
//    }
    
    private let keyboardManager = KeyboardManager()
    
    lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.inputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        manager.maxSpaceCountDuringCompletion = 1
        return manager
    }()

    
    public let inputBar = InputBarAccessoryView()
    
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        return tableView
    }()
    

    
//    let chatBar = UIView()
//    let chatTextView = UITextView()
    
    let typingLab = UILabel()
    
    var dataSource = [ChatMessage]()
    
    var selectedChatRoom: ChatRoom?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        initializeObserve()
        
        SwiftLinphone.shared.writingCallBack = { composing in
            if composing {
                self.typingLab.text = "typing..."
            } else {
                self.typingLab.text = "onLine"
            }
        }
 
        
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
            make.top.left.right.bottom.equalToSuperview()
//            make.bottom.equalTo(inputBar.snp.top)
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
        
//        self.extendedLayoutIncludesOpaqueBars = true
//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = .never
//        } else {
//            self.automaticallyAdjustsScrollViewInsets = false
//        }
//        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 49, right:0)
//
//        tableView.scrollIndicatorInsets = tableView.contentInset
        view.addSubview(inputBar)
        inputBar.delegate = self
        
        view.backgroundColor = .systemBlue
        inputBar.inputTextView.autocorrectionType = .no
        inputBar.inputTextView.autocapitalizationType = .none
        inputBar.inputTextView.keyboardType = .twitter
        let size = UIFont.preferredFont(forTextStyle: .body).pointSize
        autocompleteManager.register(prefix: "@", with: [.font: UIFont.preferredFont(forTextStyle: .body),.foregroundColor: UIColor.systemBlue,.backgroundColor: UIColor.systemBlue.withAlphaComponent(0.1)])
        autocompleteManager.register(prefix: "#", with: [.font: UIFont.boldSystemFont(ofSize: size)])
        inputBar.inputPlugins = [autocompleteManager]
        
        keyboardManager.bind(inputAccessoryView: inputBar)
        
        // Binding to the tableView will enabled interactive dismissal
        keyboardManager.bind(to: tableView)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollToBottom()
    }
    
    func scrollToBottom() {
        self.tableView.reloadData()
        let rows = tableView.numberOfRows(inSection: 0)
        if rows > 0 {
            let bottomIndexPath = IndexPath(row: rows - 1, section: 0)
            tableView.scrollToRow(at: bottomIndexPath, at: .bottom, animated: false)
        }
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
//        let bottomInset = UIDevice.isiPhoneXSierra ? 20 : 0
//        self.view.addSubview(chatBar)
//        chatBar.snp.makeConstraints { (make) in
//            make.left.right.equalToSuperview()
//            make.height.equalTo(44)
//            make.bottom.equalToSuperview().inset(bottomInset)
//        }
//
//        // 输入文字
//        chatTextView.delegate = self
//        chatBar.addSubview(chatTextView)
//        chatTextView.backgroundColor = .red
//        chatTextView.returnKeyType = .send
//        chatTextView.snp.makeConstraints { (make) in
//            make.left.right.top.bottom.equalToSuperview()
//        }
        
        // 发送按钮
        let sendButton = UIButton()
        sendButton.setTitle("功能", for: .normal)
        sendButton.backgroundColor = .orange
        sendButton.frame = CGRect(x: UIDevice.screenWidth - 44, y: 0, width: 44, height: 44)
//        chatBar.addSubview(sendButton)
        
        if let chatRoom = selectedChatRoom {
            if let friend = chatRoom.peerAddress {
//                self.navigationItem.title = friend.username
//                self.navigationItem.prompt = "0p0p0p"
                let titleLab = UILabel()
                titleLab.text = friend.username
                let tView = UIView()
                tView.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
                typingLab.text = "onLine"
                typingLab.font = UIFont.systemFont(ofSize: 11)
                titleLab.textAlignment = .center
                typingLab.textAlignment = .center
                
                tView.addSubview(typingLab)
                tView.addSubview(titleLab)
                titleLab.snp.makeConstraints { (make) in
                    make.left.right.top.equalToSuperview()
                }
                typingLab.snp.makeConstraints { (make) in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(titleLab.snp.bottom)
                }
                
                self.navigationItem.titleView = tView
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
            
//            print(self.inputBar.frame.origin.y)
//
            self.tableView.snp.remakeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.bottom.equalTo(self.inputBar.snp.top)
            }
            
            let bottomInset = UIDevice.isiPhoneXSierra ? 20 : 0
            if cg.origin.y == UIDevice.screenHeight {
//                self.chatBar.snp.remakeConstraints { (make) in
//                    make.left.right.equalToSuperview()
//                    make.height.equalTo(44)
//                    make.bottom.equalToSuperview().inset(bottomInset)
//                }
//                return
            }

//            self.chatBar.snp.remakeConstraints { (make) in
//                make.left.right.equalToSuperview()
//                make.height.equalTo(44)
//                make.bottom.equalToSuperview().offset(-cg.height)
//            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
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


extension ChatDetailViewController: InputBarAccessoryViewDelegate {

    // MARK: - InputBarAccessoryViewDelegate

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (attributes, range, stop) in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()

        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                // 正在输入
                SwiftLinphone.shared.sipChatRoom?.compose()
                
                if let sipMessage = SwiftLinphone.shared.createMessage(msg: text) {
                    self?.dataSource.append(sipMessage)
                    let indexPath = IndexPath(row: (self?.dataSource.count ?? 1) - 1, section: 0)
                    self?.tableView.insertRows(at: [indexPath], with: .automatic)
                    self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    
                    SwiftLinphone.shared.sendMessage(msg: text)
                }
                
//                self?.dataSource.messages.append()
//                let indexPath = IndexPath(row: (self?.conversation.messages.count ?? 1) - 1, section: 0)
//                self?.tableView.insertRows(at: [indexPath], with: .automatic)
//                self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//
//
//
//
//
//
//                        if let sipMessage = SwiftLinphone.shared.createMessage(msg: message) {
//                            self.dataSource.append(sipMessage)
//                            self.tableView.insertRows(at: [IndexPath(row: (self.dataSource.count - 1), section: 0)], with: .none)
//                            self.scrollToBottom()
//                        }
//                    }
                    
            }
        }
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        // Adjust content insets
        print(size)
//        tableView.contentInset.bottom = size.height + 300 // keyboard size estimate
    }

    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {

        guard autocompleteManager.currentSession != nil, autocompleteManager.currentSession?.prefix == "#" else { return }
        // Load some data asyncronously for the given session.prefix
        DispatchQueue.global(qos: .default).async {
            // fake background loading task
            var array: [AutocompleteCompletion] = []
//            for _ in 1...10 {
//                array.append(AutocompleteCompletion(text: Lorem.word()))
//            }
//            sleep(1)
//            DispatchQueue.main.async { [weak self] in
//                self?.asyncCompletions = array
//                self?.autocompleteManager.reloadData()
//            }
        }
    }

}

extension ChatDetailViewController: AutocompleteManagerDelegate, AutocompleteManagerDataSource {

    // MARK: - AutocompleteManagerDataSource

    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
        if prefix == "@" {
            return [AutocompleteCompletion(text: "user.name",
                                          context: ["id": "user.id"])]
        } else if prefix == "#" {
//            return hashtagAutocompletes + asyncCompletions
        }
        return []
    }

    func autocompleteManager(_ manager: AutocompleteManager, tableView: UITableView, cellForRowAt indexPath: IndexPath, for session: AutocompleteSession) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.reuseIdentifier, for: indexPath) as? AutocompleteCell else {
            fatalError("Oops, some unknown error occurred")
        }
//        let users = SampleData.shared.users
//        let name = session.completion?.text ?? ""
//        let user = users.filter { return $0.name == name }.first
//        cell.imageView?.image = user?.image
//        cell.textLabel?.attributedText = manager.attributedText(matching: session, fontSize: 15)
        cell.textLabel?.text = "123"
        return cell
    }

    // MARK: - AutocompleteManagerDelegate

    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        setAutocompleteManager(active: shouldBecomeVisible)
    }

    // Optional
    func autocompleteManager(_ manager: AutocompleteManager, shouldRegister prefix: String, at range: NSRange) -> Bool {
        return true
    }

    // Optional
    func autocompleteManager(_ manager: AutocompleteManager, shouldUnregister prefix: String) -> Bool {
        return true
    }

    // Optional
    func autocompleteManager(_ manager: AutocompleteManager, shouldComplete prefix: String, with text: String) -> Bool {
        return true
    }

    // MARK: - AutocompleteManagerDelegate Helper

    func setAutocompleteManager(active: Bool) {
        let topStackView = inputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.removeArrangedSubview(autocompleteManager.tableView)
            topStackView.layoutIfNeeded()
        }
        inputBar.invalidateIntrinsicContentSize()
    }
}

