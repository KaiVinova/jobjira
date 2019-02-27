//
//  AgeVC.swift
//  JobJira
//
//  Created by Vaibhav on 24/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
@objc protocol AgeDelegate
{
    @objc optional func callBackWithDict(data:[String:AnyObject])
}
class AgeVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subTitle2Label: UILabel!
    @IBOutlet weak var ageBtnView: UIView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var agePostFixLabel: UILabel!
    @IBOutlet weak var ageBtn: UIButton!
    @IBOutlet weak var notInterestedBtn: UIButton!
    @IBOutlet weak var notInterestedLbl: UILabel!
    
//MARK:- Variables and Constants
    
    var dataDict = [String:AnyObject]()
    var optionsArray = [AnyObject]()
    var editFlag:Bool!
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
        if (SignUpMetaData.sharedInstance.ageDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.ageDict
        }
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight == 480
        {
            let font = subTitleLabel.font
            subTitleLabel.font = font?.withSize(15)
            let font1 = headerLabel.font
            headerLabel.font = font1?.withSize(19)
            let font2 = descriptionLabel.font
            descriptionLabel.font = font2?.withSize(14)
        }
        setUpViewBackEndData()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight == 480
        {
            let font = ageLabel.font
            ageLabel.font = font?.withSize(15)
            let font1 = agePostFixLabel.font
            agePostFixLabel.font = font1?.withSize(13)
        }
        ageBtnView.layer.cornerRadius=ageBtnView.frame.size.height/2;
        ageBtnView.layer.masksToBounds=false;
    }
    
//MARK:- Method for SetupData on View

    func setUpViewBackEndData()
    {
        titleLabel.text = dataDict["questionInfo"]?["title"] as? String
        subTitleLabel.text = dataDict["questionInfo"]?["p1"] as? String
        headerLabel.text = dataDict["questionInfo"]?["h1"] as? String
        descriptionLabel.text = dataDict["questionInfo"]?["p2"] as? String
        subTitle2Label.text = dataDict["questionInfo"]?["h2"] as? String
        if (dataDict["questionTexts"]?.count)!>0
        {
            notInterestedLbl.text = dataDict["questionTexts"]?["age_skip_string"] as? String
        }
        agePostFixLabel.text = dataDict["questionInfo"]?["buttonText"] as? String
        let optionsRange = dataDict["questionInfo"]?["optionsRange"] as? [AnyObject]
        let startAge = optionsRange?[0] as! Int
        let endAge = optionsRange?[1] as! Int
        ageLabel.text = "Select"
        agePostFixLabel.text = "Age"
        for i in startAge...endAge
        {
            optionsArray.append(i as AnyObject)
        }
        if SignUpMetaData.sharedInstance.ageSelectedDict["answer"] as? String != nil
        {
            if SignUpMetaData.sharedInstance.ageSelectedDict["answer"] as? String == "0"
            {
                notInterestedBtn.isSelected = true
            }
            else
            {
                ageLabel.text = SignUpMetaData.sharedInstance.ageSelectedDict["answer"] as? String
                agePostFixLabel.text = "years young"
            }
        }
    }
    
//MARK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        let _ = navigationController?.popViewController(animated: true)
    }
    
//MARK:- Done Button Action
    
    @IBAction func doneBtnAction(_ sender: Any)
    {
        if SignUpMetaData.sharedInstance.ageSelectedDict["answer"] != nil
        {
            if editFlag == true
            {
                SignUpMetaData.sharedInstance.userInfoDict["age"] = SignUpMetaData.sharedInstance.ageSelectedDict["answer"] as AnyObject
                let _ = navigationController?.popViewController(animated: true)
            }
            else
            {
                SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
            }
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please select your age to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
//MARK:- Age Button Action
    
    @IBAction func ageBtnAction(_ sender: Any)
    {
        notInterestedBtn.isSelected = false
        showPopUpForItemDetail(withArray: optionsArray)
    }
    
//MARKL:- NotINterested Button Action
    
    @IBAction func notInterestedBtnAction(_ sender: Any)
    {
        ageLabel.text = "Select"
        agePostFixLabel.text = "Age"
        notInterestedBtn.isSelected = true
        SignUpMetaData.sharedInstance.ageSelectedDict = ["answer":"0" as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.ageDict["obQuestionID"]!]
    }
    
// MARK: Add item detail view Method
    
    func showPopUpForItemDetail(withArray array:[AnyObject])
    {
        let popup = AgeSelectionView.instansiateFromNib()
        popup.agedelegate = self
        popup.dataArray = array
        popup.selectedAge = ageLabel.text
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(popup)
        popup.showPopup()
    }
}

//MARK:- Extension AgeDelegate

extension AgeVC:AgeDelegate
{
    func callBackWithDict(data:[String:AnyObject])
    {
        ageLabel.text = "\(data["age"] as! Int)"
        agePostFixLabel.text = "years young"
        SignUpMetaData.sharedInstance.ageSelectedDict = ["answer":ageLabel.text as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.ageDict["obQuestionID"]!]
    }
}
