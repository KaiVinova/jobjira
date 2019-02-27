//
//  ExperinceVC.swift
//  JobJira
//
//  Created by Vaibhav on 26/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
@objc protocol ExperinceDelegate
{
    @objc optional func callBackWithDict(data:[String:AnyObject])
}
class ExperinceVC: UIViewController
{

//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subTitle2Label: UILabel!
    @IBOutlet weak var experinceBtnView: UIView!
    @IBOutlet weak var experinceLabel: UILabel!
    @IBOutlet weak var experinceBtn: UIButton!
    
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
        if (SignUpMetaData.sharedInstance.experinceDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.experinceDict
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
        experinceBtnView.layer.cornerRadius=experinceBtnView.frame.size.height/2;
        experinceBtnView.layer.masksToBounds=false;
    }
    
//MARK:- Method for SetupData on View

    func setUpViewBackEndData()
    {
        titleLabel.text = dataDict["questionInfo"]?["title"] as? String
        subTitleLabel.text = dataDict["questionInfo"]?["p1"] as? String
        headerLabel.text = dataDict["questionInfo"]?["h1"] as? String
        descriptionLabel.text = dataDict["questionInfo"]?["p2"] as? String
        subTitle2Label.text = dataDict["questionInfo"]?["h2"] as? String
        let questionOptions = dataDict["questionOptions"]?["experience"] as? [AnyObject]
        self.experinceLabel.text = "Select experince"
        optionsArray = questionOptions!
        if SignUpMetaData.sharedInstance.experinceSelectedDict["answer"] as? [String:AnyObject] != nil
        {
            self.experinceLabel.text = SignUpMetaData.sharedInstance.experinceSelectedDict["answer"]?["buttonText"] as? String
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
        if SignUpMetaData.sharedInstance.experinceSelectedDict["answer"] != nil
        {
            if editFlag == true
            {
                SignUpMetaData.sharedInstance.userInfoDict["expRangeText"] = SignUpMetaData.sharedInstance.experinceSelectedDict["answer"]?["buttonText"] as AnyObject
                let _ = navigationController?.popViewController(animated: true)
            }
            else
            {
                SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
            }
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please select your experience to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
//MARK:- Experience Button Action

    @IBAction func experinceBtnAction(_ sender: Any)
    {
        showPopUpForItemDetail(withArray: optionsArray)
    }
    
// MARK: Add item detail view Method
    
    func showPopUpForItemDetail(withArray array:[AnyObject])
    {
        let popup = ExperinceSelectionView.instansiateFromNib()
        popup.experinceDelegate = self
        popup.dataArray = array
        popup.selectedExperience = experinceLabel.text
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(popup)
        popup.showPopup()
    }
}

//MARK:- Extension ExperinceDelegate

extension ExperinceVC:ExperinceDelegate
{
    func callBackWithDict(data:[String:AnyObject])
    {
        experinceLabel.text = "\(data["buttonText"] as! String)"
        SignUpMetaData.sharedInstance.experinceSelectedDict = ["answer":data as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.experinceDict["obQuestionID"]!]
    }
}
