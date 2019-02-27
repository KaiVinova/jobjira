//
//  ExperinceSelectionView.swift
//  JobJira
//
//  Created by Vaibhav on 26/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class ExperinceSelectionView: UIView {
    
    //MARK: IBOutlets
    
    var experinceDelegate:ExperinceDelegate?
    @IBOutlet weak var experinceTable: UITableView!
    @IBOutlet weak var tableSuperView: UIView!
    @IBOutlet weak var popUpView: UIView!
    var dataArray:[AnyObject]!
    var selectedExperience:String!
    
    //MARK: Initialize View
    
    class func instansiateFromNib() -> ExperinceSelectionView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [2] as! ExperinceSelectionView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        self.experinceTable.register(UINib(nibName: "AgeSelectionCell", bundle: nil), forCellReuseIdentifier: "AgeSelectionCell")
        tableSuperView.layer.cornerRadius=4.0
        tableSuperView.layer.masksToBounds=true
        tableSuperView.clipsToBounds = true
        self.experinceTable.tableFooterView = UIView()
        self.experinceTable.estimatedRowHeight = 25.0
        self.experinceTable.rowHeight = 30.0// UITableViewAutomaticDimension
        experinceTable.reloadData()
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

extension ExperinceSelectionView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "AgeSelectionCell") as! AgeSelectionCell
        cell.selectionStyle = .none
        cell.ageTitleLabel.text = "\(dataArray[indexPath.row]["buttonText"] as! String)"
        cell.contentView.backgroundColor = UIColor(red: 73.0/255.0, green: 60.0/255.0, blue: 228.0/255.0, alpha: 1.0)
        if selectedExperience == dataArray[indexPath.row]["buttonText"] as! String {
            cell.contentView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
        }
        return cell
    }
}

//MARK: Tableview Delegates

extension ExperinceSelectionView:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let cell:AgeSelectionCell = tableView.cellForRow(at: indexPath) as! AgeSelectionCell
        cell.contentView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
        experinceDelegate?.callBackWithDict!(data: dataArray[indexPath.row] as! [String:AnyObject])
        self.hidePopUp()
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let cell:AgeSelectionCell = tableView.cellForRow(at: indexPath) as! AgeSelectionCell
        cell.contentView.backgroundColor = UIColor(red: 73.0/255.0, green: 60.0/255.0, blue: 228.0/255.0, alpha: 1.0)
    }
}
