//
//  FilterCell.swift
//  JobJira
//
//  Created by Vaibhav on 28/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {

    @IBOutlet weak var FilterNameLbl: UILabel!
    @IBOutlet weak var filterOptionLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
