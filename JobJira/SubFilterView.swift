//
//  SubFilterView.swift
//  JobJira
//
//  Created by Vaibhav on 20/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class SubFilterView: UIView {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var filterTable: UITableView!
    @IBOutlet weak var tableSuperView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var filterTopView: UIView!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var filterIcon: UIImageView!
    @IBOutlet weak var filterLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var filterDelegate:SubFilterDelegate!
    var fromView:UIView!
    var dataArray:[AnyObject]!
    var keyName:String!
    var keyId:String!
    var index:Int!
    var selectedArray:[AnyObject]!
    
    //MARK: Initialize View
    
    class func instansiateFromNib() -> SubFilterView{
        return Bundle.main.loadNibNamed("FiltersView", owner: self, options: nil)! [0] as! SubFilterView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        self.filterTable.register(UINib(nibName: "SubFilterCell", bundle: nil), forCellReuseIdentifier: "SubFilterCell")
        self.filterTable.tableFooterView = UIView()
        self.filterTable.estimatedRowHeight = 60.0
        //        self.filterTable.rowHeight = UITableViewAutomaticDimension
        if selectedArray == nil {
            selectedArray = [AnyObject]()
        }
        filterLbl.text = "\(selectedArray.count) selected"
        filterTable.reloadData()
    }
    
    //MARK: Flip Left View Method
    
    func flipLeftPopup(){
        UIView.transition(from: fromView, to: self, duration: 0.5, options: .transitionFlipFromLeft, completion: { (success) -> Void in
            self.fromView.isHidden = true
        })
    }
    
    //MARK: Flip Right View Method
    
    func flipRightPopup(){
        fromView.isHidden = false
        UIView.transition(from: self, to: fromView, duration: 0.5, options: .transitionFlipFromRight, completion: { (success) -> Void in
            self.removeFromSuperview()
        })
    }
    
    //MARK: Close Action
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        flipRightPopup()
        var tempDict = [String:AnyObject]()
        tempDict["index"] = index as AnyObject?
        tempDict["selected"] = selectedArray as AnyObject?
        self.filterDelegate.callBackWithDict!(data: tempDict)
    }
}

//MARK: Tableview Datasources

extension SubFilterView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubFilterCell") as! SubFilterCell
        cell.selectionStyle = .none
        let tempDict = dataArray[indexPath.row] as? [String:AnyObject]
        cell.subFilterLabel.text = tempDict?[keyName] as? String
        cell.subFilterSelectionBtn.addTarget(self, action: #selector(SubFilterView.selectionBtnAction(_:)), for: .touchUpInside)
        cell.subFilterSelectionBtn.tag = indexPath.row
        cell.subFilterSelectionBtn.isSelected = false
        if selectedArray.count>0 {
            for element in selectedArray {
                if element[keyId] as! String == dataArray[indexPath.row][keyId] as! String {
                    cell.subFilterSelectionBtn.isSelected = true
                }
            }
        }
        return cell
    }
    
    func selectionBtnAction(_ sender:UIButton){
        if sender.isSelected == true{
            for (index, element) in selectedArray.enumerated() {
                if element[keyId] as! String == dataArray[sender.tag][keyId] as! String {
                    selectedArray.remove(at: index)
                }
            }
        }
        else{
            selectedArray.append(dataArray[sender.tag])
        }
        filterTable.reloadData()
        filterLbl.text = "\(selectedArray.count) selected"
    }
}

//MARK: Tableview Delegates

extension SubFilterView:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        let cell:SubFilterCell = tableView.cellForRow(at: indexPath) as! SubFilterCell
        
        if cell.subFilterSelectionBtn.isSelected == true{
            for (index, element) in selectedArray.enumerated() {
                if element[keyId] as! String == dataArray[indexPath.row][keyId] as! String {
                    selectedArray.remove(at: index)
                }
            }
        }
        else{
            selectedArray.append(dataArray[indexPath.row])
        }
        filterTable.reloadData()
        filterLbl.text = "\(selectedArray.count) selected"
    }
}
