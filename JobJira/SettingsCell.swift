//
//  SettingsCell.swift
//  JobJira
//
//  Created by Vaibhav on 03/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell
{
    
//MARK:- IBOutlets

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var hintLbl: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var arrowIcon: UIImageView!
    
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
