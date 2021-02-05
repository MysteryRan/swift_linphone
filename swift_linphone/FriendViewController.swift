//
//  FriendViewController.swift
//  swift_linphone
//
//  Created by zouran on 2021/2/4.
//

import UIKit

class FriendViewController: UIViewController {
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        return tableView
    }()
    
    var friendList = [String]()
    
    var firstCharacters = [Character]()
    
    var nameDic = [Character:[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "好友"
        self.view.backgroundColor = .white
        
//        print(SwiftLinphone.shared.lc.defaultProxyConfig?.identityAddress?.username)
        
        let accountList = ["wizard15","wizard42","kenyrim"]
        if let proxyConfig = SwiftLinphone.shared.lc.defaultProxyConfig {
            if let address = proxyConfig.identityAddress {
                for i in accountList {
                    if i != address.username {
                        friendList.append(i)
                    }
                }
                print(friendList)
            }
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "FriendHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "BFHeaderID")
        tableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "MyFriendCellID")
        
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.sectionIndexTrackingBackgroundColor = UIColor.clear
        tableView.sectionIndexColor = #colorLiteral(red: 0.4, green: 0.8431372549, blue: 0.6509803922, alpha: 1)
        
        tableView.tableFooterView = UIView()
        
        
        
        for i in friendList {
            if !firstCharacters.contains(getFirstCharactor(name: i)) {
                var temps = [String]()
                temps.append(i)
                nameDic[getFirstCharactor(name: i)] = temps
                firstCharacters.append(getFirstCharactor(name: i))
            } else {
                var haveTemps = nameDic[getFirstCharactor(name: i)]
                haveTemps?.append(i)
                nameDic[getFirstCharactor(name: i)] = haveTemps
            }
        }
        firstCharacters = firstCharacters.sorted()
    
        tableView.reloadData()
    }
    
    func getFirstCharactor(name: String) -> Character {
        let mstring = NSMutableString(string: name)
        CFStringTransform(mstring, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mstring, nil, kCFStringTransformStripDiacritics, false)
        let string = mstring.capitalized
        return string[string.startIndex]
    }
}

extension FriendViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return firstCharacters.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let charactor = firstCharacters[section]
        return nameDic[charactor]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyFriendCellID") as! FriendTableViewCell
        let charactor = firstCharacters[indexPath.section]
        cell.nameLab.text = nameDic[charactor]![indexPath.row]
        return cell
    }
}

extension FriendViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BFHeaderID") as! FriendHeaderView
        header.nameTitleLab.text = "\(firstCharacters[section])"
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let charactor = firstCharacters[indexPath.section]
        let chatdetailVC = ChatDetailViewController()
        if let chatRoom = SwiftLinphone.shared.createOne2OneChat(name: nameDic[charactor]![indexPath.row]) {
        chatdetailVC.selectedChatRoom = chatRoom
            if let friend = chatRoom.peerAddress {
                SwiftLinphone.shared.ListenMessageRoom(address: friend)
                self.navigationController?.pushViewController(chatdetailVC, animated: true)
            }
        }
        
    }
}
