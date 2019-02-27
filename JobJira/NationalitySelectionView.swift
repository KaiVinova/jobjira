//
//  NationalitySelectionView.swift
//  JobJira
//
//  Created by Vaibhav on 29/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class NationalitySelectionView: UIView {
    
    //MARK:- IBOutlets
    
    var nationalityDelegate:NationalityDelegate?
    @IBOutlet weak var nationalityTable: UITableView!
    @IBOutlet weak var tableSuperView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var popUpView: UIView!
    var dataArray:[AnyObject]!
    var filterArray = [AnyObject]()
    var selectedNationality:String!
    
    //MARK: Initialize View
    
    class func instansiateFromNib() -> NationalitySelectionView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [5] as! NationalitySelectionView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        self.nationalityTable.register(UINib(nibName: "AgeSelectionCell", bundle: nil), forCellReuseIdentifier: "AgeSelectionCell")
        tableSuperView.layer.cornerRadius=4.0
        tableSuperView.layer.masksToBounds=true
        tableSuperView.clipsToBounds = true
        self.nationalityTable.tableFooterView = UIView()
        self.nationalityTable.estimatedRowHeight = 25.0
        self.nationalityTable.rowHeight = 30.0
        nationalityTable.reloadData()
        searchBar.becomeFirstResponder()
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

extension NationalitySelectionView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if filterArray.count>0 {
            return filterArray.count
        }
        else{
            return dataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "AgeSelectionCell") as! AgeSelectionCell
        cell.selectionStyle = .none
        if filterArray.count>0 {
            cell.ageTitleLabel.text = "\(filterArray[indexPath.row]["nationality"] as! String)"
            cell.contentView.backgroundColor = UIColor(red: 73.0/255.0, green: 60.0/255.0, blue: 228.0/255.0, alpha: 1.0)
            if selectedNationality == filterArray[indexPath.row]["countryID"] as! String {
                cell.contentView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
            }
        }
        else{
            cell.ageTitleLabel.text = "\(dataArray[indexPath.row]["nationality"] as! String)"
            cell.contentView.backgroundColor = UIColor(red: 73.0/255.0, green: 60.0/255.0, blue: 228.0/255.0, alpha: 1.0)
            if selectedNationality == dataArray[indexPath.row]["countryID"] as! String {
                cell.contentView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
            }
        }
        
        return cell
    }
}

//MARK: Tableview Delegates

extension NationalitySelectionView:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let cell:AgeSelectionCell = tableView.cellForRow(at: indexPath) as! AgeSelectionCell
        cell.contentView.backgroundColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
        if filterArray.count>0 {
            nationalityDelegate?.callBackWithDict!(data: filterArray[indexPath.row] as! [String : AnyObject])
        }
        else{
            nationalityDelegate?.callBackWithDict!(data: dataArray[indexPath.row] as! [String : AnyObject])
        }
        self.hidePopUp()
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let cell:AgeSelectionCell = tableView.cellForRow(at: indexPath) as! AgeSelectionCell
        cell.contentView.backgroundColor = UIColor(red: 73.0/255.0, green: 60.0/255.0, blue: 228.0/255.0, alpha: 1.0)
    }
}

//MARK:- Search Bar Delegates

extension NationalitySelectionView:UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        filterArray = dataArray.filter({ (dict) -> Bool in
            let tmp: NSString = dict["nationality"] as! NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        self.nationalityTable.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        nationalityDelegate?.callBackWithDict!(data: [String : AnyObject]())
        self.hidePopUp()
    }
}
