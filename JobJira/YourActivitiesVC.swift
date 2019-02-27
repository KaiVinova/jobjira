//
//  YourActivitiesVC.swift
//  JobJira
//
//  Created by Vaibhav on 02/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
import KVNProgress
import Firebase

class YourActivitiesVC: UIViewController
{
    
//MARK:- IBOutlets

    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var activityTable: UITableView!
    @IBOutlet weak var selectionIndicatorView: UIView!
    @IBOutlet weak var appliedBtn: UIButton!
    @IBOutlet weak var skippedBtn: UIButton!
    @IBOutlet weak var savedBtn: UIButton!
    @IBOutlet weak var placeholderLbl: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var selectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectionViewLeadingConstraint: NSLayoutConstraint!
    
//MARK:- Variables and Constants
    
    var footerView:UIView!
    var appliedArray = [AnyObject]()
    var skippedArray = [AnyObject]()
    var savedArray = [AnyObject]()
    var selectedArray = [AnyObject]()
    var appliedIndex:Int!
    var skippedIndex:Int!
    var savedIndex:Int!
    var totalApplied:Int!
    var totalSkipped:Int!
    var totalSaved:Int!
    lazy var chatRef: FIRDatabaseReference = FIRDatabase.database().reference().child("jobseeker_chats").child((UserDefaults.standard.object(forKey: "firebaseInfo") as! [String:AnyObject])["jobSeekerID"] as! String)

//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        activityTable.tableFooterView = UIView()
        activityTable.estimatedRowHeight = 87
        appliedBtn.isSelected = true
        skippedBtn.isSelected = false
        savedBtn.isSelected = false
        self.placeholderLbl.isHidden = true
        getActivityData("1", index: "1")
        initLoadingView()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = true
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
//MARK:- Menu Button Action
    
    @IBAction func munuBtnAction(_ sender: Any)
    {
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            (drawerController.drawerViewController as! MenuViewController).tableView.reloadData()
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
//MARK:- Applied Button Action
    
    @IBAction func appliedBtnAction(_ sender: Any)
    {
        if !appliedBtn.isSelected
        {
                selectedArray = appliedArray
            UIView.animate(withDuration: 0.3, animations:
            { () -> Void in
                self.selectionViewLeadingConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            })
            { (suceess) -> Void in
            }
            var flag = ""
            if self.skippedBtn.isSelected
            {
                flag = "1"
            }
            if self.savedBtn.isSelected
            {
                flag = "2"
            }
            appliedBtn.isSelected = true
            skippedBtn.isSelected = false
            savedBtn.isSelected = false
            self.placeholderLbl.isHidden = true
            if appliedArray.count == 0
            {
                appliedIndex = 1
                self.getActivityData("1", index: "\(appliedIndex!)")
            }
            if flag == "1"
            {
                self.reloadAndAnimateTableLeft(self.activityTable)
            }
            if flag == "2"
            {
                self.reloadAndAnimateTableLeft(self.activityTable)
            }
        }
    }

//MARK:- Skipped Button Action
    
    @IBAction func skippedBtnAction(_ sender: Any)
    {
        if !skippedBtn.isSelected
        {
            selectedArray = skippedArray
            UIView.animate(withDuration: 0.3, animations:
            { () -> Void in
                self.selectionViewLeadingConstraint.constant = (self.stackView.frame.size.width/3)+1
                self.view.layoutIfNeeded()
            })
            { (suceess) -> Void in
                
            }
            var flag = ""
            if self.appliedBtn.isSelected
            {
                flag = "1"
            }
            if self.savedBtn.isSelected
            {
                flag = "2"
            }
            appliedBtn.isSelected = false
            skippedBtn.isSelected = true
            savedBtn.isSelected = false
            self.placeholderLbl.isHidden = true
            if skippedArray.count == 0
            {
                skippedIndex = 1
                self.getActivityData("2", index: "\(skippedIndex!)")
            }
            if flag == "1"
            {
                self.reloadAndAnimateTableRight(self.activityTable)
            }
            if flag == "2"
            {
                self.reloadAndAnimateTableLeft(self.activityTable)
            }
        }
    }
    
//MARK:- Saved Button Action
    
    @IBAction func savedBtnAction(_ sender: Any)
    {
        if !savedBtn.isSelected
        {
            selectedArray = savedArray
            UIView.animate(withDuration: 0.3, animations:
            { () -> Void in
                self.selectionViewLeadingConstraint.constant = (self.stackView.frame.size.width*2/3)+1
                self.view.layoutIfNeeded()
                
            })
            { (suceess) -> Void in
            }
            var flag = ""
            if self.appliedBtn.isSelected
            {
                flag = "1"
            }
            if self.skippedBtn.isSelected
            {
                flag = "2"
            }
            appliedBtn.isSelected = false
            skippedBtn.isSelected = false
            savedBtn.isSelected = true
            self.placeholderLbl.isHidden = true
            if savedArray.count == 0
            {
                savedIndex = 1
                self.getActivityData("3", index: "\(savedIndex!)")
            }
            if flag == "1"
            {
                self.reloadAndAnimateTableRight(self.activityTable)
            }
            if flag == "2"
            {
                self.reloadAndAnimateTableRight(self.activityTable)
            }
        }
    }
    
//MARK:- Table View Animation
    
    func reloadAndAnimateTableLeft(_ table:UITableView)
    {
        table.reloadData()
        let cells = table.visibleCells
        let tableWidth: CGFloat = table.bounds.size.width
        for i in cells
        {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: -tableWidth, y: 0)
        }
        var index = 0
        for a in cells
        {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations:
            {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            index += 1
        }
    }

    func reloadAndAnimateTableRight(_ table:UITableView)
    {
        table.reloadData()
        let cells = table.visibleCells
        let tableWidth: CGFloat = table.bounds.size.width
        for i in cells
        {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: tableWidth, y: 0)
        }
        var index = 0
        for a in cells
        {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations:
            {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            index += 1
        }
    }
    
//MARK:- Init. Loading View
    
    func initLoadingView()
    {
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40.0))
        let actInd = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        actInd.tag = 10
        actInd.frame = CGRect(x: (self.view.frame.size.width-20)/2, y: 10, width: 20, height: 20)
        actInd.hidesWhenStopped = true
        footerView.addSubview(actInd)
        activityTable.tableFooterView = footerView
    }
    
