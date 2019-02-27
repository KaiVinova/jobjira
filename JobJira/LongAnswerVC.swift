//
//  LongAnswerVC.swift
//  JobJira
//
//  Created by Vaibhav on 17/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import KYDrawerController
import IQKeyboardManager
class LongAnswerVC: UIViewController {
    
    //MARK:- IBOutlets
    
    var index:Int!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var bioTxt: UITextView!
    @IBOutlet weak var skipBtn: UIButton!
    
    var dataDict = [String:AnyObject]()
    var maxLen = 500
    var minLen = 10
    
    //MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.screenEdgePanGestureEnabled = false
        }
        if (InitializerHelper.sharedInstance.questionsArray[index]["id"]) != nil {
            dataDict = InitializerHelper.sharedInstance.questionsArray[index]["data"] as! [String : AnyObject]
        }
        bioTxt.layer.cornerRadius = 4
        bioTxt.layer.masksToBounds = true
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight == 480{
            let font = subTitleLabel.font
            subTitleLabel.font = font?.withSize(15)
            let font1 = headerLabel.font
            headerLabel.font = font1?.withSize(19)
            let font2 = descriptionLabel.font
            descriptionLabel.font = font2?.withSize(14)
        }
        setUpViewBackEndData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 60
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 10
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Method for setting up data on view
    
    func setUpViewBackEndData(){
        titleLabel.text = dataDict["questionInfo"]?["title"] as? String
        subTitleLabel.text = dataDict["questionInfo"]?["p1"] as? String
        headerLabel.text = dataDict["questionInfo"]?["h1"] as? String
        descriptionLabel.text = dataDict["questionInfo"]?["p2"] as? String
        bioTxt.textColor = UIColor.lightGray
        bioTxt.text = "Your answer.."
    }
    
    //MARK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any) {
        postCancelData()
    }
    
    //MARK:- Done Button Action
    
    @IBAction func doneBtnAction(_ sender: Any) {
        if bioTxt.text.characters.count > minLen && bioTxt.text != "Your answer.."{
            postData()
        }
        else{
            let alert = UIAlertController(title: AppName, message: "Your answer must have more than 10 characters to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    //MARK:- Skip Button Action
    
    @IBAction func skipBtnAction(_ sender: Any) {
        let viewController = InitializerHelper.sharedInstance.pushViewControllerBasedOnSequence(self, index: self.index+1)
        if viewController != nil{
            self.navigationController?.setViewControllers([viewController!], animated: true)
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    //MARK: - Post Answer Data API
    
    func postData()
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        dict["answer"] = bioTxt.text as AnyObject
        dict["obQuestionID"] = dataDict["questionInfo"]?["obQuestionID"] as AnyObject
        
        print(dict)
        KVNProgress.show()
        UserService.postAnswerOnDemandWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success{
                let result = data!["result"]?["userInfo"]!
                print(result ?? "No Value")
                let viewController = InitializerHelper.sharedInstance.pushViewControllerBasedOnSequence(self, index: self.index+1)
                if viewController != nil{
                    self.navigationController?.setViewControllers([viewController!], animated: true)
                }
                else{
                    self.dismiss(animated: true, completion: nil)
                }
            }else{
                let alert = UIAlertController(title: AppName, message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
                if data != nil{
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        AppDelegate.shared.popAndLogout(self)
                    })
                    alert.addAction(action)
                }
                else{
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                }
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    //MARK: - Post Cancel Data API
    
    func postCancelData()
    {
        var dict = [String:AnyObject]()
        
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        dict["obQuestionID"] = dataDict["questionInfo"]?["obQuestionID"] as AnyObject
        
        print(dict)
        KVNProgress.show()
        UserService.postCancelOnDemandWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success{
                let result = data!["result"]?["userInfo"]!
                print(result ?? "No Value")
                let viewController = InitializerHelper.sharedInstance.pushViewControllerBasedOnSequence(self, index: self.index+1)
                if viewController != nil{
                    self.navigationController?.setViewControllers([viewController!], animated: true)
                }
                else{
                    self.dismiss(animated: true, completion: nil)
                }
            }else{
                let alert = UIAlertController(title: AppName, message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
                if data != nil{
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        AppDelegate.shared.popAndLogout(self)
                    })
                    alert.addAction(action)
                }
                else{
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                }
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
}

extension LongAnswerVC:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView){
        if textView.text == "Your answer.."{
            textView.textColor = UIColor.darkGray
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        if textView.text == "" || textView.text == "Your answer.."{
            textView.textColor = UIColor.lightGray
            textView.text = "Your answer.."
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        let leftCount = maxLen - numberOfChars
        if leftCount < 1 {
            countLabel.text = "\(leftCount) Character"
        }
        else{
            countLabel.text = "\(leftCount) Characters"
        }
        
        return numberOfChars < maxLen;
    }
}
