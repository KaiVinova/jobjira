//
//  PersonalDetailVC.swift
//  JobJira
//
//  Created by Vaibhav on 28/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import IQKeyboardManager
import AccountKit
import KYDrawerController
import Firebase
@objc protocol NationalityDelegate
{
    @objc optional func callBackWithDict(data:[String:AnyObject])
}

@objc protocol CountryCodeDelegate
{
    @objc optional func callBackForCodeWithDict(data:[String:AnyObject])
}

@objc protocol IAgreeDelegate
{
    @objc optional func callBack()
}

class PersonalDetailVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var personalDetailTable: UITableView!
    
//MARK:- Variables and Constants
    
    var dataDict = [String:AnyObject]()
    var optionsArray:[AnyObject]!
    var selectedDict = [String:AnyObject]()
    var emailFlag = true
    var phoneFlag = true
    var editFlag:Bool!
    var countryCodeBtn = UIButton()
    var seperatorView = UIView()
    var prList = [[String:AnyObject]]()
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    fileprivate var pendingLoginViewController: AKFViewController? = nil
    fileprivate var showAccountOnAppear = false
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
        showAccountOnAppear = accountKit.currentAccessToken != nil
        pendingLoginViewController = accountKit.viewControllerForLoginResume() as? AKFViewController
        countryCodeBtn.addTarget(self, action: #selector(PersonalDetailVC.countryCodeBtnAction(_:)), for: .touchUpInside)
        personalDetailTable.tableFooterView = UIView()
        if (SignUpMetaData.sharedInstance.personalDetailDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.personalDetailDict
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
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        loadContryList()
        IQKeyboardManager.shared().toolbarManageBehaviour = .byTag
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().toolbarManageBehaviour = .byPosition
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
//MARK:- Method for Load Country List

    func loadContryList()
    {
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: "countries", withExtension: "json")
        {
            do
            {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as! [AnyObject]
                {
                    optionsArray =  parsedData
                }
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }
    
//MARK:- Method for SetupData on View
    
    func setUpViewBackEndData()
    {
        titleLabel.text = dataDict["questionInfo"]?["title"] as? String
        subTitleLabel.text = dataDict["questionInfo"]?["p1"] as? String
        headerLabel.text = dataDict["questionInfo"]?["h1"] as? String
        descriptionLabel.text = dataDict["questionInfo"]?["p2"] as? String
        prList = dataDict["questionOptions"]?["PR_list"] as! [[String:AnyObject]]
        if SignUpMetaData.sharedInstance.personalDetailSelectedDict["answer"] != nil
        {
            selectedDict = SignUpMetaData.sharedInstance.personalDetailSelectedDict["answer"] as! [String : AnyObject]
        }
    }
    
//MARK:- Country Code Button Action
    
    func countryCodeBtnAction(_ sender:UIButton)
    {
        let indexPath = NSIndexPath(row: 2, section: 0)
        let cell = personalDetailTable.cellForRow(at: indexPath as IndexPath) as! PersonalDetailCell!
        cell?.textField.resignFirstResponder()
        showPopUpForCountryCode()
    }
   
//MARK:- Method for CountryCode POPUP
    
    func showPopUpForCountryCode()
    {
        let popup = CountryCodeSelectionView.instansiateFromNib()
        popup.codeDelegate = self
        popup.selectedCode = countryCodeBtn.titleLabel?.text
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(popup)
        popup.showPopup()
    }
    
//MARK:- Method for ItemDetail POPUP

    func showPopUpForItemDetail(withArray array:[AnyObject])
    {
        let popup = NationalitySelectionView.instansiateFromNib()
        popup.nationalityDelegate = self
        popup.dataArray = array
        if selectedDict["nationality"] != nil
        {
            popup.selectedNationality = selectedDict["nationality"] as! String
        }
        else
        {
            popup.selectedNationality = ""
        }
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(popup)
        popup.showPopup()
    }
    
    func showPopUpForPRList(withArray array:[AnyObject])
    {
        let popup = PRSelectionView.instansiateFromNib()
        popup.pRDelegate = self
        var prArray = array
        if selectedDict["nationality"] as! String == "1"{
            prArray.removeLast(array.count-1)
        }
        else{
            prArray.remove(at: 0)
        }
        
        popup.dataArray = prArray
        if selectedDict["PR_id"] != nil
        {
            popup.selectedId = selectedDict["PR_id"] as! String
        }
        else
        {
            popup.selectedId = ""
        }
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(popup)
        popup.showPopup()
    }
    
//MARK:- Method for IAgree POPUP

    func showPopUpForIAgree()
    {
        let popup = IAgreeView.instansiateFromNib()
        popup.iAgreeDelegate = self
        popup.parentViewController = self
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(popup)
        popup.showPopup()
    }
    
//MARK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        let _ = navigationController?.popViewController(animated: true)
    }
    
//MARK:- Done Button Action
    
    @IBAction func doneBtnAction(_ sender: Any)
    {
        self.view.endEditing(true)
        if selectedDict["name"] == nil || selectedDict["email"] == nil || selectedDict["mobileNumber"] == nil || selectedDict["nationality"] == nil || selectedDict["PR_id"] == nil
        {
            if selectedDict["name"] == nil
            {
                let alert = UIAlertController(title: AppName, message: "Please enter your full name", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if selectedDict["email"] == nil
            {
                let alert = UIAlertController(title: AppName, message: "Please enter your email id", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if selectedDict["mobileNumber"] == nil
            {
                let alert = UIAlertController(title: AppName, message: "Please enter your mobile number", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if selectedDict["nationality"] == nil
            {
                let alert = UIAlertController(title: AppName, message: "Please enter your nationality", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if selectedDict["PR_id"] == nil
            {
                let alert = UIAlertController(title: AppName, message: "Please enter your PR / Work permits.", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        else
        {
            if editFlag == false
            {
                if selectedDict["password"] == nil
                {
                    let alert = UIAlertController(title: AppName, message: "Please enter your password", preferredStyle: UIAlertControllerStyle.alert)
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
            if !CommonFunctions.validateName(name: selectedDict["name"] as! String)
            {
                let alert = UIAlertController(title: AppName, message: "Full Name Length should be between 3 to 30 characters", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if !CommonFunctions.validateEmail(emailAddress: selectedDict["email"] as! String)
            {
                let alert = UIAlertController(title: AppName, message: "Please enter valid email address", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if !CommonFunctions.validatePhone(phone: selectedDict["mobileNumber"] as! String){
                let alert = UIAlertController(title: AppName, message: "Mobile Number must contain at least 8 numbers", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if !emailFlag || !phoneFlag
            {
                if editFlag == true
                {
                    if !emailFlag
                    {
                        let alert = UIAlertController(title: AppName, message: "Email already exists, try another.", preferredStyle: UIAlertControllerStyle.alert)
                        let action1 =  UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        })
                        alert.addAction(action1)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    if !phoneFlag
                    {
                        let alert = UIAlertController(title: AppName, message: "Phone number already exists, try another.", preferredStyle: UIAlertControllerStyle.alert)
                        let action1 =  UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        })
                        alert.addAction(action1)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                }
                else
                {
                    let alert = UIAlertController(title: AppName, message: "Your account already exists, would you like to Sign in?", preferredStyle: UIAlertControllerStyle.alert)
                    let action1 =  UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action1)
                    let action2 =  UIAlertAction(title: "YES", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                        self.navigationController?.setViewControllers([viewcontroller], animated: true)
                    })
                    alert.addAction(action2)
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            
            if (selectedDict["nationality"] as! String).isBlank
            {
                let alert = UIAlertController(title: AppName, message: "Nationality field can't be left empty", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if (selectedDict["PR_id"] as! String).isBlank
            {
                let alert = UIAlertController(title: AppName, message: "Permanent Residence field can't be left empty", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if editFlag == false
            {
                if (selectedDict["password"] as! String).characters.count < 6
                {
                    let alert = UIAlertController(title: AppName, message: "Password must contain 6 or more characters", preferredStyle: UIAlertControllerStyle.alert)
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
            else
            {
                if selectedDict["password"] != nil
                {
                    if (selectedDict["password"] as! String).characters.count < 6{
                        let alert = UIAlertController(title: AppName, message: "Password must contain 6 or more characters", preferredStyle: UIAlertControllerStyle.alert)
                        let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        })
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                }
            }
            if editFlag == true
            {
                let userInfo = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
                if selectedDict["email"] as! String == SignUpMetaData.sharedInstance.personalDetailSelectedDict["answer"]?["email"] as! String || selectedDict["email"] as! String == userInfo["email"] as! String{
                    if self.selectedDict["mobileNumber"] as! String == SignUpMetaData.sharedInstance.personalDetailSelectedDict["answer"]?["mobileNumber"] as! String || self.selectedDict["mobileNumber"] as! String == userInfo["mobileNumber"] as! String
                    {
                        if self.selectedDict["countryCode"] as! String == SignUpMetaData.sharedInstance.personalDetailSelectedDict["answer"]?["countryCode"] as! String || self.selectedDict["countryCode"] as! String == userInfo["countryCode"] as! String
                        {
                            self.lastVerificationAndDone()
                        }
                        else
                        {
                            self.verifyPhone()
                        }
                    }
                    else
                    {
                        self.verifyPhone()
                    }
                }
                else
                {
                    verifyEmail()
                }
            }
            else
            {
                verifyEmail()
            }
        }
    }
    
//MARK:- Method for last verification
    
    func lastVerificationAndDone()
    {
        let code = selectedDict["countryCode"] as? String
        var iso:String!
        for element in CountryCodeArray
        {
            if element["code"] == code
            {
                iso = element["iso"]
                break
            }
        }
        if iso == nil
        {
            iso = "SG"
        }
        let phoneNumber = AKFPhoneNumber(countryCode: (code?.replacingOccurrences(of: "+", with: "", options: NSString.CompareOptions.literal, range:nil))!, phoneNumber: (self.selectedDict["mobileNumber"] as? String)!)
        if self.editFlag == true
        {
            
            if SignUpMetaData.sharedInstance.userInfoDict["mobileNumber"] as! String == self.selectedDict["mobileNumber"] as! String
            {
                SignUpMetaData.sharedInstance.userInfoDict["name"] = self.selectedDict["name"] as AnyObject
                SignUpMetaData.sharedInstance.userInfoDict["email"] = self.selectedDict["email"] as AnyObject
                SignUpMetaData.sharedInstance.userInfoDict["mobileNumber"] = self.selectedDict["mobileNumber"] as AnyObject
                SignUpMetaData.sharedInstance.userInfoDict["countryCode"] = self.selectedDict["countryCode"] as AnyObject
                SignUpMetaData.sharedInstance.userInfoDict["nationality"] = self.selectedDict["nationalityName"] as AnyObject
                SignUpMetaData.sharedInstance.userInfoDict["nationalityID"] = self.selectedDict["nationality"] as AnyObject
                SignUpMetaData.sharedInstance.userInfoDict["PR_id"] = self.selectedDict["PR_id"] as AnyObject
                SignUpMetaData.sharedInstance.userInfoDict["PrTitle"] = self.selectedDict["PrTitle"] as AnyObject
                SignUpMetaData.sharedInstance.personalDetailSelectedDict = ["answer":selectedDict as AnyObject,"obQuestionID":SignUpMetaData.sharedInstance.personalDetailDict["obQuestionID"]!]
                if self.selectedDict["password"] == nil
                {
                    SignUpMetaData.sharedInstance.userInfoDict["password"] = "" as AnyObject
                }
                else
                {
                    SignUpMetaData.sharedInstance.userInfoDict["password"] = self.selectedDict["password"] as AnyObject
                }
                let _ = self.navigationController?.popViewController(animated: true)
                return
            }
        }
        let inputState = UUID().uuidString
        if let viewController = self.accountKit.viewControllerForPhoneLogin(with: phoneNumber, state: inputState) as? AKFViewController
        {
            viewController.whitelistedCountryCodes = [iso]
            viewController.defaultCountryCode = iso
            self.prepareLoginViewController(viewController)
            if let viewController = viewController as? UIViewController
            {
                self.present(viewController, animated: true, completion: nil)
            }
        }

    }
    
//MARK: - Post SignUp Data API
    
    func postSignUpData()
    {
        var dict = [String:AnyObject]()
        dict["deviceTypeID"] = "2" as AnyObject?
        dict["comesAfterSignup"] = "0" as AnyObject?
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
            for element in SignUpMetaData.sharedInstance.skillsSelectedArray
            {
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
        if SignUpMetaData.sharedInstance.profilePicSelectedDict["answer"] != nil
        {
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = SignUpMetaData.sharedInstance.profilePicSelectedDict["answer"]?["imageName"] as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.profilePicDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        
        if selectedDict["name"] != nil
        {
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = selectedDict as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.personalDetailDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        dict["data"] = dataArray as AnyObject?
        print(dict)
        KVNProgress.show()
        UserService.postSignUpDataWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let result = data!["result"]?["userInfo"]!
                let questions = data!["result"]?["questions"]! as! [AnyObject]
                let firebase = data!["result"]?["fireBase"]! as? [String:AnyObject]
                let globalStrings = data!["result"]?["globalStrings"]! as? [String:AnyObject]
                let appVersionInfo = data!["result"]?["app_versioning"]! as? [String:AnyObject]

                print(result ?? "No Value")
                UserDefaults.standard.set(result, forKey: "userInfo")
                UserDefaults.standard.set(firebase, forKey: "firebaseInfo")
                UserDefaults.standard.set(globalStrings, forKey: "globalInfo")
                UserDefaults.standard.set(appVersionInfo, forKey: "app_versioning")
                SignUpMetaData.sharedInstance.resetAllDictionaryAndArray()
                self.navigateToHome(questions)
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
    
//MARK: - Get Master Data Post Signup API
    
    func getMasterDataPostLogin()
    {
        var dict = [String:AnyObject]()
        dict["comesAfterSignup"] = 1 as AnyObject?
        KVNProgress.show()
        UserService.getMasterDataWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let result = data!["result"]?["questions"]!
                print(result ?? "No Value")
                SignUpMetaData.sharedInstance.createSeperateObjectsForEachQuestionPostLogin(result as! [AnyObject])
                if (result as! [AnyObject]).count>0
                {
                }
                else
                {
                    let alert = UIAlertController(title: AppName, message: "There is problem in fetching data.", preferredStyle: UIAlertControllerStyle.alert)
                    let action1 =  UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        self.getMasterDataPostLogin()
                    })
                    alert.addAction(action1)
                    let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action2)
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
                    let action1 =  UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        self.getMasterDataPostLogin()
                    })
                    alert.addAction(action1)
                    let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action2)
                }
                self.present(alert, animated: true, completion: nil)
            }
        })
    }

//Method for Verify Email

    func verifyEmail()
    {
        var dict = [String:AnyObject]()
        dict["deviceTypeID"] = "2" as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken")
        {
            dict["deviceToken"] = token as AnyObject?
        }
        else
        {
            dict["deviceToken"] = "12345" as AnyObject?
        }
        dict["email"] = selectedDict["email"] as AnyObject?
        dict["forVerification"] = "1" as AnyObject?
        KVNProgress.show()
        UserService.postLoginDataWithoutPasswordEmailWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                self.emailFlag = false
                if self.editFlag == true
                {
                    let alert = UIAlertController(title: AppName, message: "Email already exists, try another.", preferredStyle: UIAlertControllerStyle.alert)
                    let action1 =  UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action1)
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    let alert = UIAlertController(title: AppName, message: "Your account already exists, would you like to Sign in?", preferredStyle: UIAlertControllerStyle.alert)
                    let action1 =  UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action1)
                    let action2 =  UIAlertAction(title: "YES", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                        self.navigationController?.setViewControllers([viewcontroller], animated: true)
                    })
                    alert.addAction(action2)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            else
            {
                self.emailFlag = true
                if self.editFlag == true
                {
                    let userInfo = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
                    if self.selectedDict["mobileNumber"] as! String == SignUpMetaData.sharedInstance.personalDetailSelectedDict["answer"]?["mobileNumber"] as! String || self.selectedDict["mobileNumber"] as! String == userInfo["mobileNumber"] as! String{
                        self.lastVerificationAndDone()
                    }
                    else
                    {
                        self.verifyPhone()
                    }
                }
                else
                {
                    self.verifyPhone()
                }
            }
        })
    }
    
//MARK:- mrthod for Verfiy Phone
    
    func verifyPhone()
    {
        var dict = [String:AnyObject]()
        dict["deviceTypeID"] = "2" as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken")
        {
            dict["deviceToken"] = token as AnyObject?
        }
        else
        {
            dict["deviceToken"] = "12345" as AnyObject?
        }
        dict["countryCode"] = selectedDict["countryCode"] as AnyObject?
        dict["mobileNumber"] = selectedDict["mobileNumber"] as AnyObject?
        dict["forVerification"] = "0" as AnyObject?
        KVNProgress.show()
        UserService.postLoginDataWithoutPasswordPhoneWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                self.phoneFlag = false
                if self.editFlag == true
                {
                    let alert = UIAlertController(title: AppName, message: "Phone number already exists, try another.", preferredStyle: UIAlertControllerStyle.alert)
                    let action1 =  UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action1)
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    let alert = UIAlertController(title: AppName, message: "Your account already exists, would you like to Sign in?", preferredStyle: UIAlertControllerStyle.alert)
                    let action1 =  UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action1)
                    let action2 =  UIAlertAction(title: "YES", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                        self.navigationController?.setViewControllers([viewcontroller], animated: true)
                    })
                    alert.addAction(action2)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            else
            {
                self.phoneFlag = true
                if self.editFlag == true
                {
                    self.lastVerificationAndDone()
                }
                else
                {
                    self.showPopUpForIAgree()
                }
            }
        })
    }
    
//MARK:- Method for navigation from view to HomeView
    
    func navigateToHome(_ questions:[AnyObject])
    {
        let storyBoard1 = UIStoryboard(name: "Main", bundle: nil)
        let storyBoard2 = UIStoryboard(name: "Menu", bundle: nil)
        let mainViewController   = storyBoard1.instantiateViewController(withIdentifier: "LandingVC") as! LandingVC
        mainViewController.remainingQuestions = questions
        let drawerViewController = storyBoard2.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let drawerController     = KYDrawerController(drawerDirection: .left, drawerWidth: self.view.frame.size.width*3/4)
        drawerController.mainViewController = UINavigationController(rootViewController:mainViewController)
        drawerController.drawerViewController = drawerViewController
        drawerController.mainViewController.navigationController?.isNavigationBarHidden = true
        if let nav = drawerController.displayingViewController as? UINavigationController
        {
            nav.isNavigationBarHidden = true
        }
        self.navigationController?.setViewControllers([drawerController], animated: true)
    }
    
// MARK: - Account Kit Setup
    
    fileprivate func prepareLoginViewController(_ loginViewController: AKFViewController)
    {
        loginViewController.delegate = self
        loginViewController.theme = prepareThemeForPhoneView()
        
    }
    
    fileprivate func pushViewController(_ animated: Bool, navController:UINavigationController)
    {
        if animated
        {
            SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequencePostLogin(navController)
        }
        else
        {
            UIView.performWithoutAnimation
            {
                SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequencePostLogin(navController)
            }
        }
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
    
//MARK: - Register on Firebase
    
    func registerOnFirebase(_ userInfo:[String:AnyObject], questions:[AnyObject]){
        KVNProgress.show()
        let firEmailId = userInfo["email"] as! String
        FIRAuth.auth()?.createUser(withEmail: firEmailId, password: "hvcasjd$%#$%@gfksd1212ADFSYoGe!fkszdfsg", completion: { (user, error) in
            KVNProgress.dismiss()
            if error != nil
            {
                print(error?.localizedDescription ?? "No Value")
                self.loginToFireBaseWithDict(userInfo, questions: questions)
            }
            else
            {
                self.setUserDataModelWithDict(userInfo, questions: questions)
            }
        })
    }
    
//MARK: - Login on Firebase
    
    func loginToFireBaseWithDict(_ userInfo:[String:AnyObject], questions:[AnyObject]){
        KVNProgress.show()
        let firEmailId = userInfo["email"] as! String
        FIRAuth.auth()?.signIn(withEmail: firEmailId, password: "hvcasjd$%#$%@gfksd1212ADFSYoGe!fkszdfsg", completion: { (user, error) in
            KVNProgress.dismiss()
            if error != nil
            {
                print(error?.localizedDescription ?? "No Value")
                return
            }
            else
            {
                self.setUserDataModelWithDict(userInfo, questions: questions)
            }
        })
    }
    
//MARK: - Data Model on Firebase
    
    func setUserDataModelWithDict(_ userInfo:[String:AnyObject], questions:[AnyObject])
    {
        AppDelegate.shared.ref = FIRDatabase.database().reference()
        let milisecond = Date().timeIntervalSince1970*1000
        var dictData = [String:AnyObject]()
        dictData["userId"] = userInfo["jobSeekerID"]
        dictData["onlineStatus"] = "true" as AnyObject?
        dictData["name"] = userInfo["name"]
        dictData["lastSeen"] = milisecond as AnyObject?
        AppDelegate.shared.ref.child("user").child(userInfo["jobSeekerID"] as! String).setValue(dictData)
        self.navigateToHome(questions)
    }
}

//MARK: Extension Tableview Datasources

extension PersonalDetailVC: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if self.editFlag == true
        {
            return 6
        }
        else
        {
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 3
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalDetailCell1") as! PersonalDetailCell
            cell.selectionStyle = .none
            cell.textField.tag = 4
            cell.textField.placeholder = dataDict["questionTexts"]?["nationality"] as? String
            if selectedDict["nationalityName"] != nil
            {
                cell.textField.text = selectedDict["nationalityName"] as? String
            }
            cell.openSelectorBtn.addTarget(self, action: #selector(PersonalDetailVC.openSelector(_:)), for: .touchUpInside)
            cell.openSelectorBtn.tag = indexPath.row
            return cell
        }
        else if indexPath.row == 4{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalDetailCell1") as! PersonalDetailCell
            cell.selectionStyle = .none
            cell.textField.tag = 5
            cell.textField.placeholder = dataDict["questionTexts"]?["PR_id"] as? String
            if selectedDict["PrTitle"] != nil
            {
                cell.textField.text = selectedDict["PrTitle"] as? String
            }
            

            cell.openSelectorBtn.addTarget(self, action: #selector(PersonalDetailVC.openSelector(_:)), for: .touchUpInside)
            cell.openSelectorBtn.tag = indexPath.row
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalDetailCell") as! PersonalDetailCell
            cell.selectionStyle = .none
            switch indexPath.row
            {
            case 0:
                cell.textField.tag = 1
                cell.textField.placeholder = dataDict["questionTexts"]?["full_name"] as? String
                if selectedDict["name"] != nil
                {
                    cell.textField.text = selectedDict["name"] as? String
                    cell.textField.autocapitalizationType = .words
                    cell.textField.keyboardType = .default
                }
                break
            case 1:
                cell.textField.tag = 2
                cell.textField.placeholder = dataDict["questionTexts"]?["email_address"] as? String
                if selectedDict["email"] != nil
                {
                    cell.textField.text = selectedDict["email"] as? String
                    cell.textField.keyboardType = .emailAddress
                }
                break
            case 2:
                cell.textField.tag = 3
                cell.textField.placeholder = dataDict["questionTexts"]?["mobile_number"] as? String
                if selectedDict["countryCode"] != nil
                {
                    countryCodeBtn.setTitle(selectedDict["countryCode"] as? String, for: .normal)
                }
                else
                {
                    countryCodeBtn.setTitle("+65", for: .normal)
                }
                countryCodeBtn.setTitleColor(UIColor.darkGray, for: .normal)
                countryCodeBtn.backgroundColor = UIColor.clear
                countryCodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                countryCodeBtn.frame = CGRect(x: 0, y: 0, width: 40, height: cell.textField.frame.size.height)
                countryCodeBtn.contentHorizontalAlignment = .left
                if editFlag == true
                {
                    countryCodeBtn.isEnabled = false
                }
                seperatorView.frame = CGRect(x: countryCodeBtn.frame.size.width-5, y: 0, width: 1, height: countryCodeBtn.frame.size.height)
                seperatorView.backgroundColor = UIColor.lightGray
                countryCodeBtn.addSubview(seperatorView)
                cell.textField.leftView = countryCodeBtn
                cell.textField.leftViewMode = UITextFieldViewMode.always
                if selectedDict["mobileNumber"] != nil
                {
                    cell.textField.text = selectedDict["mobileNumber"] as? String
                    cell.textField.keyboardType = .decimalPad
                }
                break
            case 5:
                cell.textField.tag = 5
                cell.textField.placeholder = dataDict["questionTexts"]?["secret_password"] as? String
                if selectedDict["password"] != nil
                {
                    cell.textField.text = selectedDict["password"] as? String
                    cell.textField.isSecureTextEntry = true
                }
                break
            default:
                break
            }
            return cell
        }
        
    }
    
    func openSelector(_ button:UIButton)
    {
        if button.tag == 4{
            if selectedDict["nationalityName"] != nil
            {
                if selectedDict["nationality"] as! String != "1"
                {
                    showPopUpForPRList(withArray: prList as [AnyObject])
                }
                else{
                    if selectedDict["nationality"] as! String == "1"{
                        if let prtitle = selectedDict["PrTitle"] as? String{
                            if prtitle == ""{
                                showPopUpForPRList(withArray: prList as [AnyObject])
                            }
                        }
                    }

                }
            }
        }
        else{
            showPopUpForItemDetail(withArray: optionsArray)
        }
    }
}

//MARK:- EXTENSION UITextField Delegate


extension PersonalDetailVC: UITextFieldDelegate
{
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        var cell = textField.superview?.superview as! UITableViewCell
        if !(cell is UITableViewCell)
        {
            cell = cell.superview as! UITableViewCell
        }
        let index = personalDetailTable.indexPath(for: cell)
        if index?.row == 3
        {
            textField.inputView = nil
            showPopUpForItemDetail(withArray: optionsArray)
        }
        if index?.row == 0
        {
            textField.autocapitalizationType = .words
            textField.keyboardType = .default
        }
        if index?.row == 1
        {
            textField.keyboardType = .emailAddress
        }
        
        if index?.row == 2
        {
            textField.keyboardType = .numberPad
        }
        if index?.row == 3
        {
            textField.keyboardType = .default
            textField.resignFirstResponder()
        }
        if index?.row == 4
        {
            textField.keyboardType = .default
            textField.resignFirstResponder()
        }
        if index?.row == 5
        {
            textField.isSecureTextEntry = true
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        var cell = textField.superview?.superview as! UITableViewCell
        if !(cell is UITableViewCell){
            cell = cell.superview as! UITableViewCell
        }
        let index = personalDetailTable.indexPath(for: cell)
        if index?.row == 0
        {
            if textField.text == ""
            {
                selectedDict["name"] = nil
            }
            else
            {
                selectedDict["name"] = textField.text as AnyObject?
            }
        }
        else if index?.row == 1
        {
            if textField.text == ""
            {
                selectedDict["email"] = nil
            }
            else
            {
                selectedDict["email"] = textField.text as AnyObject?
            }
            self.emailFlag = true
        }
        else if index?.row == 2
        {
            if textField.text == ""
            {
                selectedDict["mobileNumber"] = nil
            }
            else
            {
                selectedDict["mobileNumber"] = textField.text as AnyObject?
            }
            selectedDict["countryCode"] = countryCodeBtn.titleLabel?.text as AnyObject?
            self.phoneFlag = true
        }
        else if index?.row == 3
        {
            if textField.text == ""
            {
                selectedDict["nationalityName"] = nil
            }
            else
            {
                selectedDict["nationalityName"] = textField.text as AnyObject?
            }
        }
        else if index?.row == 4
        {
            if textField.text == ""
            {
                selectedDict["PrTitle"] = nil
            }
            else
            {
                selectedDict["PrTitle"] = textField.text as AnyObject?
            }
        }
        else if index?.row == 5
        {
            if textField.text == ""
            {
                selectedDict["password"] = nil
            }
            else
            {
                selectedDict["password"] = textField.text as AnyObject?
            }
        }
    }
}

//MARK:- Extension AKFViewControllerDelegate

extension PersonalDetailVC:AKFViewControllerDelegate
{
    func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!)
    {
        accountKit.requestAccount { (account, error) in
            if error == nil
            {
                if account?.emailAddress != nil
                {
                    if self.selectedDict["email"] as? String == account?.emailAddress
                    {
                        self.accountKit.logOut()
                        if self.editFlag == true
                        {
                            SignUpMetaData.sharedInstance.userInfoDict["name"] = self.selectedDict["name"] as AnyObject
                            SignUpMetaData.sharedInstance.userInfoDict["email"] = self.selectedDict["email"] as AnyObject
                            SignUpMetaData.sharedInstance.userInfoDict["mobileNumber"] = self.selectedDict["mobileNumber"] as AnyObject
                            SignUpMetaData.sharedInstance.userInfoDict["countryCode"] = self.selectedDict["countryCode"] as AnyObject
                            SignUpMetaData.sharedInstance.userInfoDict["nationality"] = self.selectedDict["nationalityName"] as AnyObject
                            SignUpMetaData.sharedInstance.userInfoDict["nationalityID"] = self.selectedDict["nationality"] as AnyObject
                            if self.selectedDict["password"] == nil{
                                SignUpMetaData.sharedInstance.userInfoDict["password"] = "" as AnyObject
                            }
                            else
                            {
                                SignUpMetaData.sharedInstance.userInfoDict["password"] = self.selectedDict["password"] as AnyObject
                            }
                            SignUpMetaData.sharedInstance.personalDetailSelectedDict = ["answer":self.selectedDict as AnyObject,"obQuestionID":SignUpMetaData.sharedInstance.personalDetailDict["obQuestionID"]!]
                            let _ = self.navigationController?.popViewController(animated: true)
                        }
                        else
                        {
                            self.postSignUpData()
                        }
                    }
                    else
                    {
                        let alert = UIAlertController(title: AppName, message: "You have edited the email while confirming. Do not edit it.", preferredStyle: UIAlertControllerStyle.alert)
                        let action1 =  UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { (action) -> Void in
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
                    if self.selectedDict["mobileNumber"] as? String == account?.phoneNumber?.phoneNumber
                    {
                        self.accountKit.logOut()
                        if self.editFlag == true
                        {
                            SignUpMetaData.sharedInstance.userInfoDict["name"] = self.selectedDict["name"] as AnyObject
                            SignUpMetaData.sharedInstance.userInfoDict["email"] = self.selectedDict["email"] as AnyObject
                            SignUpMetaData.sharedInstance.userInfoDict["mobileNumber"] = self.selectedDict["mobileNumber"] as AnyObject
                            SignUpMetaData.sharedInstance.userInfoDict["countryCode"] = self.selectedDict["countryCode"] as AnyObject
                            SignUpMetaData.sharedInstance.userInfoDict["nationality"] = self.selectedDict["nationalityName"] as AnyObject
                            SignUpMetaData.sharedInstance.userInfoDict["nationalityID"] = self.selectedDict["nationality"] as AnyObject
                            if self.selectedDict["password"] == nil
                            {
                                SignUpMetaData.sharedInstance.userInfoDict["password"] = "" as AnyObject
                            }
                            else
                            {
                                SignUpMetaData.sharedInstance.userInfoDict["password"] = self.selectedDict["password"] as AnyObject
                            }
                            SignUpMetaData.sharedInstance.personalDetailSelectedDict = ["answer":self.selectedDict as AnyObject,"obQuestionID":SignUpMetaData.sharedInstance.personalDetailDict["obQuestionID"]!]
                            let _ = self.navigationController?.popViewController(animated: true)
                        }
                        else
                        {
                            self.postSignUpData()
                        }
                    }
                    else
                    {
                        let alert = UIAlertController(title: AppName, message: "You have edited the phone number while confirming. Do not edit it.", preferredStyle: UIAlertControllerStyle.alert)
                        let action1 =  UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                            self.accountKit.logOut()
                            let phoneNumber = AKFPhoneNumber(countryCode: "65", phoneNumber: (self.selectedDict["mobileNumber"] as? String)!)
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

//MARK:- Extension NationalityDelegate

extension PersonalDetailVC:NationalityDelegate
{
    func callBackWithDict(data: [String : AnyObject])
    {
        if data.count>0
        {
            let indexPath = NSIndexPath(row: 3, section: 0)
            let cell = personalDetailTable.cellForRow(at: indexPath as IndexPath) as! PersonalDetailCell!
            cell?.textField.text = data["nationality"] as? String
            selectedDict["nationality"] = data["countryID"]
            selectedDict["nationalityName"] = data["nationality"]
            
            let nextIndexPath = NSIndexPath(row: 4, section: 0)
            let nextCell = personalDetailTable.cellForRow(at: nextIndexPath as IndexPath) as! PersonalDetailCell!
            if data["countryID"] as! String == "1"{
                let fixedData = prList[0]
                nextCell?.textField.text = fixedData["PrTitle"] as? String
                selectedDict["PR_id"] = fixedData["PrID"]
                selectedDict["PrTitle"] = fixedData["PrTitle"]
            }
            else{
                nextCell?.textField.text = ""
                selectedDict["PR_id"] = nil
                selectedDict["PrTitle"] = nil
            }
        }
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }
}

//MARK:- Extension NationalityDelegate

extension PersonalDetailVC:PRSelectionDelegate{
    func callBackWithPRSelectionDict(data:[String:AnyObject]){
        if data.count>0{
            let indexPath = NSIndexPath(row: 4, section: 0)
            let cell = personalDetailTable.cellForRow(at: indexPath as IndexPath) as! PersonalDetailCell!
            cell?.textField.text = data["PrTitle"] as? String
            selectedDict["PR_id"] = data["PrID"]
            selectedDict["PrTitle"] = data["PrTitle"]
        }
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }
}
//MARK:- Extension CountryCodeDelegate

extension PersonalDetailVC:CountryCodeDelegate
{
    func callBackForCodeWithDict(data: [String : AnyObject])
    {
        countryCodeBtn.setTitle(data["code"] as? String, for: .normal)
        selectedDict["countryCode"] = data["code"]
    }
}

//MARK:- Extension IAgreeDelegate

extension PersonalDetailVC:IAgreeDelegate
{
    func callBack()
    {
        self.lastVerificationAndDone()
    }
}
