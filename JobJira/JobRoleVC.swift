//
//  JobRoleVC.swift
//  JobJira
//
//  Created by Vaibhav on 28/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
@objc protocol JobRoleDelegate
{
    @objc optional func callBackWithDict(data:[AnyObject])
}
class JobRoleVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var jobRoleCollection: UICollectionView!
    
//MARK:- Variables and Consonants
    
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
        if (SignUpMetaData.sharedInstance.jobRoleDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.jobRoleDict
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

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
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
        let questionOptions = dataDict["questionOptions"]?["job_roles"] as? [AnyObject]
        optionsArray = questionOptions!
        if SignUpMetaData.sharedInstance.jobRoleSelectedArray.count>0
        {
            selectedArray = SignUpMetaData.sharedInstance.jobRoleSelectedArray as [AnyObject]
            jobRoleCollection.reloadData()
        }
    }
    
//MARK:- Back button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        let _ = navigationController?.popViewController(animated: true)
    }
    
//MARK:- Done Button Action
    
    @IBAction func doneBtnAction(_ sender: Any)
    {
        if selectedArray.count>0
        {
            SignUpMetaData.sharedInstance.jobRoleSelectedArray = selectedArray as! [[String : AnyObject]]
            if editFlag == true
            {
                SignUpMetaData.sharedInstance.userInfoDict["jobRoles"] = SignUpMetaData.sharedInstance.jobRoleSelectedArray as AnyObject
                let _ = navigationController?.popViewController(animated: true)
            }
            else
            {
                SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
            }
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please select your job role to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
}

//MARK:- Extension UICollectionViewDelegate

extension JobRoleVC: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "JobRoleSelectionVC") as! JobRoleSelectionVC
        viewcontroller.optionsArray = optionsArray
        viewcontroller.selectedArray = selectedArray
        viewcontroller.jobRoleDelegate = self
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSize(width: self.view.frame.size.width/3, height: 135)
    }
}

//MARK:- Extension UICollectionViewDataSource

extension JobRoleVC: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if selectedArray.count<3
        {
            return selectedArray.count + 1
        }
        else
        {
            return selectedArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JobRoleCell", for: indexPath) as! JobRoleCell
        if indexPath.row == selectedArray.count
        {
            cell.jobRoleTitle.text = dataDict["questionInfo"]?["buttonText"]! as? String
            cell.jobRoleImage.image = UIImage(named: "plus")
            cell.jobRoleImage.backgroundColor = UIColor.clear
        }
        else
        {
            cell.jobRoleTitle.text = selectedArray[indexPath.row]["jobRoleName"] as? String
            cell.jobRoleImage.setImageWith(URL(string: ((selectedArray[indexPath.row]["icons"] as! [String:AnyObject])["white"] as? String)!)!)
            cell.jobRoleImage.layer.cornerRadius = 4
            cell.jobRoleImage.layer.masksToBounds = true
            if indexPath.row == 0
            {
                cell.jobRoleImage.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
            }
            else if indexPath.row == 1
            {
                cell.jobRoleImage.backgroundColor = UIColor(red: 109.0/255.0, green: 106.0/255.0, blue: 220.0/255.0, alpha: 1.0)
            }
            else if indexPath.row == 2
            {
                cell.jobRoleImage.backgroundColor = UIColor(red: 250.0/255.0, green: 127.0/255.0, blue: 122.0/255.0, alpha: 1.0)
            }
        }
        return cell
    }
}

//MARK:- Extension JobRoleDelegate

extension JobRoleVC:JobRoleDelegate
{
    func callBackWithDict(data: [AnyObject])
    {
        selectedArray = data
        if selectedArray.count>0
        {
            print(selectedArray)
            jobRoleCollection.reloadData()
        }
    }
}