//MARK: - Get Card Data
    
    func getActivityData(_ actionId:String, index:String)
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        dict["pageNumber"] = index as AnyObject?
        dict["jobSeekerJobActionTypeID"] = actionId as AnyObject?
        if index == "1"
        {
            KVNProgress.show()
        }
        UserService.getCardDataWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                var jobs = data!["result"]?["jobs"]! as! [AnyObject]
                let paginationDict = data!["result"]?["pagination"]! as! [String:AnyObject]
                let activityCountArray = data!["result"]?["activityCount"]! as! [AnyObject]
                if activityCountArray.count>0
                {
                    self.totalApplied = Int(activityCountArray[0]["totalJobs"] as! String!)
                    self.appliedBtn.setTitle("Applied (\(self.totalApplied!))", for: .normal)
                    self.totalSkipped = Int(activityCountArray[1]["totalJobs"] as! String!)
                    self.skippedBtn.setTitle("Skipped (\(self.totalSkipped!))", for: .normal)
                    self.totalSaved = Int(activityCountArray[2]["totalJobs"] as! String!)
                    self.savedBtn.setTitle("Saved (\(self.totalSaved!))", for: .normal)
                }
                else
                {
                    self.appliedBtn.setTitle("Applied (0)", for: .normal)
                    self.skippedBtn.setTitle("Skipped (0)", for: .normal)
                    self.savedBtn.setTitle("Saved (0)", for: .normal)
                }
                print(data!["result"] as! [String:AnyObject])
                print(jobs)
                print(paginationDict)
                if self.appliedBtn.isSelected
                {
                    if index == "1"
                    {
                        self.appliedArray.append(contentsOf: jobs)
                    }
                    else
                    {
                        if jobs.count>0
                        {
                            if jobs[0]["groupTime"] as! Int == self.appliedArray.last?["groupTime"] as! Int{
                                var previousArray =  self.appliedArray.last?["jobs"] as! [AnyObject]
                                let nextArray =  jobs[0]["jobs"] as! [AnyObject]
                                previousArray.append(contentsOf: nextArray)
                                let groupTime = jobs[0]["groupTime"] as! Int
                                var newDict = [String:AnyObject]()
                                newDict["groupTime"] = groupTime as AnyObject?
                                newDict["jobs"] = previousArray as AnyObject?
                                self.appliedArray.removeLast()
                                jobs.removeFirst()
                                self.appliedArray.append(newDict as AnyObject)
                                self.appliedArray.append(contentsOf: jobs)
                            }
                            else
                            {
                                self.appliedArray.append(contentsOf: jobs)
                            }
                        }
                    }
                    self.selectedArray = self.appliedArray
                    self.appliedIndex = paginationDict["nextPageNumber"] as! Int!
                    self.activityTable.reloadData()
                }
                else if self.skippedBtn.isSelected
                {
                    if index == "1"
                    {
                        self.skippedArray.append(contentsOf: jobs)
                    }
                    else
                    {
                        if jobs.count>0
                        {
                            if jobs[0]["groupTime"] as! Int == self.skippedArray.last?["groupTime"] as! Int
                            {
                                var previousArray =  self.skippedArray.last?["jobs"] as! [AnyObject]
                                let nextArray =  jobs[0]["jobs"] as! [AnyObject]
                                previousArray.append(contentsOf: nextArray)
                                let groupTime = jobs[0]["groupTime"] as! Int
                                var newDict = [String:AnyObject]()
                                newDict["groupTime"] = groupTime as AnyObject?
                                newDict["jobs"] = previousArray as AnyObject?
                                self.skippedArray.removeLast()
                                jobs.removeFirst()
                                self.skippedArray.append(newDict as AnyObject)
                                self.skippedArray.append(contentsOf: jobs)
                            }
                            else
                            {
                                self.skippedArray.append(contentsOf: jobs)
                            }
                        }
                    }
                    self.selectedArray = self.skippedArray
                    self.skippedIndex = paginationDict["nextPageNumber"] as! Int!
                    self.activityTable.reloadData()
                }
                else if self.savedBtn.isSelected
                {
                    if index == "1"
                    {
                        self.savedArray.append(contentsOf: jobs)
                    }
                    else
                    {
                        if jobs.count>0
                        {
                            if jobs[0]["groupTime"] as! Int == self.savedArray.last?["groupTime"] as! Int
                            {
                                var previousArray =  self.savedArray.last?["jobs"] as! [AnyObject]
                                let nextArray =  jobs[0]["jobs"] as! [AnyObject]
                                previousArray.append(contentsOf: nextArray)
                                let groupTime = jobs[0]["groupTime"] as! Int
                                var newDict = [String:AnyObject]()
                                newDict["groupTime"] = groupTime as AnyObject?
                                newDict["jobs"] = previousArray as AnyObject?
                                self.savedArray.removeLast()
                                jobs.removeFirst()
                                self.savedArray.append(newDict as AnyObject)
                                self.savedArray.append(contentsOf: jobs)
                            }
                            else
                            {
                                self.savedArray.append(contentsOf: jobs)
                            }
                        }
                    }
                    self.selectedArray = self.savedArray
                    self.savedIndex = paginationDict["nextPageNumber"] as! Int!
                    self.activityTable.reloadData()
                }
                if self.appliedBtn.isSelected
                {
                    if self.appliedArray.count>0
                    {
                        self.placeholderLbl.isHidden = true
                    }
                    else
                    {
                        self.placeholderLbl.isHidden = false
                        self.placeholderLbl.text = "You have not applied for any job yet."
                    }
                }
                else if self.skippedBtn.isSelected
                {
                    if self.skippedArray.count>0
                    {
                        self.placeholderLbl.isHidden = true
                    }
                    else
                    {
                        self.placeholderLbl.isHidden = false
                        self.placeholderLbl.text = "You have not skipped any job yet."
                    }
                }
                else if self.savedBtn.isSelected
                {
                    if self.savedArray.count>0
                    {
                        self.placeholderLbl.isHidden = true
                    }
                    else
                    {
                        self.placeholderLbl.isHidden = false
                        self.placeholderLbl.text = "You have not saved any job yet."
                    }
                }
                let indicator = (self.footerView.viewWithTag(10) as! UIActivityIndicatorView)
                indicator.stopAnimating()
            }
            else
            {
                let alert = UIAlertController(title: AppName, message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
                if data != nil
                {
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        AppDelegate.shared.popAndLogout(self)
                    })
                    alert.addAction(action)
                }
                else
                {
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                }
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
// MARK: Firebase related methods
    
    func loginToFirebaseWithJwtToken(_ chatroomID:String, actionID:String)
    {
        KVNProgress.show()
        let fireBaseDict = UserDefaults.standard.object(forKey: "firebaseInfo") as! [String:AnyObject]
        if FIRAuth.auth()?.currentUser != nil
        {
            self.observeSingleResponse(chatroomID, actionID: actionID)
        }
        else
        {
            FIRAuth.auth()?.signIn(withCustomToken: fireBaseDict["jwtToken"] as! String, completion: { (user, error) in
                if error == nil
                {
                    print(user?.uid ?? "No ID")
                    self.observeSingleResponse(chatroomID, actionID: actionID)
                }
                else
                {
                    print(error?.localizedDescription ?? "No Value")
                    KVNProgress.dismiss()
                }
            })
        }
    }
    
    private func observeSingleResponse(_ chatroomID:String, actionID:String)
    {
        chatRef.child(chatroomID).queryOrdered(byChild: "jobseeker_chats").observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                let chatData = snapshot.value as! Dictionary<String, AnyObject>
                if let chatRoomID = chatData["chatRoomID"] as! String!, chatRoomID.characters.count > 0
                {
                    let chatRoomRef: FIRDatabaseReference = FIRDatabase.database().reference().child("chat_rooms")
                    chatRoomRef.queryOrderedByKey().queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value, with: { (snapshot1) in
                        if snapshot1.children.allObjects.count>0
                        {
                            let snapshotEmployer = snapshot1.children.allObjects[0] as! FIRDataSnapshot
                            let chatRoomData = snapshotEmployer.value as! Dictionary<String, AnyObject>
                            if let employerID = chatRoomData["employerID"] as! String!, employerID.characters.count > 0 {
                                let employerRef: FIRDatabaseReference = FIRDatabase.database().reference().child("employers")
                                employerRef.queryOrderedByKey().queryEqual(toValue: employerID).observeSingleEvent(of: .value, with:
                                    { (snapshot2) in
                                    if snapshot2.children.allObjects.count>0
                                    {
                                        let snapshotEmployer = snapshot2.children.allObjects[0] as! FIRDataSnapshot
                                        let employerData = snapshotEmployer.value as! Dictionary<String, AnyObject>
                                        if let companyName = employerData["companyName"] as! String!, companyName.characters.count > 0
                                        {
                                            if let jobID = chatRoomData["jobID"] as! String!, jobID.characters.count > 0
                                            {
                                                let jobRef: FIRDatabaseReference = FIRDatabase.database().reference().child("jobs")
                                                jobRef.queryOrderedByKey().queryEqual(toValue: jobID).observeSingleEvent(of: .value, with:
                                                    { (snapshot3) in
                                                    if snapshot3.children.allObjects.count>0
                                                    {
                                                        let snapshotJob = snapshot3.children.allObjects[0] as! FIRDataSnapshot
                                                        let jobData = snapshotJob.value as! Dictionary<String, AnyObject>
                                                        if let jobName = jobData["title"] as! String!, jobName.characters.count > 0
                                                        {
                                                            KVNProgress.dismiss()
                                                            let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
                                                            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "MessagingVC") as! MessagingVC
                                                            viewcontroller.senderDisplayName = "Testing"
                                                            viewcontroller.chat = Chats(chatRoomID: chatData["chatRoomID"] as! String, lastMessage: chatData["lastMessage"] as! String, upadtedTime: chatData["updatedTime"] as! Int, jobAppliedTime: chatRoomData["jobAppliedTime"] as! String, jobPostedTime: chatRoomData["jobPostedTime"] as! String, isClosed: chatRoomData["isClosed"] as! String, companyName: employerData["companyName"] as! String, lastOnline: employerData["lastOnline"] as! String, name: employerData["name"] as! String, online: employerData["online"] as! String, profilePicture: employerData["profilePicture"] as! String, isRemoved: jobData["isRemoved"] as! String, employerID: employerData["employerID"] as! String, title: jobData["title"] as! String, jobSeekerID: chatRoomData["jobSeekerID"] as! String, employerJobActionTypeID: chatRoomData["isClosed"] as! String, jobStatus: jobData["jobStatus"] as! String)
                                                            viewcontroller.chatRef = FIRDatabase.database().reference().child("chats").child(chatData["chatRoomID"] as! String)
                                                            let navController = UINavigationController(rootViewController: viewcontroller)
                                                            self.present(navController, animated: true, completion: nil)
                                                        }
                                                    }
                                                }, withCancel:
                                                { (error2) in
                                                    print(error2.localizedDescription)
                                                    KVNProgress.dismiss()
                                                })
                                            }
                                            else
                                            {
                                                print("Error! Could not decode channel data")
                                                KVNProgress.dismiss()
                                            }
                                        }
                                    }
                                }, withCancel:
                                { (error2) in
                                    print(error2.localizedDescription)
                                    KVNProgress.dismiss()
                                })
                            }
                            else
                            {
                                print("Error! Could not decode channel data")
                                KVNProgress.dismiss()
                            }
                        }
                    }, withCancel:
                    { (error1) in
                        print(error1.localizedDescription)
                        KVNProgress.dismiss()
                    })
                }
                else
                {
                    print("Error! Could not decode channel data")
                    KVNProgress.dismiss()
                }
            KVNProgress.dismiss()
        }, withCancel:
        { (error) in
            print(error.localizedDescription)
            KVNProgress.dismiss()
        })
    }
}

