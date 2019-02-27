//
//  ResetVC.swift
//  JobJira
//
//  Created by Vaibhav on 24/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import AccountKit
import KYDrawerController
class ResetVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var usernameTxt: UITextField!
    
//MARK:- Variables and Constans
    
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    fileprivate var pendingLoginViewController: AKFViewController? = nil
    fileprivate var showAccountOnAppear = false
    var questions:[AnyObject]!
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        showAccountOnAppear = accountKit.currentAccessToken != nil
        pendingLoginViewController = accountKit.viewControllerForLoginResume() as? AKFViewController
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
//MARK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        let _ = navigationController?.popViewController(animated: true)
    }
    
//MARK:- Done Button Action
    
    @IBAction func doneBtnAction(_ sender: Any)
    {
        if CommonFunctions.validateEmail(emailAddress: usernameTxt.text)
        {
            postLoginDataWithoutPasswordEmail()
        }
        else if CommonFunctions.validatePhone(phone: usernameTxt.text)
        {
            postLoginDataWithoutPasswordPhone()
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please enter valid Email/Mobile No.", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
//MARK: - Post Login Data for signup API
    
    func postLoginDataWithoutPasswordEmail()
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
        dict["email"] = usernameTxt.text as AnyObject?
        dict["forVerification"] = "1" as AnyObject?
        KVNProgress.show()
        UserService.postLoginDataWithoutPasswordEmailWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let inputState = UUID().uuidString
                if let viewController = self.accountKit.viewControllerForEmailLogin(withEmail: self.usernameTxt.text, state: inputState) as? AKFViewController
                {
                    self.prepareLoginViewController(viewController)
                    if let viewController = viewController as? UIViewController
                    {
                        self.present(viewController, animated: true, completion: nil)
                    }
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
    
//MARK: - Post Login Data for signup API
    
    func postLoginDataWithoutPasswordEmailAfterVerify()
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
        dict["email"] = usernameTxt.text as AnyObject?
        dict["forVerification"] = "0" as AnyObject?
        KVNProgress.show()
        UserService.postLoginDataWithoutPasswordEmailWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let result = data!["result"]?["userInfo"]!
                self.questions = data!["result"]?["questions"]! as! [AnyObject]!
                let firebase = data!["result"]?["fireBase"]! as? [String:AnyObject]
                let globalStrings = data!["result"]?["globalStrings"]! as? [String:AnyObject]
                let appVersionInfo = data!["result"]?["app_versioning"]! as? [String:AnyObject]

                print(result ?? "No Value")
                UserDefaults.standard.set(result, forKey: "userInfo")
                UserDefaults.standard.set(firebase, forKey: "firebaseInfo")
                UserDefaults.standard.set(globalStrings, forKey: "globalInfo")
                UserDefaults.standard.set(appVersionInfo, forKey: "app_versioning")

                self.navigateToHome(self.questions)
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
    
//MARK:- Method for PostLogin Data
    
    func postLoginDataWithoutPasswordPhone()
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
        if usernameTxt.text?.characters.count == 10
        {
            dict["countryCode"] = "+91" as AnyObject?
        }
        else
        {
            dict["countryCode"] = "+65" as AnyObject?
        }
        dict["mobileNumber"] = usernameTxt.text as AnyObject?
        dict["forVerification"] = "1" as AnyObject?
        KVNProgress.show()
        UserService.postLoginDataWithoutPasswordPhoneWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {

                let phoneNumber = AKFPhoneNumber(countryCode: (dict["countryCode"] as! String).replacingOccurrences(of: "+", with: "", options: NSString.CompareOptions.literal, range:nil), phoneNumber: self.usernameTxt.text!)
                let inputState = UUID().uuidString
                if let viewController = self.accountKit.viewControllerForPhoneLogin(with: phoneNumber, state: inputState) as? AKFViewController
                {
                    self.prepareLoginViewController(viewController)
                    if let viewController = viewController as? UIViewController
                    {
                        self.present(viewController, animated: true, completion: nil)
                    }
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
    
    func postLoginDataWithoutPasswordPhoneAfterVerify()
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
        if usernameTxt.text?.characters.count == 10
        {
            dict["countryCode"] = "+91" as AnyObject?
        }
        else
        {
            dict["countryCode"] = "+65" as AnyObject?
        }
        dict["mobileNumber"] = usernameTxt.text as AnyObject?
        dict["forVerification"] = "0" as AnyObject?
        KVNProgress.show()
        UserService.postLoginDataWithoutPasswordPhoneWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let result = data!["result"]?["userInfo"]!
                self.questions = data!["result"]?["questions"]! as! [AnyObject]!
                let firebase = data!["result"]?["fireBase"]! as? [String:AnyObject]
                let globalStrings = data!["result"]?["globalStrings"]! as? [String:AnyObject]
                let appVersionInfo = data!["result"]?["app_versioning"]! as? [String:AnyObject]

                print(result ?? "No Value")
                UserDefaults.standard.set(result, forKey: "userInfo")
                UserDefaults.standard.set(firebase, forKey: "firebaseInfo")
                UserDefaults.standard.set(globalStrings, forKey: "globalInfo")
                UserDefaults.standard.set(appVersionInfo, forKey: "app_versioning")

                self.navigateToHome(self.questions)
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
    
// MARK: - helpers
    
    fileprivate func prepareLoginViewController(_ loginViewController: AKFViewController)
    {
        loginViewController.delegate = self
        loginViewController.theme = prepareThemeForPhoneView()

    }
    
    fileprivate func pushViewController(_ animated: Bool)
    {
        if animated
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "LandingVC") as! LandingVC
            self.navigationController?.setViewControllers([viewcontroller], animated: true)
        }
        else
        {
            UIView.performWithoutAnimation
                {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "LandingVC") as! LandingVC
                self.navigationController?.setViewControllers([viewcontroller], animated: true)
            }
        }
    }
    
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
    
//MARK:- AKFTheme
    
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

//MARK:- Extension UITextFieldDelegate

extension ResetVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.resignFirstResponder()
    }
}

