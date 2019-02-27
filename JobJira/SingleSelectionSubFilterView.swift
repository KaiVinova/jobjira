//
//  SingleSelectionSubFilterView.swift
//  JobJira
//
//  Created by Vaibhav on 21/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class SingleSelectionSubFilterView: UIView {
    
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
    var minBudgetArray:[AnyObject]!
    var maxBudgetArray:[AnyObject]!
    var keyName:String!
    var keyId:String!
    var index:Int!
    var selectedArray:[AnyObject]!
    var selectedIndex:Int!
    
    //MARK: Initialize View
    
    class func instansiateFromNib() -> SingleSelectionSubFilterView{
        return Bundle.main.loadNibNamed("FiltersView", owner: self, options: nil)! [1] as! SingleSelectionSubFilterView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        self.filterTable.register(UINib(nibName: "RadioSubFilterCell", bundle: nil), forCellReuseIdentifier: "RadioSubFilterCell")
        self.filterTable.tableFooterView = UIView()
        self.filterTable.estimatedRowHeight = 60.0
        filterTable.reloadData()
        if selectedArray == nil {
            selectedArray = [AnyObject]()
        }
        if dataArray != nil {
            filterLbl.text = "Choose gender"
        }
        else{
            filterLbl.text = "Choose min. budget"
        }
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
    
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        self.hidePopUp()
    //    }
    @IBAction func cancelBtnAction(_ sender: Any) {
        if dataArray != nil {
            flipRightPopup()
            var tempDict = [String:AnyObject]()
            tempDict["index"] = index as AnyObject?
            tempDict["selected"] = selectedArray as AnyObject?
            self.filterDelegate.callBackWithDict!(data: tempDict)
        }
        else{
            if selectedArray.count>0 {
                if maxBudgetArray == nil {
                    filterLbl.text = "Choose max. budget"
                    for (index, element) in minBudgetArray.enumerated() {
                        for element1 in selectedArray {
                            if element[keyId] as! String == element1[keyId] as! String{
                                selectedIndex = index
                                break
                            }
                        }
                        if selectedIndex != nil {
                            break
                        }
                    }
                    maxBudgetArray = [AnyObject]()
                    for (index, element) in minBudgetArray.enumerated() {
                        if index>selectedIndex {
                            maxBudgetArray.append(element)
                        }
                    }
                    reloadAndAnimateTableRight(filterTable)
                }
                else{
                    flipRightPopup()
                    var tempDict = [String:AnyObject]()
                    tempDict["index"] = index as AnyObject?
                    tempDict["selected"] = selectedArray as AnyObject?
                    self.filterDelegate.callBackWithDict!(data: tempDict)
                }
            }
            else{
                flipRightPopup()
                var tempDict = [String:AnyObject]()
                tempDict["index"] = index as AnyObject?
                tempDict["selected"] = selectedArray as AnyObject?
                self.filterDelegate.callBackWithDict!(data: tempDict)
            }
            
        }
    }
    
    //MARK:- Method to reload table
    
    func reloadAndAnimateTableRight(_ table:UITableView) {
        table.reloadData()
        
        let cells = table.visibleCells
        let tableWidth: CGFloat = table.bounds.size.width
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: tableWidth, y: 0)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
        }
    }
}

//MARK: Tableview Datasources

extension SingleSelectionSubFilterView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if dataArray != nil {
            return dataArray.count
        }
        else{
            if maxBudgetArray != nil {
                return maxBudgetArray.count
            }
            else{
                return minBudgetArray.count - 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioSubFilterCell") as! RadioSubFilterCell
        cell.selectionStyle = .none
        var tempDict = [String:AnyObject]()
        if dataArray != nil {
            tempDict = (dataArray[indexPath.row] as? [String:AnyObject])!
        }
        else{
            if maxBudgetArray != nil {
                tempDict = (maxBudgetArray[indexPath.row] as? [String:AnyObject])!
            }
            else{
                tempDict = (minBudgetArray[indexPath.row] as? [String:AnyObject])!
            }
        }
        cell.subFilterLabel.text = tempDict[keyName] as? String
        cell.subFilterSelectionBtn.addTarget(self, action: #selector(SubFilterView.selectionBtnAction(_:)), for: .touchUpInside)
        cell.subFilterSelectionBtn.tag = indexPath.row
        cell.subFilterSelectionBtn.isSelected = false
        if dataArray != nil {
            if selectedArray.count>0 {
                for element in selectedArray {
                    if element[keyId] as! String == dataArray[indexPath.row][keyId] as! String {
                        cell.subFilterSelectionBtn.isSelected = true
                    }
                }
            }
        }
        else{
            if maxBudgetArray != nil {
                if selectedArray.count>1 {
                    if selectedArray[1][keyId] as! String == maxBudgetArray[indexPath.row][keyId] as! String {
                        cell.subFilterSelectionBtn.isSelected = true
                    }
                }
            }
            else{
                if selectedArray.count>0 {
                    if selectedArray[0][keyId] as! String == minBudgetArray[indexPath.row][keyId] as! String {
                        cell.subFilterSelectionBtn.isSelected = true
                    }
                }
            }
            
        }
        return cell
    }
    
    func selectionBtnAction(_ sender:UIButton){
        if maxBudgetArray != nil {
            if selectedArray.count==2{
                selectedArray[1] = maxBudgetArray[sender.tag]
            }
            else{
                selectedArray.append(maxBudgetArray[sender.tag])
            }
            filterTable.reloadData()
        }
        else{
            if dataArray != nil {
                selectedArray.removeAll()
                selectedArray.append(dataArray[sender.tag])
                filterTable.reloadData()
            }
            else{
                selectedArray.removeAll()
                selectedArray.append(minBudgetArray[sender.tag])
                filterTable.reloadData()
                
            }
        }
        
    }
}

//MARK: Tableview Delegates

extension SingleSelectionSubFilterView:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        if maxBudgetArray != nil {
            if selectedArray.count==2{
                selectedArray[1] = maxBudgetArray[indexPath.row]
            }
            else{
                selectedArray.append(maxBudgetArray[indexPath.row])
            }
            filterTable.reloadData()
        }
        else{
            if dataArray != nil {
                selectedArray.removeAll()
                selectedArray.append(dataArray[indexPath.row])
                filterTable.reloadData()
            }
            else{
                selectedArray.removeAll()
                selectedArray.append(minBudgetArray[indexPath.row])
                filterTable.reloadData()
                
            }
        }
    }
}
