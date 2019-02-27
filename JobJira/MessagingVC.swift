//
//  MessagingVC.swift
//  JobJira
//
//  Created by Vaibhav on 17/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController
import Photos
import AFNetworking
class MessagingVC: JSQMessagesViewController
{

// MARK: Properties
    var chatRef: FIRDatabaseReference?
    var chat: Chats?
    {
        didSet
        {
            title = chat?.chatRoomID
        }
    }
    
//MARK:- Variables and Constants
    
    var messages = [JSQMessage]()
    var messageArray = [Messages]()
    var avatarIds = [String]()
    var avatars = [String:JSQMessagesAvatarImage]()
    var initials = [String:AnyObject]()
    let userInfo = UserDefaults.standard.object(forKey: "userInfo") as! [String:AnyObject]
    let firebaseInfo = UserDefaults.standard.object(forKey: "firebaseInfo") as! [String:AnyObject]
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    private lazy var messageRef: FIRDatabaseReference = self.chatRef!//.child("messages")
    private var newMessageRefHandle: FIRDatabaseHandle?
    private lazy var employerChatRef: FIRDatabaseReference = FIRDatabase.database().reference().child("employer_chats")
    private lazy var jobSeekerChatRef: FIRDatabaseReference = FIRDatabase.database().reference().child("jobseeker_chats")
    private var localTyping = false
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://jobjira-b854b.appspot.com")
    private let imageURLNotSetKey = "NOTSET"
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    private var updatedMessageRefHandle: FIRDatabaseHandle?
    
//MARK:- View LifeCycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = linkColor
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"back"), style: .plain, target: self, action: #selector(MessagingVC.backBtnAction(_:)))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.titleView = createTitleView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"back"), style: .plain, target: self, action: #selector(MessagingVC.dummyBtnAction(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.inputToolbar.toggleSendButtonEnabled()
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "plane"), for: .normal)
        if chat?.isClosed == "1" || chat?.jobStatus != "2"
        {
            self.inputToolbar.contentView.textView.isEditable = false
            self.inputToolbar.contentView.textView.placeHolder = "Reply not allowed"
        }
        self.collectionView.collectionViewLayout.messageBubbleFont = UIFont(name: ".SFUIText-Light", size: 14)!
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
        observeMessages()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.senderId = firebaseInfo["jobSeekerID"] as! String
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
//MARK:- MEthod for create title
    
    func createTitleView() -> UIView
    {
        let titleView = NavBarView.instansiateFromNib()
        titleView.companyNameLbl.text = chat?.companyName
        titleView.designationNameLbl.text = chat?.title
        return titleView
    }
    
//MARK:- Back Button Action
    
    func backBtnAction(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }

    func dummyBtnAction(_ sender: Any)
    {
        
    }
    
