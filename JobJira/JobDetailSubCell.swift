//
//  JobDetailSubCell.swift
//  JobJira
//
//  Created by Vaibhav on 29/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class JobDetailSubCell: UITableViewCell
{
    
//MARK:- IBOutlets

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var valueLbl: UILabel!
    
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
