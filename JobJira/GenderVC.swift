
//
//  GenderVC.swift
//  JobJira
//
//  Created by Vaibhav on 24/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
class GenderVC: UIViewController
{

//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var maleBtn: CircularButton!
    @IBOutlet weak var femaleBtn: CircularButton!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleLabel: UILabel!
    @IBOutlet weak var notIntrestedBtn: UIButton!
    @IBOutlet weak var notIntrestedLbl: UILabel!
    
//MARK:- Variables and Constants

    var dataDict = [String:AnyObject]()
    var editFlag:Bool!
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
        if (SignUpMetaData.sharedInstance.genderDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.genderDict
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
    
//MARK:- Method for SetupData on View
    
    func setUpViewBackEndData()
    {
        titleLabel.text = dataDict["questionInfo"]?["title"] as? String
        subTitleLabel.text = dataDict["questionInfo"]?["p1"] as? String
        headerLabel.text = dataDict["questionInfo"]?["h1"] as? String
        descriptionLabel.text = dataDict["questionInfo"]?["p2"] as? String
        if (dataDict["questionTexts"]?.count)!>0
        {
            maleLabel.text = dataDict["questionTexts"]?["male"] as? String
            femaleLabel.text = dataDict["questionTexts"]?["female"] as? String
            notIntrestedLbl.text = dataDict["questionTexts"]?["gender_skip_string"] as? String
        }
        if SignUpMetaData.sharedInstance.genderSelectedDict["answer"] as? String == "1"
        {
            maleBtn.isSelected = true
            femaleBtn.isSelected = false
            notIntrestedBtn.isSelected = false
        }
        else if SignUpMetaData.sharedInstance.genderSelectedDict["answer"] as? String == "2"
        {
            maleBtn.isSelected = false
            femaleBtn.isSelected = true
            notIntrestedBtn.isSelected = false
        }
        else if SignUpMetaData.sharedInstance.genderSelectedDict["answer"] as? String == "3"
        {
            maleBtn.isSelected = false
            femaleBtn.isSelected = false
            notIntrestedBtn.isSelected = true
        }
        if editFlag == false
        {
            showPopUpForCoach()
        }
    }
    
//MARK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        let _ = navigationController?.popViewController(animated: true)
    }
    
//MARk:- Done Button Action
   
    @IBAction func doneBtnAction(_ sender: Any)
    {
        if maleBtn.isSelected
        {
            SignUpMetaData.sharedInstance.genderSelectedDict = ["answer":"1" as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.genderDict["obQuestionID"]!]
        }
        else if femaleBtn.isSelected
        {
            SignUpMetaData.sharedInstance.genderSelectedDict = ["answer":"2" as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.genderDict["obQuestionID"]!]
        }
        else if notIntrestedBtn.isSelected
        {
            SignUpMetaData.sharedInstance.genderSelectedDict = ["answer":"3" as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.genderDict["obQuestionID"]!]
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please select your gender to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if editFlag == true
        {
            if maleBtn.isSelected
            {
                SignUpMetaData.sharedInstance.userInfoDict["genderID"] = "1" as AnyObject
                SignUpMetaData.sharedInstance.userInfoDict["genderName"] = "Male" as AnyObject
            }
            else if femaleBtn.isSelected
            {
                SignUpMetaData.sharedInstance.userInfoDict["genderID"] = "2" as AnyObject?
                SignUpMetaData.sharedInstance.userInfoDict["genderName"] = "Female" as AnyObject
            }
            else if notIntrestedBtn.isSelected
            {
                SignUpMetaData.sharedInstance.userInfoDict["genderID"] = "3" as AnyObject?
                SignUpMetaData.sharedInstance.userInfoDict["genderName"] = "Not Disclosed" as AnyObject
            }
            let _ = navigationController?.popViewController(animated: true)
        }
        else
        {
            SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
        }
    }
    
//MARK:- Male Button Action
    
    @IBAction func maleBtnAction(_ sender: Any)
    {
        maleBtn.isSelected = true
        femaleBtn.isSelected = false
        notIntrestedBtn.isSelected = false
    }
    
//MARK:- Female Button Action

    @IBAction func femaleBtnAction(_ sender: Any)
    {
        maleBtn.isSelected = false
        femaleBtn.isSelected = true
        notIntrestedBtn.isSelected = false
    }
    
//MARK:- Not Interested Button Action
    
    @IBAction func notIntrestedBtnAction(_ sender: Any)
    {
        maleBtn.isSelected = false
        femaleBtn.isSelected = false
        notIntrestedBtn.isSelected = true
    }
    
//MARK:- Method for Coach POPUP
    
    func showPopUpForCoach()
    {
        let popup = FirstCoachView.instansiateFromNib()
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(popup)
        popup.showPopup()
    }
    
    func animStrokeEndWithDuration(_ duration:CGFloat, delgate:AnyObject) -> CABasicAnimation
    {
        let animLine = CABasicAnimation(keyPath: "strokeEnd")
        animLine.duration = CFTimeInterval(duration)
        animLine.fromValue = NSNumber(value: 0.0)
        animLine.toValue = NSNumber(value: 1.0)
        animLine.isRemovedOnCompletion = false
        animLine.fillMode = kCAFillModeBoth
        animLine.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        return animLine
    }
}