//MARK:- Extension AKFViewControllerDelegate

extension ResetVC:AKFViewControllerDelegate
{
    func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!)
    {
        accountKit.requestAccount { (account, error) in
            if error == nil{
                if account?.emailAddress != nil
                {
                    if self.usernameTxt.text == account?.emailAddress
                    {
                        self.accountKit.logOut()
                        self.postLoginDataWithoutPasswordEmailAfterVerify()
                    }
                    else
                    {
                        let alert = UIAlertController(title: AppName, message: "You have edited the email while confirming. Do not edit it.", preferredStyle: UIAlertControllerStyle.alert)
                        let action1 =  UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                            self.accountKit.logOut()
                            let inputState = UUID().uuidString
                            if let viewController = self.accountKit.viewControllerForEmailLogin(withEmail: self.usernameTxt.text, state: inputState) as? AKFViewController {
                                self.prepareLoginViewController(viewController)
                                if let viewController = viewController as? UIViewController {
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
                    if self.usernameTxt.text == account?.phoneNumber?.phoneNumber
                    {
                        self.accountKit.logOut()
                        self.postLoginDataWithoutPasswordPhoneAfterVerify()
                    }
                    else
                    {
                        let alert = UIAlertController(title: AppName, message: "You have edited the phone number while confirming. Do not edit it.", preferredStyle: UIAlertControllerStyle.alert)
                        let action1 =  UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                            self.accountKit.logOut()
                            let phoneNumber = AKFPhoneNumber(countryCode: "65", phoneNumber: self.usernameTxt.text!)
                            let inputState = UUID().uuidString
                            if let viewController = self.accountKit.viewControllerForPhoneLogin(with: phoneNumber, state: inputState) as? AKFViewController {
                                self.prepareLoginViewController(viewController)
                                if let viewController = viewController as? UIViewController {
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
