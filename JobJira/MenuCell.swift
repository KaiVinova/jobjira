//
//  MenuCell.swift
//  HomeTurph
//
//  Created by Vaibhav on 10/06/16.
//  Copyright © 2016 Vaibhav Krishna. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell
{
    
//MARK:- IBOutlets

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var menuNameLabel: UILabel!
    
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
