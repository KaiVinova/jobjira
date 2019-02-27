//
//  EducationVC.swift
//  JobJira
//
//  Created by Vaibhav on 12/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import KYDrawerController
@objc protocol EducationDelegate
{
    @objc optional func callBackWithDict(data:[String:AnyObject])
}
@objc protocol DegreeDelegate
{
    @objc optional func callBackWithDegreeDict(data:[String:AnyObject])
}
@objc protocol QualificationDelegate
{
    @objc optional func callBackWithQualificationDict(data:[String:AnyObject])
}
class EducationVC: UIViewController
{

//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subTitle2Label: UILabel!
    @IBOutlet weak var experinceBtnView: UIView!
    @IBOutlet weak var experinceLabel: UILabel!
    @IBOutlet weak var experinceBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var degreeBtnView: UIView!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var degreeBtn: UIButton!
    @IBOutlet weak var instituteBtnView: UIView!
    @IBOutlet weak var instituteLabel: UILabel!
    @IBOutlet weak var instituteBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var degreeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var instituteTopConstraint: NSLayoutConstraint!
    
//MARK:- Variables and Constants
    
    var dataDict = [String:AnyObject]()
    var optionsArray = [AnyObject]()
    var selectedDict = [String:AnyObject]()
    var editFlag:Bool!
    var fixedTopConstraint:CGFloat!
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
        experinceBtnView.layer.cornerRadius=20.0;
        experinceBtnView.layer.masksToBounds=false;
        degreeBtnView.layer.cornerRadius=20.0;
        degreeBtnView.layer.masksToBounds=false;
        instituteBtnView.layer.cornerRadius=20.0;
        instituteBtnView.layer.masksToBounds=false;
        degreeBtnView.layer.borderColor = degreeBtnView.backgroundColor?.cgColor
        degreeBtnView.layer.borderWidth = 1
        degreeBtnView.backgroundColor = UIColor.white
        instituteBtnView.layer.borderColor = instituteBtnView.backgroundColor?.cgColor
        instituteBtnView.layer.borderWidth = 1
        instituteBtnView.backgroundColor = UIColor.white
        degreeLabel.textColor = UIColor.darkGray
        instituteLabel.textColor = UIColor.darkGray
        if (SignUpMetaData.sharedInstance.educationDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.educationDict
        }
        if editFlag == true
        {
            skipBtn.isHidden = true
        }
        else
        {
            if dataDict["questionInfo"]?["isRequired"] as! String == "1"
            {
                skipBtn.isHidden = true
            }
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
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        fixedTopConstraint = degreeBtnView.frame.size.height+10
        print(fixedTopConstraint)
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
        experinceLabel.text = dataDict["questionTexts"]?["select_qualification"] as? String
        degreeLabel.text = dataDict["questionTexts"]?["education_degree"] as? String
        instituteLabel.text = dataDict["questionTexts"]?["education_institute"] as? String
        let questionOptions = dataDict["questionOptions"]?["educationalQualifications"] as? [AnyObject]
        optionsArray = questionOptions!
        degreeBtnView.isHidden = true
        instituteBtnView.isHidden = true
        if SignUpMetaData.sharedInstance.educationSelectedDict["answer"] as? [String:AnyObject] != nil
        {
            if ((SignUpMetaData.sharedInstance.educationSelectedDict["answer"] as? [String:AnyObject])?.count)!>0
            {
                let qualification = "\(SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationalQualificationName"] as! String)"
                self.experinceLabel.text = qualification
                var tempDict = [String:AnyObject]()
                tempDict["educationalQualificationID"] = SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationalQualificationID"] as AnyObject
                tempDict["educationalQualificationName"] = SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationalQualificationName"] as AnyObject
                selectedDict["qualification"] = tempDict as AnyObject?
                if SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationalQualificationID"] as! String != "6"
                {
                    let institute = "\(SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationInstitution"] as! String)"
                    self.instituteLabel.text = institute
                    degreeBtnView.isHidden = false
                    instituteBtnView.isHidden = false
                    selectedDict["institute"] = institute as AnyObject?
                    if SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationalQualificationID"] as! String == "3" || SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationalQualificationID"] as! String == "4" || SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationalQualificationID"] as! String == "5"
                    {
                        let degree = "\(SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationDegree"] as! String)"
                        self.degreeLabel.text = degree
                        selectedDict["degree"] = degree as AnyObject?
                        degreeBtnView.isUserInteractionEnabled = true
                        degreeBtnView.backgroundColor = UIColor.white
                        degreeBtnView.layoutIfNeeded()
                    }
                    else
                    {
                        degreeBtnView.isHidden = true
                        instituteTopConstraint.constant = 5
                        degreeBtnView.layoutIfNeeded()
                    }
                }
                else
                {
                    degreeBtnView.isHidden = true
                    instituteBtnView.isHidden = true
                }
            }
        }
    }
    
