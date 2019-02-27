 //
//  UserService.swift
//  GameMaster
//
//  Created by Akshay Rai on 04/02/16.
//  Copyright © 2016 AppInfy. All rights reserved.

import UIKit

class UserService {
    
    internal typealias completionClosure = (_ success : Bool, _ errorMessage: String?, _ data: [String: AnyObject]?) -> Void

    
    class func getMasterDataWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.GET(MasterData, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }
            else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func postSignUpDataWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POST(SignUp, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }
            else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func postImage(params:[String:AnyObject],profieImage: UIImage?,completionBlock: @escaping completionClosure){
        let imageData = (profieImage != nil) ? UIImagePNGRepresentation(profieImage!) : nil
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POSTWithImage(PostImage, parameters: parameters as AnyObject!, imagedata: imageData, imageKey: "profileImage", successBlock: { (JSON) -> Void in
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }
            else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func postVideo(params:[String:AnyObject],videoURL: NSURL?,completionBlock: @escaping completionClosure){
        let videoData = (videoURL != nil) ? NSData(contentsOf: videoURL as! URL) : nil
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POSTWithVideo(PostImage, parameters:  parameters as AnyObject!, imagedata: videoData as Data?, imageKey: "profileVideo", successBlock: { (JSON) -> Void in
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }
            else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func postLoginDataWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POST(Login, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }
            else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
  
    class func postLoginDataWithoutPasswordEmailWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POST(LoginWithoutPasswordEmail, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }
            else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func postLoginDataWithoutPasswordPhoneWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POST(LoginWithoutPasswordPhone, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func postAnswerDataWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POST(AnswerData, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func updateProfileWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POST(UpdateProfile, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func getCardDataWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.GET(CardData, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func actionForJobCardWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POST(JobCardAction, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func updateSettingsWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        ServiceClass.POST(ChangeSettings, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func sendContactSupportMsgWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POST(ContactSupport, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }

    class func getJobDetailWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.GET(JobDetail, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func getOnDemandQuestionsWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.GET(OnDemandQuestions, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func postAnswerOnDemandWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POST(OnDemandAnswer, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }

    class func postCancelOnDemandWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POST(CancelOnDemandAnswer, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    class func testGetWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = "gYy5DG2idisezhFk4uknRLefkBqYijMYCcIR0h9/BaA=" as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.GET("account/user_info", parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func postEmailVerificationWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POST(EmailVerification, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }

    class func getRemumeStatusWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.GET(ResumeStatus, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
    
    class func postUploadResumeWebservice(_ params:[String:AnyObject],completionBlock: @escaping completionClosure){
        var parameters = params
        parameters["appKey"] = AppKey as AnyObject?
        if let token = UserDefaults.standard.object(forKey: "devicetoken"){
            parameters["deviceToken"] = token as AnyObject?
        }
        else{
            parameters["deviceToken"] = "12345" as AnyObject?
        }
        parameters["timeStamp"] = Timestamp as AnyObject?

        ServiceClass.POST(ResumeUpload, parameters: parameters as AnyObject!, successBlock: { (JSON) -> Void in
            
            if let errorCode = JSON["status"] as? Int, Int(errorCode) != 200{
                if errorCode == 405{
                    completionBlock(false, JSON["errorstr"] as? String, ["code":405 as AnyObject])
                }
                else{
                    completionBlock(false, JSON["errorstr"] as? String, nil)
                }
            }else{
                completionBlock(true, nil,JSON)
            }
        }) { (error) -> Void in
            completionBlock(false, error.localizedDescription, nil)
        }
    }
}
