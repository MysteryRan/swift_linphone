//
//  TextChatViewController.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/27.
//

import UIKit
import linphonesw

class TextChatViewController: UIViewController {
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        return tableView
    }()
    
    var dataSource = [ChatRoom]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "消息"

        self.view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(UINib.init(nibName: "ChatHistoryCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
//        SwiftLinphone.shared.textMsgStatusCallBack = { message in
//            self.dataSource = SwiftLinphone.shared.textChatList()
//            self.tableView.reloadData()
//        }
        
        SwiftLinphone.shared.globalMsgCallBack = { message in
            self.dataSource = SwiftLinphone.shared.textChatList()
            self.tableView.reloadData()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        self.dataSource = SwiftLinphone.shared.textChatList()
        self.tableView.reloadData()
    }

}

extension TextChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChatHistoryCell
        cell.selectionStyle = .none
        cell.chatHistory = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatdetailVC = ChatDetailViewController()
        let chatRoom = dataSource[indexPath.row]
        chatdetailVC.selectedChatRoom = chatRoom
        if let friend = chatRoom.peerAddress {
            SwiftLinphone.shared.ListenMessageRoom(address: friend)
        }
        self.navigationController?.pushViewController(chatdetailVC, animated: true)
    }
}

extension TextChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
}
