//
//  LanguageSelectionCell.swift
//  JobJira
//
//  Created by Vaibhav on 30/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class LanguageSelectionCell: UITableViewCell
{
    
//MARK:- IBOutlets

    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var languageSelectionBtn: UIButton!
    
//MARK:- View LifeCycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

}
