//
//  FilterView.swift
//  JobJira
//
//  Created by Vaibhav on 28/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

@objc protocol SubFilterDelegate {
    @objc optional func callBackWithDict(data:[String:AnyObject])
}
class FilterView: UIView {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var filterTable: UITableView!
    @IBOutlet weak var tableSuperView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var filterTopView: UIView!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var filterIcon: UIImageView!
    @IBOutlet weak var filterLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    
    var filterDelegate:FilterDelegate!
    var filterDict:[String:AnyObject]!
    
    //MARK: Initialize View
    
    class func instansiateFromNib() -> FilterView{
        return Bundle.main.loadNibNamed("Views", owner: self, options: nil)! [9] as! FilterView
    }
    
    //MARK: Overridden Method
    
    override func layoutSubviews() {
        self.filterTable.register(UINib(nibName: "FilterCell", bundle: nil), forCellReuseIdentifier: "FilterCell")
        self.filterTable.tableFooterView = UIView()
        self.filterTable.estimatedRowHeight = 60.0
        resetBtn.layer.cornerRadius=14.0
        resetBtn.layer.masksToBounds=true
        resetBtn.clipsToBounds = true
        resetBtn.layer.borderColor = applyBtn.backgroundColor?.cgColor
        resetBtn.layer.borderWidth = 1.0
        applyBtn.layer.cornerRadius=14.0
        applyBtn.layer.masksToBounds=true
        applyBtn.clipsToBounds = true
        print(filterDict)
        filterTable.reloadData()
    }
    
    //MARK: Show View Method
    
    func showPopup(){
        
        self.alpha = 0
        self.popUpView.center = CGPoint(x: self.superview!.frame.width/2, y: 2 * self.superview!.frame.height)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in
            self.popUpView.center = self.superview!.center
            self.alpha = 1
        }) { (suceess) -> Void in
            
        }
    }
    
    //MARK: Hide View Method
    
    func hidePopUp(){
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in
            self.alpha = 0
            self.popUpView.center = CGPoint(x: self.superview!.frame.width/2, y: 2 * self.superview!.frame.height)
        }) { (suceess) -> Void in
            self.removeFromSuperview()
        }
    }
    
    //MARK: Close Action
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        hidePopUp()
    }
    
    //MARK:- Reset button Action
    
    @IBAction func resetBtnAction(_ sender: Any) {
        filterDelegate.callBackWithFilter!([String:AnyObject]())
        InitializerHelper.sharedInstance.resetFilters()
        hidePopUp()
    }
    
    //MARK:- Apply button Action
    
    @IBAction func applyBtnAction(_ sender: Any) {
        var selectedDict = [String:AnyObject]()
        var tempArray = [AnyObject]()
        for element in InitializerHelper.sharedInstance.selectedGender {
            tempArray.append(element["genderID"] as AnyObject)
        }
        selectedDict["genders"] = tempArray as AnyObject?
        
        tempArray = [AnyObject]()
        for element in InitializerHelper.sharedInstance.selectedBudgetRange {
            tempArray.append(element["ctcBudgetRangetID"] as AnyObject)
        }
        selectedDict["budgetRanges"] = tempArray as AnyObject?
        
        tempArray = [AnyObject]()
        for element in InitializerHelper.sharedInstance.selectedJobTypes {
            tempArray.append(element["jobTypeID"] as AnyObject)
        }
        selectedDict["jobTypes"] = tempArray as AnyObject?
        
        tempArray = [AnyObject]()
        for element in InitializerHelper.sharedInstance.selectedJobRoles {
            tempArray.append(element["jobRoleID"] as AnyObject)
        }
        selectedDict["jobRoles"] = tempArray as AnyObject?
        
        tempArray = [AnyObject]()
        for element in InitializerHelper.sharedInstance.selectedSpeakingLanguage {
            tempArray.append(element["speakingLangID"] as AnyObject)
        }
        selectedDict["speakingLanguages"] = tempArray as AnyObject?
        
        tempArray = [AnyObject]()
        for element in InitializerHelper.sharedInstance.selectedEducationalQualification {
            tempArray.append(element["educationalQualificationID"] as AnyObject)
        }
        selectedDict["educationalQualifications"] = tempArray as AnyObject?
        
        tempArray = [AnyObject]()
        for element in InitializerHelper.sharedInstance.selectedSkills {
            tempArray.append(element["primarySkillID"] as AnyObject)
        }
        selectedDict["skills"] = tempArray as AnyObject?
        
        tempArray = [AnyObject]()
        for element in InitializerHelper.sharedInstance.selectedHiringLocation {
            tempArray.append(element["stateID"] as AnyObject)
        }
        selectedDict["hiringLocations"] = tempArray as AnyObject?
        
        tempArray = [AnyObject]()
        for element in InitializerHelper.sharedInstance.selectedExperienceRange {
            tempArray.append(element["expRangeID"] as AnyObject)
        }
        selectedDict["experienceRanges"] = tempArray as AnyObject?
        
        tempArray = [AnyObject]()
        for element in InitializerHelper.sharedInstance.selectedAgeRange {
            tempArray.append(element["ageRangeID"] as AnyObject)
        }
        selectedDict["ageRanges"] = tempArray as AnyObject?
        filterDelegate.callBackWithFilter!(selectedDict)
        hidePopUp()
    }
}

