//
//  AdvertisementView.swift
//  JobJira
//
//  Created by Vaibhav on 05/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class AdvertisementView: UIView {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    var adDelegate:AdDelegate?
    var url:String!
    var imageUrl:String!
    
    //MARK: Initialize View
    
    class func instansiateFromNib() -> AdvertisementView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [12] as! AdvertisementView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        self.bannerImage.setImageWith(URL(string:imageUrl)!, placeholderImage: UIImage(named: "loading"))
        self.bannerImage.layer.cornerRadius = 4.0
        self.bannerImage.layer.masksToBounds = true
        self.bannerImage.backgroundColor = UIColor.darkGray
    }
    
    //MARK: Show View Method
    
    func showPopup(){
        self.alpha = 0
        self.popUpView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        UIView.animate(withDuration: 0.8, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.alpha = 1
            self.popUpView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
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
    
    @IBAction func closeBtnAction(_ sender: Any) {
        self.hidePopUp()
        adDelegate?.callBackWithStatus!(false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hidePopUp()
        adDelegate?.callBackWithStatus!(false)
        if !closeBtn.isHidden {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
}
