//
//  SignUpOTPVC.swift
//  JobJira
//
//  Created by Vaibhav on 28/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import AccountKit

class SignUpOTPVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subTitle2Label: UILabel!
    @IBOutlet weak var otpTxt: UITextField!
    @IBOutlet weak var verifyMeBtn: UIButton!
    @IBOutlet weak var resendOtpBtn: UIButton!
    
//MARK:- Variables and Constants
    
    var dataDict = [String:AnyObject]()
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    fileprivate var pendingLoginViewController: AKFViewController? = nil
    fileprivate var showAccountOnAppear = false
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        showAccountOnAppear = accountKit.currentAccessToken != nil
        pendingLoginViewController = accountKit.viewControllerForLoginResume() as? AKFViewController
        verifyMeBtn.layer.cornerRadius=20.0;
        verifyMeBtn.layer.masksToBounds=false;
        if (SignUpMetaData.sharedInstance.otpDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.otpDict
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
        verifyMeBtn.setTitle(dataDict["questionInfo"]?["buttonText"] as? String, for: .normal)
        otpTxt.placeholder = dataDict["questionTexts"]?["enter_otp"] as? String
    }

//MARK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        let _ = navigationController?.popViewController(animated: true)
    }
    
//MARK:- Verify OTP Button Action
    
    @IBAction func verifyOtpBtnAction(_ sender: Any)
    {

    }
  
//MARK:- Resend OTP Button Action
    
    @IBAction func resendOtpBtnAction(_ sender: Any)
    {
        
    }
}