//MARK: Tableview Datasources

extension FilterView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell") as! FilterCell
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.FilterNameLbl.text = "Gender"
            var optionsString = ""
            for (index, element) in InitializerHelper.sharedInstance.selectedGender.enumerated() {
                if index == 0{
                    optionsString = (element["genderName"] as? String)!
                }
                else{
                    optionsString = "\(optionsString), \((element["genderName"] as? String)!)"
                }
            }
            cell.filterOptionLbl.text = optionsString
            break
        case 1:
            cell.FilterNameLbl.text = "Budget Range"
            var optionsString = ""
            for (index, element) in InitializerHelper.sharedInstance.selectedBudgetRange.enumerated() {
                if index == 0{
                    optionsString = (element["ctcBudgetFrom"] as? String)!
                }
                else{
                    optionsString = "\(optionsString) - \((element["ctcBudgetFrom"] as? String)!)"
                }
            }
            cell.filterOptionLbl.text = optionsString
            break
        case 2:
            cell.FilterNameLbl.text = "Job Types"
            var optionsString = ""
            for (index, element) in InitializerHelper.sharedInstance.selectedJobTypes.enumerated() {
                if index == 0{
                    optionsString = (element["jobType"] as? String)!
                }
                else{
                    optionsString = "\(optionsString), \((element["jobType"] as? String)!)"
                }
            }
            cell.filterOptionLbl.text = optionsString
            break
        case 3:
            cell.FilterNameLbl.text = "Job Roles"
            var optionsString = ""
            for (index, element) in InitializerHelper.sharedInstance.selectedJobRoles.enumerated() {
                if index == 0{
                    optionsString = (element["jobRoleName"] as? String)!
                }
                else{
                    optionsString = "\(optionsString), \((element["jobRoleName"] as? String)!)"
                }
            }
            cell.filterOptionLbl.text = optionsString
            break
        case 4:
            cell.FilterNameLbl.text = "Speaking Languages"
            var optionsString = ""
            for (index, element) in InitializerHelper.sharedInstance.selectedSpeakingLanguage.enumerated() {
                if index == 0{
                    optionsString = (element["speakingLangName"] as? String)!
                }
                else{
                    optionsString = "\(optionsString), \((element["speakingLangName"] as? String)!)"
                }
            }
            cell.filterOptionLbl.text = optionsString
            break
        case 5:
            cell.FilterNameLbl.text = "Educational Qualifications"
            var optionsString = ""
            for (index, element) in InitializerHelper.sharedInstance.selectedEducationalQualification.enumerated() {
                if index == 0{
                    optionsString = (element["educationalQualificationName"] as? String)!
                }
                else{
                    optionsString = "\(optionsString), \((element["educationalQualificationName"] as? String)!)"
                }
            }
            cell.filterOptionLbl.text = optionsString
            break
        case 6:
            cell.FilterNameLbl.text = "Skills"
            var optionsString = ""
            for (index, element) in InitializerHelper.sharedInstance.selectedSkills.enumerated() {
                if index == 0{
                    optionsString = (element["primarySkillName"] as? String)!
                }
                else{
                    optionsString = "\(optionsString), \((element["primarySkillName"] as? String)!)"
                }
            }
            cell.filterOptionLbl.text = optionsString
            break
        case 7:
            cell.FilterNameLbl.text = "Hiring Location"
            var optionsString = ""
            for (index, element) in InitializerHelper.sharedInstance.selectedHiringLocation.enumerated() {
                if index == 0{
                    optionsString = (element["stateName"] as? String)!
                }
                else{
                    optionsString = "\(optionsString), \((element["stateName"] as? String)!)"
                }
            }
            cell.filterOptionLbl.text = optionsString
            break
        case 8:
            cell.FilterNameLbl.text = "Experience Ranges"
            var optionsString = ""
            for (index, element) in InitializerHelper.sharedInstance.selectedExperienceRange.enumerated() {
                if index == 0{
                    optionsString = (element["buttonText"] as? String)!
                }
                else{
                    optionsString = "\(optionsString) - \((element["buttonText"] as? String)!)"
                }
            }
            cell.filterOptionLbl.text = optionsString
            break
        case 9:
            cell.FilterNameLbl.text = "Age Range"
            var optionsString = ""
            for (index, element) in InitializerHelper.sharedInstance.selectedAgeRange.enumerated() {
                if index == 0{
                    optionsString = (element["buttonText"] as? String)!
                }
                else{
                    optionsString = "\(optionsString) - \((element["buttonText"] as? String)!)"
                }
            }
            cell.filterOptionLbl.text = optionsString
            break
        default:
            break
        }
        
        cell.editBtn.addTarget(self, action: #selector(FilterView.editBtnAction(_:)), for: .touchUpInside)
        cell.editBtn.tag = indexPath.row
        return cell
    }
    
    func editBtnAction(_ sender:UIButton){
        
        let index = sender.tag
        switch index {
        case 0:
            let popup = SingleSelectionSubFilterView.instansiateFromNib()
            popup.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            popup.fromView = self
            popup.dataArray = filterDict["genders"]?["options"] as? [AnyObject]
            popup.keyId = "genderID"
            popup.keyName = "genderName"
            popup.selectedArray = InitializerHelper.sharedInstance.selectedGender
            popup.index = sender.tag
            popup.filterDelegate = self
            self.addSubview(popup)
            popup.flipLeftPopup()
            break
        case 1:
            let popup = SingleSelectionSubFilterView.instansiateFromNib()
            popup.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            popup.fromView = self
            popup.minBudgetArray = filterDict["budgetRanges"]?["options"] as? [AnyObject]
            popup.keyId = "ctcBudgetRangetID"
            popup.keyName = "ctcBudgetFrom"
            popup.selectedArray = InitializerHelper.sharedInstance.selectedBudgetRange
            popup.index = sender.tag
            popup.filterDelegate = self
            self.addSubview(popup)
            popup.flipLeftPopup()
            break
        case 2:
            let popup = SubFilterView.instansiateFromNib()
            popup.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            popup.fromView = self
            popup.dataArray = filterDict["jobTypes"]?["options"] as? [AnyObject]
            popup.keyId = "jobTypeID"
            popup.keyName = "jobType"
            popup.selectedArray = InitializerHelper.sharedInstance.selectedJobTypes
            popup.index = sender.tag
            popup.filterDelegate = self
            self.addSubview(popup)
            popup.flipLeftPopup()
            break
        case 3:
            let popup = SubFilterView.instansiateFromNib()
            popup.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            popup.fromView = self
            popup.dataArray = filterDict["jobRoles"]?["options"] as? [AnyObject]
            popup.keyId = "jobRoleID"
            popup.keyName = "jobRoleName"
            popup.selectedArray = InitializerHelper.sharedInstance.selectedJobRoles
            popup.index = sender.tag
            popup.filterDelegate = self
            self.addSubview(popup)
            popup.flipLeftPopup()
            break
        case 4:
            let popup = SubFilterView.instansiateFromNib()
            popup.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            popup.fromView = self
            popup.dataArray = filterDict["speakingLanguages"]?["options"] as? [AnyObject]
            popup.keyId = "speakingLangID"
            popup.keyName = "speakingLangName"
            popup.selectedArray = InitializerHelper.sharedInstance.selectedSpeakingLanguage
            popup.index = sender.tag
            popup.filterDelegate = self
            self.addSubview(popup)
            popup.flipLeftPopup()
            break
        case 5:
            let popup = SubFilterView.instansiateFromNib()
            popup.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            popup.fromView = self
            popup.dataArray = filterDict["educationalQualifications"]?["options"] as? [AnyObject]
            popup.keyId = "educationalQualificationID"
            popup.keyName = "educationalQualificationName"
            popup.selectedArray = InitializerHelper.sharedInstance.selectedEducationalQualification
            popup.index = sender.tag
            popup.filterDelegate = self
            self.addSubview(popup)
            popup.flipLeftPopup()
            break
        case 6:
            let popup = SubFilterView.instansiateFromNib()
            popup.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            popup.fromView = self
            popup.dataArray = filterDict["skills"]?["options"] as? [AnyObject]
            popup.keyId = "primarySkillID"
            popup.keyName = "primarySkillName"
            popup.selectedArray = InitializerHelper.sharedInstance.selectedSkills
            popup.index = sender.tag
            popup.filterDelegate = self
            self.addSubview(popup)
            popup.flipLeftPopup()
            break
        case 7:
            let popup = SubFilterView.instansiateFromNib()
            popup.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            popup.fromView = self
            popup.dataArray = filterDict["hiringLocations"]?["options"] as? [AnyObject]
            popup.keyId = "stateID"
            popup.keyName = "stateName"
            popup.selectedArray = InitializerHelper.sharedInstance.selectedHiringLocation
            popup.index = sender.tag
            popup.filterDelegate = self
            self.addSubview(popup)
            popup.flipLeftPopup()
            break
        case 8:
            let popup = SingleSelectionSubFilterView.instansiateFromNib()
            popup.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            popup.fromView = self
            popup.dataArray = filterDict["experienceRanges"]?["options"] as? [AnyObject]
            popup.keyId = "expRangeID"
            popup.keyName = "buttonText"
            popup.selectedArray = InitializerHelper.sharedInstance.selectedExperienceRange
            popup.index = sender.tag
            popup.filterDelegate = self
            self.addSubview(popup)
            popup.flipLeftPopup()
            break
        case 9:
            let popup = SingleSelectionSubFilterView.instansiateFromNib()
            popup.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            popup.fromView = self
            popup.dataArray = filterDict["ageRanges"]?["options"] as? [AnyObject]
            popup.keyId = "ageRangeID"
            popup.keyName = "buttonText"
            popup.selectedArray = InitializerHelper.sharedInstance.selectedAgeRange
            popup.index = sender.tag
            popup.filterDelegate = self
            self.addSubview(popup)
            popup.flipLeftPopup()
            break
        default:
            break
        }
        
    }
    
}

