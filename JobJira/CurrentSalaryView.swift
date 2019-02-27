//
//  CurrentSalaryView.swift
//  JobJira
//
//  Created by Vaibhav on 26/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class CurrentSalaryView: UIView {
    
    //MARK: IBOutlets
    
    var currentSalaryDelegate:CurrentSalaryDelegate?
    @IBOutlet weak var salaryEntrySuperView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var salaryEntryTxt: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var popUpLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var selectedText:String!
    var currency:String!
    
    //MARK: Initialize View
    
    class func instansiateFromNib() -> CurrentSalaryView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [3] as! CurrentSalaryView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        
        salaryEntrySuperView.layer.cornerRadius=4.0
        salaryEntrySuperView.layer.masksToBounds=true
        salaryEntrySuperView.clipsToBounds = true
        
        popUpLabel.text = "Enter your current salary in \(currency!)"
        doneBtn.layer.cornerRadius=16.0
        doneBtn.layer.masksToBounds=true
        doneBtn.clipsToBounds = true
        cancelBtn.layer.cornerRadius=16.0
        cancelBtn.layer.masksToBounds=true
        cancelBtn.clipsToBounds = true
        cancelBtn.layer.borderColor = doneBtn.backgroundColor?.cgColor
        cancelBtn.layer.borderWidth = 1.0
        if selectedText != nil{
            salaryEntryTxt.text = selectedText
        }
    }
    
    //MARK: Show View Method
    
    func showPopup(){
        
        self.alpha = 0
        self.popUpView.center = CGPoint(x: self.superview!.frame.width/2, y: 2 * self.superview!.frame.height)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.popUpView.center = self.superview!.center
            self.alpha = 1
        }) { (suceess) -> Void in
            
        }
    }
    
    //MARK: Hide View Method
    
    func hidePopUp(){
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.alpha = 0
            self.popUpView.center = CGPoint(x: self.superview!.frame.width/2, y: 2 * self.superview!.frame.height)
        }) { (suceess) -> Void in
            self.removeFromSuperview()
        }
    }
    
    //MARK: Done Button Action
    
    @IBAction func doneBtnAction(_ sender: Any) {
        if salaryEntryTxt.text != "" {
            var tempDict = [String : AnyObject]()
            tempDict["currency"] = currency as AnyObject?
            tempDict["salary"] = salaryEntryTxt.text as AnyObject?
            currentSalaryDelegate?.callBackWithDict!(data: tempDict)
            self.endEditing(true)
            self.hidePopUp()
        }
        else{
            let alert = UIAlertController(title: AppName, message: "Enter your current salary.", preferredStyle: UIAlertControllerStyle.alert)
            let action1 =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            })
            alert.addAction(action1)
            self.getCurrentViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: Close Action
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.endEditing(true)
        self.hidePopUp()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
        self.hidePopUp()
    }
}


extension CurrentSalaryView: UITextFieldDelegate{
    //MARK:- UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 8
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
