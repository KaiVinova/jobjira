//
//  YourActivitiesCell.swift
//  JobJira
//
//  Created by Vaibhav on 02/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class YourActivitiesCell: UITableViewCell
{

//MARK:- IBOutlets

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var companyImage: UIImageView!
    @IBOutlet weak var designationLbl: UILabel!
    @IBOutlet weak var comanyNameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var companyProfileBtn: UIButton!
    @IBOutlet weak var designationTrailingConstant: NSLayoutConstraint!
    @IBOutlet weak var companyTrailingConstant: NSLayoutConstraint!
    
//MARK:- View LifeCycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        if companyProfileBtn != nil
        {
            companyProfileBtn.isUserInteractionEnabled = false
        }
    }

}
