//
//  JobRoleSelectionCell.swift
//  JobJira
//
//  Created by Vaibhav on 28/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class JobRoleSelectionCell: UITableViewCell
{
    
//MARK:- IBOutlets

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var jobRoleTitleLabel: UILabel!
    @IBOutlet weak var selectionImage: UIImageView!
    
//MARK:- View LifeCycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.containerView.layer.cornerRadius=4.0
        self.containerView.layer.masksToBounds=false
        self.containerView.layer.shadowColor = UIColor.black.cgColor
        self.containerView.layer.shadowOffset = CGSize.zero
        self.containerView.layer.shadowOpacity = 0.3
        self.containerView.layer.shadowRadius = 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

}