//MARK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        let _ = navigationController?.popViewController(animated: true)
    }
    
//MARK:- Done Button Actipn
    
    @IBAction func doneBtnAction(_ sender: Any)
    {
        if selectedDict.count>0
        {
            if selectedDict["qualification"] == nil
            {
                let alert = UIAlertController(title: AppName, message: "Choose your last qualification", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if selectedDict["qualification"]?["educationalQualificationID"] as? String != "6"
            {
                
                if selectedDict["qualification"]?["educationalQualificationID"] as? String == "3" || selectedDict["qualification"]?["educationalQualificationID"] as? String == "4" || selectedDict["qualification"]?["educationalQualificationID"] as? String == "5"
                {
                    if selectedDict["degree"] == nil
                    {
                        let alert = UIAlertController(title: AppName, message: "Choose your last specialization", preferredStyle: UIAlertControllerStyle.alert)
                        let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        })
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                }
                if selectedDict["institute"] == nil
                {
                    let alert = UIAlertController(title: AppName, message: "Choose where you last studied", preferredStyle: UIAlertControllerStyle.alert)
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
            var tempDict = [String:AnyObject]()
            tempDict = selectedDict["qualification"] as! [String : AnyObject]
            if selectedDict["qualification"]?["educationalQualificationID"] as? String != "6"
            {
                tempDict["educationInstitution"] = selectedDict["institute"]
                if selectedDict["qualification"]?["educationalQualificationID"] as? String == "3" || selectedDict["qualification"]?["educationalQualificationID"] as? String == "4" || selectedDict["qualification"]?["educationalQualificationID"] as? String == "5"{
                    tempDict["educationDegree"] = selectedDict["degree"]
                }
            }
            SignUpMetaData.sharedInstance.educationSelectedDict = ["answer":tempDict as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.educationDict["obQuestionID"]!]
            if editFlag == true
            {
                SignUpMetaData.sharedInstance.userInfoDict["educationalQualifications"] = SignUpMetaData.sharedInstance.educationSelectedDict["answer"] as AnyObject
                let _ = navigationController?.popViewController(animated: true)
            }
            else
            {
                SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
            }
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please specify your last qualification to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
//MARK:- Skip Button Action
    
    @IBAction func skipBtnAction(_ sender: Any)
    {
        SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
    }
    
//MARK:- Experience Button Action
    
    @IBAction func experinceBtnAction(_ sender: Any)
    {
        showPopUpForQualification(withArray: optionsArray)
    }
    
//MARK:- Degree Button Action
    
    @IBAction func degreeBtnAction(_ sender: Any)
    {
        showPopUpForDegree(withArray: optionsArray)
    }
    
//MARK:- Institute Button Action
    
    @IBAction func instituteBtnAction(_ sender: Any)
    {
        showPopUpForItemDetail(withArray: optionsArray)
    }
    
// MARK: Add item detail view Method
    
    func showPopUpForItemDetail(withArray array:[AnyObject])
    {
        let popup = EducationSelectionView.instansiateFromNib()
        popup.educationDelegate = self
        popup.selectedText = instituteLabel.text
        popup.placeholderString = dataDict["questionTexts"]?["education_institute"] as? String
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(popup)
        popup.showPopup()
    }
    
// MARK: Add Qualification view Method
    
    func showPopUpForQualification(withArray array:[AnyObject])
    {
        let popup = QualificationView.instansiateFromNib()
        popup.qualificationDelegate = self
        popup.dataArray = array
        popup.selectedQualification = experinceLabel.text
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(popup)
        popup.showPopup()
    }
    
// MARK: Add Degree view Method
    
    func showPopUpForDegree(withArray array:[AnyObject])
    {
        let popup = DegreeView.instansiateFromNib()
        popup.degreeDelegate = self
        popup.selectedText = degreeLabel.text
        popup.placeholderString = dataDict["questionTexts"]?["education_degree"] as? String
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(popup)
        popup.showPopup()
    }
    
//MARK: - Post Answer Data API
    
    func postData()
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        var dataArray = [[String:AnyObject]]()
        if SignUpMetaData.sharedInstance.educationSelectedDict["answer"] != nil
        {
            var tempDict = [String:AnyObject]()
            var answerDict = [String:AnyObject]()
            answerDict["educationalQualificationID"] = SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationalQualificationID"] as AnyObject?
            if SignUpMetaData.sharedInstance.educationSelectedDict["qualification"]?["educationalQualificationID"] as? String != "6"
            {
                answerDict["educationInstitution"] = SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationInstitution"] as AnyObject?
                if SignUpMetaData.sharedInstance.educationSelectedDict["qualification"]?["educationalQualificationID"] as? String == "3" || SignUpMetaData.sharedInstance.educationSelectedDict["qualification"]?["educationalQualificationID"] as? String == "4" || SignUpMetaData.sharedInstance.educationSelectedDict["qualification"]?["educationalQualificationID"] as? String == "5"
                {
                    answerDict["educationDegree"] = SignUpMetaData.sharedInstance.educationSelectedDict["answer"]?["educationDegree"] as AnyObject?
                }
            }
            tempDict["answer"] = answerDict as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.educationDict["obQuestionID"]
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

//MARK:- Extension QualificationDelegate

extension EducationVC:QualificationDelegate
{
    func callBackWithQualificationDict(data:[String:AnyObject])
    {
        experinceLabel.text = "\(data["educationalQualificationName"] as! String)"
        selectedDict["qualification"] = data as AnyObject
        if data["educationalQualificationID"] as! String == "6"
        {
            degreeBtnView.isHidden = true
            instituteBtnView.isHidden = true
            selectedDict["degree"] = nil
            selectedDict["institute"] = nil
        }
        else
        {
            degreeBtnView.isHidden = false
            instituteBtnView.isHidden = false
            degreeLabel.text = dataDict["questionTexts"]?["education_degree"] as? String
            instituteLabel.text = dataDict["questionTexts"]?["education_institute"] as? String
            selectedDict["degree"] = nil
            selectedDict["institute"] = nil
            if data["educationalQualificationID"] as! String == "1" || data["educationalQualificationID"] as! String == "2"
            {
                degreeBtnView.isHidden = true
                instituteTopConstraint.constant = 5
                degreeBtnView.layoutIfNeeded()
            }
            else
            {
                degreeBtnView.isHidden = false
                instituteTopConstraint.constant = fixedTopConstraint
                degreeBtnView.layoutIfNeeded()
            }
        }
    }
}

//MARK:- Extension DegreeDelegate

extension EducationVC:DegreeDelegate
{
    func callBackWithDegreeDict(data:[String:AnyObject])
    {
        if data["degree"] != nil
        {
            degreeLabel.text = "\(data["degree"] as! String)"
            selectedDict["degree"] = data["degree"] as AnyObject
        }
    }
}

//MARK:- Extension EducationDelegate

extension EducationVC:EducationDelegate
{
    func callBackWithDict(data:[String:AnyObject])
    {
        if data["institute"] != nil
        {
            instituteLabel.text = "\(data["institute"] as! String)"
            selectedDict["institute"] = data["institute"] as AnyObject
        }
    }
}