//MARK:- Extension UITableViewDelegate

extension YourActivitiesVC:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 30
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        var headerDict = [String:AnyObject]()
        headerDict = (selectedArray[section] as? [String:AnyObject])!
        let headerView = HeaderView.instansiateFromNib()
        headerView.backgroundColor = UIColor(red: 241.0/255.0, green: 242.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        headerView.headerLbl.isHidden = true
        if section == 0
        {
            headerView.headerLbl.isHidden = false
            if appliedBtn.isSelected
            {
                headerView.headerLbl.text = "Applied Jobs"
            }
            else if skippedBtn.isSelected
            {
                headerView.headerLbl.text = "Skipped Jobs"
            }
            else if savedBtn.isSelected
            {
                headerView.headerLbl.text = "Saved Jobs"
            }
        }
        headerView.dateLbl.text = ("\((headerDict["groupTime"] as? Int)!)").timeStampToDateString((headerDict["groupTime"] as? Int)!, format: "MMMM dd, yyyy")
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        var tempArray = [AnyObject]()
        tempArray = (selectedArray[indexPath.section]["jobs"] as? [AnyObject])!
        let tempDict = tempArray[indexPath.row] as? [String:AnyObject]
        if tempDict?["jobStatus"] as? String != "2"
        {
            let alert = UIAlertController(title: AppName, message: "Job is closed now", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "JobDetailVC") as! JobDetailVC
            viewcontroller.actionDelegate = self
            viewcontroller.fromScreen = "activity"
            viewcontroller.jobID = tempDict?["jobID"] as! String
            viewcontroller.jobActiveId = tempDict?["jobStatus"] as? String
            viewcontroller.employerResponseId = tempDict?["employerJobActionTypeID"] as? String
            viewcontroller.userActionId = tempDict?["jobSeekerJobActionTypeID"] as? String
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        }
    }
}

