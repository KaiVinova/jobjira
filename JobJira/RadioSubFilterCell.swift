//
//  RadioSubFilterCell.swift
//  JobJira
//
//  Created by Vaibhav on 21/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class RadioSubFilterCell: UITableViewCell {

    @IBOutlet weak var subFilterLabel: UILabel!
    @IBOutlet weak var subFilterSelectionBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
