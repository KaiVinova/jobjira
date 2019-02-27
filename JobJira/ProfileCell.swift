//
//  ProfileCell.swift
//  JobJira
//
//  Created by Vaibhav on 16/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell
{

//MARK:- IBOutlets

    @IBOutlet weak var symbolIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameBtn: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var emailVerifyBtn: UIButton!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordBtn: UIButton!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ageBtn: UIButton!
    @IBOutlet weak var natioanlityLabel: UILabel!
    @IBOutlet weak var nationalityBtn: UIButton!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var currentSalaryLabel: UILabel!
    @IBOutlet weak var currentSalaryBtn: UIButton!
    @IBOutlet weak var expectedSalaryLabel: UILabel!
    @IBOutlet weak var expectedSalaryBtn: UIButton!
    @IBOutlet weak var addResumeBtn: UIButton!
    @IBOutlet weak var updateResumeBtn: UIButton!
    @IBOutlet weak var deleteResumeBtn: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var prLabel: UILabel!
    @IBOutlet weak var prBtn: UIButton!
//MARK:- View LifeCycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        if containerView != nil
        {
            containerView.layer.cornerRadius=4.0
            containerView.layer.masksToBounds=false
            containerView.layer.borderColor = UIColor.white.cgColor
            containerView.layer.borderWidth = 1.0
            containerView.layer.shadowColor = UIColor.lightGray.cgColor
            containerView.layer.shadowOffset = CGSize.zero
            containerView.layer.shadowOpacity = 0.3
            containerView.layer.shadowRadius = 2
        }
        if videoBtn != nil
        {
            videoBtn.layer.cornerRadius=4.0
            videoBtn.layer.masksToBounds=false
            videoBtn.layer.borderColor = UIColor.white.cgColor
            videoBtn.layer.borderWidth = 1.0
            videoBtn.layer.shadowColor = UIColor.lightGray.cgColor
            videoBtn.layer.shadowOffset = CGSize.zero
            videoBtn.layer.shadowOpacity = 0.3
            videoBtn.layer.shadowRadius = 2
            videoBtn.clipsToBounds = true
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

}
