//
//  WebViewVC.swift
//  JobJira
//
//  Created by Vaibhav on 15/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
import KVNProgress
class WebViewVC: UIViewController
{
    
//MARK:- IBOutlets

    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
//MARK:- Variables and Constants
    
    var titleText: String!
    var loadData: String!
    var fromScreen: String!

//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        titleLabel.text = titleText
        if fromScreen == "pre"
        {
            menuBtn.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        }
        if loadData == "1"
        {
            let url = NSURL(string: "\(BaseURLWeb)index/terms_and_conditions_app")
            let req = NSURLRequest(url: url as! URL)
            webView.loadRequest(req as URLRequest)
        }
        else
        {
            let url = NSURL(string: "\(BaseURLWeb)index/privacy_policy_app")
            let req = NSURLRequest(url: url as! URL)
            webView.loadRequest(req as URLRequest)
        }
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
    
//MARK:- Menu button Action
    
    @IBAction func munuBtnAction(_ sender: Any)
    {
        if fromScreen == "pre"
        {
            _ = self.navigationController?.popViewController(animated: true)
        }
        else
        {
            if let drawerController = navigationController?.parent as? KYDrawerController
            {
                (drawerController.drawerViewController as! MenuViewController).tableView.reloadData()
                drawerController.setDrawerState(.opened, animated: true)
            }
        }
    }
    
//MARK:- Method for SetupData on View

    func getMasterDataPostLogin()
    {
        var dict = [String:AnyObject]()
        dict["userID"] = "e9ZGNmop7yfP0QeRbU21m5n8g3Fgv2yM8Brf6pWf8RI=" as AnyObject?
        KVNProgress.show()
        UserService.testGetWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let result = data!["result"]! as! [String:AnyObject]
                print(result)
                
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
}

//MARK:- Extension UIWebViewDelegate

extension WebViewVC:UIWebViewDelegate
{
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        KVNProgress.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        KVNProgress.dismiss()
    }
}
