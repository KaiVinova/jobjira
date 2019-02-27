//
//  SingleSelectionVC.swift
//  JobJira
//
//  Created by Vaibhav on 17/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import KYDrawerController
class SingleSelectionVC: UIViewController {
    
    //MARK:- IBOutlets
    
    var index:Int!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var jobTypeTable: UITableView!
    @IBOutlet weak var skipBtn: UIButton!
    
    var dataDict = [String:AnyObject]()
    var optionsArray = [AnyObject]()
    var selectedArray = [AnyObject]()
    
    //MARK:- View Lifdecycle
    
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
    
    //MARK:- Method for setting up data on view
    
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
            dict["answer"] = selectedArray[0]["odQuestionOptionID"] as AnyObject?
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

extension SingleSelectionVC:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTypeCell") as! JobTypeCell
        cell.selectionStyle = .none
        cell.jobTypeLabel.text = optionsArray[indexPath.row]["optionText"] as? String
        cell.jobTypeBtn.addTarget(self, action: #selector(SingleSelectionVC.jobTypeSelectionBtnAction(_:)), for: .touchUpInside)
        cell.jobTypeBtn.tag = indexPath.row
        cell.jobTypeBtn.isSelected = false
        cell.btnSuperView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
        for element in selectedArray {
            if element["odQuestionOptionID"] as! String == optionsArray[indexPath.row]["odQuestionOptionID"] as! String{
                cell.jobTypeBtn.isSelected = true
                cell.btnSuperView.backgroundColor = UIColor(red: 221.0/255.0, green: 197.0/255.0, blue: 149.0/255.0, alpha: 1.0)
                break
            }
        }
        return cell
    }
    
    func jobTypeSelectionBtnAction(_ sender:UIButton){
        selectedArray.removeAll()
        selectedArray.append(optionsArray[sender.tag])
        jobTypeTable.reloadData()
    }
}
