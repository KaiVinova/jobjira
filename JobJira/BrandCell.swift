//
//  BrandCell.swift
//  JobJira
//
//  Created by Vaibhav on 13/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class BrandCell: UICollectionViewCell
{

//MARK:- IBOutlets
    
    @IBOutlet weak var iconSuperView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var brandSelectionBtn: UIButton!
    
//MARK:- View LifeCycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.iconSuperView.layer.cornerRadius=6.0
        self.iconSuperView.layer.masksToBounds=false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
    }
}
