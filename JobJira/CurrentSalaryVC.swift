//
//  CurrentSalaryVC.swift
//  JobJira
//
//  Created by Vaibhav on 26/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
@objc protocol CurrentSalaryDelegate
{
    @objc optional func callBackWithDict(data:[String:AnyObject])
}
class CurrentSalaryVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subTitle2Label: UILabel!
    @IBOutlet weak var salaryBtnView: UIView!
    @IBOutlet weak var salaryeLabel: UILabel!
    @IBOutlet weak var salaryBtn: UIButton!
    @IBOutlet weak var fresherBtn: UIButton!
    @IBOutlet weak var hourBtnView: UIView!
    @IBOutlet weak var monthBtnView: UIView!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var hourBtn: UIButton!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var fresherLabel: UILabel!
    
//MARK:- Variables and Constants
    
    var dataDict = [String:AnyObject]()
    var editFlag:Bool!
    var currency:String!

//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
        
        if (SignUpMetaData.sharedInstance.currentSalaryDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.currentSalaryDict
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
            let font = subTitle2Label.font
            subTitle2Label.font = font?.withSize(12)
        }
        salaryBtnView.layer.cornerRadius=salaryBtnView.frame.size.height/2;
        salaryBtnView.layer.masksToBounds=false;
    }
    
//MARK:- Method for SetupData on View
    
    func setUpViewBackEndData()
    {
        titleLabel.text = dataDict["questionInfo"]?["title"] as? String
        subTitleLabel.text = dataDict["questionInfo"]?["p1"] as? String
        headerLabel.text = dataDict["questionInfo"]?["h1"] as? String
        descriptionLabel.text = dataDict["questionInfo"]?["p2"] as? String
        subTitle2Label.text = dataDict["questionInfo"]?["h2"] as? String
        monthLabel.text = dataDict["questionTexts"]?["per_month"] as? String
        hourLabel.text = dataDict["questionTexts"]?["per_hour"] as? String
        fresherLabel.text = dataDict["questionTexts"]?["i_am_new"] as? String
        currency = dataDict["questionTexts"]?["currency"] as? String
        salaryeLabel.text = "Current Salary"
        if SignUpMetaData.sharedInstance.currentSalarySelectedDict["answer"] as? [String:AnyObject] != nil
        {
            if SignUpMetaData.sharedInstance.currentSalarySelectedDict["answer"]?["salaryTypeID"] as? String == "3"
            {
                fresherBtn.isSelected = true
            }
            else if SignUpMetaData.sharedInstance.currentSalarySelectedDict["answer"]?["salaryTypeID"] as? String == "1"
            {
                monthBtnView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
                hourBtnView.backgroundColor = UIColor(red: 108.0/255.0, green: 105.0/255.0, blue: 217.0/255.0, alpha: 1.0)
                monthBtn.isSelected = true
                hourBtn.isSelected = false
            }
            else if SignUpMetaData.sharedInstance.currentSalarySelectedDict["answer"]?["salaryTypeID"] as? String == "2"
            {
                hourBtnView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
                monthBtnView.backgroundColor = UIColor(red: 108.0/255.0, green: 105.0/255.0, blue: 217.0/255.0, alpha: 1.0)
                hourBtn.isSelected = true
                monthBtn.isSelected = false
            }
            let salary = "\(currency!) \(SignUpMetaData.sharedInstance.currentSalarySelectedDict["answer"]?["salary"] as! String)"
            self.salaryeLabel.text = salary
        }
    }
    
    
//MARK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        let _ = navigationController?.popViewController(animated: true)
    }
    
