//
//  JobRoleSelectionVC.swift
//  JobJira
//
//  Created by Vaibhav on 28/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
class JobRoleSelectionVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var jobRoleSelectionTable: UITableView!
    
//MARK:- Variables and Constants
    
    var optionsArray:[AnyObject]!
    var selectedArray:[AnyObject]!
    var jobRoleDelegate:JobRoleDelegate!
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
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
            let _ = self.navigationController?.popViewController(animated: true)
            jobRoleDelegate.callBackWithDict!(data: selectedArray)
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please select at least 1 job role to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: Extension Tableview Datasources

extension JobRoleSelectionVC:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobRoleSelectionCell") as! JobRoleSelectionCell
        cell.selectionStyle = .none
        cell.jobRoleTitleLabel.text = optionsArray[indexPath.row]["jobRoleName"] as? String
        cell.iconView.setImageWith(URL(string: ((optionsArray[indexPath.row]["icons"] as! [String:AnyObject])["grey"] as? String)!)!)
        cell.containerView.backgroundColor = UIColor.white
        cell.jobRoleTitleLabel.textColor = UIColor.darkGray
        if selectedArray.count>0
        {
            for element in selectedArray
            {
                if element["jobRoleID"] as! String == optionsArray[indexPath.row]["jobRoleID"] as! String
                {
                    cell.containerView.backgroundColor = UIColor(red: 100.0/255.0, green: 99.0/255.0, blue: 218.0/255.0, alpha: 1.0)
                    cell.jobRoleTitleLabel.textColor = UIColor.white
                    cell.iconView.setImageWith(URL(string: ((optionsArray[indexPath.row]["icons"] as! [String:AnyObject])["white"] as? String)!)!)
                }
            }
        }
        return cell
    }
}

//MARK: Extension Tableview Delegates

extension JobRoleSelectionVC:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell:JobRoleSelectionCell = tableView.cellForRow(at: indexPath) as! JobRoleSelectionCell
        if cell.jobRoleTitleLabel.textColor == UIColor.white
        {
            for (index, element) in selectedArray.enumerated()
            {
                if element["jobRoleID"] as! String == optionsArray[indexPath.row]["jobRoleID"] as! String
                {
                    selectedArray.remove(at: index)
                }
            }
        }
        else
        {
            if selectedArray.count > 2
            {
                let alert = UIAlertController(title: AppName, message: "You can select upto 3 job roles!", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            selectedArray.append(optionsArray[indexPath.row])
        }
        jobRoleSelectionTable.reloadData()
    }
}
