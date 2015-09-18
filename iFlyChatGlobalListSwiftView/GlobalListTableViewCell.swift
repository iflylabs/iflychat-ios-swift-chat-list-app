//
//  GlobalListTableViewCell.swift
//  iFlyChatGlobalListSwiftView
//
//  Created by Prateek Grover on 04/08/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

import UIKit

class GlobalListTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
       
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
