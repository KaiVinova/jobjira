//
//  AvailablityVC.swift
//  JobJira
//
//  Created by Vaibhav on 12/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import KYDrawerController
class AvailablityVC: UIViewController
{
    
//MARK:- IBOutlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var jobTypeTable: UITableView!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
//MARK:- Variables and Constants

    var dataDict = [String:AnyObject]()
    var optionsArray = [AnyObject]()
    var selectedArray = [AnyObject]()
    var editFlag:Bool!
    
//MARk:- View LifeCycle

    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
        
        if (SignUpMetaData.sharedInstance.availabilityDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.availabilityDict
        }
        if editFlag == true
        {
            skipBtn.isHidden = true
        }
        else
        {
            if self.navigationController?.viewControllers.count==2
            {
                backBtn.isHidden = true
            }
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
        let questionOptions = dataDict["questionOptions"]?["availability"] as? [AnyObject]
        optionsArray = questionOptions!
        if SignUpMetaData.sharedInstance.availabilitySelectedArray.count>0
        {
            selectedArray = SignUpMetaData.sharedInstance.availabilitySelectedArray as [AnyObject]
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
            SignUpMetaData.sharedInstance.availabilitySelectedArray = selectedArray as! [[String : AnyObject]]
            if editFlag == true
            {
                SignUpMetaData.sharedInstance.userInfoDict["availabilityType"] = SignUpMetaData.sharedInstance.availabilitySelectedArray[0]["availabilityType"] as AnyObject
                let _ = navigationController?.popViewController(animated: true)
            }
            else
            {
                postData()
            }
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please mark your availability to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
//MARK:- Skip Button Action
    
    @IBAction func skipBtnAction(_ sender: Any)
    {
        SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequencePostLogin(self.navigationController!)
    }
    
//MARK: - Post SignUp Data API
    
    func postData()
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        var dataArray = [[String:AnyObject]]()
        if SignUpMetaData.sharedInstance.availabilitySelectedArray.count > 0
        {
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = SignUpMetaData.sharedInstance.availabilitySelectedArray[0]["availabilityTypeID"] as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.availabilityDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        dict["data"] = dataArray as AnyObject?
        print(dict)
        KVNProgress.show()
        UserService.updateProfileWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let result = data!["result"]?["userInfo"]!
                print(result ?? "No Value")
                UserDefaults.standard.set(result, forKey: "userInfo")
                SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequencePostLogin(self.navigationController!)
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

//MARK: Extension Tableview Datasources

extension AvailablityVC:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTypeCell") as! JobTypeCell
        cell.selectionStyle = .none
        cell.jobTypeLabel.text = optionsArray[indexPath.row]["availabilityType"] as? String
        cell.jobTypeBtn.addTarget(self, action: #selector(JobTypeVC.jobTypeSelectionBtnAction(_:)), for: .touchUpInside)
        cell.jobTypeBtn.tag = indexPath.row
        cell.jobTypeBtn.isSelected = false
        cell.btnSuperView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
        for element in selectedArray
        {
            if element["availabilityTypeID"] as! String == optionsArray[indexPath.row]["availabilityTypeID"] as! String
            {
                cell.jobTypeBtn.isSelected = true
                cell.btnSuperView.backgroundColor = UIColor(red: 221.0/255.0, green: 197.0/255.0, blue: 149.0/255.0, alpha: 1.0)
                break
            }
        }
        return cell
    }
    
//MARK:- Job type selection Button Action
    
    func jobTypeSelectionBtnAction(_ sender:UIButton)
    {
        selectedArray.removeAll()
        selectedArray.append(optionsArray[sender.tag])
        jobTypeTable.reloadData()
    }
}
