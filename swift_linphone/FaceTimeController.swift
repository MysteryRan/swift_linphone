//
//  FaceTimeController.swift
//  swift_linphone
//
//  Created by zouran on 2021/1/27.
//

import UIKit
import linphonesw

class FaceTimeController: UIViewController {
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        return tableView
    }()
    
    var dataSource = [CallMessage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.navigationItem.title = "音视频通话"
        
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(UINib.init(nibName: "CallHistoryCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
//        print(SwiftLinphone.shared.lc.proxyConfigList)
        
        do {
//        let titleLab = UILabel()
//        titleLab.text = "音视频通话"
//        titleLab.font = UIFont.init(name: "PingFang-SC-Medium", size: 18)
//        self.view.addSubview(titleLab)
//        titleLab.textAlignment = .center
//        titleLab.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.top.equalToSuperview().offset(100)
//        }
//
//        let audioView = UIButton()
//        audioView.backgroundColor = .init(red: 76/255.0, green: 129/255.0, blue: 233/255.0, alpha: 1)
//        audioView.layer.masksToBounds = true;
//        audioView.layer.cornerRadius = 10;
//        self.view.addSubview(audioView)
//        audioView.snp.makeConstraints { (make) in
//            make.top.equalTo(titleLab.snp.bottom).offset(25)
//            make.left.equalToSuperview().offset(10)
//            make.right.equalToSuperview().offset(-10)
//            make.height.equalTo(audioView.snp.width).multipliedBy(90/150.0)
//        }
//        audioView.addTarget(self, action: #selector(audioChat), for: .touchUpInside)
//
//        let rightRow = UIImageView()
//        rightRow.image = UIImage(named: "icon_more_3")
//        audioView.addSubview(rightRow)
//        rightRow.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.right.equalToSuperview().offset(-5)
//        }
//
//        let tipOne = UILabel()
//        tipOne.text = "音频通话"
//        tipOne.font = UIFont.init(name: "PingFang-SC-Medium", size: 16)
//        tipOne.textColor = UIColor.white
//        audioView.addSubview(tipOne)
//        tipOne.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(20)
//            make.left.equalToSuperview().offset(15)
//        }
//
//        let tipTwo = UILabel()
//        tipTwo.text = ""
//        tipTwo.textColor = .init(red: 1, green: 1, blue: 1, alpha: 0.3)
//        tipTwo.font = UIFont.systemFont(ofSize: 14)
//        audioView.addSubview(tipTwo)
//        tipTwo.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(15)
//            make.top.equalTo(tipOne.snp.bottom).offset(10)
//        }
//
//        let bottomView = UIView()
//        bottomView.backgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.3)
//        bottomView.layer.masksToBounds = true;
//        bottomView.layer.cornerRadius = 5;
//        audioView.addSubview(bottomView)
//        bottomView.snp.makeConstraints { (make) in
//            make.bottom.equalToSuperview().offset(-20)
//            make.left.equalToSuperview().offset(15)
//            make.width.equalTo(40)
//            make.height.equalTo(5)
//        }
        }
        
        dataSource = SwiftLinphone.shared.getCallLogs()
        self.tableView.reloadData()
        
        
    }
    
    @objc func audioChat() {
        let bool = SwiftLinphone.shared.AudioChat()
    }

}

extension FaceTimeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension FaceTimeController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CallHistoryCell
        cell.selectionStyle = .none
        cell.callMessage = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    
}
