//
//  CountryCodeSelectionCell.swift
//  JobJira
//
//  Created by Vaibhav on 06/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class CountryCodeSelectionCell: UITableViewCell {

    @IBOutlet weak var countryNameLbl: UILabel!
    @IBOutlet weak var countryCodeLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
