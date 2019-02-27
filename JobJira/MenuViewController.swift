//
//  MenuViewController.swift
//  JobJira
//
//  Created by Vaibhav on 15/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import SafariServices
import KYDrawerController
import Firebase
class MenuViewController: UIViewController
{
    
//MARK:- IBoutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var picImgView: CircularImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
//MARK:- Variables and Constants
    
    let iconArrayWithoutUpdate = ["home", "profile-1", "activities", "refer", "rate", "terms", "privacy", "support", "settings", "logout"]
    let titleArrayWithoutUpdate = ["Home", "My Profile", "Your Activities", "Refer a Friend", "Rate Jobjira", "Terms & Conditions", "Privacy Policy", "Contact Support", "Settings", "Logout"]
    let iconArrayWithUpdate = ["home", "profile-1", "activities", "refer", "rate", "terms", "privacy", "support", "settings", "new", "logout"]
    let titleArrayWithUpdate = ["Home", "My Profile", "Your Activities", "Refer a Friend", "Rate Jobjira", "Terms & Conditions", "Privacy Policy", "Contact Support", "Settings", "Update Version", "Logout"]
    var iconArray = [String]()
    var titleArray = [String]()

//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.backgroundView = UIView()
        checkVersion()
    }
    
    //MARK: - Check version of the App
    func checkVersion(){
        let appVersion = UserDefaults.standard.object(forKey: "app_versioning") as? [String:AnyObject]
        if appVersion != nil{
            let iOSVersion = appVersion!["IOS"] as! [String:AnyObject]
            let maxVersion = iOSVersion["latestVersion"] as! Float
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                print(Float(version)!)
                let versionF = Float(version)!
                if versionF < maxVersion{
                    iconArray = iconArrayWithUpdate
                    titleArray = titleArrayWithUpdate
                }
                else{
                    iconArray = iconArrayWithoutUpdate
                    titleArray = titleArrayWithoutUpdate
                }
            }
        }
        else{
            iconArray = iconArrayWithoutUpdate
            titleArray = titleArrayWithoutUpdate
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if let dict = UserDefaults.standard.object(forKey: "userInfo")
        {
            let userDict = dict as! [String:AnyObject]
            if userDict["name"] as! String == ""
            {
                nameLbl.text = "User"
            }
            else
            {
                nameLbl.text = userDict["name"] as? String
            }
            if userDict["profilePicture"] as! String == ""
            {
                if userDict["genderID"] as! String == "1"
                {
                    picImgView.image = UIImage(named: "avatar_man")
                }
                else
                {
                    picImgView.image = UIImage(named: "avatar_woman")
                }
            }
            else
            {
                if InitializerHelper.sharedInstance.profileImage != nil
                {
                    picImgView.image = InitializerHelper.sharedInstance.profileImage
                }
                else
                {
                    let picUrlRequest = URLRequest(url: URL(string: userDict["profilePicture"] as! String)!)
                    picImgView.setImageWith(picUrlRequest, placeholderImage: nil, success: { (request, reponse, image) in
                        InitializerHelper.sharedInstance.profileImage = nil
                        InitializerHelper.sharedInstance.profileImage = image
                        self.picImgView.image = InitializerHelper.sharedInstance.profileImage
                    }, failure: { (request, response, error) in
                        InitializerHelper.sharedInstance.profileImage = nil
                    })
                }
            }
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
// MARK: - Safari Delegate
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
// MARK: - Push View Controller Method
    
    func navigateToMenuOptions(_ viewController:UIViewController)
    {
        if let drawerController = self.parent as? KYDrawerController
        {
            drawerController.setDrawerState(.closed, animated: true)
            if let nav = self.parent?.childViewControllers[0] as? UINavigationController
            {
                nav.setViewControllers([viewController], animated: true)
            }
        }
    }
    
// MARK: - Share Method
    
    func shareApp()
    {
        let text:String!
        let url:URL!
        if let globalInfo = UserDefaults.standard.object(forKey: "globalInfo") as? [String:AnyObject]
        {
            text = globalInfo["inviteMessage"] as! String
            url = URL(string: globalInfo["websiteUrl"] as! String)!
        }
        else
        {
            text = "Hey mate, please check out the awesome app for finding jobs."
            url = URL(string: "https://www.Jobjira.com")!
        }
        let textToShare = [text, url] as [Any]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }
  
// MARK: - Logout Method
    
    func popAndLogout()
    {
        if (self.parent as? KYDrawerController) != nil
        {
            if UserDefaults.standard.object(forKey: "userInfo") != nil
            {
                UserDefaults.standard.removeObject(forKey: "userInfo")
                SignUpMetaData.sharedInstance.resetAllDictionaryAndArrayPreLoginAndPostLogin()
                InitializerHelper.sharedInstance.profileImage = nil
                InitializerHelper.sharedInstance.videoImage = nil
            }
            if UserDefaults.standard.object(forKey: "firebaseInfo") != nil
            {
                UserDefaults.standard.removeObject(forKey: "firebaseInfo")
            }
            if FIRAuth.auth()?.currentUser != nil
            {
                do
                {
                    _ = try FIRAuth.auth()?.signOut()
                }
                catch let error
                {
                    print(error.localizedDescription)
                }
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            self.navigationController?.setViewControllers([viewController], animated: true)
        }
    }
    
// MARK: - Show App Store Link Method
    
    func jumpToAppStore(appId: String)
    {
        let urlHttp:String!
        if let globalInfo = UserDefaults.standard.object(forKey: "globalInfo") as? [String:AnyObject]
        {
            urlHttp = globalInfo["appStoreLink"] as! String
        }
        else
        {
            urlHttp = "https://itunes.apple.com/"
        }
        UIApplication.shared.openURL(NSURL(string: urlHttp)! as URL)
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
                self.popAndLogout()
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

//MARK:- Extension UITableViewDelegate

extension MenuViewController:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (UI_USER_INTERFACE_IDIOM() == .pad)
        {
            return 64
        }
        else
        {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        switch indexPath.row
        {
            case 0:
                InitializerHelper.sharedInstance.resetFilters()
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "LandingVC") as! LandingVC
                navigateToMenuOptions(viewcontroller)
                break
            case 1:
                SignUpMetaData.sharedInstance.userInfoDict = [String:AnyObject]()
                let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                navigateToMenuOptions(viewcontroller)
                break
            case 2:
                let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "YourActivitiesVC") as! YourActivitiesVC
                navigateToMenuOptions(viewcontroller)
                break
            case 3:
                shareApp()
                break
            case 4:
                jumpToAppStore(appId: "1166965056")
                break
            case 5:
                let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                viewcontroller.titleText = "Terms & Conditions"
                viewcontroller.loadData = "1"
                viewcontroller.fromScreen = "post"
                navigateToMenuOptions(viewcontroller)
                break
            case 6:
                let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                viewcontroller.titleText = "Privacy Policy"
                viewcontroller.loadData = "2"
                viewcontroller.fromScreen = "post"
                navigateToMenuOptions(viewcontroller)
                break
            case 7:
                let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "ContactSupportVC") as! ContactSupportVC
                navigateToMenuOptions(viewcontroller)
                break
            case 8:
                let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
                navigateToMenuOptions(viewcontroller)
                break
            case 9:
                if titleArray.count == 10{
                    let alert = UIAlertController(title: AppName, message: "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.actionSheet)
                    let action1 =  UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        self.postDynamicChangesData("logout")
                    })
                    let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
                    })
                    alert.addAction(action1)
                    alert.addAction(action2)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    jumpToAppStore(appId: "1166965056")
                }
                break
        case 10:
            let alert = UIAlertController(title: AppName, message: "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.actionSheet)
            let action1 =  UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.postDynamicChangesData("logout")
            })
            let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            })
            alert.addAction(action1)
            alert.addAction(action2)
            self.present(alert, animated: true, completion: nil)
            break
            default:
                break
        }
        SignUpMetaData.sharedInstance.resetAllDictionaryAndArrayPreLoginAndPostLogin()
    }
}

//MARK:- Extension UITableViewDataSource

extension MenuViewController:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1") as! MenuCell
        cell.selectionStyle = .none
        cell.menuNameLabel.text = titleArray[indexPath.row]
        cell.iconImage.image = UIImage(named: iconArray[indexPath.row])
        return cell
    }
}
