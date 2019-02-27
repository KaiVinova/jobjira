//
//  SkillsVC.swift
//  JobJira
//
//  Created by Vaibhav on 25/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import TagListView
import KYDrawerController
class SkillsVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subTitle2Label: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    
//MARK:- Variables and Constants
    
    var dataDict = [String:AnyObject]()
    var optionsArray = [AnyObject]()
    var selectedArray = [AnyObject]()
    var editFlag:Bool!
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
        tagListView.delegate = self
        tagListView.textFont = UIFont(name: ".SFUIText-Bold", size: 18)!
        if (SignUpMetaData.sharedInstance.skillsDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.skillsDict
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
        subTitle2Label.text = dataDict["questionInfo"]?["h2"] as? String
        let questionOptions = dataDict["questionOptions"]?["skills"] as? [AnyObject]
        optionsArray = questionOptions!
        if optionsArray.count>0
        {
            for element in optionsArray
            {
                tagListView.addTag(element["primarySkillName"] as! String)
            }
        }
        if SignUpMetaData.sharedInstance.skillsSelectedArray.count>0
        {
            selectedArray = SignUpMetaData.sharedInstance.skillsSelectedArray as [AnyObject]
            for element in selectedArray
            {
                for object in tagListView.tagViews
                {
                    if object.titleLabel?.text == element["primarySkillName"] as? String
                    {
                        selectedArray.append(element as AnyObject)
                        let selectedIcon = object.subviews.last as! UIImageView
                        selectedIcon.isHidden = object.isSelected
                        object.isSelected = !object.isSelected
                    }
                }
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
        if selectedArray.count>0
        {
            SignUpMetaData.sharedInstance.skillsSelectedArray = selectedArray as! [[String : AnyObject]]
            if editFlag == true
            {
                SignUpMetaData.sharedInstance.userInfoDict["skills"] = SignUpMetaData.sharedInstance.skillsSelectedArray as AnyObject
                let _ = navigationController?.popViewController(animated: true)
            }
            else
            {
                SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
            }
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please select your skills to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
}

//MARK:- Extension TagListViewDelegate

extension SkillsVC:TagListViewDelegate
{
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView)
    {
        print("Tag pressed: \(title), \(sender)")
        let selectedIcon = tagView.subviews.last as! UIImageView
        selectedIcon.isHidden = tagView.isSelected
        tagView.isSelected = !tagView.isSelected
        if selectedArray.count>0
        {
            selectedArray.removeAll()
        }
        for element in sender.selectedTags()
        {
            for object in optionsArray
            {
                if element.titleLabel?.text == object["primarySkillName"] as? String{
                    selectedArray.append(object)
                    break
                }
            }
        }
    }
}
