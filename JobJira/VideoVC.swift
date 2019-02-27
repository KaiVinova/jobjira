//
//  VideoVC.swift
//  JobJira
//
//  Created by Vaibhav on 12/12/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit
import KVNProgress
import AVFoundation
import AVKit
import KYDrawerController
class VideoVC: UIViewController
{

//MARK:- IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var profilePicView: UIView!
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!

//MARK:- Variables and Constants
    
    var dataDict = [String:AnyObject]()
    var videoUrl:NSURL? = nil
    var editFlag:Bool!
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let drawerController = navigationController?.parent as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
        profilePicView.isHidden = true
        selectionView.isHidden = false
        profilePicBtn.layer.cornerRadius = 4
        profilePicBtn.layer.masksToBounds = true
        if (SignUpMetaData.sharedInstance.videoDict["obQuestionID"]) != nil
        {
            dataDict = SignUpMetaData.sharedInstance.videoDict
        }
        setUpViewBackEndData()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
//MARK:- Method for SetupData on View

    func setUpViewBackEndData()
    {
        titleLabel.text = dataDict["questionInfo"]?["title"] as? String
        subTitleLabel.text = dataDict["questionInfo"]?["p1"] as? String
        headerLabel.text = dataDict["questionInfo"]?["h1"] as? String
        descriptionLabel.text = dataDict["questionInfo"]?["p2"] as? String
        if SignUpMetaData.sharedInstance.videoSelectedDict["answer"] != nil
        {
            if editFlag == true
            {
                let urlString = SignUpMetaData.sharedInstance.videoSelectedDict["answer"]?["videoUrl"] as? String
                self.videoUrl = URL(string: urlString!) as NSURL?
            }
            else
            {
                let urlString = SignUpMetaData.sharedInstance.videoSelectedDict["answer"]?["videoUrl"] as? String
                self.videoUrl = URL(string: urlString!) as NSURL?
            }
            if InitializerHelper.sharedInstance.videoImage != nil
            {
                self.profilePicBtn.setBackgroundImage(InitializerHelper.sharedInstance.videoImage, for: .normal)
            }
            else
            {
                let queue = DispatchQueue.global(qos: .default)
                queue.async(execute: {() -> Void in
                    let image = CommonFunctions.videoSnapshot(self.videoUrl!)
                    DispatchQueue.main.async(execute: {() -> Void in
                        self.profilePicBtn.setBackgroundImage(image, for: .normal)
                        InitializerHelper.sharedInstance.videoImage = nil
                        InitializerHelper.sharedInstance.videoImage = image
                    })
                })
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
    }
    
//MARK:- Back Button Action
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        let _ = navigationController?.popViewController(animated: true)
    }
    
//MARK:- Done Button Action
    
    @IBAction func doneBtnAction(_ sender: Any)
    {
        if editFlag == true
        {
            if videoUrl != nil
            {
                if (videoUrl?.absoluteString?.hasPrefix("http://"))! || (videoUrl?.absoluteString?.hasPrefix("https://"))!
                {
                    let alert = UIAlertController(title: AppName, message: "Please record or upload a video from gallery to proceed", preferredStyle: UIAlertControllerStyle.alert)
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    postImageDataAPI()
                }
            }
            else
            {
                SignUpMetaData.sharedInstance.userInfoDict["profileVideo"] = "" as AnyObject?
                let _ = self.navigationController?.popViewController(animated: true)
            }
            return
        }
        if videoUrl != nil
        {
            if SignUpMetaData.sharedInstance.videoSelectedDict["answer"] != nil
            {
                if editFlag == true
                {
                    if (videoUrl?.absoluteString?.hasPrefix("http://"))! || (videoUrl?.absoluteString?.hasPrefix("https://"))!
                    {
                        let alert = UIAlertController(title: AppName, message: "Please record or upload a video from gallery to proceed", preferredStyle: UIAlertControllerStyle.alert)
                        let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        })
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else
                    {
                        postImageDataAPI()
                    }
                }
                else
                {
                    SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequencePostLogin(self.navigationController!)
                }
            }
            else
            {
                if (videoUrl?.absoluteString?.hasPrefix("http://"))! || (videoUrl?.absoluteString?.hasPrefix("https://"))!
                {
                    let alert = UIAlertController(title: AppName, message: "Please record or upload a video from gallery to proceed", preferredStyle: UIAlertControllerStyle.alert)
                    let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    postImageDataAPI()
                }
            }
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Please record or upload a video from gallery to proceed", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
//MARK:- Gallery Button Action
    
    @IBAction func gallaryBtnAction(_ sender: Any)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.videoMaximumDuration = 30
        imagePicker.videoQuality = .typeMedium
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
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .video
            imagePicker.videoMaximumDuration = 30
            imagePicker.videoQuality = .typeMedium
            imagePicker.allowsEditing = true
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.rear
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        else if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .video
            imagePicker.videoMaximumDuration = 30
            imagePicker.videoQuality = .typeMedium
            imagePicker.allowsEditing = true
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.front
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
//MARK:- Skip Button Action
    
    @IBAction func skipBtnAction(_ sender: Any)
    {
        SignUpMetaData.sharedInstance.pushViewControllerBasedOnSequencePostLogin(self.navigationController!)
    }
    
//MARK:- Remove Button Action
    
    @IBAction func removeBtnAction(_ sender: Any)
    {
        self.videoUrl = nil
        profilePicBtn.setImage(nil, for: .normal)
        profilePicView.isHidden = true
        selectionView.isHidden = false
        SignUpMetaData.sharedInstance.videoSelectedDict = [String:AnyObject]()
    }
    
// Mark : Post Image Data Api
    
    func postImageDataAPI()
    {
        var dict = [String:AnyObject]()
        dict["fileType"] = "2" as AnyObject?
        KVNProgress.show()
        UserService.postVideo(params: dict, videoURL: videoUrl, completionBlock: { (success,
            errorMessage, data) -> Void in
            KVNProgress.dismiss(completion: { 
                if success
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        let result = data?["result"] as! [String:AnyObject]
                        var tempDict = [String:AnyObject]()
                        tempDict["videoName"] = result["fileName"] as AnyObject?
                        tempDict["videoUrl"] = result["fileUrl"] as AnyObject?
                        SignUpMetaData.sharedInstance.videoSelectedDict = ["answer":tempDict as AnyObject, "obQuestionID":SignUpMetaData.sharedInstance.videoDict["obQuestionID"]!]
                        if self.editFlag == true
                        {
                            SignUpMetaData.sharedInstance.userInfoDict["profileVideo"] = result["fileUrl"] as AnyObject?
                            let _ = self.navigationController?.popViewController(animated: true)
                        }
                        else
                        {
                            self.postData()
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
    
//MARK:- Play button Action
    
    @IBAction func playBtnAction(_ sender: Any)
    {
        if videoUrl != nil
        {
            let player = AVPlayer(url: videoUrl! as URL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true)
            {
                playerViewController.player!.play()
            }
        }
        else
        {
            let alert = UIAlertController(title: AppName, message: "Nothing to play", preferredStyle: UIAlertControllerStyle.alert)
            let action =  UIAlertAction(title: AlertOk, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
//MARK: - Post Answer Data API
    
    func postData()
    {
        var dict = [String:AnyObject]()
        let userInfoDict = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
        dict["jobSeekerID"] = userInfoDict["jobSeekerID"] as AnyObject?
        var dataArray = [[String:AnyObject]]()
        if SignUpMetaData.sharedInstance.videoSelectedDict["answer"] != nil
        {
            var tempDict = [String:AnyObject]()
            tempDict["answer"] = SignUpMetaData.sharedInstance.videoSelectedDict["answer"]?["videoName"] as AnyObject?
            tempDict["obQuestionID"] = SignUpMetaData.sharedInstance.videoDict["obQuestionID"]
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
}

//MARK:- Extension UIImagePickerControllerDelegate

extension VideoVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL
        {
            guard let data = NSData(contentsOf: videoURL as URL) else
            {
                return
            }
            KVNProgress.show(withStatus: "Compressing video")
            print("File size before compression: \(Double(data.length / 1048576)) mb")
            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
            compressVideo(inputURL: videoURL as URL, outputURL: compressedURL)
            { (exportSession) in
                guard let session = exportSession else
                {
                    return
                }
                
                switch session.status
                {
                case .unknown:
                    break
                case .waiting:
                    break
                case .exporting:
                    break
                case .completed:
                    guard let compressedData = NSData(contentsOf: compressedURL) else
                    {
                        return
                    }
                    DispatchQueue.main.async
                    {
                        print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                        self.videoUrl = compressedURL as NSURL?
                        InitializerHelper.sharedInstance.videoImage = nil
                        InitializerHelper.sharedInstance.videoImage = CommonFunctions.videoSnapshot(videoURL)
                        self.profilePicBtn.setBackgroundImage(InitializerHelper.sharedInstance.videoImage, for: .normal)
                        self.profilePicView.isHidden = false
                        self.selectionView.isHidden = true
                        KVNProgress.dismiss()
                    }
                case .failed:
                    break
                case .cancelled:
                    break
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void)
    {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else
        {
            handler(nil)
            return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously
        { () -> Void in
            handler(exportSession)
        }
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool)
    {
        UIApplication.shared.statusBarStyle = .lightContent
    }
}
