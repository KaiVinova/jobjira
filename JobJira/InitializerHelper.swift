//
//  InitializerHelper.swift
//  JobJira
//
//  Created by Vaibhav on 17/01/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

import UIKit

class InitializerHelper: NSObject {

    //MARK: - Singleton Instance
    class var sharedInstance: InitializerHelper {
        struct Static {
            static let instance = InitializerHelper()
        }
        return Static.instance
    }
    
    var questionsArray:[[String:AnyObject]]!
    var videoImage:UIImage?
    var profileImage:UIImage?
    
    //Filters 
    var selectedGender = [AnyObject]()
    var selectedBudgetRange = [AnyObject]()
    var selectedJobTypes = [AnyObject]()
    var selectedJobRoles = [AnyObject]()
    var selectedSpeakingLanguage = [AnyObject]()
    var selectedEducationalQualification = [AnyObject]()
    var selectedSkills = [AnyObject]()
    var selectedHiringLocation = [AnyObject]()
    var selectedExperienceRange = [AnyObject]()
    var selectedAgeRange = [AnyObject]()

    
    //MARK: - Initialize each dictionary
    func createSeperateObjectsForEachQuestion(_ questionArray:[AnyObject]){
        questionsArray = [[String:AnyObject]]()
        for element in questionArray {
            let object = element as! [String:AnyObject]
            if let questionTypeID = object["questionInfo"]?["questionTypeID"] as? String{
                if questionTypeID == "1" {
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionTypeID as AnyObject?
                    tempDict["viewController"] = "CheckBoxVC" as AnyObject?
                    tempDict["data"] = element
                    questionsArray.append(tempDict)
                }
                if questionTypeID == "2" {
                    if object["optionSelectionLimit"] as? String == "0" {
                        var tempDict = [String:AnyObject]()
                        tempDict["id"] = questionTypeID as AnyObject?
                        tempDict["viewController"] = "MultiSelectionVC" as AnyObject?
                        tempDict["data"] = element
                        questionsArray.append(tempDict)
                    }
                    else{
                        var tempDict = [String:AnyObject]()
                        tempDict["id"] = questionTypeID as AnyObject?
                        tempDict["viewController"] = "SingleSelectionVC" as AnyObject?
                        tempDict["data"] = element
                        questionsArray.append(tempDict)
                    }
                }
                if questionTypeID == "4" {
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionTypeID as AnyObject?
                    tempDict["viewController"] = "LongAnswerVC" as AnyObject?
                    tempDict["data"] = element
                    questionsArray.append(tempDict)
                }
                if questionTypeID == "5" {
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionTypeID as AnyObject?
                    tempDict["viewController"] = "SingleSelectionVC" as AnyObject?
                    tempDict["data"] = element
                    questionsArray.append(tempDict)
                }
            }
        }
    }
    
    //MARK: - VC push method
    func pushViewControllerBasedOnSequence(_ viewController:UIViewController, index:Int) -> UIViewController?{
        if questionsArray == nil {
            return nil
        }
        if questionsArray.count == 0 {
            return nil
        }
        if index == questionsArray.count {
            _ = viewController.dismiss(animated: true, completion: nil)
            return nil
        }
        else{
            let questionTypeID = questionsArray[index]["id"] as! String
            let userInfo = questionsArray[index]["data"] as! [String:AnyObject]
            let optionSelectionLimit = userInfo["questionInfo"]?["optionSelectionLimit"] as! String
            if  questionTypeID == "1"{
                let storyBoard = UIStoryboard(name: "OnBoard", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "CheckBoxVC") as! CheckBoxVC
                viewcontroller.index = index
                return viewcontroller
            }
            if  questionTypeID == "2"{
                if optionSelectionLimit == "0" {
                    let storyBoard = UIStoryboard(name: "OnBoard", bundle: nil)
                    let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "MultiSelectionVC") as! MultiSelectionVC
                    viewcontroller.index = index
                    return viewcontroller
                }
                else{
                    let storyBoard = UIStoryboard(name: "OnBoard", bundle: nil)
                    let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "SingleSelectionVC") as! SingleSelectionVC
                    viewcontroller.index = index
                    return viewcontroller
                }
            }
            if  questionTypeID == "4"{
                let storyBoard = UIStoryboard(name: "OnBoard", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "LongAnswerVC") as! LongAnswerVC
                viewcontroller.index = index
                return viewcontroller
            }
            if  questionTypeID == "5"{
                let storyBoard = UIStoryboard(name: "OnBoard", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "SingleSelectionVC") as! SingleSelectionVC
                viewcontroller.index = index
                return viewcontroller
            }
        }
        return nil
    }
    
    func resetFilters(){
        selectedGender = [AnyObject]()
        selectedBudgetRange = [AnyObject]()
        selectedJobTypes = [AnyObject]()
        selectedJobRoles = [AnyObject]()
        selectedSpeakingLanguage = [AnyObject]()
        selectedEducationalQualification = [AnyObject]()
        selectedSkills = [AnyObject]()
        selectedHiringLocation = [AnyObject]()
        selectedExperienceRange = [AnyObject]()
        selectedAgeRange = [AnyObject]()

    }
}
