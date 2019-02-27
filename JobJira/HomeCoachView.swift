//
//  HomeCoachView.swift
//  JobJira
//
//  Created by Vaibhav on 04/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class HomeCoachView: UIView {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var popUpView: UIView!
    var dataArray:[AnyObject]!
    var selectedNationality:String!
    
    //MARK: Initialize View
    
    class func instansiateFromNib() -> HomeCoachView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [11] as! HomeCoachView
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
            UserDefaults.standard.set("1", forKey: "homeCoach")
        })
    }
    
    //MARK: Close Action
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hidePopUp()
    }
    
    
}
