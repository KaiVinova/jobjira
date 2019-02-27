//
//  OneTimePasswordVC.swift
//  JobJira
//
//  Created by Vaibhav on 24/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class OneTimePasswordVC: UIViewController
{

//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var otpTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTxt: UITextField!

//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
        
    }
}

//MARK:- Extension UITextFieldDelegate

extension OneTimePasswordVC: UITextFieldDelegate
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
