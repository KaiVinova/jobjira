//
//  LanguageVC.swift
//  JobJira
//
//  Created by Vaibhav on 30/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import KYDrawerController
class LanguageVC: UIViewController
{

//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var languageTable: UITableView!
    @IBOutlet weak var backBtn: UIButton!

//MARK:- Variables and Constants
    
    var dataDict = [String:AnyObject]()
    var optionsArray = [AnyObject]()
    var selectedArray = [AnyObject]()
    var editFlag:Bool!
    var afterSignUpFlag:Bool!
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
        if (SignUpMetaData.sharedInstance.languageDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.languageDict
        }
        if editFlag == true
        {
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
        let questionOptions = dataDict["questionOptions"]?["speakingLanguages"] as? [AnyObject]
        optionsArray = questionOptions!
        if SignUpMetaData.sharedInstance.languageSelectedDict.count>0
        {
            selectedArray = SignUpMetaData.sharedInstance.languageSelectedDict as [AnyObject]
            languageTable.reloadData()
        }
    }
    
//MARK:- BAck Button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        let _ = navigationController?.popViewController(animated: true)
    }
    
//MARK:- Done Button Action
    
    @IBAction func doneBtnAction(_ sender: Any)
    {
        if selectedArray.count>0
        {
            SignUpMetaData.sharedInstance.languageSelectedDict = selectedArray as! [[String : AnyObject]]
            if editFlag == true
            {
                SignUpMetaData.sharedInstance.userInfoDict["speakingLanguages"] = SignUpMetaData.sharedInstance.languageSelectedDict as AnyObject
                let _ = navigationController?.popViewController(animated: true)
            }
            else
            {
                if afterSignUpFlag == true
                {
                    postData()
                }
                else
                {
                    SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
                }
            }
        }
            
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please select your language to proceed", preferredStyle: UIAlertControllerStyle.alert)
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
        if self.afterSignUpFlag == true
        {
            SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequencePostLogin(self.navigationController!)
        }
        else
        {
            SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
        }
    }
    
//MARK: - Post SignUp Data API
    
    func postData()
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        var dataArray = [[String:AnyObject]]()
        if SignUpMetaData.sharedInstance.languageSelectedDict.count > 0
        {
            var tempArray = [String]()
            for element in SignUpMetaData.sharedInstance.languageSelectedDict
            {
                tempArray.append(element["speakingLangName"] as! String)
            }
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = tempArray as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.languageDict["obQuestionID"]
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

//MARK:  Extension Tableview Datasources

extension LanguageVC:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return optionsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageSelectionCell") as! LanguageSelectionCell
        cell.selectionStyle = .none
        cell.languageLabel.text = optionsArray[indexPath.row]["speakingLangName"] as? String
        cell.languageSelectionBtn.addTarget(self, action: #selector(LanguageVC.languageSelectionBtnAction(_:)), for: .touchUpInside)
        cell.languageSelectionBtn.tag = indexPath.row
        cell.languageSelectionBtn.isSelected = false
        if selectedArray.count>0
        {
            for element in selectedArray
            {
                if element["speakingLangID"] as! String == optionsArray[indexPath.row]["speakingLangID"] as! String
                {
                    cell.languageSelectionBtn.isSelected = true
                }
            }
        }
        return cell
    }
    
//MARK:- Select Language Button Action
    
    func languageSelectionBtnAction(_ sender:UIButton)
    {
        if sender.isSelected == true
        {
            for (index, element) in selectedArray.enumerated()
            {
                if element["speakingLangID"] as! String == optionsArray[sender.tag]["speakingLangID"] as! String
                {
                    selectedArray.remove(at: index)
                }
            }
        }
        else
        {
            selectedArray.append(optionsArray[sender.tag])
        }
        languageTable.reloadData()
    }
}

//MARK: Tableview Delegates

extension LanguageVC:UITableViewDelegate
{
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
        {
            tableView.deselectRow(at: indexPath, animated: true)
            let cell:LanguageSelectionCell = tableView.cellForRow(at: indexPath) as! LanguageSelectionCell
            if cell.languageSelectionBtn.isSelected == true
            {
                for (index, element) in selectedArray.enumerated()
                {
                    if element["speakingLangID"] as! String == optionsArray[indexPath.row]["speakingLangID"] as! String
                    {
                        selectedArray.remove(at: index)
                    }
                }
            }
            else
            {
                selectedArray.append(optionsArray[indexPath.row])
            }
            languageTable.reloadData()
        }
}
