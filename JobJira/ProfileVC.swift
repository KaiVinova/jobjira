//
//  ProfileVC.swift
//  JobJira
//
//  Created by Vaibhav on 15/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
import KVNProgress
import AVFoundation
import AVKit
import AccountKit

class ProfileVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircularImageV!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var picBtn: CircularButton!
    
    
//MARK:- Variables and Constants

    var cachedImageViewSize: CGRect!
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    fileprivate var pendingLoginViewController: AKFViewController? = nil
    fileprivate var showAccountOnAppear = false
    var dynamicUserInfo = [String:AnyObject]()
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UserDefaults.standard.set("1", forKey: "prPop")
        getMasterData()
        getResumeStatusData()
        loadUserInfo()
        tableView.estimatedRowHeight = 300
        if !UIAccessibilityIsReduceTransparencyEnabled()
        {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.alpha = 0.9
            blurEffectView.frame = coverImageView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            let blurEffect1 = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurEffectView1 = UIVisualEffectView(effect: blurEffect1)
            blurEffectView1.alpha = 0.2
            blurEffectView1.frame = coverImageView.bounds
            blurEffectView1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            coverImageView.addSubview(blurEffectView1)
            coverImageView.addSubview(blurEffectView)
        }
        showAccountOnAppear = accountKit.currentAccessToken != nil
        pendingLoginViewController = accountKit.viewControllerForLoginResume() as? AKFViewController
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = true
        }
        if SignUpMetaData.sharedInstance.userInfoDict.count>0
        {
            updateView()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        if UserDefaults.standard.object(forKey: "prPop") as! String == "0" {
            checkPrStatus()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func checkPrStatus(){
        if SignUpMetaData.sharedInstance.userInfoDict.count>0
        {
            if SignUpMetaData.sharedInstance.userInfoDict["PrTitle"] as! String == ""{
                editBtn.isSelected = true
                menuBtn.isSelected = true
                tableView.reloadData()
                showAlertForSettingPR()
            }
        }
    }
    
    //MARK:- Method For Load User Information
    func showAlertForSettingPR(){
        UserDefaults.standard.set("1", forKey: "prPop")
        let alert = UIAlertController(title: "Important", message: "Your PR & Work permit/pass is not set in your profile. Tap to setup now.", preferredStyle: UIAlertControllerStyle.alert)
        let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            UserDefaults.standard.set("0", forKey: "prPop")
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "PersonalDetailVC") as! PersonalDetailVC
            viewController.editFlag = true
            self.navigationController?.pushViewController(viewController, animated: true)
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func willEnterForeground() {
        if UserDefaults.standard.object(forKey: "prPop") as! String == "0" {
            checkPrStatus()
        }
    }
    
//MARK:- Method For Load User Information
    
    func loadUserInfo()
    {
        if UserDefaults.standard.object(forKey: "userInfo") != nil
        {
            print(UserDefaults.standard.object(forKey: "userInfo") ?? "Nil")
            SignUpMetaData.sharedInstance.userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
            updateView()
        }
    }
    
//MARK:- Method for updating View
    
    func updateView()
    {
        self.cachedImageViewSize = self.coverImageView.frame
        nameLabel.text = SignUpMetaData.sharedInstance.userInfoDict["name"] as? String
        if ((SignUpMetaData.sharedInstance.userInfoDict["workLocations"] as? [[String:AnyObject]])?.count)! > 0
        {
            for (index,element) in (SignUpMetaData.sharedInstance.userInfoDict["workLocations"] as? [[String:AnyObject]])!.enumerated()
            {
                if index == 0
                {
                    if element["stateName"] != nil
                    {
                        locationLabel.text = (element["stateName"] as? String)!
                    }
                    else
                    {
                        locationLabel.text = "No preferred location"
                    }
                }
            }
        }
        else
        {
            locationLabel.text = "No preferred location"
        }
        if SignUpMetaData.sharedInstance.userInfoDict["profilePicture"] as! String == ""
        {
            if SignUpMetaData.sharedInstance.userInfoDict["genderID"] as! String == "1"
            {
                profileImageView.image = UIImage(named: "avatar_man")
                coverImageView.image = UIImage(named: "avatar_man")
            }
            else
            {
                profileImageView.image = UIImage(named: "avatar_woman")
                coverImageView.image = UIImage(named: "avatar_woman")
            }
        }
        else
        {
            profileImageView.setImageWith(URL(string: SignUpMetaData.sharedInstance.userInfoDict["profilePicture"] as! String)!)
            coverImageView.setImageWith(URL(string: SignUpMetaData.sharedInstance.userInfoDict["profilePicture"] as! String)!)
            if InitializerHelper.sharedInstance.profileImage != nil
            {
                profileImageView.image = InitializerHelper.sharedInstance.profileImage
                coverImageView.image = InitializerHelper.sharedInstance.profileImage
            }
            else
            {
                let picUrlRequest = URLRequest(url: URL(string: SignUpMetaData.sharedInstance.userInfoDict["profilePicture"] as! String)!)
                profileImageView.setImageWith(picUrlRequest, placeholderImage: nil, success: { (request, reponse, image) in
                    InitializerHelper.sharedInstance.profileImage = nil
                    InitializerHelper.sharedInstance.profileImage = image
                    self.profileImageView.image = InitializerHelper.sharedInstance.profileImage
                    self.coverImageView.image = InitializerHelper.sharedInstance.profileImage
                }, failure: { (request, response, error) in
                    InitializerHelper.sharedInstance.profileImage = nil
                    if SignUpMetaData.sharedInstance.userInfoDict["genderID"] as! String == "1"
                    {
                        self.profileImageView.image = UIImage(named: "avatar_man")
                        self.coverImageView.image = UIImage(named: "avatar_man")
                    }
                    else
                    {
                        self.profileImageView.image = UIImage(named: "avatar_woman")
                        self.coverImageView.image = UIImage(named: "avatar_woman")
                    }
                })
            }

        }
        tableView.reloadData()
    }
    
//MARK:- Method for Store Response
    
    func createAnswerDict()
    {
        if UserDefaults.standard.object(forKey: "userInfo") != nil
        {
            let userDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
            if userDict["genderID"] as! String != ""
            {
                SignUpMetaData.sharedInstance.genderSelectedDict = ["answer":userDict["genderID"]!, "obQuestionID":SignUpMetaData.sharedInstance.genderDict["obQuestionID"]!]
            }
            if userDict["age"] as! String != ""
            {
                SignUpMetaData.sharedInstance.ageSelectedDict = ["answer":userDict["age"]!, "obQuestionID":SignUpMetaData.sharedInstance.ageDict["obQuestionID"]!]
            }
            if (userDict["workLocations"] as! [[String:AnyObject]]).count > 0
            {
                if SignUpMetaData.sharedInstance.locationDict["obQuestionID"] != nil{
                    let list = SignUpMetaData.sharedInstance.locationDict["questionOptions"]?["workLocations"] as! [[String:AnyObject]]
                    let selectedList = userDict["workLocations"] as! [[String:AnyObject]]
                    for element in list
                    {
                        for item in selectedList
                        {
                            if item["stateID"] as! String == element["stateID"] as! String
                            {
                                SignUpMetaData.sharedInstance.locationSelectedDict.append(element)
                            }
                        }
                    }
                }
            }
            if (userDict["skills"] as! [[String:AnyObject]]).count > 0
            {
                if SignUpMetaData.sharedInstance.skillsDict["obQuestionID"] != nil
                {
                    let list = SignUpMetaData.sharedInstance.skillsDict["questionOptions"]?["skills"] as! [[String:AnyObject]]
                    let selectedList = userDict["skills"] as! [[String:AnyObject]]
                    for element in list
                    {
                        for item in selectedList
                        {
                            if item["primarySkillID"] as! String == element["primarySkillID"] as! String
                            {
                                SignUpMetaData.sharedInstance.skillsSelectedArray.append(element)
                            }
                        }
                    }
                }
            }
            if userDict["expRangeID"] as! String != ""
            {
                if SignUpMetaData.sharedInstance.experinceDict["obQuestionID"] != nil{
                    let list = SignUpMetaData.sharedInstance.experinceDict["questionOptions"]?["experience"] as! [[String:AnyObject]]
                    for element in list
                    {
                        if element["expRangeID"] as! String == userDict["expRangeID"] as! String
                        {
                            SignUpMetaData.sharedInstance.experinceSelectedDict = ["answer":element as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.experinceDict["obQuestionID"]!]
                            break
                        }
                    }
                }
            }
            if userDict["currentSalary"] as! String != ""
            {
                var mData = [String:AnyObject]()
                mData["salaryTypeID"] = userDict["currentSalaryTypeID"] as AnyObject
                mData["salary"] = userDict["currentSalary"] as AnyObject
                SignUpMetaData.sharedInstance.currentSalarySelectedDict = ["answer":mData as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.currentSalaryDict["obQuestionID"]!]
            }
            if userDict["expectedSalary"] as! String != ""
            {
                var mData = [String:AnyObject]()
                mData["salaryTypeID"] = userDict["expectedSalaryTypeID"] as AnyObject
                mData["salary"] = userDict["expectedSalary"] as AnyObject
                SignUpMetaData.sharedInstance.expectedSalarySelectedDict = ["answer":mData as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.expectedSalaryDict["obQuestionID"]!]
            }
            if (userDict["jobTypes"] as! [[String:AnyObject]]).count > 0
            {
                if SignUpMetaData.sharedInstance.jobTypeDict["obQuestionID"] != nil
                {
                    let list = SignUpMetaData.sharedInstance.jobTypeDict["questionOptions"]?["job_types"] as! [[String:AnyObject]]
                    let selectedList = userDict["jobTypes"] as! [[String:AnyObject]]
                    for element in list
                    {
                        for item in selectedList
                        {
                            if item["jobTypeID"] as! String == element["jobTypeID"] as! String
                            {
                                SignUpMetaData.sharedInstance.jobTypeSelecedArray.append(element)
                            }
                        }
                    }
                }
            }
            if (userDict["jobRoles"] as! [[String:AnyObject]]).count > 0
            {
                if SignUpMetaData.sharedInstance.jobRoleDict["obQuestionID"] != nil
                {
                    let list = SignUpMetaData.sharedInstance.jobRoleDict["questionOptions"]?["job_roles"] as! [[String:AnyObject]]
                    let selectedList = userDict["jobRoles"] as! [[String:AnyObject]]
                    for element in list
                    {
                        for item in selectedList
                        {
                            if item["jobRoleID"] as! String == element["jobRoleID"] as! String
                            {
                                SignUpMetaData.sharedInstance.jobRoleSelectedArray.append(element)
                            }
                        }
                    }
                }
            }
            if (userDict["speakingLanguages"] as! [[String:AnyObject]]).count > 0
            {
                if SignUpMetaData.sharedInstance.languageDict["obQuestionID"] != nil{
                    let list = SignUpMetaData.sharedInstance.languageDict["questionOptions"]?["speakingLanguages"] as! [[String:AnyObject]]
                    let selectedList = userDict["speakingLanguages"] as! [[String:AnyObject]]
                    for element in list
                    {
                        for item in selectedList
                        {
                            if item["speakingLangID"] as! String == element["speakingLangID"] as! String
                            {
                                SignUpMetaData.sharedInstance.languageSelectedDict.append(element)
                            }
                        }
                    }
                }
            }
            if userDict["profilePicture"] as! String != ""
            {
                var tempDict = [String:AnyObject]()
                tempDict["imageUrl"] = userDict["profilePicture"] as AnyObject?
                tempDict["imageName"] = (userDict["profilePicture"] as! String).breakStringIntoArray().last as AnyObject?
                SignUpMetaData.sharedInstance.profilePicSelectedDict = ["answer":tempDict as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.profilePicDict["obQuestionID"]!]
            }
            if userDict["name"] as! String != ""
            {
                var tempDict = [String:AnyObject]()
                tempDict["name"] = userDict["name"] as AnyObject?
                tempDict["email"] = userDict["email"] as AnyObject?
                let countryCode = "+\(userDict["countryCode"] as! String)"
                tempDict["mobileNumber"] = userDict["mobileNumber"] as AnyObject?
                tempDict["countryCode"] = countryCode as AnyObject?
                tempDict["nationalityName"] = userDict["nationality"] as AnyObject?
                tempDict["nationality"] = userDict["nationalityID"] as AnyObject?
                tempDict["PR_id"] = userDict["PR_id"] as AnyObject?
                tempDict["PrTitle"] = userDict["PrTitle"] as AnyObject?
                SignUpMetaData.sharedInstance.personalDetailSelectedDict = ["answer":tempDict as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.personalDetailDict["obQuestionID"]!]
            }
            if userDict["availabilityTypeID"] as! String != ""
            {
                if SignUpMetaData.sharedInstance.availabilityDict["obQuestionID"] != nil
                {
                    let list = SignUpMetaData.sharedInstance.availabilityDict["questionOptions"]?["availability"] as! [[String:AnyObject]]
                    for element in list
                    {
                        if element["availabilityTypeID"] as! String == userDict["availabilityTypeID"] as! String
                        {
                            SignUpMetaData.sharedInstance.availabilitySelectedArray.append(element)
                            break
                        }
                    }
                }
            }
            if userDict["profileAvailabilityTypeID"] as! String != ""
            {
                if SignUpMetaData.sharedInstance.profileAvailabilityDict["obQuestionID"] != nil
                {
                    let list = SignUpMetaData.sharedInstance.profileAvailabilityDict["questionOptions"]?["profileAvailability"] as! [[String:AnyObject]]
                    for element in list
                    {
                        if element["profileAvailabilityTypeID"] as! String == userDict["profileAvailabilityTypeID"] as! String{
                            SignUpMetaData.sharedInstance.profileAvailabilitySelectedArray.append(element)
                            break
                        }
                    }
                }
            }
            if let educationalQualifications = userDict["educationalQualifications"] as? [String:AnyObject]
            {
                if SignUpMetaData.sharedInstance.educationDict["obQuestionID"] != nil
                {
                    SignUpMetaData.sharedInstance.educationSelectedDict = ["answer":educationalQualifications as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.educationDict["obQuestionID"]!]
                }
            }
            if let brandArray = userDict["popularBrands"] as? [[String:AnyObject]]
            {
                if brandArray.count > 0 {
                    if SignUpMetaData.sharedInstance.brandDict["obQuestionID"] != nil
                    {
                        let list = SignUpMetaData.sharedInstance.brandDict["questionOptions"]?["popularBrands"] as! [[String:AnyObject]]
                        for element in list
                        {
                            for item in brandArray
                            {
                                if item["brandID"] as! String == element["brandID"] as! String
                                {
                                    SignUpMetaData.sharedInstance.brandSelectedArray.append(element)
                                }
                            }
                        }
                    }
                }
            }
            if userDict["profileVideo"] as! String != ""
            {
                var tempDict = [String:AnyObject]()
                tempDict["videoUrl"] = userDict["profileVideo"] as AnyObject?
                tempDict["videoName"] = (userDict["profileVideo"] as! String).breakStringIntoArray().last as AnyObject?
                SignUpMetaData.sharedInstance.videoSelectedDict = ["answer":tempDict as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.videoDict["obQuestionID"]!]
            }
            if userDict["bio"] as! String != ""
            {
                SignUpMetaData.sharedInstance.bioSelectedDict = ["answer":userDict["bio"] as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.bioDict["obQuestionID"]!]
            }
        }
    }
    
//MARK:- Menu Button Action
    
    @IBAction func munuBtnAction(_ sender: Any)
    {
        let button = sender as! UIButton
        if button.isSelected
        {
            if SignUpMetaData.sharedInstance.userInfoDict.count>0
            {
                if (UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject])["PrTitle"] as! String == ""{
                    return
                }
            }
            button.isSelected = false
            editBtn.isSelected = false
            SignUpMetaData.sharedInstance.userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
            InitializerHelper.sharedInstance.profileImage = nil
            InitializerHelper.sharedInstance.videoImage = nil
            updateView()
        }
        else
        {
            if let drawerController = navigationController?.parent as? KYDrawerController
            {
                (drawerController.drawerViewController as! MenuViewController).tableView.reloadData()
                drawerController.setDrawerState(.opened, animated: true)
            }
        }
    }
    
//MARK:- Edit Button Action

    @IBAction func editBtnAction(_ sender: Any)
    {
        if SignUpMetaData.sharedInstance.viewControllerOrder.count == 0
        {
            let alert = UIAlertController(title: AppName, message: "Unable to load data.", preferredStyle: UIAlertControllerStyle.alert)
            let action1 =  UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.getMasterData()
                self.loadUserInfo()
            })
            alert.addAction(action1)
            let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action2)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let button = sender as! UIButton
        if !button.isSelected
        {
            button.isSelected = true
            menuBtn.isSelected = true
            tableView.reloadData()
        }
        else
        {
            updateProfile()
        }
    }
    
