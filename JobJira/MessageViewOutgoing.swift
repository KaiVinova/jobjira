//
//  MessageViewOutgoing.swift
//  SwiftExample
//
//  Created by Vaibhav on 06/02/17.
//  Copyright © 2017 MacMeDan. All rights reserved.
//

import UIKit
import JSQMessagesViewController
class MessageViewOutgoing: JSQMessagesCollectionViewCellOutgoing {

    @IBOutlet weak var timeLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override class func nib() -> UINib {
        return UINib (nibName: "messageViewOutgoing", bundle: Bundle.main)
    }
    
    override class func cellReuseIdentifier() -> String {
        return "MessageViewOutgoing"
    }
    
    override class func mediaCellReuseIdentifier() -> String {
        return "MessageViewOutgoing_JSQMedia"
    }

}
