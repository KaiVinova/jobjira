//
//  PlaceholderView.swift
//  JobJira
//
//  Created by Vaibhav on 10/02/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class PlaceholderView: UIView {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var placeholderLbl1: UILabel!
    @IBOutlet weak var placeholderLbl2: UILabel!
    class func instansiateFromNib() -> PlaceholderView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [17] as! PlaceholderView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.frame = (self.superview?.bounds)!
    }
}
