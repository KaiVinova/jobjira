//
//  LandingVC.swift
//  JobJira
//
//  Created by Vaibhav on 03/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import KYDrawerController
import Koloda
import pop

private var numberOfCards: UInt = 5
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.8

@objc protocol AdDelegate
{
    @objc optional func callBackWithStatus(_ status:Bool)
}

@objc protocol JobDetailDelegate
{
    @objc optional func callBackWithAction(_ status:String)
}

@objc protocol FilterDelegate
{
    @objc optional func callBackWithFilter(_ dict:[String:AnyObject])
}

class LandingVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var swipingView: KolodaView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var checkIcon: UIImageView!
    @IBOutlet weak var matchInfoLbl: UILabel!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var placeholderLbl: UILabel!
    @IBOutlet weak var notifyLbl: UILabel!
    
//MARK:- Variables and Constants
    
    var remainingQuestions:[AnyObject]!
    var dataSource: Array<UIImage> =
        {
        var array: Array<UIImage> = []
        for index in 0..<numberOfCards
        {
            array.append(UIImage(named: "cards_\(index + 1)")!)
        }
        
        return array
    }()
    var cardArray = [AnyObject]()
    var index:Int!
    var totalJobAvailable:Int!
    var adBannerStatus:Bool = false
    var adFiredStatus:Bool = false
    var adArray = [AnyObject]()
    var backFlag = "0"
    var checkAdditionalQuestionFlag:String!
    var filterDict = [String:AnyObject]()
    var selctedFilter = [String:AnyObject]()
    let placeholderNormalString = "No new matching jobs available. You can also try filtering."
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UserDefaults.standard.set("0", forKey: "versionFlag")
        UserDefaults.standard.set("0", forKey: "popUp")
        UIApplication.shared.statusBarStyle = .lightContent
        swipingView.delegate = self
        swipingView.dataSource = self
        swipingView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        swipingView.countOfVisibleCards = kolodaCountOfVisibleCards
        self.placeholderLbl.isHidden = true
        self.notifyLbl.isHidden = true
        self.notifyLbl.text = ""
        if let globalInfo = UserDefaults.standard.object(forKey: "globalInfo") as? [String:AnyObject]{
            if let texts = globalInfo["texts"] as? [String:AnyObject]{
                self.placeholderLbl.text = (texts["noRelativeJobsMessage"] as? String)?.replacingOccurrences(of: "\\n", with: "\n")
            }
            else{
                self.placeholderLbl.text = placeholderNormalString
            }
        }
        else{
            self.placeholderLbl.text = placeholderNormalString
        }

        self.matchInfoLbl.text = "Fetching..."

        getCardData()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = true
        }
        if self.adArray.count>0
        {
            self.adWithTimer()
        }
        if UIApplication.shared.applicationIconBadgeNumber > 0
        {
            self.postDynamicChangesData("resetBadgeCount")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func willEnterForeground() {
        if UserDefaults.standard.object(forKey: "popUp") as! String == "0" {
            checkVersionForForcedUpdate()
        }
    }
    
//MARK:- Menu Button Action
    
    @IBAction func menuBtnAction(_ sender: Any)
    {
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            (drawerController.drawerViewController as! MenuViewController).tableView.reloadData()
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
//MARK:- Chat Button Action
    
    @IBAction func chatBtnAction(_ sender: Any)
    {
        let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
        let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "ChatListVC") as! ChatListVC
        viewcontroller.fromScreen = "home"
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
//MARK:- Filter Button Action
    
    @IBAction func filterBtnAction(_ sender: Any)
    {
        showPopUpForItemDetail(withArray: [AnyObject]())
    }
    
// MARK: Add item detail view Method
    
    func showPopUpForItemDetail(withArray array:[AnyObject])
    {
        let popup = FilterView.instansiateFromNib()
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        popup.filterDict = filterDict
        popup.filterDelegate = self
        self.view.addSubview(popup)
        popup.showPopup()
    }
    
    //MARK: - Check version of the App
    func checkVersionForForcedUpdate(){
        let appVersion = UserDefaults.standard.object(forKey: "app_versioning") as? [String:AnyObject]
        if appVersion != nil{
            let iOSVersion = appVersion!["IOS"] as! [String:AnyObject]
            let minVersion = iOSVersion["minimumVersionSupported"] as! Float
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                print(Float(version)!)
                let versionF = Float(version)!
                if versionF < minVersion{
                    UserDefaults.standard.set("1", forKey: "popUp")
                    let alert = UIAlertController(title: AppName, message: "New version is available on app store. Older version is obsolete. Please update now.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let yesAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        UserDefaults.standard.set("0", forKey: "popUp")
                        self.jumpToAppStore()
                    })
                    alert.addAction(yesAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //MARK: - Check version of the App
    func checkVersion(){
        let hardUpdate = UserDefaults.standard.object(forKey: "hardUpdate") as? String
        if hardUpdate == nil{
            let appVersion = UserDefaults.standard.object(forKey: "app_versioning") as! [String:AnyObject]
            let iOSVersion = appVersion["IOS"] as! [String:AnyObject]
            let minVersion = iOSVersion["minimumVersionSupported"] as! Float
            let maxVersion = iOSVersion["latestVersion"] as! Float
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                print(Float(version)!)
                let versionF = Float(version)!
                if versionF >= minVersion{
                    if versionF < maxVersion{
                        let popUpFlag = UserDefaults.standard.object(forKey: "versionFlag") as! String
                        if popUpFlag == "0"{
                            UserDefaults.standard.set("1", forKey: "popUp")
                            let alert = UIAlertController(title: AppName, message: "New version is available on app store. Would you like to update?", preferredStyle: UIAlertControllerStyle.alert)
                            let yesAction =  UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                                UserDefaults.standard.set("0", forKey: "popUp")
                                self.jumpToAppStore()
                            })
                            alert.addAction(yesAction)
                            let noAction =  UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                                UserDefaults.standard.set("1", forKey: "versionFlag")
                                UserDefaults.standard.set("0", forKey: "popUp")
                            })
                            alert.addAction(noAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                else{
                    UserDefaults.standard.set("1", forKey: "popUp")
                    let alert = UIAlertController(title: AppName, message: "New version is available on app store. Older version is obsolete. Please update now.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let yesAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        UserDefaults.standard.set("0", forKey: "popUp")
                        self.jumpToAppStore()
                    })
                    alert.addAction(yesAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Show App Store Link Method
    
    func jumpToAppStore()
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
                    self.pushViewController(false, navController: self.navigationController!)
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
                
                if data != nil{
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
    
//MARK:- Method For Moving to NextVC
    
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
    
//MARK: - Get Card Data
    
    func getCardData()
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        if index != nil
        {
            dict["pageNumber"] = index as AnyObject?
            if selctedFilter.count==0
            {
                dict["getJobFilters"] = "0" as AnyObject?
            }
        }
        else
        {
            dict["pageNumber"] = "0" as AnyObject?
            if selctedFilter.count==0
            {
                dict["getJobFilters"] = "1" as AnyObject?
            }
        }
        if selctedFilter.count>0
        {
            dict["filters"] = selctedFilter as AnyObject?
        }
        KVNProgress.show()
        UserService.getCardDataWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                print(data ?? "No value")
                if data!["result"]?["jobFilters"] != nil
                {
                    if let filter = data!["result"]?["jobFilters"]! as? [String:AnyObject]
                    {
                        if filter.count>0
                        {
                            self.filterDict = filter
                        }
                    }
                }
                let jobs = data!["result"]?["jobs"]! as! [AnyObject]
                let paginationDict = data!["result"]?["pagination"]! as! [String:AnyObject]
                let advertisements = data!["result"]?["advertisements"]! as! [AnyObject]
                let appVersionInfo = data!["result"]?["app_versioning"]! as? [String:AnyObject]

                UserDefaults.standard.set(appVersionInfo, forKey: "app_versioning")
                if UserDefaults.standard.object(forKey: "popUp") as! String == "0" {
                    self.checkVersion()
                }
                self.adArray = [AnyObject]()
                self.adArray = advertisements
                if self.adArray.count>0
                {
                    self.adWithTimer()
                }
                print(data!["result"] as! [String:AnyObject])
                print(jobs)
                print(paginationDict)
                if self.cardArray.count>0
                {
                    for element in jobs
                    {
                        for (index1, item) in self.cardArray.enumerated()
                        {
                            if element["jobID"] as! String == item["jobID"] as! String
                            {
                                self.cardArray.remove(at: index1)
                            }
                        }
                    }
                }
                self.cardArray.append(contentsOf: jobs)
                if jobs.count==0
                {
                    self.placeholderLbl.isHidden = false
                    if let globalInfo = UserDefaults.standard.object(forKey: "globalInfo") as? [String:AnyObject]{
                        if let texts = globalInfo["texts"] as? [String:AnyObject]{
                            if self.selctedFilter.count>0
                            {
                                self.placeholderLbl.text = self.placeholderNormalString
                            }
                            else{
                                self.placeholderLbl.text = (texts["noRelativeJobsMessage"] as? String)?.replacingOccurrences(of: "\\n", with: "\n")
                            }
                        }
                        else{
                            self.placeholderLbl.text = self.placeholderNormalString
                        }
                    }
                    else{
                        self.placeholderLbl.text = self.placeholderNormalString
                    }
                    
                }
                else
                {
                    self.placeholderLbl.isHidden = true
                    self.notifyLbl.isHidden = true
                    if UserDefaults.standard.object(forKey: "homeCoach") == nil
                    {
                        self.showPopUpForCoach()
                    }
                    self.swipingView.reloadData()
                    self.swipingView.applyAppearAnimationIfNeeded()
                }
                self.index = paginationDict["nextPageNumber"] as! Int!
                if self.index == 2 || self.index == 0
                {
                    self.totalJobAvailable = paginationDict["totalResults"] as! Int!
                }
                if self.totalJobAvailable > 1
                {
                    self.matchInfoLbl.text = "\(self.totalJobAvailable!) Jobs matching your profile"
                }
                else
                {
                    self.matchInfoLbl.text = "\(self.totalJobAvailable!) Job matching your profile"
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if self.checkAdditionalQuestionFlag != nil
                {
                    self.getOnDemandQuestions()
                }
                else
                {
                    if self.remainingQuestions != nil{
                        if self.remainingQuestions.count>0{
                            SignUpMetaData.sharedInstance.createSeperateObjectsForEachQuestionPostLogin(self.remainingQuestions)
                            self.pushViewController(false, navController: self.navigationController!)
                            self.remainingQuestions.removeAll()
                        }
                    }
                }
            }
        })
    }
    
//MARK: - Get Card Data
    
    func respondToCard(_ actionID:String, jobID:String)
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        dict["jobSeekerJobActionTypeID"] = actionID as AnyObject?
        dict["jobID"] = jobID as AnyObject?
        UserService.actionForJobCardWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            if success
            {
                print(data ?? "No Value")
                
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
    
//MARK:- Method for Demanding Questions
    
    func getOnDemandQuestions()
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        KVNProgress.show()
        UserService.getOnDemandQuestionsWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let result = data!["result"]?["questions"]!
                let firebase = data!["result"]?["fireBase"]! as? [String:AnyObject]
                print(result ?? "No Value")
                UserDefaults.standard.set(firebase, forKey: "firebaseInfo")
                InitializerHelper.sharedInstance.createSeperateObjectsForEachQuestion(result as! [AnyObject])
                if (result as! [AnyObject]).count>0
                {
                    let viewController = InitializerHelper.sharedInstance.pushViewControllerBasedOnSequence(self, index: 0)
                    if viewController != nil
                    {
                        let navController = UINavigationController(rootViewController: viewController!)
                        navController.isNavigationBarHidden = true
                        self.present(navController, animated: true, completion: nil)
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
            self.checkAdditionalQuestionFlag = nil
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
        UserService.postEmailVerificationWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            if success
            {
                print(data ?? "No Value")
                UIApplication.shared.applicationIconBadgeNumber = 0
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
    
//MARK:- Metod for CoachPOPUP
    
    func showPopUpForCoach()
    {
        let popup = HomeCoachView.instansiateFromNib()
        popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(popup)
        popup.showPopup()
    }
    
//MARK:- Method for AdPOPUP
    
    func showPopUpForAd()
    {
        if !adBannerStatus
        {
            adBannerStatus = true
            let popup = AdvertisementView.instansiateFromNib()
            popup.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            popup.adDelegate = self
            let randomIndex = Int(arc4random_uniform(UInt32(self.adArray.count)))
            popup.imageUrl = self.adArray[randomIndex]["image"] as! String
            popup.url = self.adArray[randomIndex]["url"] as! String
            self.view.addSubview(popup)
            popup.showPopup()
        }
    }

//MARK:- MEthod for adTimer
    
    func adWithTimer()
    {
        if !adFiredStatus
        {
            adFiredStatus = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 60)
            {
                self.showPopUpForAd()
            }
        }
    }
}

//MARK:- Extension KolodaViewDelegate

extension LandingVC:KolodaViewDelegate
{
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection]
    {
        return [.left, .right, .up]
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView)
    {
        if index != 0
        {
            self.totalJobAvailable = self.totalJobAvailable-1
            if self.totalJobAvailable > 1
            {
                self.matchInfoLbl.text = "\(self.totalJobAvailable!) Jobs matching your profile"
            }
            else
            {
                self.matchInfoLbl.text = "\(self.totalJobAvailable!) Job matching your profile"
            }
            self.matchInfoLbl.text = "Fetching..."
            self.getCardData()
        }
        else
        {
            self.placeholderLbl.isHidden = false
        }
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int)
    {
        
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool
    {
        return true
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool
    {
        return true
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection){
        if backFlag == "1"
        {
            self.totalJobAvailable = self.totalJobAvailable-1
            if self.totalJobAvailable > 1
            {
                self.matchInfoLbl.text = "\(self.totalJobAvailable!) Jobs matching your profile"
            }
            else
            {
                self.matchInfoLbl.text = "\(self.totalJobAvailable!) Job matching your profile"
            }
            backFlag = "0"
            return
        }
        
        if direction == .right
        {
            if UserDefaults.standard.object(forKey: "rightSwipeHint") == nil
            {
                let alert = UIAlertController(title: AppName, message:"Swipping right means you are applying for this job.", preferredStyle: UIAlertControllerStyle.alert)
                let action1 =  UIAlertAction(title: "Apply", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    UserDefaults.standard.set("1", forKey: "rightSwipeHint")
                    let cardDict = self.cardArray[index] as? [String:AnyObject]
                    self.respondToCard("1", jobID:  (cardDict?["jobID"] as? String)!)
                    self.totalJobAvailable = self.totalJobAvailable-1
                    if self.totalJobAvailable > 1
                    {
                        self.matchInfoLbl.text = "\(self.totalJobAvailable!) Jobs matching your profile"
                    }
                    else
                    {
                        self.matchInfoLbl.text = "\(self.totalJobAvailable!) Job matching your profile"
                    }
                })
                alert.addAction(action1)
                let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
                    koloda.revertAction()
                })
                alert.addAction(action2)
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                let cardDict = cardArray[index] as? [String:AnyObject]
                self.respondToCard("1", jobID:  (cardDict?["jobID"] as? String)!)
                self.totalJobAvailable = self.totalJobAvailable-1
                if self.totalJobAvailable > 1
                {
                    self.matchInfoLbl.text = "\(self.totalJobAvailable!) Jobs matching your profile"
                }
                else
                {
                    self.matchInfoLbl.text = "\(self.totalJobAvailable!) Job matching your profile"
                }
            }

        }
        else if direction == .left
        {
            if UserDefaults.standard.object(forKey: "leftSwipeHint") == nil
            {
                let alert = UIAlertController(title: AppName, message:"Swipping left means you are skipping this job.", preferredStyle: UIAlertControllerStyle.alert)
                let action1 =  UIAlertAction(title: "Skip", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    UserDefaults.standard.set("1", forKey: "leftSwipeHint")
                    let cardDict = self.cardArray[index] as? [String:AnyObject]
                    self.respondToCard("2", jobID:  (cardDict?["jobID"] as? String)!)
                    self.totalJobAvailable = self.totalJobAvailable-1
                    if self.totalJobAvailable > 1
                    {
                        self.matchInfoLbl.text = "\(self.totalJobAvailable!) Jobs matching your profile"
                    }
                    else
                    {
                        self.matchInfoLbl.text = "\(self.totalJobAvailable!) Job matching your profile"
                    }
                })
                alert.addAction(action1)
                let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
                    koloda.revertAction()
                })
                alert.addAction(action2)
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                let cardDict = cardArray[index] as? [String:AnyObject]
                self.respondToCard("2", jobID:  (cardDict?["jobID"] as? String)!)
                self.totalJobAvailable = self.totalJobAvailable-1
                if self.totalJobAvailable > 1
                {
                    self.matchInfoLbl.text = "\(self.totalJobAvailable!) Jobs matching your profile"
                }
                else
                {
                    self.matchInfoLbl.text = "\(self.totalJobAvailable!) Job matching your profile"
                }
            }
        }
        else if direction == .up
        {
            if UserDefaults.standard.object(forKey: "upSwipeHint") == nil
            {
                let alert = UIAlertController(title: AppName, message:"Swipping up means you are saving this job for future reference.", preferredStyle: UIAlertControllerStyle.alert)
                let action1 =  UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    UserDefaults.standard.set("1", forKey: "upSwipeHint")
                    let cardDict = self.cardArray[index] as? [String:AnyObject]
                    self.respondToCard("3", jobID:  (cardDict?["jobID"] as? String)!)
                    self.totalJobAvailable = self.totalJobAvailable-1
                    if self.totalJobAvailable > 1
                    {
                        self.matchInfoLbl.text = "\(self.totalJobAvailable!) Jobs matching your profile"
                    }
                    else
                    {
                        self.matchInfoLbl.text = "\(self.totalJobAvailable!) Job matching your profile"
                    }
                })
                alert.addAction(action1)
                let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
                    koloda.revertAction()
                })
                alert.addAction(action2)
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                let cardDict = cardArray[index] as? [String:AnyObject]
                self.respondToCard("3", jobID:  (cardDict?["jobID"] as? String)!)
                self.totalJobAvailable = self.totalJobAvailable-1
                if self.totalJobAvailable > 1
                {
                    self.matchInfoLbl.text = "\(self.totalJobAvailable!) Jobs matching your profile"
                }
                else
                {
                    self.matchInfoLbl.text = "\(self.totalJobAvailable!) Job matching your profile"
                }
            }
        }
        if self.adArray.count>0
        {
            if (index+1)%5 == 0
            {
                showPopUpForAd()
            }
        }
    }
}

