//
//  FirstCoachView.swift
//  JobJira
//
//  Created by Vaibhav on 08/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class FirstCoachView: UIView {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var popUpView: UIView!
    var dataArray:[AnyObject]!
    var selectedNationality:String!
    
    //MARK: Initialize View
    
    class func instansiateFromNib() -> FirstCoachView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [6] as! FirstCoachView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        
    }
    
    //MARK: Show View Method
    
    func showPopup(){
        self.alpha = 0
        UIView.animate(withDuration: 0.8, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.alpha = 1
        }, completion: { (suceess) -> Void in
            
        })
    }
    
    //MARK: Hide View Method
    
    func hidePopUp(){
        UIView.animate(withDuration: 0.8, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.alpha = 0
        }, completion: { (suceess) -> Void in
            self.removeFromSuperview()
        })
    }
    
    //MARK: Close Action
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hidePopUp()
    }
    
    
}
