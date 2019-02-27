//
//  JobTypeVC.swift
//  JobJira
//
//  Created by Vaibhav on 26/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
class JobTypeVC: UIViewController
{
    
//MARK:- IBOulets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var jobTypeTable: UITableView!
    
//MARK:- Variables and Costants
    
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
        if (SignUpMetaData.sharedInstance.jobTypeDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.jobTypeDict
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
        let questionOptions = dataDict["questionOptions"]?["job_types"] as? [AnyObject]
        optionsArray = questionOptions!
        if SignUpMetaData.sharedInstance.jobTypeSelecedArray.count>0
        {
            selectedArray = SignUpMetaData.sharedInstance.jobTypeSelecedArray as [AnyObject]
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
            SignUpMetaData.sharedInstance.jobTypeSelecedArray = selectedArray as! [[String : AnyObject]]
            if editFlag == true
            {
                SignUpMetaData.sharedInstance.userInfoDict["jobTypes"] = SignUpMetaData.sharedInstance.jobTypeSelecedArray as AnyObject
                let _ = navigationController?.popViewController(animated: true)
            }
            else
            {
                SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
            }
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please select your job type to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
}

//MARK: Extension Tableview Datasources

extension JobTypeVC:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTypeCell") as! JobTypeCell
        cell.selectionStyle = .none
        cell.jobTypeLabel.text = optionsArray[indexPath.row]["jobType"] as? String
        cell.jobTypeBtn.addTarget(self, action: #selector(JobTypeVC.jobTypeSelectionBtnAction(_:)), for: .touchUpInside)
        cell.jobTypeBtn.tag = indexPath.row
        cell.jobTypeBtn.isSelected = false
        cell.btnSuperView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
        for element in selectedArray
        {
            if element["jobTypeID"] as! String == optionsArray[indexPath.row]["jobTypeID"] as! String
            {
                cell.jobTypeBtn.isSelected = true
                cell.btnSuperView.backgroundColor = UIColor(red: 221.0/255.0, green: 197.0/255.0, blue: 149.0/255.0, alpha: 1.0)
                break
            }
        }
        return cell
    }
    
    func jobTypeSelectionBtnAction(_ sender:UIButton)
    {
        sender.isSelected = !sender.isSelected
        if sender.isSelected
        {
            if sender.tag == optionsArray.count-1
            {
                selectedArray.removeAll()
                selectedArray.append(optionsArray[sender.tag])
                jobTypeTable.reloadData()
            }
            else
            {
                if selectedArray.count>0
                {
                    if selectedArray.count == 1 && selectedArray[0]["jobType"] as! String == "All"
                    {
                        selectedArray.removeAll()
                        selectedArray.append(optionsArray[sender.tag])
                        jobTypeTable.reloadData()
                    }
                    else
                    {
                        selectedArray.append(optionsArray[sender.tag])
                        sender.superview?.backgroundColor = UIColor(red: 221.0/255.0, green: 197.0/255.0, blue: 149.0/255.0, alpha: 1.0)
                    }
                }
                else
                {
                    selectedArray.append(optionsArray[sender.tag])
                    sender.superview?.backgroundColor = UIColor(red: 221.0/255.0, green: 197.0/255.0, blue: 149.0/255.0, alpha: 1.0)
                }
            }
        }
        else
        {
            for (index,element) in selectedArray.enumerated()
            {
                if element["jobTypeID"] as! String == optionsArray[sender.tag]["jobTypeID"] as! String
                {
                    selectedArray.remove(at: index)
                    sender.superview?.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
                    break
                }
            }
        }
    }
}

