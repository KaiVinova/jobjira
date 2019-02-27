//
//  LocationVC.swift
//  JobJira
//
//  Created by Vaibhav on 25/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
@objc protocol LocationDelegate
{
    @objc optional func callBackWithDict(data:[String:AnyObject])
}
class LocationVC: UIViewController
{

//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subTitle2Label: UILabel!
    @IBOutlet weak var jobTypeTable: UITableView!
    @IBOutlet weak var notPreferredBtn: UIButton!

//MARK:- Vsriables and Constants
    
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
        jobTypeTable.estimatedRowHeight = 80
        jobTypeTable.tableFooterView = UIView()
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
        if (SignUpMetaData.sharedInstance.locationDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.locationDict
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
        let questionOptions = dataDict["questionOptions"]?["workLocations"] as? [AnyObject]
        optionsArray = questionOptions!
        if SignUpMetaData.sharedInstance.locationSelectedDict.count>0
        {
            selectedArray = SignUpMetaData.sharedInstance.locationSelectedDict as [AnyObject]
            for element in selectedArray
            {
                if element["stateID"] as! String == "0"
                {
                    notPreferredBtn.isSelected = true
                    break
                }
            }
            jobTypeTable.reloadData()
        }
        else
        {
            if editFlag == true
            {
                notPreferredBtn.isSelected = true
                let tempDict = ["stateID":"0"]
                selectedArray.append(tempDict as AnyObject)
            }
        }
    }
    
//MARK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        let _ = navigationController?.popViewController(animated: true)
    }
    
//MARK:- Not Preferred Button Action
    
    @IBAction func notPreferredBtnAction(_ sender: Any)
    {
        notPreferredBtn.isSelected = true
        selectedArray.removeAll()
        let tempDict = ["stateID":"0"]
        selectedArray.append(tempDict as AnyObject)
        jobTypeTable.reloadData()
    }
    
//MARK:- Done Button Action
    
    @IBAction func doneBtnAction(_ sender: Any)
    {
        if selectedArray.count>0
        {
            SignUpMetaData.sharedInstance.locationSelectedDict = selectedArray as! [[String : AnyObject]]
            if editFlag == true
            {
                SignUpMetaData.sharedInstance.userInfoDict["workLocations"] = SignUpMetaData.sharedInstance.locationSelectedDict as AnyObject
                let _ = navigationController?.popViewController(animated: true)
            }
            else
            {
                SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
            }
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please select your preferred location to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
   
//MARK:- Location Button Action
    
    @IBAction func locationBtnAction(_ sender: Any)
    {
        showPopUpForItemDetail(withArray: optionsArray)
    }
    
// MARK: Add item detail view Method
    
    func showPopUpForItemDetail(withArray array:[AnyObject])
    {
        let popup = LocationSelectionView.instansiateFromNib()
        popup.locationDelegate = self
        popup.dataArray = array
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(popup)
        popup.showPopup()
    }
}

//MARK:  Extension Tableview Datasources

extension LocationVC:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTypeCell") as! JobTypeCell
        cell.selectionStyle = .none
        cell.btnSuperView.layer.cornerRadius=20.0;
        cell.btnSuperView.layer.masksToBounds=false;
        cell.jobTypeLabel.text = optionsArray[indexPath.row]["stateName"] as? String
        cell.jobTypeBtn.addTarget(self, action: #selector(MultiSelectionVC.jobTypeSelectionBtnAction(_:)), for: .touchUpInside)
        cell.jobTypeBtn.tag = indexPath.row
        cell.jobTypeBtn.isSelected = false
        cell.btnSuperView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
        for element in selectedArray
        {
            if element["stateID"] as! String == optionsArray[indexPath.row]["stateID"] as! String
            {
                cell.jobTypeBtn.isSelected = true
                cell.btnSuperView.backgroundColor = UIColor(red: 221.0/255.0, green: 197.0/255.0, blue: 149.0/255.0, alpha: 1.0)
                break
            }
        }
        return cell
    }
    
//MARk:- JobType Button Action
    
    func jobTypeSelectionBtnAction(_ sender:UIButton)
    {
        sender.isSelected = !sender.isSelected
        if selectedArray.count>0
        {
            for (index, element) in selectedArray.enumerated()
            {
                let tempDict = element as! [String:AnyObject]
                if tempDict["stateID"] as! String == "0"
                {
                    notPreferredBtn.isSelected = false
                    selectedArray.remove(at: index)
                    break
                }
            }
        }
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
                    if selectedArray.count == 1 && selectedArray[0]["stateName"] as! String == "All"
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
                if element["stateID"] as! String == optionsArray[sender.tag]["stateID"] as! String
                {
                    selectedArray.remove(at: index)
                    sender.superview?.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
                    break
                }
            }
        }
    }
}

//MARK: Extension Tableview Delegates

extension LocationVC:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
}

//MARK:- Extension LocationDelegate

extension LocationVC:LocationDelegate
{
    func callBackWithDict(data:[String:AnyObject])
    {
    }
}
