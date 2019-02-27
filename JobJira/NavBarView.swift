//
//  NavBarView.swift
//  JobJira
//
//  Created by Vaibhav on 01/02/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class NavBarView: UIView {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var companyNameLbl: UILabel!
    @IBOutlet weak var designationNameLbl: UILabel!
    
    class func instansiateFromNib() -> NavBarView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [16] as! NavBarView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        
    }
    
}

