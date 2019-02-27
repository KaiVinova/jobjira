//
//  CardView.swift
//  JobJira
//
//  Created by Vaibhav on 27/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var companyPic: UIImageView!
    @IBOutlet weak var companyNameLbl: UILabel!
    @IBOutlet weak var companyDomainLbl: UILabel!
    @IBOutlet weak var companyDecriptionLbl: UILabel!
    @IBOutlet weak var jobDesignationLbl: UILabel!
    @IBOutlet weak var jobDescriptionLbl: UILabel!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cardTapBtn: UIButton!
    
    //MARK:- Initialize View
    
    class func instansiateFromNib() -> CardView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [8] as! CardView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight == 480{
            let font = companyNameLbl.font
            companyNameLbl.font = font?.withSize(15)
            let font1 = companyDomainLbl.font
            companyDomainLbl.font = font1?.withSize(12)
            let font2 = companyDecriptionLbl.font
            companyDecriptionLbl.font = font2?.withSize(12)
            let font3 = jobDesignationLbl.font
            jobDesignationLbl.font = font3?.withSize(16)
            let font4 = jobDescriptionLbl.font
            jobDescriptionLbl.font = font4?.withSize(12)
        }
        self.frame = (self.superview?.bounds)!
        self.layer.cornerRadius=4.0
        self.layer.masksToBounds=true
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        
        skipBtn.layer.cornerRadius=16.0
        skipBtn.layer.masksToBounds=true
        skipBtn.clipsToBounds = true
        
        applyBtn.layer.cornerRadius=16.0
        applyBtn.layer.masksToBounds=true
        applyBtn.clipsToBounds = true
        self.layoutIfNeeded()
    }
}
