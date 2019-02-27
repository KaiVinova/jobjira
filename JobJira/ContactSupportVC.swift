//
//  ContactSupportVC.swift
//  JobJira
//
//  Created by Vaibhav on 04/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
import KVNProgress
class ContactSupportVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var contactText: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var tableSupport: UITableView!
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        sendBtn.layer.cornerRadius=20.0
        sendBtn.layer.masksToBounds=false
        textContainerView.layer.cornerRadius=4.0
        textContainerView.layer.masksToBounds=false
        contactText.textColor = UIColor.lightGray
        contactText.text = "Type your message here.."
        tableSupport.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        tableHeaderView.frame = CGRect(x: 0, y:  0, width:  tableHeaderView.frame.size.width, height: tableSupport.frame.size.height)
        tableSupport.contentSize.height = tableHeaderView.frame.size.height
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = true
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
//MARK:- Menu Button Action
    
    @IBAction func munuBtnAction(_ sender: Any)
    {
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            (drawerController.drawerViewController as! MenuViewController).tableView.reloadData()
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
//MARK:- Send Button Action
    
    @IBAction func sendBtnAction(_ sender: Any)
    {
        if contactText.text.characters.count > 0 && contactText.text != "Type your message here.." && !contactText.text.isBlank
        {
            sendCustomerSupportMessage()
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please tell us your queries", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }

//MARK: - Get Card Data
    
    func sendCustomerSupportMessage()
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        dict["content"] = contactText.text as AnyObject?
        KVNProgress.show()
        UserService.sendContactSupportMsgWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                print(data ?? "No Value")
                let alert = UIAlertController(title: AppName, message:"Your message has been successfully submitted, We will get in touch with your shortly", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    self.contactText.textColor = UIColor.lightGray
                    self.contactText.text = "Type your message here.."
                    self.contactText.resignFirstResponder()
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

//MARK:- Extension UITextViewDelegate

extension ContactSupportVC:UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView.text == "Type your message here.."
        {
            textView.textColor = UIColor.darkGray
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        tableSupport.contentSize.height = tableHeaderView.frame.size.height
        if textView.text == "" || textView.text == "Type your message here.."
        {
            textView.textColor = UIColor.lightGray
            textView.text = "Type your message here.."
        }
    }
}
