//
//  JobDetailVC.swift
//  JobJira
//
//  Created by Vaibhav on 29/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
import KVNProgress
import IQKeyboardManager
class JobDetailVC: UIViewController
{

//MARK:- IBOutlets
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var jobDetailTable: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var companyLogoImage: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var companyDescription: UILabel!
    
//MARK:- Variables and Constants
    
    var actionDelegate:JobDetailDelegate!
    var fromScreen:String!
    var jobID:String!
    var employerResponseId:String!
    var userActionId:String!
    var jobActiveId:String!
    var rowCount = 6
    var jobDetailDict = [String:AnyObject]()
    var answerArray = [String]()
    var maxLen = 200
    var minLen = 10

//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
        jobDetailTable.estimatedRowHeight = 100
        companyDescription.text = ""
        if fromScreen == "activity"
        {
            saveBtn.isHidden = true
        }
        getJobDetails()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 60
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 10
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
//MARK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
//MARK:- Save Button Action
    
    @IBAction func saveBtnAction(_ sender: Any)
    {
        respondToCard("3", jobID: jobID)
    }
   
//MARK: - Get Card Data
    
    func getJobDetails()
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        dict["jobID"] = jobID as AnyObject?
        KVNProgress.show()
        UserService.getJobDetailWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let result = data!["result"]?["jobInfo"] as! [String:AnyObject]
                print(result)
                self.setDataFromServer(result)
            }
            else
            {
                let alert = UIAlertController(title: AppName, message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
                if data != nil
                {
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        AppDelegate.shared.popAndLogout(self)
                    })
                    alert.addAction(action)
                }
                else
                {
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                }
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
//MARK:- Method for Save Response
    
    func setDataFromServer(_ dict:[String:AnyObject])
    {
        jobDetailDict = dict
        if fromScreen == "activity"
        {
            if jobActiveId == "2"
            {
                if employerResponseId == "1"
                {
                    rowCount = 6
                }
                else
                {
                    rowCount = 5
                }
            }
            else
            {
                rowCount = 5
            }
        }
        if userActionId != "1"
        {
            rowCount = rowCount+(jobDetailDict["additionalQuestions"] as! [AnyObject]).count
            if (jobDetailDict["additionalQuestions"] as! [AnyObject]).count>0
            {
                for _ in (jobDetailDict["additionalQuestions"] as! [AnyObject])
                {
                    answerArray.append("")
                }
            }
        }
        titleLbl.text = jobDetailDict["jobDetails"]?["title"] as? String
        subTitleLbl.text = jobDetailDict["companyDescription"]?["companyName"] as? String
        companyLogoImage.setImageWithString(jobDetailDict["companyDescription"]?["profilePicture"] as? String)
        companyDescription.text = jobDetailDict["companyDescription"]?["companyDescription"] as? String
        jobDetailTable.reloadData()
        if let headerView = jobDetailTable.tableHeaderView
        {
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            if height != headerFrame.size.height
            {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                jobDetailTable.tableHeaderView = headerView
            }
        }
        let indexPath = IndexPath(item: 2, section: 0)
        jobDetailTable.reloadRows(at: [indexPath], with: .top)
    }
    
//MARK: - Respond to Card
    
    func respondToCard(_ actionID:String, jobID:String)
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        dict["jobSeekerJobActionTypeID"] = actionID as AnyObject?
        dict["jobID"] = jobID as AnyObject?
        if actionID == "1"
        {
            var tempArray = [AnyObject]()
            for (index, element) in answerArray.enumerated()
            {
                if element != ""
                {
                    var tempDict = [String:AnyObject]()
                    let questionDict = (jobDetailDict["additionalQuestions"] as! [AnyObject])[index] as? [String:AnyObject]
                    tempDict["jobAdditionalQuestionID"] = questionDict?["jobAdditionalQuestionID"]
                    tempDict["answer"] = element as AnyObject?
                    tempArray.append(tempDict as AnyObject)
                }
            }
            dict["data"] = tempArray as AnyObject?
        }
        KVNProgress.show()
        UserService.actionForJobCardWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                print(data ?? "No Value")
                let message:String!
                if actionID == "1"
                {
                    message = "You have successfully applied for the job!"
                }
                else if actionID == "2"
                {
                    message = "You have successfully skipped the job!"
                }
                else if actionID == "3"
                {
                    message = "You have successfully saved the job!"
                }
                else
                {
                    message = "You have successfully withdrawn the job!"
                }
                let alert = UIAlertController(title: AppName, message: message, preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    self.actionDelegate.callBackWithAction!(actionID)
                    _ = self.navigationController?.popViewController(animated: true)
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                let alert = UIAlertController(title: AppName, message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
                if data != nil
                {
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        AppDelegate.shared.popAndLogout(self)
                    })
                    alert.addAction(action)
                }
                else
                {
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                }
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
}

