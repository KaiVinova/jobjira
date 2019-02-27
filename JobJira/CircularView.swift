//
//  CircularView.swift
//  HomeTurph
//
//  Created by Vaibhav on 30/08/16.
//  Copyright © 2016 Vaibhav Krishna. All rights reserved.
//

import UIKit

class CircularView: UIView
{

//MARK:- View LifeCycle

    override func layoutSubviews()
    {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
    }
}
