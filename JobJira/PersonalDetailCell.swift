//
//  PersonalDetailCell.swift
//  JobJira
//
//  Created by Vaibhav on 28/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class PersonalDetailCell: UITableViewCell
{
    
//MARK:- IBOutlets

    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var openSelectorBtn: UIButton!
    
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