//MARK:- Extension UITableViewDelegate

extension JobDetailVC:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
}

//MARK:- Extension UITableViewDataSource

extension JobDetailVC:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if fromScreen == "activity"
        {
            if jobDetailDict.count>0
            {
                return rowCount
            }
            else
            {
                return 0
            }
        }
        else
        {
            if jobDetailDict.count>0
            {
                return rowCount
            }
            else
            {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if fromScreen == "activity"
        {
            switch indexPath.row
            {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JobDetailCell1", for: indexPath) as! JobDetailCell
                    cell.selectionStyle = .none
                    let jobDict = jobDetailDict["jobDetails"] as! [String:AnyObject]
                    cell.titleNameLbl.text = "Job Description"
                    cell.descriptionLbl.text = jobDict["shortDescription"] as? String
                    return cell
                case 1:
                    return configureSecondCell(tableView, indexPath: indexPath)
                case 2:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JobDetailCell3", for: indexPath) as! JobDetailCell
                    cell.selectionStyle = .none
                    let jobRolesDict = jobDetailDict["jobRoles"] as! [String:AnyObject]
                    cell.titleNameLbl.text = jobRolesDict["text"] as? String
                    let jobRolesArray = jobRolesDict["values"] as! [String]
                    cell.tagView.removeAllTags()
                    if jobRolesArray.count>0
                    {
                        for element in jobRolesArray
                        {
                            cell.tagView.addTag(element)
                        }
                    }
                    return cell
                case 3:
                    return configureFourthCell(tableView, indexPath: indexPath)
                case 4:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JobDetailCell1", for: indexPath) as! JobDetailCell
                    cell.selectionStyle = .none
                    let jobDict = jobDetailDict["jobDetails"] as! [String:AnyObject]
                    cell.titleNameLbl.text = "Job Scope"
                    cell.descriptionLbl.text = jobDict["longDescription"] as? String
                    return cell
                case rowCount-1:
                    if userActionId == "1"
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "JobDetailCell7", for: indexPath) as! JobDetailCell
                        cell.selectionStyle = .none
                        cell.withdrawBtn.addTarget(self, action: #selector(JobDetailVC.withdrawBtnAction(_:)), for: .touchUpInside)
                        cell.withdrawBtn.tag = indexPath.row
                        return cell
                    }
                    else if userActionId == "2"
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "JobDetailCell6", for: indexPath) as! JobDetailCell
                        cell.selectionStyle = .none
                        cell.applyBtn.addTarget(self, action: #selector(JobDetailVC.applyBtnAction(_:)), for: .touchUpInside)
                        cell.applyBtn.tag = indexPath.row
                        return cell
                    }
                    else
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "JobDetailCell5", for: indexPath) as! JobDetailCell
                        cell.selectionStyle = .none
                        cell.skipBtn.addTarget(self, action: #selector(JobDetailVC.skipBtnAction(_:)), for: .touchUpInside)
                        cell.skipBtn.tag = indexPath.row
                        cell.applyBtn.addTarget(self, action: #selector(JobDetailVC.applyBtnAction(_:)), for: .touchUpInside)
                        cell.applyBtn.tag = indexPath.row
                        return cell
                    }
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JobDetailCell8", for: indexPath) as! JobDetailCell
                    cell.selectionStyle = .none
                    let jobExtraQuestionsArray = jobDetailDict["additionalQuestions"] as! [AnyObject]
                    let jobExtraQuestionsDict = jobExtraQuestionsArray[indexPath.row-5] as! [String:AnyObject]
                    cell.questionLbl.text = jobExtraQuestionsDict["questionText"] as? String
                    cell.titleNameLbl.text = "Question #\(indexPath.row-4)"
                    if answerArray[indexPath.row-5] != ""
                    {
                        cell.answerTxt.text = answerArray[indexPath.row-5]
                        cell.answerTxt.textColor = UIColor.darkGray
                        let numberOfChars = cell.answerTxt.text.characters.count
                        let leftCount = maxLen - numberOfChars
                        if leftCount < 1
                        {
                            cell.charCountLbl.text = "\(leftCount) Character"
                        }
                        else
                        {
                            cell.charCountLbl.text = "\(leftCount) Characters"
                        }
                    }
                    return cell
            }
        }
        else
        {
            switch indexPath.row
            {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JobDetailCell1", for: indexPath) as! JobDetailCell
                    cell.selectionStyle = .none
                    let jobDict = jobDetailDict["jobDetails"] as! [String:AnyObject]
                    cell.titleNameLbl.text = "Job Description"
                    cell.descriptionLbl.text = jobDict["shortDescription"] as? String
                    return cell
                case 1:
                    return configureSecondCell(tableView, indexPath: indexPath)
                case 2:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JobDetailCell3", for: indexPath) as! JobDetailCell
                    cell.selectionStyle = .none
                    let jobRolesDict = jobDetailDict["jobRoles"] as! [String:AnyObject]
                    cell.titleNameLbl.text = jobRolesDict["text"] as? String
                    let jobRolesArray = jobRolesDict["values"] as! [String]
                    cell.tagView.removeAllTags()
                    if jobRolesArray.count>0
                    {
                        for element in jobRolesArray
                        {
                            cell.tagView.addTag(element)
                        }
                    }
                    return cell
                case 3:
                    return configureFourthCell(tableView, indexPath: indexPath)
                case 4:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JobDetailCell1", for: indexPath) as! JobDetailCell
                    cell.selectionStyle = .none
                    let jobDict = jobDetailDict["jobDetails"] as! [String:AnyObject]
                    cell.titleNameLbl.text = "Job Scope"
                    cell.descriptionLbl.text = jobDict["longDescription"] as? String
                    return cell
                case rowCount-1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JobDetailCell5", for: indexPath) as! JobDetailCell
                    cell.selectionStyle = .none
                    cell.skipBtn.addTarget(self, action: #selector(JobDetailVC.skipBtnAction(_:)), for: .touchUpInside)
                    cell.skipBtn.tag = indexPath.row
                    cell.applyBtn.addTarget(self, action: #selector(JobDetailVC.applyBtnAction(_:)), for: .touchUpInside)
                    cell.applyBtn.tag = indexPath.row
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JobDetailCell8", for: indexPath) as! JobDetailCell
                    cell.selectionStyle = .none
                    let jobExtraQuestionsArray = jobDetailDict["additionalQuestions"] as! [AnyObject]
                    let jobExtraQuestionsDict = jobExtraQuestionsArray[indexPath.row-5] as! [String:AnyObject]
                    cell.questionLbl.text = jobExtraQuestionsDict["questionText"] as? String
                    cell.titleNameLbl.text = "Question #\(indexPath.row-4)"
                    if answerArray[indexPath.row-5] != ""
                    {
                        cell.answerTxt.text = answerArray[indexPath.row-5]
                        cell.answerTxt.textColor = UIColor.darkGray
                        let numberOfChars = cell.answerTxt.text.characters.count
                        let leftCount = maxLen - numberOfChars
                        if leftCount < 1
                        {
                            cell.charCountLbl.text = "\(leftCount) Character"
                        }
                        else
                        {
                            cell.charCountLbl.text = "\(leftCount) Characters"
                        }
                    }
                return cell
            }
        }
    }
    
    func configureSecondCell(_ table:UITableView, indexPath:IndexPath) -> JobDetailCell
    {
        let cell = table.dequeueReusableCell(withIdentifier: "JobDetailCell2", for: indexPath) as! JobDetailCell
        cell.selectionStyle = .none
        if  cell.containerView.viewWithTag(1001) == nil
        {
            let jobOtherDetailArray = jobDetailDict["jobOtherDetails"] as! [AnyObject]
            if jobOtherDetailArray.count>0
            {
                var heightValue:String!
                for (index, element) in jobOtherDetailArray.enumerated()
                {
                    if index == 0
                    {
                        let titleLbl = UILabel()
                        titleLbl.text = element["text"] as? String
                        titleLbl.numberOfLines = 0
                        titleLbl.textColor = UIColor.darkGray
                        titleLbl.translatesAutoresizingMaskIntoConstraints = false
                        titleLbl.font = UIFont(name: ".SFUIText-Light", size: 12)!
                        titleLbl.tag = index+1001
                        cell.containerView.addSubview(titleLbl)
                        cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .left, relatedBy: .equal, toItem: cell.containerView, attribute: .left, multiplier: 1.0, constant: 10.0 ))
                        cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .top, relatedBy: .equal, toItem: cell.containerView, attribute: .top, multiplier: 1.0, constant: 10.0 ))
                        cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: (self.view.frame.size.width/2)-25 ))
                        let valueLbl = UILabel()
                        var value = ""
                        for (vIndex, item) in (element["values"] as! [String]).enumerated()
                        {
                            if vIndex == 0
                            {
                                value = item
                            }
                            else
                            {
                                value = "\(value)\n\(item)"
                            }
                        }
                        valueLbl.text = value
                        valueLbl.numberOfLines = 0
                        valueLbl.textColor = UIColor.darkGray
                        valueLbl.translatesAutoresizingMaskIntoConstraints = false
                        valueLbl.font = UIFont(name: ".SFUIText-Light", size: 12)!
                        valueLbl.tag = index+2001
                        cell.containerView.addSubview(valueLbl)
                        cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .left, relatedBy: .equal, toItem: titleLbl, attribute: .right, multiplier: 1.0, constant: 10.0 ))
                        cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .top, relatedBy: .equal, toItem: titleLbl, attribute: .top, multiplier: 1.0, constant: 0.0 ))
                        cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: (self.view.frame.size.width/2)-25 ))
                        if titleLbl.numberOfLines<=valueLbl.numberOfLines
                        {
                            cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .bottom, relatedBy: .equal, toItem: cell.containerView, attribute: .bottom, multiplier: 1.0, constant: -10.0 ))
                            heightValue = "1"
                        }
                        else
                        {
                            cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .bottom, relatedBy: .equal, toItem: cell.containerView, attribute: .bottom, multiplier: 1.0, constant: -10.0 ))
                            heightValue = "2"
                        }
                    }
                    else
                    {
                        let previousTitleLbl = cell.containerView.viewWithTag(index+1000) as! UILabel
                        let previousValueLbl = cell.containerView.viewWithTag(index+2000) as! UILabel
                        for constarint in cell.containerView.constraints
                        {
                            if constarint.firstAttribute == .bottom
                            {
                                cell.containerView.removeConstraint(constarint)
                            }
                        }
                        let titleLbl = UILabel()
                        titleLbl.text = element["text"] as? String
                        titleLbl.numberOfLines = 0
                        titleLbl.textColor = UIColor.darkGray
                        titleLbl.translatesAutoresizingMaskIntoConstraints = false
                        titleLbl.font = UIFont(name: ".SFUIText-Light", size: 12)!
                        titleLbl.tag = index+1001
                        cell.containerView.addSubview(titleLbl)
                        cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .left, relatedBy: .equal, toItem: cell.containerView, attribute: .left, multiplier: 1.0, constant: 10.0 ))
                        if heightValue == "1"
                        {
                            cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .top, relatedBy: .equal, toItem: previousValueLbl, attribute: .bottom, multiplier: 1.0, constant: 5.0 ))
                        }
                        else
                        {
                            cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .top, relatedBy: .equal, toItem: previousTitleLbl, attribute: .bottom, multiplier: 1.0, constant: 5.0 ))
                        }
                        cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: (self.view.frame.size.width/2)-25 ))
                        let valueLbl = UILabel()
                        var value = ""
                        for (vIndex, item) in (element["values"] as! [String]).enumerated()
                        {
                            if vIndex == 0
                            {
                                value = item
                            }
                            else
                            {
                                value = "\(value)\n\(item)"
                            }
                        }
                        valueLbl.text = value
                        valueLbl.numberOfLines = 0
                        valueLbl.textColor = UIColor.darkGray
                        valueLbl.translatesAutoresizingMaskIntoConstraints = false
                        valueLbl.font = UIFont(name: ".SFUIText-Light", size: 12)!
                        valueLbl.tag = index+2001
                        cell.containerView.addSubview(valueLbl)
                        cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .left, relatedBy: .equal, toItem: titleLbl, attribute: .right, multiplier: 1.0, constant: 10.0 ))
                        cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .top, relatedBy: .equal, toItem: titleLbl, attribute: .top, multiplier: 1.0, constant: 0.0 ))
                        cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: (self.view.frame.size.width/2)-25 ))
                            if titleLbl.numberOfLines<=valueLbl.numberOfLines
                            {
                                cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .bottom, relatedBy: .equal, toItem: cell.containerView, attribute: .bottom, multiplier: 1.0, constant: -10.0 ))
                                heightValue = "1"
                            }
                            else
                            {
                                cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .bottom, relatedBy: .equal, toItem: cell.containerView, attribute: .bottom, multiplier: 1.0, constant: -10.0 ))
                                heightValue = "2"
                            }
                        }
                    }
                }
            }
        return cell
    }
    
    func configureFourthCell(_ table:UITableView, indexPath:IndexPath) -> JobDetailCell
    {
        let cell = table.dequeueReusableCell(withIdentifier: "JobDetailCell4", for: indexPath) as! JobDetailCell
        cell.selectionStyle = .none
        if  cell.containerView.viewWithTag(1001) == nil
        {
            let desiredProfileDetailsArray = jobDetailDict["desiredProfileDetails"] as! [AnyObject]
            if desiredProfileDetailsArray.count>0
            {
                var heightValue:String!
                for (index, element) in desiredProfileDetailsArray.enumerated()
                {
                    if index == 0
                    {
                        let titleLbl = UILabel()
                        titleLbl.text = element["text"] as? String
                        titleLbl.numberOfLines = 0
                        titleLbl.textColor = UIColor.darkGray
                        titleLbl.translatesAutoresizingMaskIntoConstraints = false
                        titleLbl.font = UIFont(name: ".SFUIText-Light", size: 12)!
                        titleLbl.tag = index+1001
                        cell.containerView.addSubview(titleLbl)
                        cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .left, relatedBy: .equal, toItem: cell.containerView, attribute: .left, multiplier: 1.0, constant: 10.0 ))
                        cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .top, relatedBy: .equal, toItem: cell.dividerView, attribute: .top, multiplier: 1.0, constant: 10.0 ))
                        cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: (self.view.frame.size.width/2)-25 ))
                        let valueLbl = UILabel()
                        var value = ""
                        if element.count>1
                        {
                            for (vIndex, item) in (element["values"] as! [String]).enumerated()
                            {
                                if vIndex == 0
                                {
                                    value = item
                                }
                                else
                                {
                                    value = "\(value)\n\(item)"
                                }
                            }
                        }
                        valueLbl.text = value
                        valueLbl.numberOfLines = 0
                        valueLbl.textColor = UIColor.darkGray
                        valueLbl.translatesAutoresizingMaskIntoConstraints = false
                        valueLbl.font = UIFont(name: ".SFUIText-Light", size: 12)!
                        valueLbl.tag = index+2001
                        cell.containerView.addSubview(valueLbl)
                        cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .left, relatedBy: .equal, toItem: titleLbl, attribute: .right, multiplier: 1.0, constant: 10.0 ))
                        cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .top, relatedBy: .equal, toItem: titleLbl, attribute: .top, multiplier: 1.0, constant: 0.0 ))
                        cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: (self.view.frame.size.width/2)-25 ))
                        if titleLbl.numberOfLines<=valueLbl.numberOfLines
                        {
                            cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .bottom, relatedBy: .equal, toItem: cell.containerView, attribute: .bottom, multiplier: 1.0, constant: -10.0 ))
                            heightValue = "1"
                        }
                        else
                        {
                            cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .bottom, relatedBy: .equal, toItem: cell.containerView, attribute: .bottom, multiplier: 1.0, constant: -10.0 ))
                            heightValue = "2"
                        }
                    }
                    else
                    {
                        let previousTitleLbl = cell.containerView.viewWithTag(index+1000) as! UILabel
                        let previousValueLbl = cell.containerView.viewWithTag(index+2000) as! UILabel
                        for constarint in cell.containerView.constraints
                        {
                            if constarint.firstAttribute == .bottom
                            {
                                cell.containerView.removeConstraint(constarint)
                            }
                        }
                        let titleLbl = UILabel()
                        titleLbl.text = element["text"] as? String
                        titleLbl.numberOfLines = 0
                        titleLbl.textColor = UIColor.darkGray
                        titleLbl.translatesAutoresizingMaskIntoConstraints = false
                        titleLbl.font = UIFont(name: ".SFUIText-Light", size: 12)!
                        titleLbl.tag = index+1001
                        cell.containerView.addSubview(titleLbl)
                        cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .left, relatedBy: .equal, toItem: cell.containerView, attribute: .left, multiplier: 1.0, constant: 10.0 ))
                        if heightValue == "1"
                        {
                            cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .top, relatedBy: .equal, toItem: previousValueLbl, attribute: .bottom, multiplier: 1.0, constant: 5.0 ))
                        }
                        else
                        {
                            cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .top, relatedBy: .equal, toItem: previousTitleLbl, attribute: .bottom, multiplier: 1.0, constant: 5.0 ))
                        }
                        cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: (self.view.frame.size.width/2)-25 ))
                        let valueLbl = UILabel()
                        var value = ""
                        if element.count>1
                        {
                            for (vIndex, item) in (element["values"] as! [String]).enumerated()
                            {
                                if vIndex == 0
                                {
                                    value = item
                                }
                                else
                                {
                                    value = "\(value)\n\(item)"
                                }
                            }
                        }
                        valueLbl.text = value
                        valueLbl.numberOfLines = 0
                        valueLbl.textColor = UIColor.darkGray
                        valueLbl.translatesAutoresizingMaskIntoConstraints = false
                        valueLbl.font = UIFont(name: ".SFUIText-Light", size: 12)!
                        valueLbl.tag = index+2001
                        cell.containerView.addSubview(valueLbl)
                        cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .left, relatedBy: .equal, toItem: titleLbl, attribute: .right, multiplier: 1.0, constant: 10.0 ))
                        cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .top, relatedBy: .equal, toItem: titleLbl, attribute: .top, multiplier: 1.0, constant: 0.0 ))
                        cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: (self.view.frame.size.width/2)-25 ))
                            if titleLbl.numberOfLines<=valueLbl.numberOfLines
                            {
                                cell.containerView.addConstraint(NSLayoutConstraint( item: valueLbl, attribute: .bottom, relatedBy: .equal, toItem: cell.containerView, attribute: .bottom, multiplier: 1.0, constant: -10.0 ))
                                heightValue = "1"
                            }
                            else
                            {
                                cell.containerView.addConstraint(NSLayoutConstraint( item: titleLbl, attribute: .bottom, relatedBy: .equal, toItem: cell.containerView, attribute: .bottom, multiplier: 1.0, constant: -10.0 ))
                                heightValue = "2"
                            }
                    }
                }
            }
        }
        return cell
    }
    
