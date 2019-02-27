//
//  JobDetailCell.swift
//  JobJira
//
//  Created by Vaibhav on 29/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import TagListView

class JobDetailCell: UITableViewCell
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleNameLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var tagView: TagListView!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var withdrawBtn: UIButton!
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var answerTxt: UITextView!
    @IBOutlet weak var charCountLbl: UILabel!

//MARK:- Variables and Constants
    
    var maxLen = 200
    var minLen = 10
    
//MARK:- View LifeCycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        if containerView != nil
        {
            containerView.layer.cornerRadius = 4.0
            containerView.layer.masksToBounds = true
        }
        if answerTxt != nil
        {
            answerTxt.layer.cornerRadius = 4.0
            answerTxt.layer.masksToBounds = false
            answerTxt.layer.shadowColor = UIColor.lightGray.cgColor
            answerTxt.layer.shadowRadius = 5.0
            answerTxt.layer.shadowOpacity = 0.5
        }
        if skipBtn != nil
        {
            skipBtn.layer.cornerRadius = 16.0
            skipBtn.layer.masksToBounds = true
        }
        if applyBtn != nil
        {
            applyBtn.layer.cornerRadius = 16.0
            applyBtn.layer.masksToBounds = true
        }
        if answerTxt != nil
        {
            answerTxt.textColor = UIColor.lightGray
            answerTxt.text = "Your answer.."
            answerTxt.font = UIFont(name: ".SFUIText-Light", size: 12)!
        }
        if tagView != nil
        {
            tagView.textFont = UIFont(name: ".SFUIText-Light", size: 12)!
        }
        if charCountLbl != nil
        {
            charCountLbl.text = "\(maxLen) Characters"
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
    }
    
    override func didMoveToSuperview()
    {
        super.didMoveToSuperview()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

}
