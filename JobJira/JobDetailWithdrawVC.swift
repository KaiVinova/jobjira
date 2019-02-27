//
//  JobDetailWithdrawVC.swift
//  JobJira
//
//  Created by Vaibhav on 28/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
class JobDetailWithdrawVC: UIViewController
{

//MARK:- IBOutlets
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var companyLogoImage: UIImageView!
    @IBOutlet weak var companyDescriptionLbl: UILabel!
    @IBOutlet weak var companySubDescLbl: UILabel!
    @IBOutlet weak var jobTitleLbl: UILabel!
    @IBOutlet weak var jobDescriptionLbl: UILabel!
    @IBOutlet weak var withdrawBtn: UIButton!
    
//MARK:- Variales and Constants

    var jobID:String!
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
//MRK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
//MARK:- WithDraw Button Action
    
    @IBAction func withdrawBtnAction(_ sender: Any)
    {
        
    }
}
