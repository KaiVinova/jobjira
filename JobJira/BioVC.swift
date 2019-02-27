//
//  BioVC.swift
//  JobJira
//
//  Created by Vaibhav on 12/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import IQKeyboardManager
import KYDrawerController
class BioVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var bioTxt: UITextView!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
//MARK:- Variables and Constants

    var dataDict = [String:AnyObject]()
    var maxLen = 0
    var minLen = 0
    var editFlag:Bool!
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
        if (SignUpMetaData.sharedInstance.bioDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.bioDict
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
        bioTxt.layer.cornerRadius = 4
        bioTxt.layer.masksToBounds = true
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
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 60
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 10
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
        let optionsRange = dataDict["questionInfo"]?["optionsRange"] as? [AnyObject]
        minLen = optionsRange?[0] as! Int
        maxLen = optionsRange?[1] as! Int
        bioTxt.textColor = UIColor.lightGray
        bioTxt.text = "Keep your bio short and sweet.."
        if SignUpMetaData.sharedInstance.bioSelectedDict["answer"] != nil
        {
            bioTxt.textColor = UIColor.darkGray
            bioTxt.text = SignUpMetaData.sharedInstance.bioSelectedDict["answer"] as! String
            let numberOfChars = bioTxt.text.characters.count
            let leftCount = maxLen - numberOfChars
            if leftCount < 1
            {
                countLabel.text = "\(leftCount) Character"
            }
            else
            {
                countLabel.text = "\(leftCount) Characters"
            }
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
        if bioTxt.text == "Keep your bio short and sweet.."
        {
            let alert = UIAlertController(title: AppName, message: "Please write something about yourself to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if bioTxt.text.characters.count <= minLen || bioTxt.text.isBlank
        {
            let alert = UIAlertController(title: AppName, message: "Your bio should be more than \(minLen) characters in length", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        SignUpMetaData.sharedInstance.bioSelectedDict = ["answer":bioTxt.text as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.bioDict["obQuestionID"]!]
        if editFlag == true
        {
            SignUpMetaData.sharedInstance.userInfoDict["bio"] = bioTxt.text as AnyObject
            let _ = navigationController?.popViewController(animated: true)
        }
        else
        {
            postData()
        }
    }
    
//MARK:- Skip Button Action

    @IBAction func skipBtnAction(_ sender: Any)
    {
       let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
//MARK: - Post Answer Data API
    
    func postData()
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        var dataArray = [[String:AnyObject]]()
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
                let _ = self.navigationController?.popToRootViewController(animated: true)
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

//MARK:- Extension UITextViewDelegate

extension BioVC:UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView.text == "Keep your bio short and sweet.."
        {
            textView.textColor = UIColor.darkGray
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text == "" || textView.text == "Keep your bio short and sweet.."
        {
            textView.textColor = UIColor.lightGray
            textView.text = "Keep your bio short and sweet.."
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        let leftCount = maxLen - numberOfChars
        if leftCount < 1
        {
            countLabel.text = "\(leftCount) Character"
        }
        else
        {
            countLabel.text = "\(leftCount) Characters"
        }
        return numberOfChars < maxLen;
    }
}