//MARK:- Extension KolodaViewDataSource

extension LandingVC:KolodaViewDataSource
{
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int
    {
        return cardArray.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView
    {
        let card = CardView.instansiateFromNib()
        let cardDict = cardArray[index] as? [String:AnyObject]
        card.companyNameLbl.text = cardDict?["companyName"] as? String
        card.companyDomainLbl.text = cardDict?["companyWebsiteUrl"] as? String
        card.companyDecriptionLbl.text = cardDict?["companyDescription"] as? String
        card.jobDesignationLbl.text = cardDict?["title"] as? String
        card.jobDescriptionLbl.text = cardDict?["shortDescription"] as? String
        if cardDict?["profilePicture"] as? String != ""
        {
            card.companyPic.setImageWith(URL(string:(cardDict?["profilePicture"] as? String)!)!, placeholderImage: UIImage(named: "plus"))
        }
        else
        {
            card.companyPic.image = UIImage(named: "plus")
        }
        card.cardTapBtn.addTarget(self, action: #selector(LandingVC.cardTapBtnAction(_:)), for: .touchUpInside)
        card.applyBtn.addTarget(self, action: #selector(LandingVC.applyForJobBtnAction(_:)), for: .touchUpInside)
        card.skipBtn.addTarget(self, action: #selector(LandingVC.skipJobBtnAction(_:)), for: .touchUpInside)
        card.saveBtn.addTarget(self, action: #selector(LandingVC.saveJobBtnAction(_:)), for: .touchUpInside)
        card.cardTapBtn.tag = index
        card.applyBtn.tag = index
        card.skipBtn.tag = index
        card.saveBtn.tag = index
        return card
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView?
    {
        return nil
    }
    
    func cardTapBtnAction(_ sender:UIButton)
    {
        print("Card Tapped")
        let cardDict = cardArray[sender.tag] as? [String:AnyObject]
        let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
        let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "JobDetailVC") as! JobDetailVC
        viewcontroller.actionDelegate = self
        viewcontroller.fromScreen = "home"
        viewcontroller.jobID = cardDict?["jobID"] as! String
        viewcontroller.jobActiveId = cardDict?["jobStatus"] as? String
        viewcontroller.employerResponseId = cardDict?["employerJobActionTypeID"] as? String
        viewcontroller.userActionId = cardDict?["jobSeekerJobActionTypeID"] as? String
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }

    func applyForJobBtnAction(_ sender:UIButton)
    {
        print("Applied")
        self.swipingView?.swipe(SwipeResultDirection.right)
    }
    
    func skipJobBtnAction(_ sender:UIButton)
    {
        print("Skipped")
        self.swipingView?.swipe(SwipeResultDirection.left)
    }
    
    func saveJobBtnAction(_ sender:UIButton)
    {
        print("Saved")
        self.swipingView?.swipe(SwipeResultDirection.up)
    }
}

//MARK:- Extension FilterDelegate

extension LandingVC:FilterDelegate
{
    func callBackWithFilter(_ dict:[String:AnyObject])
    {
        selctedFilter = dict
        index = 0
        cardArray = [AnyObject]()
        swipingView.reloadData()
        getCardData()
    }
}

//MARK:- Extension AdDelegate

extension LandingVC:AdDelegate
{
    func callBackWithStatus(_ status:Bool)
    {
        adBannerStatus = status
        adFiredStatus = status
        if !status
        {
            adWithTimer()
        }
    }
}

//MARK:- Extension JobDetailDelegate

extension LandingVC:JobDetailDelegate
{
    func callBackWithAction(_ status:String)
    {
        backFlag = "1"
        if status == "1"
        {
            self.swipingView?.swipe(SwipeResultDirection.right)
        }
        else if status == "2"
        {
            self.swipingView?.swipe(SwipeResultDirection.left)
        }
        else
        {
            self.swipingView?.swipe(SwipeResultDirection.up)
        }
    }
}