//MARK:- Helper
    
    private func addMessage(withId id: String, name: String, text: String)
    {
        if let message = JSQMessage(senderId: id, displayName: name, text: text)
        {
            messages.append(message)
        }
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem, name: String)
    {
        if let message = JSQMessage(senderId: id, displayName: name, media: mediaItem)
        {
            messages.append(message)
            
            if (mediaItem.image == nil)
            {
                photoMessageMap[key] = mediaItem
            }
            collectionView.reloadData()
        }
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "createdTime": "\(Int(Double(Timestamp)!))",
            "from": "1",
            "message": text!,
            ]
        itemRef.setValue(messageItem)
        let chatItem = [
            "chatRoomID": (chat?.chatRoomID)!,
            "lastMessage": text!,
            "updatedTime": -1*Int(Double(Timestamp)!)
        ] as [String : Any]
        employerChatRef.child((chat?.employerID)!).child((chat?.chatRoomID)!).updateChildValues(chatItem)
        jobSeekerChatRef.child((chat?.jobSeekerID)!).child((chat?.chatRoomID)!).updateChildValues(chatItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage(animated: true)
    }
    
    private func observeMessages()
    {
        let messageQuery = messageRef.queryLimited(toLast:25)
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, AnyObject>
            if let from = messageData["from"] as! String!{
                let id:String!
                let name:String!
                if from == "2"
                {
                    id = self.chat?.employerID
                    name = self.chat?.name
                }
                else
                {
                    id = self.chat?.jobSeekerID
                    name = self.userInfo["name"] as! String
                }
                if let text = messageData["message"] as! String!, text.characters.count > 0
                {
                    self.createMessageObjectAndAppend(messageData as [String : AnyObject])
                    self.addMessage(withId: id, name: name, text: text)
                    self.finishReceivingMessage(animated: true)
                }
                else if let photoURL = messageData["photoURL"] as! String!
                {
                    if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId)
                    {
                        self.createMessageObjectAndAppend(messageData as [String : AnyObject])
                        self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem, name: name)
                        if photoURL.hasPrefix("gs://")
                        {
                            self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                        }
                    }
                }
                else
                {
                    print("Error! Could not decode message data")
                }
            }
            
        })
        
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, AnyObject>
            if let photoURL = messageData["photoURL"] as! String! {
                if let mediaItem = self.photoMessageMap[key]
                {
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
                }
            }
        })
    }
    
    deinit
    {
        if let refHandle = newMessageRefHandle
        {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle
        {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
//MARK:- Method for createMessageObjectAndAppend
    
    func createMessageObjectAndAppend(_ messageData:[String:AnyObject])
    {
        if let from = messageData["from"] as! String!
        {
            let name:String!
            if from == "2"
            {
                name = self.chat?.name
            }
            else
            {
                name = self.userInfo["name"] as! String
            }
            if let text = messageData["message"] as! String!, text.characters.count > 0
            {
                self.messageArray.append(Messages(createdTime: messageData["createdTime"] as! String, from: messageData["from"] as! String, message: text, name: name, profilePicture: "", employerID: (self.chat?.employerID)!, jobSeekerID: (self.chat?.jobSeekerID)!, photoURL: ""))
            }
            else if let photoURL = messageData["photoURL"] as! String!
            {
                self.messageArray.append(Messages(createdTime: messageData["createdTime"] as! String, from: messageData["from"] as! String, message: "", name: name, profilePicture: "", employerID: (self.chat?.employerID)!, jobSeekerID: (self.chat?.jobSeekerID)!, photoURL: photoURL))
            }
        }
    }
    
//MARK:- Method For sendPhotoMessage
    
    func sendPhotoMessage() -> String?
    {
        let itemRef = messageRef.childByAutoId()
        let messageItem =
            [
            "photoURL": imageURLNotSetKey,
            "createdTime": "\(Int(Double(Timestamp)!))",
            "from": "1"
            ]
        itemRef.setValue(messageItem)
        let chatItem = [
            "chatRoomID": (chat?.chatRoomID)!,
            "lastMessage": imageURLNotSetKey,
            "updatedTime": -1*Int(Double(Timestamp)!)
            ] as [String : Any]
        employerChatRef.child((chat?.employerID)!).child((chat?.chatRoomID)!).updateChildValues(chatItem)
        jobSeekerChatRef.child((chat?.jobSeekerID)!).child((chat?.chatRoomID)!).updateChildValues(chatItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String)
    {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
        let chatItem =
            [
            "chatRoomID": (chat?.chatRoomID)!,
            "lastMessage": url,
            "updatedTime": -1*Int(Double(Timestamp)!)
            ] as [String : Any]
        employerChatRef.child((chat?.employerID)!).child((chat?.chatRoomID)!).updateChildValues(chatItem)
        jobSeekerChatRef.child((chat?.jobSeekerID)!).child((chat?.chatRoomID)!).updateChildValues(chatItem)
    }
    
//MARK:- Accessory Button
    
    override func didPressAccessoryButton(_ sender: UIButton)
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        }
        else
        {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        present(picker, animated: true, completion:nil)
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?)
    {
        let storageRef = FIRStorage.storage().reference(forURL: photoURL)
        storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error
            {
                print("Error downloading image data: \(error)")
                return
            }
            storageRef.metadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr
                {
                    print("Error downloading metadata: \(error)")
                    return
                }
                if (metadata?.contentType == "image/gif")
                {
                    mediaItem.image = UIImage.gifWithData(data!)
                }
                else
                {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                guard key != nil else
                {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
// MARK: - Backend methods (avatar)

    func loadAvatar(_ userId: String, urlString:String)
    {
        if avatarIds.contains(userId)
        {
            return
        }
        else
        {
            avatarIds.append(userId)
        }
        DownloadManager.image(urlString, completion:{ path, error, network in
            if error == nil
            {
                let image = UIImage(contentsOfFile: path!)
                if image != nil
                {
                    self.avatars[userId] = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
                    self.perform(#selector(MessagingVC.delayedRelod), with: nil, afterDelay: 0.1)
                }
            }
        })
    }
    
    func delayedRelod()
    {
        self.collectionView.reloadData()
    }
    
// MARK: Collection view data source (and related) methods
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        let message = messages[indexPath.item]
        if message.senderId == senderId
        {
            return outgoingBubbleImageView
        }
        else
        {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        if chat?.profilePicture != ""
        {
            self.loadAvatar((chat?.employerID)!, urlString: "\(ImageBaseURL)\((chat?.profilePicture)!)")
        }
        if userInfo["profilePicture"] as! String != ""
        {
            self.loadAvatar((chat?.jobSeekerID)!, urlString: userInfo["profilePicture"] as! String)
        }
        let message = messages[indexPath.item]
        if avatars[message.senderId] != nil
        {
            return avatars[message.senderId]
        }
        else
        {
            let stringInputArr = (message.senderDisplayName as String).components(separatedBy: " ")
            var stringNeed = ""
            for (index,string) in stringInputArr.enumerated()
            {
                if index<2
                {
                    if string != ""
                    {
                        stringNeed = stringNeed + String(string.characters.first!)
                    }
                }
            }
            return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: stringNeed, backgroundColor: UIColor.black, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 14), diameter: 30)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        let msg = self.messages[indexPath.item]
        var preMsg:JSQMessage?
        if indexPath.item != 0
        {
            preMsg = self.messages[indexPath.item - 1]
        }
        if indexPath.item == 0
        {
            let date = JSQMessagesTimestampFormatter.shared().relativeDate(for: msg.date)
            return NSAttributedString(string: date!)
        }
        else if indexPath.item - 1 > 0 && preMsg?.date != msg.date
        {
            let date = JSQMessagesTimestampFormatter.shared().relativeDate(for: msg.date)
            return NSAttributedString(string: date!)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        let timestamp = messageArray[indexPath.item].createdTime
        let time = JSQMessagesTimestampFormatter.shared().time(for: Date(timeIntervalSince1970: Double(timestamp)! as TimeInterval))
        return  NSAttributedString(string: time!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        let message = messageArray[indexPath.item]
        if message.from == "2"
        {
            if indexPath.item > 0
            {
                let previousMessage = messageArray[indexPath.item-1]
                if previousMessage.from == message.from
                {
                    return nil
                }
            }
            return NSAttributedString(string: message.name)
        }
        else
        {
            return nil
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if message.senderId == senderId
        {
            cell.textView?.textColor = UIColor.darkGray
        }
        else
        {
            cell.textView?.textColor = UIColor.darkGray
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        let message = messageArray[indexPath.item]
        if message.from == "2"
        {
            if indexPath.item > 0
            {
                let previousMessage = messageArray[indexPath.item-1]
                if previousMessage.from == message.from
                {
                    return 0
                }
            }
            return 20
        }
        else
        {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        let msg = self.messages[indexPath.item]
        var preMsg:JSQMessage?
        if indexPath.item != 0
        {
            preMsg = self.messages[indexPath.item - 1]
        }
        if indexPath.item == 0
        {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        else if indexPath.item - 1 > 0 && preMsg!.date != msg.date
        {
            let premsg = self.messages[indexPath.item - 1]
            let msg = self.messages[indexPath.item]
            if msg.date.timeIntervalSince((premsg.date)!)/60 > 1
            {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return 14
    }
    
// MARK: Firebase related methods
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage
    {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage
    {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
// MARK: UITextViewDelegate methods
    
    override func textViewDidChange(_ textView: UITextView)
    {
        super.textViewDidChange(textView)
    }
}

// MARK: Image Picker Delegate

extension MessagingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        picker.dismiss(animated: true, completion:nil)
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL
        {
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            if let key = sendPhotoMessage()
            {
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    let path = "\(FIRAuth.auth()?.currentUser?.uid)/\(Double(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                    self.storageRef.child(path).putFile(imageFileURL!, metadata: nil) { (metadata, error) in
                        if let error = error
                        {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
        }
        else
        {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            if let key = sendPhotoMessage()
            {
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                let imagePath = FIRAuth.auth()!.currentUser!.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                storageRef.child(imagePath).put(imageData!, metadata: metadata) { (metadata, error) in
                    if let error = error
                    {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion:nil)
    }
}
