//
//  ChatListVC.swift
//  JobJira
//
//  Created by Vaibhav on 12/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit
import KYDrawerController
import Firebase
import KVNProgress
import Shimmer
class ChatListVC: UIViewController
{
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var segementView: UISegmentedControl!
    @IBOutlet weak var placeholderLbl: UILabel!
    
    var fromScreen:String!
    var activeChats: [Chats] = []
    var archivedChats: [Chats] = []
    var placeholderLoading:Bool = true
    lazy var chatRef: FIRDatabaseReference = FIRDatabase.database().reference().child("jobseeker_chats").child((UserDefaults.standard.object(forKey: "firebaseInfo") as! [String:AnyObject])["jobSeekerID"] as! String)
    private var channelRefHandle: FIRDatabaseHandle?
    
    //MARK:- View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.screenEdgePanGestureEnabled = false
        }
        segementView.isEnabled = false
        self.chatTable.isScrollEnabled = false
        chatTable.estimatedRowHeight = 100
        chatTable.tableFooterView = UIView()
        self.segementView.layer.borderColor = OrangeColor.cgColor
        self.segementView.tintColor = OrangeColor
        placeholderLbl.isHidden = true
        chatTable.reloadData()
        loginToFirebaseWithJwtToken()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Method for loggong in to thr firebase
    
    func loginToFirebaseWithJwtToken(){
        let fireBaseDict = UserDefaults.standard.object(forKey: "firebaseInfo") as! [String:AnyObject]
        if FIRAuth.auth()?.currentUser != nil{
            self.observeSingleResponse()
            self.observeRegularly()
        }
        else{
            FIRAuth.auth()?.signIn(withCustomToken: fireBaseDict["jwtToken"] as! String, completion: { (user, error) in
                if error == nil{
                    print(user?.uid ?? "No ID")
                    self.observeSingleResponse()
                    self.observeRegularly()
                }
                else{
                    print(error?.localizedDescription ?? "No Value")
                }
            })
        }
    }
    
    deinit {
        if let refHandle = channelRefHandle {
            chatRef.removeObserver(withHandle: refHandle)
        }
    }
    
    //MARK:- Firebase observer for any change in firebase DB
    
    private func observeRegularly(){
        channelRefHandle = chatRef.queryOrdered(byChild: "jobseeker_chats").observe(.childChanged, with: { (snapshot) in
            let chatData = snapshot.value as! Dictionary<String, AnyObject>
            if let chatRoomID = chatData["chatRoomID"] as! String!, chatRoomID.characters.count > 0 {
                let chatRoomRef: FIRDatabaseReference = FIRDatabase.database().reference().child("chat_rooms")
                chatRoomRef.queryOrderedByKey().queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value, with: { (snapshot1) in
                    if snapshot1.children.allObjects.count>0{
                        let snapshotEmployer = snapshot1.children.allObjects[0] as! FIRDataSnapshot
                        let chatRoomData = snapshotEmployer.value as! Dictionary<String, AnyObject>
                        if let employerID = chatRoomData["employerID"] as! String!, employerID.characters.count > 0 {
                            let employerRef: FIRDatabaseReference = FIRDatabase.database().reference().child("employers")
                            employerRef.queryOrderedByKey().queryEqual(toValue: employerID).observeSingleEvent(of: .value, with: { (snapshot2) in
                                if snapshot2.children.allObjects.count>0{
                                    let snapshotEmployer = snapshot2.children.allObjects[0] as! FIRDataSnapshot
                                    let employerData = snapshotEmployer.value as! Dictionary<String, AnyObject>
                                    if let companyName = employerData["companyName"] as! String!, companyName.characters.count > 0 {
                                        if let jobID = chatRoomData["jobID"] as! String!, jobID.characters.count > 0 {
                                            let jobRef: FIRDatabaseReference = FIRDatabase.database().reference().child("jobs")
                                            jobRef.queryOrderedByKey().queryEqual(toValue: jobID).observeSingleEvent(of: .value, with: { (snapshot3) in
                                                if snapshot3.children.allObjects.count>0{
                                                    let snapshotJob = snapshot3.children.allObjects[0] as! FIRDataSnapshot
                                                    let jobData = snapshotJob.value as! Dictionary<String, AnyObject>
                                                    if let jobName = jobData["title"] as! String!, jobName.characters.count > 0 {
                                                        if chatRoomData["isClosed"] as! String == "0" && jobData["jobStatus"] as! String == "2"{
                                                            for (index,item) in self.activeChats.enumerated(){
                                                                if item.chatRoomID == chatData["chatRoomID"] as! String{
                                                                    self.activeChats.remove(at: index)
                                                                    let indexPath = IndexPath(row: index, section: 0)
                                                                    self.chatTable.deleteRows(at: [indexPath], with: .bottom)
                                                                    break
                                                                }
                                                            }
                                                            if self.activeChats.count>0{
                                                                self.activeChats.insert(Chats(chatRoomID: chatData["chatRoomID"] as! String, lastMessage: chatData["lastMessage"] as! String, upadtedTime: chatData["updatedTime"] as! Int, jobAppliedTime: chatRoomData["jobAppliedTime"] as! String, jobPostedTime: chatRoomData["jobPostedTime"] as! String, isClosed: chatRoomData["isClosed"] as! String, companyName: employerData["companyName"] as! String, lastOnline: employerData["lastOnline"] as! String, name: employerData["name"] as! String, online: employerData["online"] as! String, profilePicture: employerData["profilePicture"] as! String, isRemoved: jobData["isRemoved"] as! String, employerID: employerData["employerID"] as! String, title: jobData["title"] as! String, jobSeekerID: chatRoomData["jobSeekerID"] as! String, employerJobActionTypeID: chatRoomData["isClosed"] as! String, jobStatus: jobData["jobStatus"] as! String), at: 0)
                                                            }
                                                            else{
                                                                self.activeChats.append(Chats(chatRoomID: chatData["chatRoomID"] as! String, lastMessage: chatData["lastMessage"] as! String, upadtedTime: chatData["updatedTime"] as! Int, jobAppliedTime: chatRoomData["jobAppliedTime"] as! String, jobPostedTime: chatRoomData["jobPostedTime"] as! String, isClosed: chatRoomData["isClosed"] as! String, companyName: employerData["companyName"] as! String, lastOnline: employerData["lastOnline"] as! String, name: employerData["name"] as! String, online: employerData["online"] as! String, profilePicture: employerData["profilePicture"] as! String, isRemoved: jobData["isRemoved"] as! String, employerID: employerData["employerID"] as! String, title: jobData["title"] as! String, jobSeekerID: chatRoomData["jobSeekerID"] as! String, employerJobActionTypeID: chatRoomData["isClosed"] as! String, jobStatus: jobData["jobStatus"] as! String))
                                                            }
                                                            self.placeholderLoading = false
                                                            self.segementView.isEnabled = true
                                                            self.chatTable.isScrollEnabled = true
                                                            self.chatTable.reloadData()
                                                            
                                                        }
                                                        else{
                                                            for (index,item) in self.archivedChats.enumerated(){
                                                                if item.chatRoomID == chatData["chatRoomID"] as! String{
                                                                    self.archivedChats.remove(at: index)
                                                                    let indexPath = IndexPath(row: index, section: 0)
                                                                    self.chatTable.deleteRows(at: [indexPath], with: .bottom)
                                                                    break
                                                                }
                                                            }
                                                            if self.archivedChats.count>0{
                                                                self.archivedChats.insert(Chats(chatRoomID: chatData["chatRoomID"] as! String, lastMessage: chatData["lastMessage"] as! String, upadtedTime: chatData["updatedTime"] as! Int, jobAppliedTime: chatRoomData["jobAppliedTime"] as! String, jobPostedTime: chatRoomData["jobPostedTime"] as! String, isClosed: chatRoomData["isClosed"] as! String, companyName: employerData["companyName"] as! String, lastOnline: employerData["lastOnline"] as! String, name: employerData["name"] as! String, online: employerData["online"] as! String, profilePicture: employerData["profilePicture"] as! String, isRemoved: jobData["isRemoved"] as! String, employerID: employerData["employerID"] as! String, title: jobData["title"] as! String, jobSeekerID: chatRoomData["jobSeekerID"] as! String, employerJobActionTypeID: chatRoomData["employerJobActionTypeID"] as! String, jobStatus: jobData["jobStatus"] as! String), at: 0)
                                                            }
                                                            else{
                                                                self.archivedChats.append(Chats(chatRoomID: chatData["chatRoomID"] as! String, lastMessage: chatData["lastMessage"] as! String, upadtedTime: chatData["updatedTime"] as! Int, jobAppliedTime: chatRoomData["jobAppliedTime"] as! String, jobPostedTime: chatRoomData["jobPostedTime"] as! String, isClosed: chatRoomData["isClosed"] as! String, companyName: employerData["companyName"] as! String, lastOnline: employerData["lastOnline"] as! String, name: employerData["name"] as! String, online: employerData["online"] as! String, profilePicture: employerData["profilePicture"] as! String, isRemoved: jobData["isRemoved"] as! String, employerID: employerData["employerID"] as! String, title: jobData["title"] as! String, jobSeekerID: chatRoomData["jobSeekerID"] as! String, employerJobActionTypeID: chatRoomData["employerJobActionTypeID"] as! String, jobStatus: jobData["jobStatus"] as! String))
                                                            }
                                                            self.placeholderLoading = false
                                                            self.segementView.isEnabled = true
                                                            self.chatTable.isScrollEnabled = true
                                                            self.chatTable.reloadData()
                                                        }
                                                        self.checkObjectCount()
                                                    }
                                                }
                                            }, withCancel: { (error2) in
                                                print(error2.localizedDescription)
                                            })
                                        }
                                        else{
                                            print("Error! Could not decode channel data")
                                        }
                                    }
                                }
                                
                            }, withCancel: { (error2) in
                                print(error2.localizedDescription)
                            })
                        }
                        else{
                            print("Error! Could not decode channel data")
                        }
                    }
                    
                    
                }, withCancel: { (error1) in
                    print(error1.localizedDescription)
                })
            } else {
                print("Error! Could not decode channel data")
            }
        }, withCancel: { (error) in
            print(error.localizedDescription)
        })
    }
    
    // MARK: Firebase observer for getting chat list
    private func observeSingleResponse() {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        chatRef.queryOrdered(byChild: "jobseeker_chats").observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            self.activeChats.removeAll()
            self.archivedChats.removeAll()
            if snapshot.children.allObjects.count>0{
                for element in snapshot.children.allObjects{
                    let snapshotChat = element as! FIRDataSnapshot
                    let chatData = snapshotChat.value as! Dictionary<String, AnyObject>
                    if let chatRoomID = chatData["chatRoomID"] as! String!, chatRoomID.characters.count > 0 {
                        let chatRoomRef: FIRDatabaseReference = FIRDatabase.database().reference().child("chat_rooms")
                        chatRoomRef.queryOrderedByKey().queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value, with: { (snapshot1) in
                            if snapshot1.children.allObjects.count>0{
                                let snapshotEmployer = snapshot1.children.allObjects[0] as! FIRDataSnapshot
                                let chatRoomData = snapshotEmployer.value as! Dictionary<String, AnyObject>
                                if let employerID = chatRoomData["employerID"] as! String!, employerID.characters.count > 0 {
                                    let employerRef: FIRDatabaseReference = FIRDatabase.database().reference().child("employers")
                                    employerRef.queryOrderedByKey().queryEqual(toValue: employerID).observeSingleEvent(of: .value, with: { (snapshot2) in
                                        if snapshot2.children.allObjects.count>0{
                                            let snapshotEmployer = snapshot2.children.allObjects[0] as! FIRDataSnapshot
                                            let employerData = snapshotEmployer.value as! Dictionary<String, AnyObject>
                                            if let companyName = employerData["companyName"] as! String!, companyName.characters.count > 0 {
                                                if let jobID = chatRoomData["jobID"] as! String!, jobID.characters.count > 0 {
                                                    let jobRef: FIRDatabaseReference = FIRDatabase.database().reference().child("jobs")
                                                    jobRef.queryOrderedByKey().queryEqual(toValue: jobID).observeSingleEvent(of: .value, with: { (snapshot3) in
                                                        if snapshot3.children.allObjects.count>0{
                                                            let snapshotJob = snapshot3.children.allObjects[0] as! FIRDataSnapshot
                                                            let jobData = snapshotJob.value as! Dictionary<String, AnyObject>
                                                            if let jobName = jobData["title"] as! String!, jobName.characters.count > 0 {
                                                                
                                                                if chatRoomData["isClosed"] as! String == "0" && jobData["jobStatus"] as! String == "2"{
                                                                    
                                                                    self.activeChats.append(Chats(chatRoomID: chatData["chatRoomID"] as! String, lastMessage: chatData["lastMessage"] as! String, upadtedTime: chatData["updatedTime"] as! Int, jobAppliedTime: chatRoomData["jobAppliedTime"] as! String, jobPostedTime: chatRoomData["jobPostedTime"] as! String, isClosed: chatRoomData["isClosed"] as! String, companyName: employerData["companyName"] as! String, lastOnline: employerData["lastOnline"] as! String, name: employerData["name"] as! String, online: employerData["online"] as! String, profilePicture: employerData["profilePicture"] as! String, isRemoved: jobData["isRemoved"] as! String, employerID: employerData["employerID"] as! String, title: jobData["title"] as! String, jobSeekerID: chatRoomData["jobSeekerID"] as! String, employerJobActionTypeID: chatRoomData["employerJobActionTypeID"] as! String, jobStatus: jobData["jobStatus"] as! String))
                                                                    if self.activeChats.count>1{
                                                                        self.activeChats.sort(by: {$0.upadtedTime < $1.upadtedTime})
                                                                    }
                                                                    self.placeholderLoading = false
                                                                    self.segementView.isEnabled = true
                                                                    self.chatTable.isScrollEnabled = true
                                                                    self.chatTable.reloadData()
                                                                }
                                                                else{
                                                                    self.archivedChats.append(Chats(chatRoomID: chatData["chatRoomID"] as! String, lastMessage: chatData["lastMessage"] as! String, upadtedTime: chatData["updatedTime"] as! Int, jobAppliedTime: chatRoomData["jobAppliedTime"] as! String, jobPostedTime: chatRoomData["jobPostedTime"] as! String, isClosed: chatRoomData["isClosed"] as! String, companyName: employerData["companyName"] as! String, lastOnline: employerData["lastOnline"] as! String, name: employerData["name"] as! String, online: employerData["online"] as! String, profilePicture: employerData["profilePicture"] as! String, isRemoved: jobData["isRemoved"] as! String, employerID: employerData["employerID"] as! String, title: jobData["title"] as! String, jobSeekerID: chatRoomData["jobSeekerID"] as! String, employerJobActionTypeID: chatRoomData["employerJobActionTypeID"] as! String, jobStatus: jobData["jobStatus"] as! String))
                                                                    if self.archivedChats.count>1{
                                                                        self.archivedChats.sort(by: {$0.upadtedTime < $1.upadtedTime})
                                                                    }
                                                                    self.placeholderLoading = false
                                                                    self.segementView.isEnabled = true
                                                                    self.chatTable.isScrollEnabled = true
                                                                    self.chatTable.reloadData()
                                                                }
                                                                self.checkObjectCount()
                                                            }
                                                        }
                                                    }, withCancel: { (error2) in
                                                        print(error2.localizedDescription)
                                                    })
                                                }
                                                else{
                                                    print("Error! Could not decode channel data")
                                                }
                                            }
                                        }
                                        
                                    }, withCancel: { (error2) in
                                        print(error2.localizedDescription)
                                    })
                                }
                                else{
                                    print("Error! Could not decode channel data")
                                }
                            }
                            
                            
                        }, withCancel: { (error1) in
                            print(error1.localizedDescription)
                        })
                    } else {
                        print("Error! Could not decode channel data")
                        KVNProgress.dismiss()
                    }
                }
            }
            else{
                self.placeholderLoading = false
                self.segementView.isEnabled = true
                self.chatTable.isScrollEnabled = true
                self.chatTable.reloadData()
                self.checkObjectCount()
            }
        }, withCancel: { (error) in
            print(error.localizedDescription)
            KVNProgress.dismiss()
        })
    }
    
    //MARK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Home Button Action
    
    @IBAction func homeBtnAction(_ sender: Any) {
        if fromScreen == "home" {
            _ = self.navigationController?.popViewController(animated: true)
        }
        else{
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "LandingVC") as! LandingVC
            if let drawerController = self.parent?.parent as? KYDrawerController {
                if let nav = drawerController.childViewControllers[0] as? UINavigationController{
                    nav.setViewControllers([viewController], animated: true)
                }
            }
        }
    }
    
    //MARK:- Segement control Action
    
    @IBAction func segmentSelected(_ sender: Any) {
        switch segementView.selectedSegmentIndex
        {
        case 0:
            reloadAndAnimateTableLeft(chatTable)
            checkObjectCount()
            break
        case 1:
            reloadAndAnimateTableRight(chatTable)
            checkObjectCount()
            break
        default:
            break;
        }
    }
    
    //MARK:- Method for checking count of object in chat list array
    
    func checkObjectCount(){
        switch segementView.selectedSegmentIndex
        {
        case 0:
            if activeChats.count>0 {
                placeholderLbl.isHidden = true
            }
            else{
                placeholderLbl.isHidden = false
            }
            break
        case 1:
            if archivedChats.count>0 {
                placeholderLbl.isHidden = true
            }
            else{
                placeholderLbl.isHidden = false
            }
            break
        default:
            break;
        }
    }
    
    //MARK:- Methods for reloading table
    
    func reloadAndAnimateTableLeft(_ table:UITableView) {
        table.reloadData()
        
        let cells = table.visibleCells
        let tableWidth: CGFloat = table.bounds.size.width
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: -tableWidth, y: 0)
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