//MARK:- Pic Button Action
    
    @IBAction func picBtnAction(_ sender: Any)
    {
        if editBtn.isSelected
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "ProfilePicVC") as! ProfilePicVC
            viewController.editFlag = true
            viewController.afterSignUpFlag = false
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
//MARK: - Get Master Data for Update API
    
    func getMasterData()
    {
        var dict = [String:AnyObject]()
        dict["comesAfterSignup"] = 2 as AnyObject?
        KVNProgress.show()
        UserService.getMasterDataWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let result = data!["result"]?["questions"]!
                print(result ?? "No Value")
                SignUpMetaData.sharedInstance.createSeperateObjectsForEachQuestion(result as! [AnyObject])
                SignUpMetaData.sharedInstance.createSeperateObjectsForEachQuestionPostLogin(result as! [AnyObject])
                self.createAnswerDict()
                UserDefaults.standard.set("0", forKey: "prPop")
                if UserDefaults.standard.object(forKey: "prPop") as! String == "0" {
                    self.checkPrStatus()
                }
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
    
//MARK: - Get Master Data for Update API
    
    func getResumeStatusData()
    {
        var dict = [String:AnyObject]()
        let userDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userDict["jobSeekerID"] as AnyObject
        KVNProgress.show()
        UserService.getRemumeStatusWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let result = data!["result"]?["dynamicInfo"]!
                print(result ?? "No Value")
                self.dynamicUserInfo = result as! [String:AnyObject]
                self.updateView()
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
    
//MARK: - Post SignUp Data API
    
    func updateProfile()
    {
        var dict = [String:AnyObject]()
        let userDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userDict["jobSeekerID"] as AnyObject
        var dataArray = [[String:AnyObject]]()
        if SignUpMetaData.sharedInstance.genderSelectedDict["answer"] != nil
        {
            dataArray.append(SignUpMetaData.sharedInstance.genderSelectedDict)
        }
        if SignUpMetaData.sharedInstance.ageSelectedDict["answer"] != nil
        {
            dataArray.append(SignUpMetaData.sharedInstance.ageSelectedDict)
        }
        if SignUpMetaData.sharedInstance.locationSelectedDict.count > 0
        {
            var tempArray = [String]()
            for element in SignUpMetaData.sharedInstance.locationSelectedDict
            {
                tempArray.append(element["stateID"] as! String)
            }
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = tempArray as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.locationDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        if SignUpMetaData.sharedInstance.skillsSelectedArray.count > 0
        {
            var tempArray = [String]()
            for element in SignUpMetaData.sharedInstance.skillsSelectedArray{
                tempArray.append(element["primarySkillID"] as! String)
            }
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = tempArray as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.skillsDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        if SignUpMetaData.sharedInstance.experinceSelectedDict["answer"] != nil
        {
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = SignUpMetaData.sharedInstance.experinceSelectedDict["answer"]?["expRangeID"] as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.experinceDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        if SignUpMetaData.sharedInstance.currentSalarySelectedDict["answer"] != nil
        {
            dataArray.append(SignUpMetaData.sharedInstance.currentSalarySelectedDict)
        }
        if SignUpMetaData.sharedInstance.expectedSalarySelectedDict["answer"] != nil
        {
            dataArray.append(SignUpMetaData.sharedInstance.expectedSalarySelectedDict)
        }
        if SignUpMetaData.sharedInstance.jobTypeSelecedArray.count > 0
        {
            var tempArray = [String]()
            for element in SignUpMetaData.sharedInstance.jobTypeSelecedArray
            {
                tempArray.append(element["jobTypeID"] as! String)
            }
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = tempArray as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.jobTypeDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        if SignUpMetaData.sharedInstance.jobRoleSelectedArray.count > 0
        {
            var tempArray = [String]()
            for element in SignUpMetaData.sharedInstance.jobRoleSelectedArray
            {
                tempArray.append(element["jobRoleID"] as! String)
            }
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = tempArray as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.jobRoleDict["obQuestionID"]
            dataArray.append(tempDict)
        }
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
        if SignUpMetaData.sharedInstance.profilePicSelectedDict["answer"] != nil
        {
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = SignUpMetaData.sharedInstance.profilePicSelectedDict["answer"]?["imageName"] as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.profilePicDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        else
        {
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = "" as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.profilePicDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        if SignUpMetaData.sharedInstance.personalDetailSelectedDict["answer"] != nil
        {
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = SignUpMetaData.sharedInstance.personalDetailSelectedDict["answer"] as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.personalDetailDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        if SignUpMetaData.sharedInstance.availabilitySelectedArray.count > 0
        {
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = SignUpMetaData.sharedInstance.availabilitySelectedArray[0]["availabilityTypeID"] as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.availabilityDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        
        if SignUpMetaData.sharedInstance.profileAvailabilitySelectedArray.count > 0
        {
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = SignUpMetaData.sharedInstance.profileAvailabilitySelectedArray[0]["profileAvailabilityTypeID"] as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.profileAvailabilityDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        if SignUpMetaData.sharedInstance.educationSelectedDict["answer"] != nil
        {
            if ((SignUpMetaData.sharedInstance.educationSelectedDict["answer"] as? [String:AnyObject])?.count)!>0
            {
                var tempDict = [String:AnyObject]()
                var answerDict = [String:AnyObject]()
                if SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationalQualificationID"] as? String != nil
                {
                    answerDict["educationalQualificationID"] = SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationalQualificationID"] as AnyObject?
                }
                if SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationDegree"] as? String != nil
                {
                    answerDict["educationDegree"] = SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationDegree"] as AnyObject?
                }
                if SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationInstitution"] as? String != nil
                {
                    answerDict["educationInstitution"] = SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationInstitution"] as AnyObject?
                }
                tempDict["answer"] = answerDict as AnyObject?
                tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.educationDict["obQuestionID"]
                dataArray.append(tempDict)
            }
        }
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
        if SignUpMetaData.sharedInstance.videoSelectedDict["answer"] != nil
        {
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = SignUpMetaData.sharedInstance.videoSelectedDict["answer"]?["videoName"] as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.videoDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        else
        {
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = "" as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.videoDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        if SignUpMetaData.sharedInstance.bioSelectedDict["answer"] != nil
        {
            dataArray.append(SignUpMetaData.sharedInstance.bioSelectedDict)
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
                let alert = UIAlertController(title: AppName, message: "Profile updated successfully", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    self.menuBtn.isSelected = false
                    self.editBtn.isSelected = false
                    SignUpMetaData.sharedInstance.userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
                    self.getResumeStatusData()
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
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
    
//MARK: - Post Dynamic Changes Data API
    
    func postDynamicChangesData(_ key:String)
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        dict["action"] = key as AnyObject
        print(dict)
        KVNProgress.show()
        UserService.postEmailVerificationWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                if key == "verifyEmail"
                {
                    let alert = UIAlertController(title: AppName, message: "Your email is verified now!", preferredStyle: UIAlertControllerStyle.alert)
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        SignUpMetaData.sharedInstance.userInfoDict["isEmailVerified"] = "1" as AnyObject
                        UserDefaults.standard.set(SignUpMetaData.sharedInstance.userInfoDict, forKey: "userInfo")
                        self.getResumeStatusData()
                        self.updateView()
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    let alert = UIAlertController(title: AppName, message: "Resume deleted from your profile.", preferredStyle: UIAlertControllerStyle.alert)
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        self.getResumeStatusData()
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                
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
    
//MARK: - Post Resume Action Data API
    
    func postResumeDataChanges()
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        dict["type"] = "2" as AnyObject
        print(dict)
        KVNProgress.show()
        UserService.postUploadResumeWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let alert = UIAlertController(title: AppName, message: "A link has been sent on your registered email. Please follow the link.", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    self.updateView()
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
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

//MARK:- Extension UITableViewDataSource

extension ProfileVC:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if dynamicUserInfo.count>0
        {
           return 15
        }
        else
        {
            return 14
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        switch indexPath.row
        {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell1") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "Introduction Video"
                cell.symbolIcon.image = UIImage(named: "intro_vid")
                cell.videoBtn.addTarget(self, action: #selector(ProfileVC.videoBtnAction(_:)), for: .touchUpInside)
                cell.videoBtn.layer.cornerRadius = 4.0
                cell.videoBtn.layer.masksToBounds=false
                cell.videoBtn.clipsToBounds = true
                if SignUpMetaData.sharedInstance.userInfoDict["profileVideo"] as! String != ""
                {
                    if InitializerHelper.sharedInstance.videoImage != nil
                    {
                        cell.videoBtn.setBackgroundImage(InitializerHelper.sharedInstance.videoImage, for: .normal)
                        cell.videoBtn.setImage(UIImage(named: "play_button"), for: .normal)
                        cell.videoBtn.setTitle(nil, for: .normal)
                    }
                    else
                    {
                        let queue = DispatchQueue.global(qos: .default)
                        queue.async(execute: {() -> Void in
                            let image = CommonFunctions.videoSnapshot(NSURL(string: SignUpMetaData.sharedInstance.userInfoDict["profileVideo"] as! String)!)
                            InitializerHelper.sharedInstance.videoImage = nil
                            InitializerHelper.sharedInstance.videoImage = image
                            DispatchQueue.main.async(execute: {() -> Void in
                                cell.videoBtn.setBackgroundImage(image, for: .normal)
                                cell.videoBtn.setImage(UIImage(named: "play_button"), for: .normal)
                                cell.videoBtn.setTitle(nil, for: .normal)
                            })
                        })
                    }
                }
                else
                {
                    cell.videoBtn.setBackgroundImage(nil, for: .normal)
                    cell.videoBtn.setImage(nil, for: .normal)
                    cell.videoBtn.setTitle("No Intro Video", for: .normal)
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell2") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "Personal Information"
                cell.symbolIcon.image = UIImage(named: "personal_info")
                cell.nameBtn.addTarget(self, action: #selector(ProfileVC.nameBtnAction(_:)), for: .touchUpInside)
                cell.emailBtn.addTarget(self, action: #selector(ProfileVC.emailBtnAction(_:)), for: .touchUpInside)
                cell.emailVerifyBtn.addTarget(self, action: #selector(ProfileVC.emailVerificationBtnAction(_:)), for: .touchUpInside)
                cell.passwordBtn.addTarget(self, action: #selector(ProfileVC.passwordBtnAction(_:)), for: .touchUpInside)
                cell.phoneBtn.addTarget(self, action: #selector(ProfileVC.phoneBtnAction(_:)), for: .touchUpInside)
                cell.genderBtn.addTarget(self, action: #selector(ProfileVC.genderBtnAction(_:)), for: .touchUpInside)
                cell.ageBtn.addTarget(self, action: #selector(ProfileVC.ageBtnAction(_:)), for: .touchUpInside)
                cell.nationalityBtn.addTarget(self, action: #selector(ProfileVC.nationalityBtnAction(_:)), for: .touchUpInside)
                cell.prBtn.addTarget(self, action: #selector(ProfileVC.prBtnAction(_:)), for: .touchUpInside)

                if SignUpMetaData.sharedInstance.userInfoDict.count > 0
                {
                    cell.nameLabel.text = SignUpMetaData.sharedInstance.userInfoDict["name"] as? String
                    cell.emailLabel.text = SignUpMetaData.sharedInstance.userInfoDict["email"] as? String
                    cell.passwordLabel.text = "********"
                    cell.phoneLabel.text = SignUpMetaData.sharedInstance.userInfoDict["mobileNumber"] as? String
                    if SignUpMetaData.sharedInstance.userInfoDict["genderName"] as? String == "3"{
                        cell.genderLabel.text = "Not Disclosed"
                    }
                    else{
                        cell.genderLabel.text = SignUpMetaData.sharedInstance.userInfoDict["genderName"] as? String
                    }
                    if SignUpMetaData.sharedInstance.userInfoDict["age"] as? String == "0"{
                        cell.ageLabel.text = "Not Disclosed"
                    }
                    else{
                        cell.ageLabel.text = SignUpMetaData.sharedInstance.userInfoDict["age"] as? String
                    }
                    cell.natioanlityLabel.text = SignUpMetaData.sharedInstance.userInfoDict["nationality"] as? String
                    cell.prLabel.text = SignUpMetaData.sharedInstance.userInfoDict["PrTitle"] as? String
                    cell.emailVerifyBtn.setTitle("Verify", for: .normal)
                    cell.emailVerifyBtn.setTitle("Verified", for: .selected)
                    cell.emailVerifyBtn.setTitleColor(UIColor.red, for: .normal)
                    cell.emailVerifyBtn.setTitleColor(UIColor.green, for: .selected)
                    if dynamicUserInfo.count>0
                    {
                        if dynamicUserInfo["isEmailVerified"] as? String == "0"
                        {
                            cell.emailVerifyBtn.isSelected = false
                        }
                        else
                        {
                            cell.emailVerifyBtn.isSelected = true
                        }
                    }
                    else
                    {
                        if SignUpMetaData.sharedInstance.userInfoDict["isEmailVerified"] as? String == "0"
                        {
                            cell.emailVerifyBtn.isSelected = false
                        }
                        else
                        {
                            cell.emailVerifyBtn.isSelected = true
                        }
                    }
                    
                }
                if editBtn.isSelected
                {
                    cell.nameLabel.textColor = linkColor
                    cell.emailLabel.textColor = linkColor
                    cell.passwordLabel.textColor = linkColor
                    cell.phoneLabel.textColor = linkColor
                    cell.genderLabel.textColor = linkColor
                    cell.ageLabel.textColor = linkColor
                    cell.natioanlityLabel.textColor = linkColor
                    cell.prLabel.textColor = linkColor
                }
                else
                {
                    cell.nameLabel.textColor = UIColor.darkGray
                    cell.emailLabel.textColor = UIColor.darkGray
                    cell.passwordLabel.textColor = UIColor.darkGray
                    cell.phoneLabel.textColor = UIColor.darkGray
                    cell.genderLabel.textColor = UIColor.darkGray
                    cell.ageLabel.textColor = UIColor.darkGray
                    cell.natioanlityLabel.textColor = UIColor.darkGray
                    cell.prLabel.textColor = UIColor.darkGray
                }
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell3") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "About me"
                cell.symbolIcon.image = UIImage(named: "about_me")
                cell.editBtn.addTarget(self, action: #selector(ProfileVC.multipleBtnAction(_:)), for: .touchUpInside)
                cell.editBtn.tag = indexPath.row
                if SignUpMetaData.sharedInstance.userInfoDict["bio"] as? String != ""
                {
                    cell.valueLabel.text = SignUpMetaData.sharedInstance.userInfoDict["bio"] as? String
                }
                else
                {
                    cell.valueLabel.text = "NA"
                }
                if editBtn.isSelected
                {
                    cell.valueLabel.textColor = linkColor
                }
                else
                {
                    cell.valueLabel.textColor = UIColor.darkGray
                }
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell3") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "Education"
                cell.symbolIcon.image = UIImage(named: "education")
                cell.editBtn.addTarget(self, action: #selector(ProfileVC.multipleBtnAction(_:)), for: .touchUpInside)
                cell.editBtn.tag = indexPath.row
                if let educationalQualifications = SignUpMetaData.sharedInstance.userInfoDict["educationalQualifications"] as? [String:AnyObject]
                {
                    var educationString = ""
                    if educationalQualifications.count>0
                    {
                        if educationalQualifications["educationalQualificationID"] as! String != "6"
                        {
                            if educationalQualifications["educationalQualificationID"] as! String == "3" || educationalQualifications["educationalQualificationID"] as! String == "4" || educationalQualifications["educationalQualificationID"] as! String == "5"
                            {
                                if educationalQualifications["educationDegree"] != nil
                                {
                                    educationString = "\(educationString)\((educationalQualifications["educationDegree"] as? String)!)"
                                }
                                if educationalQualifications["educationalQualificationName"] != nil
                                {
                                    educationString = "\(educationString)(\((educationalQualifications["educationalQualificationName"] as? String)!))"
                                }
                                if educationalQualifications["educationInstitution"] != nil
                                {
                                    educationString = "\(educationString) from \((educationalQualifications["educationInstitution"] as? String)!)"
                                }
                            }
                            else
                            {
                                if educationalQualifications["educationalQualificationName"] != nil
                                {
                                    educationString = "\(educationString)\((educationalQualifications["educationalQualificationName"] as? String)!)"
                                }
                                if educationalQualifications["educationInstitution"] != nil
                                {
                                    educationString = "\(educationString) from \((educationalQualifications["educationInstitution"] as? String)!)"
                                }
                            }
                        }
                        else
                        {
                            if educationalQualifications["educationalQualificationName"] != nil
                            {
                                educationString = (educationalQualifications["educationalQualificationName"] as? String)!
                            }
                        }
                    }
                    if educationString != ""
                    {
                        cell.valueLabel.text = educationString
                    }
                    else
                    {
                        cell.valueLabel.text = "NA"
                    }
                }
                else
                {
                    cell.valueLabel.text = "NA"
                }
                if editBtn.isSelected
                {
                    cell.valueLabel.textColor = linkColor
                }
                else
                {
                    cell.valueLabel.textColor = UIColor.darkGray
                }
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell3") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "Languages"
                cell.symbolIcon.image = UIImage(named: "languages")
                cell.editBtn.addTarget(self, action: #selector(ProfileVC.multipleBtnAction(_:)), for: .touchUpInside)
                cell.editBtn.tag = indexPath.row
                if ((SignUpMetaData.sharedInstance.userInfoDict["speakingLanguages"] as? [[String:AnyObject]])?.count)! > 0
                {
                    for (index,element) in (SignUpMetaData.sharedInstance.userInfoDict["speakingLanguages"] as? [[String:AnyObject]])!.enumerated()
                    {
                        if index == 0
                        {
                            cell.valueLabel.text = (element["speakingLangName"] as? String)!
                        }
                        else
                        {
                            cell.valueLabel.text = "\(cell.valueLabel.text!), \((element["speakingLangName"] as? String)!)"
                        }
                    }
                }
                else
                {
                    cell.valueLabel.text = "NA"
                }
                if editBtn.isSelected
                {
                    cell.valueLabel.textColor = linkColor
                }
                else
                {
                    cell.valueLabel.textColor = UIColor.darkGray
                }
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell3") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "Skills"
                cell.symbolIcon.image = UIImage(named: "skills")
                cell.editBtn.addTarget(self, action: #selector(ProfileVC.multipleBtnAction(_:)), for: .touchUpInside)
                cell.editBtn.tag = indexPath.row
                if ((SignUpMetaData.sharedInstance.userInfoDict["skills"] as? [[String:AnyObject]])?.count)! > 0
                {
                    for (index,element) in (SignUpMetaData.sharedInstance.userInfoDict["skills"] as? [[String:AnyObject]])!.enumerated()
                    {
                        if index == 0
                        {
                            cell.valueLabel.text = (element["primarySkillName"] as? String)!
                        }
                        else
                        {
                            cell.valueLabel.text = "\(cell.valueLabel.text!), \((element["primarySkillName"] as? String)!)"
                        }
                    }
                }
                else
                {
                    cell.valueLabel.text = "NA"
                }
                if editBtn.isSelected
                {
                    cell.valueLabel.textColor = linkColor
                }
                else
                {
                    cell.valueLabel.textColor = UIColor.darkGray
                }
                return cell
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell3") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "Experience"
                cell.symbolIcon.image = UIImage(named: "experience")
                cell.editBtn.addTarget(self, action: #selector(ProfileVC.multipleBtnAction(_:)), for: .touchUpInside)
                cell.editBtn.tag = indexPath.row
                if SignUpMetaData.sharedInstance.userInfoDict["expRangeText"] as? String != ""
                {
                    cell.valueLabel.text = SignUpMetaData.sharedInstance.userInfoDict["expRangeText"] as? String
                }
                else
                {
                    cell.valueLabel.text = "NA"
                }
                if editBtn.isSelected
                {
                    cell.valueLabel.textColor = linkColor
                }
                else
                {
                    cell.valueLabel.textColor = UIColor.darkGray
                }
                return cell
            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell4") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "Salary"
                cell.symbolIcon.image = UIImage(named: "salary")
                cell.currentSalaryBtn.addTarget(self, action: #selector(ProfileVC.currentSalaryBtnAction(_:)), for: .touchUpInside)
                cell.expectedSalaryBtn.addTarget(self, action: #selector(ProfileVC.expectedSalaryBtnAction(_:)), for: .touchUpInside)
                if SignUpMetaData.sharedInstance.userInfoDict["currentSalaryTypeID"] as? String == "1"
                {
                    cell.currentSalaryLabel.text = "Current: \((SignUpMetaData.sharedInstance.userInfoDict["currency"] as? String)!)\((SignUpMetaData.sharedInstance.userInfoDict["currentSalary"] as? String)!)/mon"
                }
                else if SignUpMetaData.sharedInstance.userInfoDict["currentSalaryTypeID"] as? String == "2"
                {
                    cell.currentSalaryLabel.text = "Current: \((SignUpMetaData.sharedInstance.userInfoDict["currency"] as? String)!)\((SignUpMetaData.sharedInstance.userInfoDict["currentSalary"] as? String)!)/hr"
                }
                else
                {
                    cell.currentSalaryLabel.text = "Current: Fresher"
                }
                if SignUpMetaData.sharedInstance.userInfoDict["expectedSalaryTypeID"] as? String == "1"
                {
                    cell.expectedSalaryLabel.text = "Expected: \((SignUpMetaData.sharedInstance.userInfoDict["currency"] as? String)!)\((SignUpMetaData.sharedInstance.userInfoDict["expectedSalary"] as? String)!)/mon"
                }
                else if SignUpMetaData.sharedInstance.userInfoDict["expectedSalaryTypeID"] as? String == "2"
                {
                    cell.expectedSalaryLabel.text = "Expected: \((SignUpMetaData.sharedInstance.userInfoDict["currency"] as? String)!)\((SignUpMetaData.sharedInstance.userInfoDict["expectedSalary"] as? String)!)/hr"
                }
                else
                {
                    cell.expectedSalaryLabel.text = "Expected: Flexible"
                }
                if editBtn.isSelected
                {
                    cell.currentSalaryLabel.textColor = linkColor
                    cell.expectedSalaryLabel.textColor = linkColor
                }
                else
                {
                    cell.currentSalaryLabel.textColor = UIColor.darkGray
                    cell.expectedSalaryLabel.textColor = UIColor.darkGray
                }
                return cell
            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell3") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "Preferred Job Location"
                cell.symbolIcon.image = UIImage(named: "job_location")
                cell.editBtn.addTarget(self, action: #selector(ProfileVC.multipleBtnAction(_:)), for: .touchUpInside)
                cell.editBtn.tag = indexPath.row
                if ((SignUpMetaData.sharedInstance.userInfoDict["workLocations"] as? [[String:AnyObject]])?.count)! > 0
                {
                    for (index,element) in (SignUpMetaData.sharedInstance.userInfoDict["workLocations"] as? [[String:AnyObject]])!.enumerated()
                    {
                        if index == 0
                        {
                            if element["stateName"] != nil
                            {
                                cell.valueLabel.text = "\((element["stateName"] as? String)!)"
                            }
                            else
                            {
                                cell.valueLabel.text = "No preferred location"
                            }
                        }
                        else
                        {
                            cell.valueLabel.text = "\(cell.valueLabel.text!)\n\((element["stateName"] as? String)!)"
                        }
                    }
                }
                else
                {
                    cell.valueLabel.text = "No preferred location"
                }
                if editBtn.isSelected
                {
                    cell.valueLabel.textColor = linkColor
                }
                else
                {
                    cell.valueLabel.textColor = UIColor.darkGray
                }
                return cell
            case 9:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell3") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "Preferred Job Type"
                cell.symbolIcon.image = UIImage(named: "job_type")
                cell.editBtn.addTarget(self, action: #selector(ProfileVC.multipleBtnAction(_:)), for: .touchUpInside)
                cell.editBtn.tag = indexPath.row
                if ((SignUpMetaData.sharedInstance.userInfoDict["jobTypes"] as? [[String:AnyObject]])?.count)! > 0
                {
                    for (index,element) in (SignUpMetaData.sharedInstance.userInfoDict["jobTypes"] as? [[String:AnyObject]])!.enumerated()
                    {
                        if index == 0
                        {
                            cell.valueLabel.text = (element["jobType"] as? String)!
                        }
                        else
                        {
                            cell.valueLabel.text = "\(cell.valueLabel.text!), \((element["jobType"] as? String)!)"
                        }
                    }
                }
                else
                {
                    cell.valueLabel.text = "NA"
                }
                if editBtn.isSelected
                {
                    cell.valueLabel.textColor = linkColor
                }
                else
                {
                    cell.valueLabel.textColor = UIColor.darkGray
                }
                return cell
            case 10:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell3") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "Job Roles"
                cell.symbolIcon.image = UIImage(named: "roles")
                cell.editBtn.addTarget(self, action: #selector(ProfileVC.multipleBtnAction(_:)), for: .touchUpInside)
                cell.editBtn.tag = indexPath.row
                if ((SignUpMetaData.sharedInstance.userInfoDict["jobRoles"] as? [[String:AnyObject]])?.count)! > 0
                {
                    for (index,element) in (SignUpMetaData.sharedInstance.userInfoDict["jobRoles"] as? [[String:AnyObject]])!.enumerated()
                    {
                        if index == 0
                        {
                            cell.valueLabel.text = (element["jobRoleName"] as? String)!
                        }
                        else
                        {
                            cell.valueLabel.text = "\(cell.valueLabel.text!), \((element["jobRoleName"] as? String)!)"
                        }
                    }
                }
                else
                {
                    cell.valueLabel.text = "NA"
                }
                if editBtn.isSelected
                {
                    cell.valueLabel.textColor = linkColor
                }
                else
                {
                    cell.valueLabel.textColor = UIColor.darkGray
                }
                return cell
            case 11:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell3") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "My Availability"
                cell.symbolIcon.image = UIImage(named: "my_availability")
                cell.editBtn.addTarget(self, action: #selector(ProfileVC.multipleBtnAction(_:)), for: .touchUpInside)
                cell.editBtn.tag = indexPath.row
                if SignUpMetaData.sharedInstance.userInfoDict["availabilityType"] as? String != ""
                {
                    cell.valueLabel.text = SignUpMetaData.sharedInstance.userInfoDict["availabilityType"] as? String
                }
                else
                {
                    cell.valueLabel.text = "NA"
                }
                if editBtn.isSelected
                {
                    cell.valueLabel.textColor = linkColor
                }
                else
                {
                    cell.valueLabel.textColor = UIColor.darkGray
                }
                return cell
            case 12:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell3") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "Profile Availability"
                cell.symbolIcon.image = UIImage(named: "profile_availability")
                cell.editBtn.addTarget(self, action: #selector(ProfileVC.multipleBtnAction(_:)), for: .touchUpInside)
                cell.editBtn.tag = indexPath.row
                if SignUpMetaData.sharedInstance.userInfoDict["profileAvailabilityType"] as? String != ""
                {
                    cell.valueLabel.text = SignUpMetaData.sharedInstance.userInfoDict["profileAvailabilityType"] as? String
                }
                else
                {
                    cell.valueLabel.text = "NA"
                }
                if editBtn.isSelected
                {
                    cell.valueLabel.textColor = linkColor
                }
                else
                {
                    cell.valueLabel.textColor = UIColor.darkGray
                }
                return cell
            case 13:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell3") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "Brands I Like"
                cell.symbolIcon.image = UIImage(named: "brands_i_like")
                cell.editBtn.addTarget(self, action: #selector(ProfileVC.multipleBtnAction(_:)), for: .touchUpInside)
                cell.editBtn.tag = indexPath.row
                if let array = SignUpMetaData.sharedInstance.userInfoDict["popularBrands"] as?  [[String:AnyObject]]
                {
                    if array.count > 0
                    {
                        for (index,element) in (SignUpMetaData.sharedInstance.userInfoDict["popularBrands"] as? [[String:AnyObject]])!.enumerated()
                        {
                            if index == 0
                            {
                                cell.valueLabel.text = (element["brandName"] as? String)!
                            }
                            else
                            {
                                cell.valueLabel.text = "\(cell.valueLabel.text!), \((element["brandName"] as? String)!)"
                            }
                        }
                    }
                    else
                    {
                        cell.valueLabel.text = "NA"
                    }
                }
                else{
                    cell.valueLabel.text = "NA"
                }
                
                if editBtn.isSelected
                {
                    cell.valueLabel.textColor = linkColor
                }
                else
                {
                    cell.valueLabel.textColor = UIColor.darkGray
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell5") as! ProfileCell
                cell.selectionStyle = .none
                cell.titleLabel.text = "Resume"
                cell.symbolIcon.image = UIImage(named: "resume")
                cell.addResumeBtn.addTarget(self, action: #selector(ProfileVC.addResumeBtnAction(_:)), for: .touchUpInside)
                cell.addResumeBtn.tag = indexPath.row
                cell.updateResumeBtn.addTarget(self, action: #selector(ProfileVC.updateResumeBtnAction(_:)), for: .touchUpInside)
                cell.updateResumeBtn.tag = indexPath.row
                cell.deleteResumeBtn.addTarget(self, action: #selector(ProfileVC.deleteResumeBtnAction(_:)), for: .touchUpInside)
                cell.deleteResumeBtn.tag = indexPath.row
                if dynamicUserInfo["resume"] as! String == ""
                {
                    cell.heightConstraint.constant = 0
                    cell.addResumeBtn.isHidden = false
                    cell.updateResumeBtn.isHidden = true
                    cell.deleteResumeBtn.isHidden = true
                    cell.valueLabel.text = "NA"
                }
                else
                {
                    cell.heightConstraint.constant = 30
                    cell.addResumeBtn.isHidden = true
                    cell.updateResumeBtn.isHidden = false
                    cell.deleteResumeBtn.isHidden = false
                    let timeStamp = Int((dynamicUserInfo["resumeUpdateTime"] as? String)!)
                    cell.valueLabel.text = ("Last Updated : \((dynamicUserInfo["resumeUpdateTime"] as? String)!.timeStampToDateString(timeStamp!, format: "MMM dd, yyyy"))")
                }
                return cell
        }
    }
    
//MARK:- Video Button Action
    
    func videoBtnAction(_ sender:UIButton)
    {
        if editBtn.isSelected
        {
            let storyBoard = UIStoryboard(name: "PostLogin", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "VideoVC") as! VideoVC
            viewController.editFlag = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else
        {
            if SignUpMetaData.sharedInstance.userInfoDict["profileVideo"] as! String != ""
            {
                let player = AVPlayer(url: URL(string: SignUpMetaData.sharedInstance.userInfoDict["profileVideo"] as! String)!)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true)
                {
                    playerViewController.player!.play()
                }
            }
        }
    }
    
//MARK:- Name button Action
    
    func nameBtnAction(_ sender:UIButton)
    {
        if editBtn.isSelected
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "PersonalDetailVC") as! PersonalDetailVC
            viewController.editFlag = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
//MARK:- Email Button Action
    
    func emailBtnAction(_ sender:UIButton)
    {
        if editBtn.isSelected
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "PersonalDetailVC") as! PersonalDetailVC
            viewController.editFlag = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
//MARK:- Email Verifiation Button Action
    
    func emailVerificationBtnAction(_ sender:UIButton)
    {
        if !sender.isSelected{
            let inputState = UUID().uuidString
            if let viewController = self.accountKit.viewControllerForEmailLogin(withEmail: SignUpMetaData.sharedInstance.userInfoDict["email"] as? String, state: inputState) as? AKFViewController
            {
                self.prepareLoginViewController(viewController)
                if let viewController = viewController as? UIViewController
                {
                    self.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
    
//MARK:- Password button Action
    
    func passwordBtnAction(_ sender:UIButton)
    {
        if editBtn.isSelected
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "PersonalDetailVC") as! PersonalDetailVC
            viewController.editFlag = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

//MARK:- Phone Button Action
    
    func phoneBtnAction(_ sender:UIButton)
    {
        if editBtn.isSelected
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "PersonalDetailVC") as! PersonalDetailVC
            viewController.editFlag = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
//MARK:- Gender button Action
    
    func genderBtnAction(_ sender:UIButton)
    {
        if editBtn.isSelected
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "GenderVC") as! GenderVC
            viewController.editFlag = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
//MARK:- Age Button Action
    
    func ageBtnAction(_ sender:UIButton)
    {
        if editBtn.isSelected
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "AgeVC") as! AgeVC
            viewController.editFlag = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
//MARK:- Nationality Button Action
    
    func nationalityBtnAction(_ sender:UIButton)
    {
        if editBtn.isSelected
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "PersonalDetailVC") as! PersonalDetailVC
            viewController.editFlag = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    //MARK:- Nationality Button Action
    
    func prBtnAction(_ sender:UIButton)
    {
        if editBtn.isSelected
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "PersonalDetailVC") as! PersonalDetailVC
            viewController.editFlag = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
//MARK:- Multiple Button Action
    
    func multipleBtnAction(_ sender:UIButton)
    {
        if editBtn.isSelected
        {
            switch sender.tag
            {
            case 2:
                let storyBoard = UIStoryboard(name: "PostLogin", bundle: nil)
                let viewController = storyBoard.instantiateViewController(withIdentifier: "BioVC") as! BioVC
                viewController.editFlag = true
                self.navigationController?.pushViewController(viewController, animated: true)
                break
            case 3:
                let storyBoard = UIStoryboard(name: "PostLogin", bundle: nil)
                let viewController = storyBoard.instantiateViewController(withIdentifier: "EducationVC") as! EducationVC
                viewController.editFlag = true
                self.navigationController?.pushViewController(viewController, animated: true)
                break
            case 4:
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyBoard.instantiateViewController(withIdentifier: "LanguageVC") as! LanguageVC
                viewController.editFlag = true
                viewController.afterSignUpFlag = false
                self.navigationController?.pushViewController(viewController, animated: true)
                break
            case 5:
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyBoard.instantiateViewController(withIdentifier: "SkillsVC") as! SkillsVC
                viewController.editFlag = true
                self.navigationController?.pushViewController(viewController, animated: true)
                break
            case 6:
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyBoard.instantiateViewController(withIdentifier: "ExperinceVC") as! ExperinceVC
                viewController.editFlag = true
                self.navigationController?.pushViewController(viewController, animated: true)
                break
            case 8:
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyBoard.instantiateViewController(withIdentifier: "LocationVC") as! LocationVC
                viewController.editFlag = true
                self.navigationController?.pushViewController(viewController, animated: true)
                break
            case 9:
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyBoard.instantiateViewController(withIdentifier: "JobTypeVC") as! JobTypeVC
                viewController.editFlag = true
                self.navigationController?.pushViewController(viewController, animated: true)
                break
            case 10:
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyBoard.instantiateViewController(withIdentifier: "JobRoleVC") as! JobRoleVC
                viewController.editFlag = true
                self.navigationController?.pushViewController(viewController, animated: true)
                break
            case 11:
                let storyBoard = UIStoryboard(name: "PostLogin", bundle: nil)
                let viewController = storyBoard.instantiateViewController(withIdentifier: "AvailablityVC") as! AvailablityVC
                viewController.editFlag = true
                self.navigationController?.pushViewController(viewController, animated: true)
                break
            case 12:
                let storyBoard = UIStoryboard(name: "PostLogin", bundle: nil)
                let viewController = storyBoard.instantiateViewController(withIdentifier: "ProfileAvailablityVC") as! ProfileAvailablityVC
                viewController.editFlag = true
                self.navigationController?.pushViewController(viewController, animated: true)
                break
            case 13:
                let storyBoard = UIStoryboard(name: "PostLogin", bundle: nil)
                let viewController = storyBoard.instantiateViewController(withIdentifier: "BrandVC") as! BrandVC
                viewController.editFlag = true
                self.navigationController?.pushViewController(viewController, animated: true)
                break
            default:
                break
            }
        }
    }
    
//MARK:- Current Salary Button Action
    
    func currentSalaryBtnAction(_ sender:UIButton)
    {
        if editBtn.isSelected
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "CurrentSalaryVC") as! CurrentSalaryVC
            viewController.editFlag = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
//MARK:- Expected Salary Button Action
    
    func expectedSalaryBtnAction(_ sender:UIButton)
    {
        if editBtn.isSelected
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "ExpectedSalaryVC") as! ExpectedSalaryVC
            viewController.editFlag = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
//MARk:- Add Resume Button Action
    
    func addResumeBtnAction(_ sender:UIButton)
    {
        postResumeDataChanges()
    }
    
//MARk:- Update Resume Button Action
    
    func updateResumeBtnAction(_ sender:UIButton)
    {
        postResumeDataChanges()
    }
    
//MARK:- Delete Resume Button Action
    
    func deleteResumeBtnAction(_ sender:UIButton)
    {
        let alert = UIAlertController(title: AppName, message: "Do you want to delete your resume?", preferredStyle: UIAlertControllerStyle.actionSheet)
        let action1 =  UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.postDynamicChangesData("deleteResume")
        })
        let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
        })
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }

// MARK:- Helpers
    
    fileprivate func prepareLoginViewController(_ loginViewController: AKFViewController)
    {
        loginViewController.delegate = self
        loginViewController.theme = prepareThemeForPhoneView()
    }

    fileprivate func prepareThemeForPhoneView() -> AKFTheme
    {
        let theme = AKFTheme.default()
        theme.backgroundColor = UIColor(red: 241.0/255.0, green: 242.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        theme.buttonBackgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
        theme.buttonTextColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        theme.headerBackgroundColor = UIColor(red: 73.0/255.0, green: 60.0/255.0, blue: 228.0/255.0, alpha: 1.0)
        theme.headerTextColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        theme.iconColor = UIColor(red: 73.0/255.0, green: 60.0/255.0, blue: 228.0/255.0, alpha: 1.0)
        theme.inputBackgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        theme.inputBorderColor = UIColor(red: 104.0/255.0, green: 104.0/255.0, blue: 104.0/255.0, alpha: 1.0)
        theme.inputTextColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        theme.statusBarStyle = .lightContent
        theme.textColor = UIColor(red: 104.0/255.0, green: 104.0/255.0, blue: 104.0/255.0, alpha: 1.0)
        theme.titleColor = UIColor(red: 104.0/255.0, green: 104.0/255.0, blue: 104.0/255.0, alpha: 1.0)
        return theme
    }
}

//MARK:- Extension UITableViewDelegate

extension ProfileVC:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
}

//MARK:- Extension UIScrollViewDelegate

extension ProfileVC:UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let y: CGFloat = -scrollView.contentOffset.y
        if y > 0
        {
            self.coverImageView.frame = CGRect(x:0, y:scrollView.contentOffset.y, width:self.cachedImageViewSize.size.width + y, height:self.cachedImageViewSize.size.height + y)
            self.coverImageView.center = CGPoint(x:self.view.center.x, y:self.coverImageView.center.y)
        }
    }
}

//MARK:- Extension AKFViewControllerDelegate

extension ProfileVC:AKFViewControllerDelegate
{
    func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!)
    {
        accountKit.requestAccount { (account, error) in
            if error == nil
            {
                if account?.emailAddress != nil
                {
                    if SignUpMetaData.sharedInstance.userInfoDict["email"] as? String == account?.emailAddress
                    {
                        self.accountKit.logOut()
                        self.postDynamicChangesData("verifyEmail")
                    }
                    else
                    {
                        let alert = UIAlertController(title: AppName, message: "You have edited the email while confirming. Do not edit it.", preferredStyle: UIAlertControllerStyle.alert)
                        let action1 =  UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                            self.accountKit.logOut()
                            let inputState = UUID().uuidString
                            if let viewController = self.accountKit.viewControllerForEmailLogin(withEmail: SignUpMetaData.sharedInstance.userInfoDict["email"] as? String, state: inputState) as? AKFViewController
                            {
                                self.prepareLoginViewController(viewController)
                                if let viewController = viewController as? UIViewController
                                {
                                    self.present(viewController, animated: true, completion: nil)
                                }
                            }
                        })
                        let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        })
                        alert.addAction(action1)
                        alert.addAction(action2)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else if account?.phoneNumber != nil
                {
                    if SignUpMetaData.sharedInstance.userInfoDict["mobileNumber"] as? String == account?.phoneNumber?.phoneNumber
                    {
                        self.accountKit.logOut()
                        self.postDynamicChangesData("verifyEmail")
                    }
                    else
                    {
                        let alert = UIAlertController(title: AppName, message: "You have edited the phone number while confirming. Do not edit it.", preferredStyle: UIAlertControllerStyle.alert)
                        let action1 =  UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                            self.accountKit.logOut()
                            let phoneNumber = AKFPhoneNumber(countryCode: "65", phoneNumber: (SignUpMetaData.sharedInstance.userInfoDict["mobileNumber"] as? String)!)
                            let inputState = UUID().uuidString
                            if let viewController = self.accountKit.viewControllerForPhoneLogin(with: phoneNumber, state: inputState) as? AKFViewController
                            {
                                self.prepareLoginViewController(viewController)
                                if let viewController = viewController as? UIViewController
                                {
                                    self.present(viewController, animated: true, completion: nil)
                                }
                            }
                        })
                        let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        })
                        alert.addAction(action1)
                        alert.addAction(action2)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else
            {
                let alert = UIAlertController(title: AppName, message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func viewController(_ viewController: UIViewController!, didFailWithError error: Error!)
    {
        print("\(viewController) did fail with error: \(error)")
    }
}

