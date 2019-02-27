//
//  CheckBoxVC.swift
//  JobJira
//
//  Created by Vaibhav on 17/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import KYDrawerController
class CheckBoxVC: UIViewController {
    
    //MARK:-IBOutlets

    var index:Int!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var languageTable: UITableView!
    var dataDict = [String:AnyObject]()
    var optionsArray = [AnyObject]()
    var selectedArray = [AnyObject]()
    var afterSignUpFlag:Bool!
    
//MARK:- View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.screenEdgePanGestureEnabled = false
        }
        if (InitializerHelper.sharedInstance.questionsArray[index]["id"]) != nil {
            dataDict = InitializerHelper.sharedInstance.questionsArray[index]["data"] as! [String : AnyObject]
        }
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight == 480{
            let font = subTitleLabel.font
            subTitleLabel.font = font?.withSize(15)
            let font1 = headerLabel.font
            headerLabel.font = font1?.withSize(19)
            let font2 = descriptionLabel.font
            descriptionLabel.font = font2?.withSize(14)
        }
        setUpViewBackEndData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Method to set up data on view

    func setUpViewBackEndData(){
        titleLabel.text = dataDict["questionInfo"]?["title"] as? String
        subTitleLabel.text = dataDict["questionInfo"]?["p1"] as? String
        headerLabel.text = dataDict["questionInfo"]?["h1"] as? String
        descriptionLabel.text = dataDict["questionInfo"]?["p2"] as? String
        let questionOptions = dataDict["questionOptions"] as? [AnyObject]
        
        optionsArray = questionOptions!
    }
    
    //MARK:- Back Button Action

    @IBAction func backBtnAction(_ sender: Any) {
        postCancelData()
    }
    
    //MARK:- Done Button Action

    @IBAction func doneBtnAction(_ sender: Any) {
        if selectedArray.count>0 {
            postData()
        }
        else{
            let alert = UIAlertController(title: AppName, message: "Choose from the options to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    //MARK:- Skip Button Action

    @IBAction func skipBtnAction(_ sender: Any) {
        let viewController = InitializerHelper.sharedInstance.pushViewControllerBasedOnSequence(self, index: self.index+1)
        if viewController != nil{
            self.navigationController?.setViewControllers([viewController!], animated: true)
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Post Answer Data API
    
    func postData()
    {
        var dict = [String:AnyObject]()
        
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        if selectedArray.count > 0{
            var tempArray = [String]()
            for element in selectedArray{
                tempArray.append(element["odQuestionOptionID"] as! String)
            }
            dict["answer"] = tempArray as AnyObject?
            dict["obQuestionID"] = dataDict["questionInfo"]?["obQuestionID"] as AnyObject
        }
        print(dict)
        KVNProgress.show()
        UserService.postAnswerOnDemandWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success{
                let result = data!["result"]?["userInfo"]!
                print(result ?? "No Value")
                let viewController = InitializerHelper.sharedInstance.pushViewControllerBasedOnSequence(self, index: self.index+1)
                if viewController != nil{
                    self.navigationController?.setViewControllers([viewController!], animated: true)
                }
                else{
                    self.dismiss(animated: true, completion: nil)
                }
            }else{
                let alert = UIAlertController(title: AppName, message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
                if data != nil{
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        AppDelegate.shared.popAndLogout(self)
                    })
                    alert.addAction(action)
                }
                else{
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                }
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    //MARK: - Post Cancel Data API
    
    func postCancelData()
    {
        var dict = [String:AnyObject]()
        
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        dict["obQuestionID"] = dataDict["questionInfo"]?["obQuestionID"] as AnyObject
        
        print(dict)
        KVNProgress.show()
        UserService.postCancelOnDemandWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success{
                let result = data!["result"]?["userInfo"]!
                print(result ?? "No Value")
                let viewController = InitializerHelper.sharedInstance.pushViewControllerBasedOnSequence(self, index: self.index+1)
                if viewController != nil{
                    self.navigationController?.setViewControllers([viewController!], animated: true)
                }
                else{
                    self.dismiss(animated: true, completion: nil)
                }
            }else{
                let alert = UIAlertController(title: AppName, message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
                if data != nil{
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        AppDelegate.shared.popAndLogout(self)
                    })
                    alert.addAction(action)
                }
                else{
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                }
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
}
//MARK: Tableview Datasources

extension CheckBoxVC:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageSelectionCell") as! LanguageSelectionCell
        cell.selectionStyle = .none
        cell.languageLabel.text = optionsArray[indexPath.row]["optionText"] as? String
        cell.languageSelectionBtn.addTarget(self, action: #selector(CheckBoxVC.languageSelectionBtnAction(_:)), for: .touchUpInside)
        cell.languageSelectionBtn.tag = indexPath.row
        cell.languageSelectionBtn.isSelected = false
        if selectedArray.count>0 {
            for element in selectedArray {
                if element["odQuestionOptionID"] as! String == optionsArray[indexPath.row]["odQuestionOptionID"] as! String {
                    cell.languageSelectionBtn.isSelected = true
                }
            }
        }
        return cell
    }
    
    func languageSelectionBtnAction(_ sender:UIButton){
        if sender.isSelected == true{
            for (index, element) in selectedArray.enumerated() {
                if element["odQuestionOptionID"] as! String == optionsArray[sender.tag]["odQuestionOptionID"] as! String {
                    selectedArray.remove(at: index)
                }
            }
        }
        else{
            selectedArray.append(optionsArray[sender.tag])
        }
        languageTable.reloadData()
    }
}

//MARK: Tableview Delegates

extension CheckBoxVC:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        let cell:LanguageSelectionCell = tableView.cellForRow(at: indexPath) as! LanguageSelectionCell
        
        if cell.languageSelectionBtn.isSelected == true{
            for (index, element) in selectedArray.enumerated() {
                if element["odQuestionOptionID"] as! String == optionsArray[indexPath.row]["odQuestionOptionID"] as! String {
                    selectedArray.remove(at: index)
                }
            }
        }
        else{
            selectedArray.append(optionsArray[indexPath.row])
        }
        languageTable.reloadData()
        
    }
}

