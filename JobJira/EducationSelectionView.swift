//
//  EducationSelectionView.swift
//  JobJira
//
//  Created by Vaibhav on 13/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class EducationSelectionView: UIView {
    
    //MARK:- IBOutlets
    
    var educationDelegate:EducationDelegate?
    @IBOutlet weak var salaryEntrySuperView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var salaryEntryTxt: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var selectedText:String!
    var placeholderString:String!
    
    //MARK: Initialize View
    
    class func instansiateFromNib() -> EducationSelectionView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [7] as! EducationSelectionView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        
        salaryEntrySuperView.layer.cornerRadius=4.0
        salaryEntrySuperView.layer.masksToBounds=true
        salaryEntrySuperView.clipsToBounds = true
        
        doneBtn.layer.cornerRadius=16.0
        doneBtn.layer.masksToBounds=true
        doneBtn.clipsToBounds = true
        cancelBtn.layer.cornerRadius=16.0
        cancelBtn.layer.masksToBounds=true
        cancelBtn.clipsToBounds = true
        cancelBtn.layer.borderColor = doneBtn.backgroundColor?.cgColor
        cancelBtn.layer.borderWidth = 1.0
        if selectedText != nil{
            if selectedText != placeholderString {
                salaryEntryTxt.text = selectedText
            }
        }
        salaryEntryTxt.becomeFirstResponder()
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
    
    //MARK:- Done Button Action
    
    @IBAction func doneBtnAction(_ sender: Any) {
        if salaryEntryTxt.text != "" {
            var tempDict = [String : AnyObject]()
            tempDict["institute"] = salaryEntryTxt.text as AnyObject?
            educationDelegate?.callBackWithDict!(data: tempDict)
            self.endEditing(true)
            self.hidePopUp()
        }
        else{
            let alert = UIAlertController(title: AppName, message: "Enter your last institution where you studied.", preferredStyle: UIAlertControllerStyle.alert)
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


extension EducationSelectionView: UITextFieldDelegate{
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
        let maxLength = 50
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
}
