//
//  JobTypeCell.swift
//  JobJira
//
//  Created by Vaibhav on 26/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class JobTypeCell: UITableViewCell
{

//MARK:- IBOutlets
    
    @IBOutlet weak var btnSuperView: UIView!
    @IBOutlet weak var jobTypeLabel: UILabel!
    @IBOutlet weak var jobSubTypeLabel: UILabel!
    @IBOutlet weak var jobTypeBtn: UIButton!
    
//MARK:- View LifeCycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        btnSuperView.layer.cornerRadius=20.0;
        btnSuperView.layer.masksToBounds=false;
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

}
