//
//  SignInVC.swift
//  JobJira
//
//  Created by Vaibhav on 24/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import KYDrawerController
import Firebase
import TTTAttributedLabel
class SignInVC: UIViewController
{

//MARK:- IBOutlets
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var tAndCLbl: TTTAttributedLabel!
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        loginBtn.layer.cornerRadius=20.0;
        loginBtn.layer.masksToBounds=false;
        let str:NSString = self.tAndCLbl.text! as NSString
        let subscriptionNoticeAttributedString = NSAttributedString(string:str as String, attributes: [
            NSFontAttributeName: UIFont(name:".SFUIText-Light", size:11)!,
            NSParagraphStyleAttributeName: NSMutableParagraphStyle(),
            NSForegroundColorAttributeName: UIColor.darkGray.cgColor,
            ])
        self.tAndCLbl
            .setText(subscriptionNoticeAttributedString)
        let subscriptionNoticeLinkAttributes = [
            NSFontAttributeName: UIFont(name:".SFUIText-Medium", size:12)!,
            NSForegroundColorAttributeName: LightBlueColor,
            NSUnderlineStyleAttributeName: NSNumber(value:true),
            ]
        let subscriptionNoticeActiveLinkAttributes = [
            NSFontAttributeName: UIFont(name:".SFUIText-Medium", size:12)!,
            NSForegroundColorAttributeName: LightBlueColor.withAlphaComponent(0.80),
            NSUnderlineStyleAttributeName: NSNumber(value:true),
            ]
        self.tAndCLbl.linkAttributes = subscriptionNoticeLinkAttributes
        self.tAndCLbl.activeLinkAttributes = subscriptionNoticeActiveLinkAttributes
        let range : NSRange = str.range(of: "Terms & Conditions")
        self.tAndCLbl.addLink(to: NSURL(string: "https://www.google.com")! as URL!, with: range)
        self.tAndCLbl.delegate = self
        getMasterData()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }

//MARK:- Forgot Button Action

    @IBAction func forgetPasswordBtnAction(_ sender: Any)
    {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "ResetVC") as! ResetVC
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
//MARK:- Login Button Action
    
    @IBAction func loginBtnAction(_ sender: Any)
    {
        if usernameTxt.text == ""
        {
            let alert = UIAlertController(title: AppName, message: "Please enter your email address/Mobile No.", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.usernameTxt.text = ""
                self.usernameTxt.becomeFirstResponder()
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if !CommonFunctions.validateEmail(emailAddress: usernameTxt.text) && !(usernameTxt.text?.isPhoneNumber)!
        {
            let alert = UIAlertController(title: AppName, message: "Please enter the valid Email address", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.usernameTxt.text = ""
                self.usernameTxt.becomeFirstResponder()
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if passwordTxt.text == ""
        {
            let alert = UIAlertController(title: AppName, message: "Please enter your password", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.passwordTxt.text = ""
                self.passwordTxt.becomeFirstResponder()
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        postLoginData()
    }

//MARK:- SignUp Button Action
    
    @IBAction func signUpBtnAction(_ sender: Any)
    {
        if SignUpMetaData.sharedInstance.viewControllerOrder.count>0
        {
            SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Try re-launcing the app", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
//MARK: - Post Login Data for signup API
    
    func postLoginData()
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
        if (usernameTxt.text?.isEmail)!
        {
            dict["email"] = usernameTxt.text as AnyObject?
        }
        else
        {
            dict["email"] = usernameTxt.text as AnyObject?
            if usernameTxt.text?.characters.count == 10
            {
                dict["countryCode"] = "+91" as AnyObject?
            }
            else
            {
                dict["countryCode"] = "+65" as AnyObject?
            }
        }
        dict["password"] = passwordTxt.text as AnyObject?
        KVNProgress.show()
        UserService.postLoginDataWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let result = data!["result"]?["userInfo"]! as? [String:AnyObject]
                let questions = data!["result"]?["questions"]! as? [AnyObject]
                let firebase = data!["result"]?["fireBase"]! as? [String:AnyObject]
                let globalStrings = data!["result"]?["globalStrings"]! as? [String:AnyObject]
                let appVersionInfo = data!["result"]?["app_versioning"]! as? [String:AnyObject]

                print(data!["result"] ?? "No Value")
                UserDefaults.standard.set(result, forKey: "userInfo")
                UserDefaults.standard.set(firebase, forKey: "firebaseInfo")
                UserDefaults.standard.set(globalStrings, forKey: "globalInfo")
                UserDefaults.standard.set(appVersionInfo, forKey: "app_versioning")
                self.navigateToHome(questions!)
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
    
//MARK;- method for navigate to home view from current view
    
    func navigateToHome(_ question:[AnyObject])
    {
        let storyBoard1 = UIStoryboard(name: "Main", bundle: nil)
        let storyBoard2 = UIStoryboard(name: "Menu", bundle: nil)
        let drawerViewController = storyBoard2.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let drawerController     = KYDrawerController(drawerDirection: .left, drawerWidth: self.view.frame.size.width*3/4)
        if let userInfo = UserDefaults.standard.object(forKey: "userInfo") as? [String:AnyObject]{
            if userInfo["PrTitle"] as! String != ""{
                let mainViewController = storyBoard1.instantiateViewController(withIdentifier: "LandingVC") as! LandingVC
                mainViewController.remainingQuestions = question
                drawerController.mainViewController = UINavigationController(
                    rootViewController: mainViewController)
            }
            else{
                let mainViewController = storyBoard2.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                drawerController.mainViewController = UINavigationController(
                    rootViewController: mainViewController)
                drawerController.mainViewController.navigationController?.navigationBar.isHidden = true
            }
        }
        drawerController.drawerViewController = drawerViewController
        drawerController.mainViewController.navigationController?.isNavigationBarHidden = true
        if let nav = drawerController.displayingViewController as? UINavigationController
        {
            nav.isNavigationBarHidden = true
        }
        self.navigationController?.setViewControllers([drawerController], animated: true)
    }
    
//MARK: - Get Master Data for signup API
    
    func getMasterData()
    {
        var dict = [String:AnyObject]()
        dict["comesAfterSignup"] = 0 as AnyObject?
        KVNProgress.show()
        UserService.getMasterDataWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let result = data!["result"]?["questions"]!
                print(result ?? "No Value")
                SignUpMetaData.sharedInstance.createSeperateObjectsForEachQuestion(result as! [AnyObject])
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

//MARk:- Extension UITextFieldDelegate

extension SignInVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}

//MARk:- Extension TTTAttributedLabelDelegate

extension SignInVC:TTTAttributedLabelDelegate
{
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!)
    {
        let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
        let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
        viewcontroller.titleText = "Terms & Conditions"
        viewcontroller.loadData = "1"
        viewcontroller.fromScreen = "pre"
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
}
