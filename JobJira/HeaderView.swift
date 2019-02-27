//
//  HeaderView.swift
//  JobJira
//
//  Created by Vaibhav on 03/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var headerLbl: UILabel!
    
    //MARK:- Initialize View
    
    class func instansiateFromNib() -> HeaderView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [10] as! HeaderView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        
    }
}