//MARK:- Month Button Action

    @IBAction func monthBtnAction(_ sender: Any)
    {
        if !fresherBtn.isSelected
        {
            monthBtnView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
            hourBtnView.backgroundColor = UIColor(red: 108.0/255.0, green: 105.0/255.0, blue: 217.0/255.0, alpha: 1.0)
            monthBtn.isSelected = true
            hourBtn.isSelected = false
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please uncheck - \"I am new and I have never worked before\" checkbox to specify your current salary", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }

//MARK:- Hour Button Action

    @IBAction func hourBtnAction(_ sender: Any)
    {
        if !fresherBtn.isSelected
        {
            hourBtnView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
            monthBtnView.backgroundColor = UIColor(red: 108.0/255.0, green: 105.0/255.0, blue: 217.0/255.0, alpha: 1.0)
            hourBtn.isSelected = true
            monthBtn.isSelected = false
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please uncheck - \"I am new and I have never worked before\" checkbox to specify your current salary", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
//MARK:- Done Button Action

    @IBAction func doneBtnAction(_ sender: Any)
    {
        if SignUpMetaData.sharedInstance.currentSalarySelectedDict["answer"] != nil
        {
            var tempDict = SignUpMetaData.sharedInstance.currentSalarySelectedDict["answer"] as! [String:AnyObject]
            if hourBtn.isSelected
            {
                tempDict["salaryTypeID"] = "2" as AnyObject?
            }
            else if monthBtn.isSelected
            {
                tempDict["salaryTypeID"] = "1" as AnyObject?
            }
            else
            {
                tempDict["salaryTypeID"] = "3" as AnyObject?
            }
            SignUpMetaData.sharedInstance.currentSalarySelectedDict["answer"] = tempDict as AnyObject?
            if editFlag == true
            {
                SignUpMetaData.sharedInstance.userInfoDict["currentSalaryTypeID"] = SignUpMetaData.sharedInstance.currentSalarySelectedDict["answer"]?["salaryTypeID"] as AnyObject
                SignUpMetaData.sharedInstance.userInfoDict["currentSalary"] = SignUpMetaData.sharedInstance.currentSalarySelectedDict["answer"]?["salary"] as AnyObject
                let _ = navigationController?.popViewController(animated: true)
            }
            else
            {
                SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
            }
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please specify your current salary to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
//MARK:- Salary Button Action
    
    @IBAction func salaryBtnAction(_ sender: Any)
    {
        if hourBtn.isSelected || monthBtn.isSelected
        {
            showPopUpForItemDetail(withArray: NSMutableArray())
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Select per month or per hour", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
// MARK: Add item detail view Method
    
    func showPopUpForItemDetail(withArray array:NSMutableArray)
    {
        let popup = CurrentSalaryView.instansiateFromNib()
        popup.currentSalaryDelegate = self
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        popup.currency = currency
        if SignUpMetaData.sharedInstance.currentSalarySelectedDict["answer"] != nil
        {
            popup.selectedText = SignUpMetaData.sharedInstance.currentSalarySelectedDict["answer"]?["salary"] as! String
        }
        self.view.addSubview(popup)
        popup.showPopup()
    }
    
//MARK:- Fresher Button Action

    @IBAction func fresherBtnAction(_ sender: Any)
    {
        fresherBtn.isSelected = !fresherBtn.isSelected
        if fresherBtn.isSelected {
            var mData = [String:AnyObject]()
            mData["salary"] = "0" as AnyObject?
            mData["salaryTypeID"] = "3" as AnyObject?
            SignUpMetaData.sharedInstance.currentSalarySelectedDict = ["answer":mData as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.currentSalaryDict["obQuestionID"]!]
            hourBtnView.backgroundColor = UIColor(red: 108.0/255.0, green: 105.0/255.0, blue: 217.0/255.0, alpha: 1.0)
            monthBtnView.backgroundColor = UIColor(red: 108.0/255.0, green: 105.0/255.0, blue: 217.0/255.0, alpha: 1.0)
            hourBtn.isSelected = false
            monthBtn.isSelected = false
            salaryeLabel.text = "Current Salary"
        }
        else
        {
            SignUpMetaData.sharedInstance.currentSalarySelectedDict = [String:AnyObject]()
        }
    }
}

//MARK:- Extension CurrentSalaryDelegate

extension CurrentSalaryVC:CurrentSalaryDelegate
{
    func callBackWithDict(data:[String:AnyObject])
    {
        if data["salary"] != nil
        {
            var mData = data
            if hourBtn.isSelected
            {
                mData["salaryTypeID"] = "2" as AnyObject?
            }
            else if monthBtn.isSelected
            {
                mData["salaryTypeID"] = "1" as AnyObject?
            }
            mData["currency"] = nil
            salaryeLabel.text = "\(currency!) \(data["salary"] as! String)"
            SignUpMetaData.sharedInstance.currentSalarySelectedDict = ["answer":mData as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.currentSalaryDict["obQuestionID"]!]
        }
    }
}