//MARK:- Extension UITableViewDataSource

extension YourActivitiesVC:UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return selectedArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ((selectedArray[section]["jobs"] as? [AnyObject])?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YourActivitiesCell", for: indexPath) as! YourActivitiesCell
        cell.selectionStyle = .none
        var tempArray = [AnyObject]()
        tempArray = (selectedArray[indexPath.section]["jobs"] as? [AnyObject])!
        let tempDict = tempArray[indexPath.row] as? [String:AnyObject]
        if tempDict?["profilePicture"] as? String != ""
        {
            cell.companyImage.setImageWith(URL(string:(tempDict?["profilePicture"] as? String)!)!, placeholderImage: UIImage(named: "plus"))
        }
        else
        {
            cell.companyImage.image = UIImage(named: "plus")
        }
        cell.designationLbl.text = tempDict?["title"] as? String
        cell.comanyNameLbl.text = tempDict?["companyName"] as? String
        let timeStamp = Int((tempDict?["actionTakenTime"] as? String)!)
        cell.timeLbl.text = ("Posted: \((tempDict?["actionTakenTime"] as? String)!.timeStampToDateString(timeStamp!, format: "MMM dd, yyyy"))")
        cell.statusView.layer.cornerRadius = 4.0
        cell.statusView.clipsToBounds = true
        switch (tempDict?["jobSeekerJobActionTypeID"] as? String)!
        {
            case "1":
                cell.statusView.isHidden = false
                cell.companyTrailingConstant.constant = 5
                cell.designationTrailingConstant.constant = 5
                break
            default:
                cell.statusView.isHidden = true
                cell.companyTrailingConstant.constant = -cell.statusView.frame.size.width
                cell.designationTrailingConstant.constant = -cell.statusView.frame.size.width
                break
        }
        switch (tempDict?["employerJobActionTypeID"] as? String)!
        {
            case "1":
                cell.statusIcon.image = UIImage(named: "waiting")
                cell.statusLbl.text = "Awaiting Review"
                break
            case "2":
                cell.statusIcon.image = UIImage(named: "chat_cell")
                cell.statusLbl.text = "Chat"
                break
            case "3":
                cell.statusIcon.image = UIImage(named: "declined")
                cell.statusLbl.text = "Declined"
                break
            default:
                break
        }
        switch (tempDict?["jobStatus"] as? String)!
        {
            case "2":
                cell.containerView.alpha = 1.0
                break
            default:
                cell.containerView.alpha = 0.5
                break
        }
        cell.statusBtn.addTarget(self, action: #selector(YourActivitiesVC.statusBtnAction(_:)), for: .touchUpInside)
        cell.statusBtn.tag = indexPath.row*1000+indexPath.section
        cell.companyProfileBtn.addTarget(self, action: #selector(YourActivitiesVC.companyProfileBtnAction(_:)), for: .touchUpInside)
        cell.companyProfileBtn.tag = indexPath.row*1000+indexPath.section
        return cell
    }
    
//MARK:- Status Button Action
    
    func statusBtnAction(_ sender:UIButton)
    {
        let section = sender.tag%1000
        let row = sender.tag/1000
        print("section \(section), row \(row)")
        var tempArray = [AnyObject]()
        tempArray = (selectedArray[section]["jobs"] as? [AnyObject])!
        let tempDict = tempArray[row] as? [String:AnyObject]
        switch (tempDict?["jobStatus"] as? String)!
        {
        case "2":
            switch (tempDict?["employerJobActionTypeID"] as? String)!
            {
                case "1":
                    break
                case "2":
                    loginToFirebaseWithJwtToken((tempDict?["jobSeekerJobActionID"] as? String)!, actionID: "2")
                    break
                case "3","4":
                    let alert = UIAlertController(title: AppName, message: "Job has been closed or declined by employer", preferredStyle: UIAlertControllerStyle.alert)
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    break
                default:
                    break
            }
            break
        default:
                break
        }
    }
    
//MARK:- Company profile Button Action
    
    func companyProfileBtnAction(_ sender:UIButton)
    {
        let section = sender.tag%1000
        let row = sender.tag/1000
        print("section \(section), row \(row)")
        let alert = UIAlertController(title: AppName, message: "Under Development!", preferredStyle: UIAlertControllerStyle.alert)
        let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        return
    }
    
//MARK:- Method for Make Section Rounded Corner
    
    func makeSectionRoundedCorner(_ tableView:UITableView, cell1:UITableViewCell, indexPath:IndexPath)
    {
        let cell = cell1 as! YourActivitiesCell
        if (cell.responds(to: #selector(getter: UIView.tintColor)))
        {
            if (tableView == self.activityTable)
            {
                let cornerRadius : CGFloat = 12.0
                cell.containerView.backgroundColor = UIColor.white
                let layer: CAShapeLayer = CAShapeLayer()
                let pathRef:CGMutablePath = CGMutablePath()
                let bounds: CGRect = cell.bounds.insetBy(dx: 0, dy: 0)
                var addLine: Bool = false
                if (indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1)
                {
                    pathRef.__addRoundedRect(transform: nil, rect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
                }
                else if (indexPath.row == 0)
                {
                    pathRef.move(to: CGPoint(x: CGFloat(bounds.minX), y: CGFloat(bounds.maxY)), transform: .identity)
                    pathRef.addArc(tangent1End: CGPoint(x: CGFloat(bounds.minX), y: CGFloat(bounds.minY)), tangent2End: CGPoint(x: CGFloat(bounds.midX), y: CGFloat(bounds.minY)), radius: cornerRadius, transform: .identity)
                    pathRef.addArc(tangent1End: CGPoint(x: CGFloat(bounds.maxX), y: CGFloat(bounds.minY)), tangent2End: CGPoint(x: CGFloat(bounds.maxX), y: CGFloat(bounds.midY)), radius: cornerRadius, transform: .identity)
                    pathRef.addLine(to: CGPoint(x: CGFloat(bounds.maxX), y: CGFloat(bounds.maxY)), transform: .identity)
                    addLine = true
                }
                else if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1)
                {
                    pathRef.move(to: CGPoint(x: CGFloat(bounds.minX), y: CGFloat(bounds.minY)), transform: .identity)
                    pathRef.addArc(tangent1End: CGPoint(x: CGFloat(bounds.minX), y: CGFloat(bounds.maxY)), tangent2End: CGPoint(x: CGFloat(bounds.midX), y: CGFloat(bounds.maxY)), radius: cornerRadius, transform: .identity)
                    pathRef.addArc(tangent1End: CGPoint(x: CGFloat(bounds.maxX), y: CGFloat(bounds.maxY)), tangent2End: CGPoint(x: CGFloat(bounds.maxX), y: CGFloat(bounds.midY)), radius: cornerRadius, transform: .identity)
                }
                else
                {
                    pathRef.addRect(bounds)
                    addLine = true
                }
                layer.path = pathRef
                layer.fillColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.8).cgColor
                if (addLine == true)
                {
                    let lineLayer: CALayer = CALayer()
                    let lineHeight: CGFloat = (1.0 / UIScreen.main.scale)
                    lineLayer.frame = CGRect(x: bounds.minX+10, y: bounds.size.height-lineHeight, width: bounds.size.width-10, height: lineHeight)
                    lineLayer.backgroundColor = tableView.separatorColor?.cgColor
                    layer.addSublayer(lineLayer)
                }
                let testView: UIView = UIView(frame: bounds)
                testView.layer.insertSublayer(layer, at: 0)
                testView.backgroundColor = UIColor.clear
                cell.containerView = testView
            }
        }
    }
}

//MARK:- Extension UIScrollViewDelegate

extension YourActivitiesVC:UIScrollViewDelegate
{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let offset = scrollView.contentOffset
        let  bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y: Float = Float(offset.y) + Float(bounds.size.height) + Float(inset.bottom)
        let height: Float = Float(size.height)
        let distance: Float = 0
        if y >= height + distance
        {
            let indicator = (footerView.viewWithTag(10) as! UIActivityIndicatorView)
            if appliedBtn.isSelected
            {
                if appliedArray.count>0
                {
                    if appliedIndex != 0
                    {
                        if appliedIndex == nil
                        {
                            appliedIndex = 1
                        }
                        self.getActivityData("1", index: "\(appliedIndex!)")
                        indicator.startAnimating()
                    }
                }
            }
            else if skippedBtn.isSelected
            {
                if skippedArray.count>0
                {
                    if skippedIndex != 0
                    {
                        if skippedIndex == nil
                        {
                            skippedIndex = 1
                        }
                        self.getActivityData("2", index: "\(skippedIndex!)")
                        indicator.startAnimating()
                    }
                }
            }
            if savedBtn.isSelected
            {
                if savedArray.count>0
                {
                    if savedIndex != 0
                    {
                        if savedIndex == nil
                        {
                            savedIndex = 1
                        }
                        self.getActivityData("3", index: "\(savedIndex!)")
                        indicator.startAnimating()
                    }
                }
            }
        }
    }
}

//MARK:- Extension JobDetailDelegate

extension YourActivitiesVC:JobDetailDelegate
{
    func callBackWithAction(_ status:String)
    {
        self.appliedArray = [AnyObject]()
        self.appliedIndex = 1
        self.skippedArray = [AnyObject]()
        self.skippedIndex = 1
        self.savedArray = [AnyObject]()
        self.savedIndex = 1
        if appliedBtn.isSelected
        {
            self.getActivityData("1", index: "\(appliedIndex!)")
        }
        else if skippedBtn.isSelected
        {
            self.getActivityData("2", index: "\(skippedIndex!)")
        }
        if savedBtn.isSelected
        {
            self.getActivityData("3", index: "\(savedIndex!)")
        }
        self.activityTable.reloadData()
    }
}
