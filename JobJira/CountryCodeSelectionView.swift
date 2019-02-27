//
//  CountryCodeSelectionView.swift
//  JobJira
//
//  Created by Vaibhav on 06/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class CountryCodeSelectionView: UIView {
    
    //MARK:- IBOutlets
    
    var codeDelegate:CountryCodeDelegate?
    @IBOutlet weak var ageTable: UITableView!
    @IBOutlet weak var tableSuperView: UIView!
    @IBOutlet weak var popUpView: UIView!
    var dataArray:[AnyObject]!
    var selectedCode:String!
    
    //MARK: Initialize View
    
    class func instansiateFromNib() -> CountryCodeSelectionView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [13] as! CountryCodeSelectionView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        self.ageTable.register(UINib(nibName: "CountryCodeSelectionCell", bundle: nil), forCellReuseIdentifier: "CountryCodeSelectionCell")
        tableSuperView.layer.cornerRadius=4.0
        tableSuperView.layer.masksToBounds=true
        tableSuperView.clipsToBounds = true
        self.ageTable.tableFooterView = UIView()
        self.ageTable.estimatedRowHeight = 25.0
        self.ageTable.rowHeight = 30.0
        ageTable.reloadData()
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

extension CountryCodeSelectionView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return CountryCodeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCodeSelectionCell") as! CountryCodeSelectionCell
        cell.selectionStyle = .none
        cell.countryNameLbl.text = CountryCodeArray[indexPath.row]["name"]
        cell.countryCodeLbl.text = CountryCodeArray[indexPath.row]["code"]
        cell.contentView.backgroundColor = UIColor(red: 73.0/255.0, green: 60.0/255.0, blue: 228.0/255.0, alpha: 1.0)
        if selectedCode == cell.countryCodeLbl.text {
            cell.contentView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
        }
        return cell
    }
}

//MARK: Tableview Delegates

extension CountryCodeSelectionView:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let cell:CountryCodeSelectionCell = tableView.cellForRow(at: indexPath) as! CountryCodeSelectionCell
        cell.contentView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
        
        codeDelegate?.callBackForCodeWithDict!(data: CountryCodeArray[indexPath.row] as [String : AnyObject])
        self.hidePopUp()
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let cell:CountryCodeSelectionCell = tableView.cellForRow(at: indexPath) as! CountryCodeSelectionCell
        cell.contentView.backgroundColor = UIColor(red: 73.0/255.0, green: 60.0/255.0, blue: 228.0/255.0, alpha: 1.0)
    }
}