//MARK: Tableview Delegates

extension FilterView:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableViewAutomaticDimension
    }
}

extension FilterView:SubFilterDelegate{
    func callBackWithDict(data:[String:AnyObject]){
        let index = data["index"] as! Int
        switch index {
        case 0:
            InitializerHelper.sharedInstance.selectedGender = data["selected"] as! [AnyObject]
            break
        case 1:
            InitializerHelper.sharedInstance.selectedBudgetRange = data["selected"] as! [AnyObject]
            break
        case 2:
            InitializerHelper.sharedInstance.selectedJobTypes = data["selected"] as! [AnyObject]
            break
        case 3:
            InitializerHelper.sharedInstance.selectedJobRoles = data["selected"] as! [AnyObject]
            break
        case 4:
            InitializerHelper.sharedInstance.selectedSpeakingLanguage = data["selected"] as! [AnyObject]
            break
        case 5:
            InitializerHelper.sharedInstance.selectedEducationalQualification = data["selected"] as! [AnyObject]
            break
        case 6:
            InitializerHelper.sharedInstance.selectedSkills = data["selected"] as! [AnyObject]
            break
        case 7:
            InitializerHelper.sharedInstance.selectedHiringLocation = data["selected"] as! [AnyObject]
            break
        case 8:
            InitializerHelper.sharedInstance.selectedExperienceRange = data["selected"] as! [AnyObject]
            break
        case 9:
            InitializerHelper.sharedInstance.selectedAgeRange = data["selected"] as! [AnyObject]
            break
        default:
            break
        }
        filterTable.reloadData()
    }
}
