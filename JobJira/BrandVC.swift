//
//  BrandVC.swift
//  JobJira
//
//  Created by Vaibhav on 12/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import KYDrawerController
class BrandVC: UIViewController
{
    
//MARK:- IBOutlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var jobRoleCollection: UICollectionView!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
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
        if (SignUpMetaData.sharedInstance.brandDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.brandDict
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
        let questionOptions = dataDict["questionOptions"]?["popularBrands"] as? [AnyObject]
        optionsArray = questionOptions!
        jobRoleCollection.reloadData()
        if SignUpMetaData.sharedInstance.brandSelectedArray.count>0
        {
            selectedArray = SignUpMetaData.sharedInstance.brandSelectedArray as [AnyObject]
            jobRoleCollection.reloadData()
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
            SignUpMetaData.sharedInstance.brandSelectedArray = selectedArray as! [[String : AnyObject]]
            if editFlag == true
            {
                SignUpMetaData.sharedInstance.userInfoDict["popularBrands"] = SignUpMetaData.sharedInstance.brandSelectedArray as AnyObject
                let _ = navigationController?.popViewController(animated: true)
            }
            else
            {
                postData()
            }
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please select your brand preferences to proceed", preferredStyle: UIAlertControllerStyle.alert)
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
    
//MARK: - Post Answer Data API
    
    func postData()
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        var dataArray = [[String:AnyObject]]()
        if SignUpMetaData.sharedInstance.brandSelectedArray.count > 0
        {
            var tempArray = [String]()
            for element in SignUpMetaData.sharedInstance.brandSelectedArray
            {
                tempArray.append(element["brandID"] as! String)
            }
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = tempArray as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.brandDict["obQuestionID"]
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

//MARK:- Extension UICollectionViewDelegate

extension BrandVC: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSize(width: (self.view.frame.size.width-50)/4, height: 70)
    }
    
//MARK:- Brand Selection Butotn Action
    
    func brandSelectionBtnAction(_ sender:UIButton)
    {
        sender.isSelected = !sender.isSelected
        if sender.isSelected
        {
            selectedArray.append(optionsArray[sender.tag])
            sender.superview?.backgroundColor = UIColor.darkGray
        }
        else
        {
            for (index,element) in selectedArray.enumerated()
            {
                if element["brandID"] as! String == optionsArray[sender.tag]["brandID"] as! String
                {
                    selectedArray.remove(at: index)
                    sender.superview?.backgroundColor = UIColor.lightGray
                    break
                }
            }
            print(selectedArray)
        }
    }
}

//MARK:- Extension UICollectionViewDataSource

extension BrandVC: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return optionsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrandCell", for: indexPath) as! BrandCell
        cell.iconImageView.image = nil
        cell.iconImageView.setImageWith(URL(string: (optionsArray[indexPath.row]["brandImage"] as! String))!)
        cell.brandSelectionBtn.addTarget(self, action: #selector(BrandVC.brandSelectionBtnAction(_:)), for: .touchUpInside)
        cell.brandSelectionBtn.tag = indexPath.item
        cell.brandSelectionBtn.superview?.backgroundColor = UIColor.lightGray
        cell.brandSelectionBtn.isSelected = false
        if selectedArray.count>0{
            for element in selectedArray
            {
                if element["brandID"] as! String == optionsArray[indexPath.row]["brandID"] as! String
                {
                    cell.brandSelectionBtn.superview?.backgroundColor = UIColor.darkGray
                    cell.brandSelectionBtn.isSelected = true
                }
            }
        }
        return cell
    }
}
