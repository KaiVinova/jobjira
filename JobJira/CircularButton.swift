//
//  CircularButton.swift
//  HomeTurph
//
//  Created by Vaibhav on 31/08/16.
//  Copyright © 2016 Vaibhav Krishna. All rights reserved.
//

import UIKit

class CircularButton: UIButton
{

//MARK:- View LifeCycle

    override func layoutSubviews()
    {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

}
