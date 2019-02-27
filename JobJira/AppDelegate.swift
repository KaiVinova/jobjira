//
//  AppDelegate.swift
//  JobJira
//
//  Created by Vaibhav on 23/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import CoreData
import KYDrawerController
import Firebase
import FirebaseMessaging
import Fabric
import Crashlytics
import UserNotifications
import KVNProgress
import FBSDKCoreKit
import FBSDKLoginKit
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storageRef:FIRStorageReference!
    var ref:FIRDatabaseReference!
    var isModal: Bool {
        return self.window?.currentViewController?.presentingViewController?.presentedViewController == self
            || (self.window?.currentViewController?.navigationController != nil && self.window?.currentViewController?.navigationController?.presentingViewController?.presentedViewController == self.window?.currentViewController?.navigationController)
            || self.window?.currentViewController?.tabBarController?.presentingViewController is UITabBarController
    }
    
    //MARK: Singlton Instance

    class var shared: AppDelegate {
        struct Static {
            static let instance = AppDelegate()
        }
        return Static.instance
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        
        ACTAutomatedUsageTracker.enableAutomatedUsageReporting(withConversionID: "846854935")
        ACTConversionReporter.report(withConversionID: "846854935", label: "MUiPCPmoiXMQl_bnkwM", value: "0.00", isRepeatable: false)
        UIApplication.shared.statusBarStyle = .lightContent
        if UserDefaults.standard.object(forKey: "userInfo") == nil{
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.isNavigationBarHidden = true
            window?.rootViewController = navigationController
        }
        else{
            navigateToHome()
        }
        self.window?.makeKeyAndVisible()
        FIRApp.configure()
        if FIRInstanceID.instanceID().token() != nil {
            print(FIRInstanceID.instanceID().token() ?? "No token")
            let userDefault:UserDefaults = UserDefaults.standard
            userDefault.set(FIRInstanceID.instanceID().token(), forKey:"devicetoken")
            userDefault.synchronize()
        }
        else{
            let userDefault:UserDefaults = UserDefaults.standard
            if userDefault.object(forKey: "devicetoken") == nil {
                userDefault.set("12345", forKey:"devicetoken")
                userDefault.synchronize()
                NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.tokenRefreshNotification(_:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
            }
        }
        configureStorage()
        callOtherFunctios()
        
        if launchOptions != nil {
            //opened from a push notification when the app is closed
            if   let userInfo = (launchOptions![UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any])
            {
                self.actionForRecievedNotification(userInfo)
            }
            
            if (launchOptions?[UIApplicationLaunchOptionsKey.url]) != nil{
                FBSDKAppLinkUtility.fetchDeferredAppLink({ (url, error) in
                    if error != nil{
                        print("Received error while fetching deferred app link \(String(describing: error?.localizedDescription))")
                    }
                    if url != nil{
                        UIApplication.shared.openURL(url!)
                    }
                })
            }
        }
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    //MARK: Methods for Configuring storage

    func configureStorage(){
        let storageURL = FIRApp.defaultApp()?.options.storageBucket
        self.storageRef = FIRStorage.storage().reference(forURL: "gs://\(storageURL!)")
    }
    
    //MARK: Methods for Push Notification

    func callOtherFunctios()
    {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
                print(granted)
                print(error ?? "No value")
            }
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: ([.badge, .sound, .alert]), categories: nil));
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {

    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
    {
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.
        print("%@", userInfo)
        self.actionForRecievedNotification(userInfo)
    }

    
    func tokenRefreshNotification(_ notification: NSNotification) {
        // NOTE: It can be nil here
        let refreshedToken = FIRInstanceID.instanceID().token()
        print("InstanceID token: \(refreshedToken)")
        let userDefault:UserDefaults = UserDefaults.standard
        userDefault.set(refreshedToken, forKey:"devicetoken")
        userDefault.synchronize()
    }
    
    //MARK: Methods for navigating to home

    func navigateToHome()
    {
        let storyBoard1 = UIStoryboard(name: "Main", bundle: nil)
        let storyBoard2 = UIStoryboard(name: "Menu", bundle: nil)
        let drawerViewController = storyBoard2.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let drawerController = KYDrawerController(drawerDirection: .left, drawerWidth: (window?.frame.size.width)!*3/4)
        if let userInfo = UserDefaults.standard.object(forKey: "userInfo") as? [String:AnyObject]{
            if userInfo["PrTitle"] as! String != ""{
                let mainViewController = storyBoard1.instantiateViewController(withIdentifier: "LandingVC") as! LandingVC
                mainViewController.checkAdditionalQuestionFlag = "1"
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
        if let nav = drawerController.displayingViewController as? UINavigationController{
            nav.isNavigationBarHidden = true
        }
        let navigationController = UINavigationController(rootViewController: drawerController)
        navigationController.isNavigationBarHidden = true
        window?.rootViewController = navigationController
    }
    
    //MARK: App Lifecycle Methods

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UserDefaults.standard.set("1", forKey: "background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UserDefaults.standard.set("0", forKey: "background")
        FBSDKAppEvents.activateApp()

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        UserDefaults.standard.set("1", forKey: "background")
        self.saveContext()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool{
        
        let sourceApplication: String? = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let urlScheme = BFURL(inboundURL: url, sourceApplication: sourceApplication)
        if urlScheme != nil {
            if urlScheme?.targetURL != nil{
                if (urlScheme?.targetURL.absoluteString.contains("jobjiraapp://"))! {
                    FBSDKAppEvents.logEvent("install")
                }
            }
        }
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "JobJira")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    //MARK: Method for logout from the app

    func popAndLogout(_ viewController:UIViewController){
        if viewController.navigationController!.navigationController != nil {
            if UserDefaults.standard.object(forKey: "userInfo") != nil {
                UserDefaults.standard.removeObject(forKey: "userInfo")
                SignUpMetaData.sharedInstance.resetAllDictionaryAndArrayPreLoginAndPostLogin()
                InitializerHelper.sharedInstance.profileImage = nil
                InitializerHelper.sharedInstance.videoImage = nil
            }
            if UserDefaults.standard.object(forKey: "firebaseInfo") != nil {
                UserDefaults.standard.removeObject(forKey: "firebaseInfo")
            }
            if FIRAuth.auth()?.currentUser != nil{
                do{
                    _ = try FIRAuth.auth()?.signOut()
                }
                catch let error{
                    print(error.localizedDescription)
                }
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            viewController.navigationController!.navigationController?.setViewControllers([viewcontroller], animated: true)
        }
    }

    //MARK: Method for handling push notifications

    func actionForRecievedNotification(_ userInfo:[AnyHashable:Any]){
        if let type = userInfo["type"] as? String{
            if type == "1"{
                if let action = userInfo["employerJobActionTypeID"] as? String{
                    if action == "2"{
                        if !isModal{
                            if let chatId = userInfo["chatRoomID"] as? String{
                                if let info = userInfo["aps"] as? [AnyHashable:Any]{
                                    if let dict = info["alert"] as? [AnyHashable:Any]{
                                        self.loginToFirebaseWithJwtToken(chatId, background:UserDefaults.standard.object(forKey: "background") as! String, info:dict)
                                    }
                                }
                            }
                        }
                    }
                    else{
                        if UserDefaults.standard.object(forKey: "background") as! String == "1"{
                            if (self.window?.rootViewController?.childViewControllers.count)!>0{
                                if let viewC = self.window?.rootViewController?.childViewControllers[0] as? KYDrawerController {
                                    let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
                                    let viewController = storyBoard.instantiateViewController(withIdentifier: "YourActivitiesVC") as! YourActivitiesVC
                                    if let nav = viewC.mainViewController as? UINavigationController{
                                        nav.setViewControllers([viewController], animated: true)
                                    }
                                }
                            }
                        }
                        else{
                            if let info = userInfo["aps"] as? [AnyHashable:Any]{
                                if let dict = info["alert"] as? [AnyHashable:Any]{
                                    let alert = UIAlertController(title: dict["title"] as! String?, message: dict["body"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
                                    let action1 =  UIAlertAction(title: "View", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                                        if (self.window?.rootViewController?.childViewControllers.count)!>0{
                                            if let viewC = self.window?.rootViewController?.childViewControllers[0] as? KYDrawerController {
                                                let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
                                                let viewController = storyBoard.instantiateViewController(withIdentifier: "YourActivitiesVC") as! YourActivitiesVC
                                                if let nav = viewC.mainViewController as? UINavigationController{
                                                    nav.setViewControllers([viewController], animated: true)
                                                }
                                            }
                                        }
                                    })
                                    alert.addAction(action1)
                                    let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                                    })
                                    alert.addAction(action2)
                                    self.window?.currentViewController?.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
            else if type == "2"{
                if let info = userInfo["aps"] as? [AnyHashable:Any]{
                    if let dict = info["alert"] as? [AnyHashable:Any]{
                        let alert = UIAlertController(title: dict["title"] as! String?, message: dict["body"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
                        let action1 =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        })
                        alert.addAction(action1)
                        self.window?.currentViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else if type == "3"{
                if !isModal{
                    if let chatId = userInfo["chatRoomID"] as? String{
                        if let info = userInfo["aps"] as? [AnyHashable:Any]{
                            if let dict = info["alert"] as? [AnyHashable:Any]{
                                self.loginToFirebaseWithJwtToken(chatId, background:UserDefaults.standard.object(forKey: "background") as! String, info:dict)
                            }
                        }
                    }
                }
            }
            else if type == "4"{
                if (self.window?.rootViewController?.childViewControllers.count)!>0{
                    if let viewC = self.window?.rootViewController?.childViewControllers[0] as? KYDrawerController {
                        let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
                        let viewController = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                        if let nav = viewC.mainViewController as? UINavigationController{
                            nav.setViewControllers([viewController], animated: true)
                        }
                    }
                 }
            }
        }
    }
    
    // MARK: Firebase related methods
    
    func loginToFirebaseWithJwtToken(_ chatroomID:String, background:String, info:[AnyHashable:Any]){
        KVNProgress.show()
        let fireBaseDict = UserDefaults.standard.object(forKey: "firebaseInfo") as! [String:AnyObject]
        if FIRAuth.auth()?.currentUser != nil{
            self.observeSingleResponse(chatroomID, background:background, info:info)
        }
        else{
            FIRAuth.auth()?.signIn(withCustomToken: fireBaseDict["jwtToken"] as! String, completion: { (user, error) in
                if error == nil{
                    print(user?.uid ?? "No ID")
                    self.observeSingleResponse(chatroomID, background:background, info:info)
                }
                else{
                    print(error?.localizedDescription ?? "No Value")
                    KVNProgress.dismiss()
                }
            })
        }
        
    }
    
    private func observeSingleResponse(_ chatroomID:String, background:String, info:[AnyHashable:Any]) {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        let chatRef: FIRDatabaseReference = FIRDatabase.database().reference().child("jobseeker_chats").child((UserDefaults.standard.object(forKey: "firebaseInfo") as! [String:AnyObject])["jobSeekerID"] as! String)
        chatRef.child(chatroomID).queryOrdered(byChild: "jobseeker_chats").observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            let chatData = snapshot.value as! Dictionary<String, AnyObject>
            if let chatRoomID = chatData["chatRoomID"] as! String!, chatRoomID.characters.count > 0 {
                let chatRoomRef: FIRDatabaseReference = FIRDatabase.database().reference().child("chat_rooms")
                chatRoomRef.queryOrderedByKey().queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value, with: { (snapshot1) in
                    if snapshot1.children.allObjects.count>0{
                        let snapshotEmployer = snapshot1.children.allObjects[0] as! FIRDataSnapshot
                        let chatRoomData = snapshotEmployer.value as! Dictionary<String, AnyObject>
                        if let employerID = chatRoomData["employerID"] as! String!, employerID.characters.count > 0 {
                            let employerRef: FIRDatabaseReference = FIRDatabase.database().reference().child("employers")
                            employerRef.queryOrderedByKey().queryEqual(toValue: employerID).observeSingleEvent(of: .value, with: { (snapshot2) in
                                if snapshot2.children.allObjects.count>0{
                                    let snapshotEmployer = snapshot2.children.allObjects[0] as! FIRDataSnapshot
                                    let employerData = snapshotEmployer.value as! Dictionary<String, AnyObject>
                                    if let companyName = employerData["companyName"] as! String!, companyName.characters.count > 0 {
                                        if let jobID = chatRoomData["jobID"] as! String!, jobID.characters.count > 0 {
                                            let jobRef: FIRDatabaseReference = FIRDatabase.database().reference().child("jobs")
                                            jobRef.queryOrderedByKey().queryEqual(toValue: jobID).observeSingleEvent(of: .value, with: { (snapshot3) in
                                                if snapshot3.children.allObjects.count>0{
                                                    let snapshotJob = snapshot3.children.allObjects[0] as! FIRDataSnapshot
                                                    let jobData = snapshotJob.value as! Dictionary<String, AnyObject>
                                                    if let jobName = jobData["title"] as! String!, jobName.characters.count > 0 {
                                                        KVNProgress.dismiss()
                                                        if background == "1"{
                                                            let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
                                                            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "MessagingVC") as! MessagingVC
                                                            viewcontroller.senderDisplayName = "Testing"
                                                            viewcontroller.chat = Chats(chatRoomID: chatData["chatRoomID"] as! String, lastMessage: chatData["lastMessage"] as! String, upadtedTime: chatData["updatedTime"] as! Int, jobAppliedTime: chatRoomData["jobAppliedTime"] as! String, jobPostedTime: chatRoomData["jobPostedTime"] as! String, isClosed: chatRoomData["isClosed"] as! String, companyName: employerData["companyName"] as! String, lastOnline: employerData["lastOnline"] as! String, name: employerData["name"] as! String, online: employerData["online"] as! String, profilePicture: employerData["profilePicture"] as! String, isRemoved: jobData["isRemoved"] as! String, employerID: employerData["employerID"] as! String, title: jobData["title"] as! String, jobSeekerID: chatRoomData["jobSeekerID"] as! String, employerJobActionTypeID: chatRoomData["isClosed"] as! String, jobStatus: jobData["jobStatus"] as! String)
                                                            viewcontroller.chatRef = FIRDatabase.database().reference().child("chats").child(chatData["chatRoomID"] as! String)
                                                            let navController = UINavigationController(rootViewController: viewcontroller)
                                                            self.window?.currentViewController?.present(navController, animated: true, completion: nil)
                                                        }
                                                        else{
                                                            let alert = UIAlertController(title: info["title"] as! String?, message: info["body"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
                                                            let action1 =  UIAlertAction(title: "View", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                                                                let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
                                                                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "MessagingVC") as! MessagingVC
                                                                viewcontroller.senderDisplayName = "Testing"
                                                                viewcontroller.chat = Chats(chatRoomID: chatData["chatRoomID"] as! String, lastMessage: chatData["lastMessage"] as! String, upadtedTime: chatData["updatedTime"] as! Int, jobAppliedTime: chatRoomData["jobAppliedTime"] as! String, jobPostedTime: chatRoomData["jobPostedTime"] as! String, isClosed: chatRoomData["isClosed"] as! String, companyName: employerData["companyName"] as! String, lastOnline: employerData["lastOnline"] as! String, name: employerData["name"] as! String, online: employerData["online"] as! String, profilePicture: employerData["profilePicture"] as! String, isRemoved: jobData["isRemoved"] as! String, employerID: employerData["employerID"] as! String, title: jobData["title"] as! String, jobSeekerID: chatRoomData["jobSeekerID"] as! String, employerJobActionTypeID: chatRoomData["isClosed"] as! String, jobStatus: jobData["jobStatus"] as! String)
                                                                viewcontroller.chatRef = FIRDatabase.database().reference().child("chats").child(chatData["chatRoomID"] as! String)
                                                                let navController = UINavigationController(rootViewController: viewcontroller)
                                                                self.window?.currentViewController?.present(navController, animated: true, completion: nil)
                                                            })
                                                            alert.addAction(action1)
                                                            let action2 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                                                            })
                                                            alert.addAction(action2)
                                                            self.window?.currentViewController?.present(alert, animated: true, completion: nil)
                                                        }
                                                        
                                                    }
                                                }
                                            }, withCancel: { (error2) in
                                                print(error2.localizedDescription)
                                                KVNProgress.dismiss()
                                            })
                                        }
                                        else{
                                            print("Error! Could not decode channel data")
                                            KVNProgress.dismiss()
                                        }
                                    }
                                }
                                
                            }, withCancel: { (error2) in
                                print(error2.localizedDescription)
                                KVNProgress.dismiss()
                            })
                        }
                        else{
                            print("Error! Could not decode channel data")
                            KVNProgress.dismiss()
                        }
                    }
                    
                    
                }, withCancel: { (error1) in
                    print(error1.localizedDescription)
                    KVNProgress.dismiss()
                })
            } else {
                print("Error! Could not decode channel data")
                KVNProgress.dismiss()
            }
            KVNProgress.dismiss()
        }, withCancel: { (error) in
            print(error.localizedDescription)
            KVNProgress.dismiss()
        })
    }

}
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
        self.actionForRecievedNotification(userInfo)

    }
}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }
}