//MARK:- TableView Delegate

extension ChatListVC:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if placeholderLoading {
            return 80
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        if placeholderLoading {
            return
        }
        if segementView.selectedSegmentIndex == 0 {
            let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "MessagingVC") as! MessagingVC
            viewcontroller.senderDisplayName = "Testing"
            viewcontroller.chat = activeChats[indexPath.row]
            viewcontroller.chatRef = FIRDatabase.database().reference().child("chats").child(activeChats[indexPath.row].chatRoomID)
            let navController = UINavigationController(rootViewController: viewcontroller)
            self.present(navController, animated: true, completion: nil)
        }
        else{
            let storyBoard = UIStoryboard(name: "Menu", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "MessagingVC") as! MessagingVC
            viewcontroller.senderDisplayName = "Testing"
            viewcontroller.chat = archivedChats[indexPath.row]
            viewcontroller.chatRef = FIRDatabase.database().reference().child("chats").child(archivedChats[indexPath.row].chatRoomID)
            let navController = UINavigationController(rootViewController: viewcontroller)
            self.present(navController, animated: true, completion: nil)
        }
    }
}

//MARK:- TableView Datasource

extension ChatListVC:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if placeholderLoading {
            return 2
        }
        if segementView.selectedSegmentIndex == 0 {
            return activeChats.count
        }
        else{
            return archivedChats.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if placeholderLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell1", for: indexPath) as! ChatListCell
            cell.selectionStyle = .none
            let shimmeringView = FBShimmeringView()
            shimmeringView.isShimmering = true
            shimmeringView.shimmeringBeginFadeDuration = 0.3
            shimmeringView.shimmeringOpacity = 1.0
            shimmeringView.shimmeringDirection = .right
            cell.layoutIfNeeded()
            shimmeringView.frame = cell.containerView.frame
            let placeholder = PlaceholderView.instansiateFromNib()
            placeholder.frame = shimmeringView.bounds
            shimmeringView.contentView = placeholder
            placeholder.layoutIfNeeded()
            shimmeringView.backgroundColor = UIColor.clear
            cell.containerView.removeFromSuperview()
            cell.contentView.addSubview(shimmeringView)
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        cell.selectionStyle = .none
        let chat:Chats!
        if segementView.selectedSegmentIndex == 0 {
            chat = activeChats[indexPath.row]
        }
        else{
            chat = archivedChats[indexPath.row]
        }
        cell.companyLbl.text = chat.companyName
        cell.designationLbl.text = chat.title
        let jobAppliedTime = Int(chat.jobAppliedTime)
        cell.appliedLbl.text = "Applied : \(chat.jobAppliedTime.timeStampToDateString(jobAppliedTime!, format: "MMM dd, yyyy"))"
        let jobPostedTime = Int(chat.jobPostedTime)
        cell.postedLbl.text = "Posted : \(chat.jobPostedTime.timeStampToDateString(jobPostedTime!, format: "MMM dd, yyyy"))"
        let imageUrl = URL(string: "\(ImageBaseURL)\(chat.profilePicture)")
        cell.iconImage.setImageWith(imageUrl!, placeholderImage: UIImage(named: "profile"))
        return cell
    }
}
