//
//  MasterViewControllerCell.swift
//  Note Taker
//
//  Created by Nathan Pavlovsky on 7/27/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//
//  This is the file that controlls the cell for the master view controller

import UIKit

class MasterViewControllerCell: UITableViewCell {

    @IBOutlet var titleText : UILabel!
    @IBOutlet var dateText : UILabel!
    @IBOutlet var accessoryImageView : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
