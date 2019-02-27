//
//  SettingsVC.swift
//  JobJira
//
//  Created by Vaibhav on 03/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
import KVNProgress

class SettingsVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingsTable: UITableView!
    
//MARK:- Variables and Constants

    var settingsArray = ["Disable Notifications", "Mute Chat", "Set private mode"]
    var notificationValue:String!
    var muteChatValue:String!
    var locationShareValue:String!
    var privateModeValue:String!
    var userInfoDict:[String:AnyObject]!
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        notificationValue = userInfoDict["receiveNotification"] as? String
        muteChatValue = userInfoDict["muteChat"] as? String
        locationShareValue = userInfoDict["allowLocationUse"] as? String
        privateModeValue = userInfoDict["privateModeEnabled"] as? String
        settingsTable.estimatedRowHeight = 61
        settingsTable.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = true
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
//MARK:- Menu Button Action
    
    @IBAction func munuBtnAction(_ sender: Any)
    {
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            (drawerController.drawerViewController as! MenuViewController).tableView.reloadData()
            drawerController.setDrawerState(.opened, animated: true)
        }
    }

//MARK: - Post Settings Data
    
    func postSettingsInfo(_ switchB:UISwitch)
    {
        var dict = [String:AnyObject]()
        dict["receiveNotification"] = self.notificationValue as AnyObject?
        dict["muteChat"] = self.muteChatValue as AnyObject?
        dict["allowLocationUse"] = self.locationShareValue as AnyObject?
        dict["privateModeEnabled"] = self.privateModeValue as AnyObject?
        var userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        UserService.updateSettingsWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            if success
            {
                print(data ?? "No Value")
                if switchB.tag == 0
                {
                    if self.notificationValue == "0"
                    {
                        switchB.isOn = true
                    }
                    else
                    {
                        switchB.isOn = false
                    }
                }
                else if switchB.tag == 1
                {
                    if self.muteChatValue == "1"
                    {
                        switchB.isOn = true
                    }
                    else
                    {
                        switchB.isOn = false
                    }
                }
                else if switchB.tag == 2
                {
                    if self.privateModeValue == "1"
                    {
                        switchB.isOn = true
                    }
                    else
                    {
                        switchB.isOn = false
                    }
                }
                self.userInfoDict["receiveNotification"] = self.notificationValue as AnyObject?
                self.userInfoDict["muteChat"] = self.muteChatValue as AnyObject?
                self.userInfoDict["allowLocationUse"] = self.locationShareValue as AnyObject?
                self.userInfoDict["privateModeEnabled"] = self.privateModeValue as AnyObject?
                UserDefaults.standard.set(self.userInfoDict, forKey: "userInfo")
            }
            else
            {
                if data != nil
                {
                    let alert = UIAlertController(title: AppName, message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        AppDelegate.shared.popAndLogout(self)
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    let alert = UIAlertController(title: AppName, message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    if switchB.tag == 0
                    {
                        if self.notificationValue == "1"
                        {
                            switchB.isOn = true
                            self.notificationValue = "0"
                        }
                        else
                        {
                            switchB.isOn = false
                            self.notificationValue = "1"
                        }
                    }
                    else if switchB.tag == 1
                    {
                        if self.muteChatValue == "0"
                        {
                            switchB.isOn = true
                            self.muteChatValue = "1"
                        }
                        else
                        {
                            switchB.isOn = false
                            self.muteChatValue = "0"
                        }
                    }
                    else if switchB.tag == 2
                    {
                        if self.privateModeValue == "0"
                        {
                            switchB.isOn = true
                            self.privateModeValue = "1"
                        }
                        else
                        {
                            switchB.isOn = false
                            self.privateModeValue = "0"
                        }
                    }
                    self.settingsTable.reloadData()
                }
            }
        })
    }
}

//MARK:- Extension UITableViewDelegate

extension SettingsVC:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARk:- Extension UITableViewDataSource

extension SettingsVC:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return settingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.selectionStyle = .none
        cell.titleLbl.text = settingsArray[indexPath.row]
        if indexPath.row == 2 {
            cell.hintLbl.text = "In private mode, your profile will be hidden from all potential employers. You will also not get matched to any jobs"
        }
        else
        {
            cell.hintLbl.text = " "
        }
        if indexPath.row == 4
        {
            cell.switchBtn.isHidden = true
            cell.arrowIcon.isHidden = false
        }
        else
        {
            cell.switchBtn.isHidden = false
            cell.arrowIcon.isHidden = true
            if indexPath.row == 0
            {
                if notificationValue == "1"
                {
                    cell.switchBtn.isOn = false
                }
                else
                {
                    cell.switchBtn.isOn = true
                }
            }
            else if indexPath.row == 1
            {
                if muteChatValue == "1"
                {
                    cell.switchBtn.isOn = true
                }
                else
                {
                    cell.switchBtn.isOn = false
                }
            }
            else
            {
                if privateModeValue == "1"
                {
                    cell.switchBtn.isOn = true
                }
                else
                {
                    cell.switchBtn.isOn = false
                }
            }
        }
        cell.switchBtn.addTarget(self, action: #selector(SettingsVC.statusBtnAction(_:)), for: .valueChanged)
        cell.switchBtn.tag = indexPath.row
        return cell
    }
    
//MARK:- Status Button Action
    
    func statusBtnAction(_ sender:UISwitch)
    {
        if sender.isOn
        {
            if sender.tag == 0
            {
                notificationValue = "0"
            }
            else if sender.tag == 1
            {
                muteChatValue = "1"
            }
            else
            {
                privateModeValue = "1"
            }
        }
        else
        {
            if sender.tag == 0
            {
                notificationValue = "1"
            }
            else if sender.tag == 1
            {
                muteChatValue = "0"
            }
            else
            {
                privateModeValue = "0"
            }
        }
        postSettingsInfo(sender)
    }
}