//MARK:- Skip Button Action
    
    func skipBtnAction(_ sender: UIButton)
    {
        respondToCard("2", jobID: jobID)
    }
    
//MARK:- Apply Button Action
    
    func applyBtnAction(_ sender: UIButton)
    {
        respondToCard("1", jobID: jobID)
    }
    
//MARK:- WithDraw Button Action
    
    func withdrawBtnAction(_ sender: UIButton)
    {
        let alert = UIAlertController(title: AppName, message: "Are you sure to withdraw this application?", preferredStyle: UIAlertControllerStyle.alert)
        let action1 =  UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
            self.respondToCard("4", jobID: self.jobID)
        })
        alert.addAction(action1)
        let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) -> Void in
        })
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK:- Extension UITextViewDelegate

extension JobDetailVC:UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView.text == "Your answer.."
        {
            textView.textColor = UIColor.darkGray
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text == "" || textView.text == "Your answer.."
        {
            textView.textColor = UIColor.lightGray
            textView.text = "Your answer.."
        }
        var cell = textView.superview?.superview?.superview as! UITableViewCell
        if !(cell.isKind(of: UITableViewCell.self))
        {
            cell = cell.superview as! UITableViewCell
        }
        let index = jobDetailTable.indexPath(for: cell)
        if cell.isKind(of: JobDetailCell.self)
        {
            let jobCell = cell as! JobDetailCell
            if jobCell.answerTxt.text != "Your answer.."
            {
                answerArray[(index?.row)!-5] = jobCell.answerTxt.text
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        var cell = textView.superview?.superview?.superview as! UITableViewCell
        if !(cell.isKind(of: UITableViewCell.self))
        {
            cell = cell.superview as! UITableViewCell
        }
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        let leftCount = maxLen - numberOfChars
        if cell.isKind(of: JobDetailCell.self)
        {
            let jobCell = cell as! JobDetailCell
            if leftCount < 1
            {
                jobCell.charCountLbl.text = "\(leftCount) Character"
            }
            else
            {
                jobCell.charCountLbl.text = "\(leftCount) Characters"
            }
        }
        return numberOfChars < maxLen;
    }
}
