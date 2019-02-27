//
//  QualificationView.swift
//  JobJira
//
//  Created by Vaibhav on 18/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class QualificationView: UIView {
    
    //MARK:- IBOutlets
    
    var qualificationDelegate:QualificationDelegate?
    @IBOutlet weak var nationalityTable: UITableView!
    @IBOutlet weak var tableSuperView: UIView!
    @IBOutlet weak var popUpView: UIView!
    var dataArray:[AnyObject]!
    var selectedQualification:String!
    
    //MARK: Initialize View
    
    class func instansiateFromNib() -> QualificationView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [14] as! QualificationView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        self.nationalityTable.register(UINib(nibName: "AgeSelectionCell", bundle: nil), forCellReuseIdentifier: "AgeSelectionCell")
        tableSuperView.layer.cornerRadius=4.0
        tableSuperView.layer.masksToBounds=true
        tableSuperView.clipsToBounds = true
        self.nationalityTable.tableFooterView = UIView()
        self.nationalityTable.estimatedRowHeight = 25.0
        self.nationalityTable.rowHeight = 30.0// UITableViewAutomaticDimension
        nationalityTable.reloadData()
    }
    
    //MARK: Show View Method
    
    func showPopup(){
        
        self.alpha = 0
        self.popUpView.center = CGPoint(x: self.superview!.frame.width/2, y: 2 * self.superview!.frame.height)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.popUpView.center = self.superview!.center
            self.alpha = 1
        }) { (suceess) -> Void in
            
        }
    }
    
    //MARK: Hide View Method
    
    func hidePopUp(){
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.alpha = 0
            self.popUpView.center = CGPoint(x: self.superview!.frame.width/2, y: 2 * self.superview!.frame.height)
            
        }) { (suceess) -> Void in
            self.removeFromSuperview()
        }
    }
}

//MARK: Tableview Datasources

extension QualificationView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "AgeSelectionCell") as! AgeSelectionCell
        cell.selectionStyle = .none
        cell.ageTitleLabel.text = "\(dataArray[indexPath.row]["educationalQualificationName"] as! String)"
        cell.contentView.backgroundColor = UIColor(red: 73.0/255.0, green: 60.0/255.0, blue: 228.0/255.0, alpha: 1.0)
        if selectedQualification == cell.ageTitleLabel.text {
            cell.contentView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
        }
        return cell
    }
}

//MARK: Tableview Delegates

extension QualificationView:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let cell:AgeSelectionCell = tableView.cellForRow(at: indexPath) as! AgeSelectionCell
        cell.contentView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
        qualificationDelegate?.callBackWithQualificationDict!(data: dataArray[indexPath.row] as! [String : AnyObject])
        self.hidePopUp()
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let cell:AgeSelectionCell = tableView.cellForRow(at: indexPath) as! AgeSelectionCell
        cell.contentView.backgroundColor = UIColor(red: 73.0/255.0, green: 60.0/255.0, blue: 228.0/255.0, alpha: 1.0)
    }
}
