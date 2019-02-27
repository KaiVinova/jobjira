//
//  IAgreeView.swift
//  JobJira
//
//  Created by Vaibhav on 09/03/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class IAgreeView: UIView {
    
    //MARK:- IBOutlets
    
    var iAgreeDelegate:IAgreeDelegate?
    @IBOutlet weak var popUpSuperView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var tAndCLbl: TTTAttributedLabel!
    
    var parentViewController:UIViewController!
    //MARK: Initialize View
    
    class func instansiateFromNib() -> IAgreeView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [18] as! IAgreeView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        
        popUpSuperView.layer.cornerRadius=4.0
        popUpSuperView.layer.masksToBounds=true
        popUpSuperView.clipsToBounds = true
        
        doneBtn.layer.cornerRadius=16.0
        doneBtn.layer.masksToBounds=true
        doneBtn.clipsToBounds = true
        cancelBtn.layer.cornerRadius=16.0
        cancelBtn.layer.masksToBounds=true
        cancelBtn.clipsToBounds = true
        cancelBtn.layer.borderColor = doneBtn.backgroundColor?.cgColor
        cancelBtn.layer.borderWidth = 1.0
        
        let str:NSString = self.tAndCLbl.text! as NSString
        
        let subscriptionNoticeAttributedString = NSAttributedString(string:str as String, attributes: [
            NSFontAttributeName: UIFont(name:".SFUIText-Medium", size:16)!,
            NSParagraphStyleAttributeName: NSMutableParagraphStyle(),
            NSForegroundColorAttributeName: UIColor.white.cgColor,
            ])
        self.tAndCLbl
            .setText(subscriptionNoticeAttributedString)
        
        let subscriptionNoticeLinkAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSUnderlineStyleAttributeName: NSNumber(value:true),
            ]
        
        let subscriptionNoticeActiveLinkAttributes = [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.80),
            NSUnderlineStyleAttributeName: NSNumber(value:true),
            ]
        
        self.tAndCLbl.linkAttributes = subscriptionNoticeLinkAttributes
        self.tAndCLbl.activeLinkAttributes = subscriptionNoticeActiveLinkAttributes
        
        let range : NSRange = str.range(of: "Terms & Conditions")
        self.tAndCLbl.addLink(to: NSURL(string: "https://www.google.com")! as URL!, with: range)
        
        self.tAndCLbl.delegate = self
        
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
    
    @IBAction func iAgreeBtnAction(_ sender: Any) {
        iAgreeDelegate?.callBack!()
        self.endEditing(true)
        self.hidePopUp()
    }
    
    //MARK: Close Action
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.endEditing(true)
        self.hidePopUp()
    }
}

//MARK:- TTTAttributedLabel Delegate

extension IAgreeView:TTTAttributedLabelDelegate{
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!){
        let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
        let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
        viewcontroller.titleText = "Terms & Conditions"
        viewcontroller.loadData = "1"
        viewcontroller.fromScreen = "pre"
        parentViewController.navigationController?.pushViewController(viewcontroller, animated: true)
    }
}
