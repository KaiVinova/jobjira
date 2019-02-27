//
//  ChatListCell.swift
//  JobJira
//
//  Created by Vaibhav on 12/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class ChatListCell: UITableViewCell
{
    
//MARK:- IBOutlets

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var designationLbl: UILabel!
    @IBOutlet weak var newMsgLbl: UILabel!
    @IBOutlet weak var companyLbl: UILabel!
    @IBOutlet weak var postedLbl: UILabel!
    @IBOutlet weak var appliedLbl: UILabel!
    
//MARK:- View LifeCycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        if containerView != nil
        {
            containerView.layer.cornerRadius = 4.0
            containerView.layer.masksToBounds = false
            containerView.layer.shadowColor = UIColor.lightGray.cgColor
            containerView.layer.shadowRadius = 1
            containerView.layer.shadowOpacity = 0.3
        }
        if iconImage != nil
        {
            iconImage.image = UIImage(named: "profile")
        }
    }
    
    override func layoutIfNeeded()
    {
        super.layoutIfNeeded()
        if self.containerView != nil
        {
            self.containerView.frame = CGRect(x: 10, y: 5, width: self.frame.size.width-20, height: self.frame.size.height-10)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

}
