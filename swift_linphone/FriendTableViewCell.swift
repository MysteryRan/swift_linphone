//
//  FriendTableViewCell.swift
//  swift_linphone
//
//  Created by zouran on 2021/2/4.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        print("here")
        return true
    }
    
}
