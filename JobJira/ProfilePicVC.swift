//
//  ProfilePicVC.swift
//  JobJira
//
//  Created by Vaibhav on 02/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import KYDrawerController
class ProfilePicVC: UIViewController
{
    
//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var profilePicImage: CircularImageV!
    @IBOutlet weak var profilePicView: UIView!
    @IBOutlet weak var profilePicBtn: CircularButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
//MARK:- Variables and Constants

    var profileImage: UIImage? = nil
    var editFlag:Bool!
    var afterSignUpFlag:Bool!

//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight == 480
        {
            let font = subTitleLabel.font
            subTitleLabel.font = font?.withSize(15)
            let font1 = headerLabel.font
            headerLabel.font = font1?.withSize(19)
            let font2 = descriptionLabel.font
            descriptionLabel.font = font2?.withSize(14)
        }
        profilePicView.isHidden = true
        selectionView.isHidden = false
        if SignUpMetaData.sharedInstance.profilePicSelectedDict["answer"] != nil
        {
            if editFlag == true
            {
                if InitializerHelper.sharedInstance.profileImage != nil
                {
                    self.profilePicImage.image = InitializerHelper.sharedInstance.profileImage
                }
                else
                {
                    let queue = DispatchQueue.global(qos: .default)
                    queue.async(execute: {() -> Void in
                        do
                        {
                            self.profileImage = try UIImage(data: Data(contentsOf: URL(string: (SignUpMetaData.sharedInstance.profilePicSelectedDict["answer"]?["imageUrl"] as? String)!)!))
                            InitializerHelper.sharedInstance.profileImage = UIImage()
                            InitializerHelper.sharedInstance.profileImage = self.profileImage
                            DispatchQueue.main.async(execute: {() -> Void in
                                self.profilePicImage.image = InitializerHelper.sharedInstance.profileImage
                            })
                        }
                        catch let error as Error
                        {
                            print(error)
                            InitializerHelper.sharedInstance.profileImage = nil
                        }
                    })
                }
            }
            else
            {
                profileImage = SignUpMetaData.sharedInstance.profilePicSelectedDict["answer"]?["image"] as? UIImage
                self.profilePicImage.image = profileImage
            }
            profilePicView.isHidden = false
            selectionView.isHidden = true
        }
        if editFlag == true
        {
            skipBtn.isHidden = true
        }
        else
        {
            if self.navigationController?.viewControllers.count==2
            {
                backBtn.isHidden = true
            }
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    

//MARK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
//MARK:- Done Button Action
    
    @IBAction func doneBtnAction(_ sender: Any)
    {
        if editFlag == true
        {
            if profileImage != nil
            {
                postImageDataAPI()
            }
            else
            {
                SignUpMetaData.sharedInstance.userInfoDict["profilePicture"] = "" as AnyObject?
                let _ = self.navigationController?.popViewController(animated: true)
            }
        }
            
        else
        {
            if profileImage != nil
            {
                if SignUpMetaData.sharedInstance.profilePicSelectedDict["answer"] != nil{
                    if editFlag == true
                    {
                        postImageDataAPI()
                    }
                    else
                    {
                        if afterSignUpFlag == true
                        {
                             SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequencePostLogin(self.navigationController!)
                        }
                        else
                        {
                            SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
                        }
                    }
                }
                else
                {
                    postImageDataAPI()
                }
            }
            else
            {
                let alert = UIAlertController(title: AppName, message: "Please capture or upload a picture from gallery to proceed", preferredStyle: UIAlertControllerStyle.alert)
                let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

//MARK:- Gallery Button Action
    
    @IBAction func gallaryBtnAction(_ sender: Any)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
//MARK:- Camera Button Action
    
    @IBAction func cameraBtnAction(_ sender: Any)
    {
        if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.rear
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        else if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.front
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
//MARK:- Skip Button Action
    
    @IBAction func skipBtnAction(_ sender: Any)
    {
        if self.afterSignUpFlag == true
        {
            SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequencePostLogin(self.navigationController!)
        }
        else
        {
            SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
        }
    }
    
//MARK:- Renove Button Action
    
    @IBAction func removeBtnAction(_ sender: Any)
    {
        self.profileImage = nil
        profilePicImage.image = nil
        profilePicView.isHidden = true
        selectionView.isHidden = false
        SignUpMetaData.sharedInstance.profilePicSelectedDict = [String:AnyObject]()
    }
    
// Mark : Post Image Data Api
    
    func postImageDataAPI()
    {
        var dict = [String:AnyObject]()
        dict["fileType"] = "1" as AnyObject?
        KVNProgress.show()
        UserService.postImage(params: dict, profieImage: self.profileImage , completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss(completion: {
                if success
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        let result = data?["result"] as! [String:AnyObject]
                        var tempDict = [String:AnyObject]()
                        tempDict["imageName"] = result["fileName"] as AnyObject?
                        tempDict["imageUrl"] = result["fileUrl"] as AnyObject?
                        tempDict["image"] = self.profileImage
                        SignUpMetaData.sharedInstance.profilePicSelectedDict = ["answer":tempDict as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.profilePicDict["obQuestionID"]!]
                        InitializerHelper.sharedInstance.profileImage = nil
                        InitializerHelper.sharedInstance.profileImage = self.profileImage
                        if self.editFlag == true
                        {
                            SignUpMetaData.sharedInstance.userInfoDict["profilePicture"] = result["fileUrl"] as AnyObject?
                            let _ = self.navigationController?.popViewController(animated: true)
                        }
                        else
                        {
                            if self.afterSignUpFlag == true
                            {
                                self.postData()
                            }
                            else
                            {
                                SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequence(self)
                            }
                        }
                    }
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
        })
    }
    
//MARK: - Post Answer Data API
    
    func postData()
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        var dataArray = [[String:AnyObject]]()
        if SignUpMetaData.sharedInstance.profilePicSelectedDict["answer"] != nil
        {
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = SignUpMetaData.sharedInstance.profilePicSelectedDict["answer"]?["imageName"] as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.profilePicDict["obQuestionID"]
            dataArray.append(tempDict)
        }
        dict["data"] = dataArray as AnyObject?
        print(dict)
        KVNProgress.show()
        UserService.updateProfileWebservice(dict, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss()
            if success
            {
                let result = data!["result"]?["userInfo"]!
                print(result ?? "No Value")
                UserDefaults.standard.set(result, forKey: "userInfo")
                SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequencePostLogin(self.navigationController!)
            }
            else
            {
                let alert = UIAlertController(title: AppName, message: errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
                if data != nil{
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
}

//MARK:- Extension UIImagePickerControllerDelegate

extension ProfilePicVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let chooseimage = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            self.profileImage  = CommonFunctions.fixOrientationforImage(image: chooseimage)
            self.profileImage = CommonFunctions.resizeImage(size: CGSize(width:400, height:400), image: self.profileImage!)
            profilePicImage.image = self.profileImage
        }
        picker.dismiss(animated: true, completion: nil)
        profilePicView.isHidden = false
        selectionView.isHidden = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool)
    {
        UIApplication.shared.statusBarStyle = .lightContent
    }
}
