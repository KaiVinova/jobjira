//
//  ExampleOverlayView.swift
//  KolodaView
//
//  Created by Eugene Andreyev on 6/21/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda

private let overlayRightImageName = "heart"
private let overlayLeftImageName = "cross"

class ExampleOverlayView: OverlayView {
    
    @IBOutlet var likeOverlayImageView: UIImageView!
    @IBOutlet var skipOverlayImageView: UIImageView!

    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                skipOverlayImageView.isHidden = false
                likeOverlayImageView.isHidden = true
//                overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .right? :
                skipOverlayImageView.isHidden = true
                likeOverlayImageView.isHidden = false
//                overlayImageView.image = UIImage(named: overlayRightImageName)
            default:
                skipOverlayImageView.isHidden = true
                likeOverlayImageView.isHidden = true
//                overlayImageView.image = nil
            }
        }
    }

}
