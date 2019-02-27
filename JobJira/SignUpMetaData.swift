//
//  SignUpMetaData.swift
//  JobJira
//
//  Created by Vaibhav on 28/11/16.
//  Copyright © 2016 Vaibhav. All rights reserved.
//

import UIKit

class SignUpMetaData: NSObject
{
    
//MARK: - Singleton Instance
    class var sharedInstance: SignUpMetaData
    {
        struct Static
        {
            static let instance = SignUpMetaData()
        }
        return Static.instance
    }
    
//MARK: - All Dictionaries for respective VC
    
    var viewControllerOrder = [[String:AnyObject]]()
    var genderDict = [String:AnyObject]()
    var ageDict = [String:AnyObject]()
    var locationDict = [String:AnyObject]()
    var skillsDict = [String:AnyObject]()
    var experinceDict = [String:AnyObject]()
    var currentSalaryDict = [String:AnyObject]()
    var expectedSalaryDict = [String:AnyObject]()
    var jobTypeDict = [String:AnyObject]()
    var jobRoleDict = [String:AnyObject]()
    var personalDetailDict = [String:AnyObject]()
    var otpDict = [String:AnyObject]()
    var languageDict = [String:AnyObject]()
    var profilePicDict = [String:AnyObject]()
    var viewControllerOrderPostLogin = [[String:AnyObject]]()
    var availabilityDict = [String:AnyObject]()
    var profileAvailabilityDict = [String:AnyObject]()
    var educationDict = [String:AnyObject]()
    var brandDict = [String:AnyObject]()
    var videoDict = [String:AnyObject]()
    var bioDict = [String:AnyObject]()
    
//MARK: - All slected Dictionaries and Arrays for respective VC
    
    var genderSelectedDict = [String:AnyObject]()
    var ageSelectedDict = [String:AnyObject]()
    var locationSelectedDict = [[String:AnyObject]]()
    var skillsSelectedArray = [[String:AnyObject]]()
    var experinceSelectedDict = [String:AnyObject]()
    var currentSalarySelectedDict = [String:AnyObject]()
    var expectedSalarySelectedDict = [String:AnyObject]()
    var jobTypeSelecedArray = [[String:AnyObject]]()
    var jobRoleSelectedArray = [[String:AnyObject]]()
    var personalDetailSelectedDict = [String:AnyObject]()
    var languageSelectedDict = [[String:AnyObject]]()
    var profilePicSelectedDict = [String:AnyObject]()
    var availabilitySelectedArray = [[String:AnyObject]]()
    var profileAvailabilitySelectedArray = [[String:AnyObject]]()
    var educationSelectedDict = [String:AnyObject]()
    var brandSelectedArray = [[String:AnyObject]]()
    var videoSelectedDict = [String:AnyObject]()
    var bioSelectedDict = [String:AnyObject]()
    var userInfoDict = [String:AnyObject]()

//MARK: - Initialize each dictionary
    func createSeperateObjectsForEachQuestion(_ questionArray:[AnyObject])
    {
        for element in questionArray
        {
            let object = element as! [String:AnyObject]
            if let questionId = object["obQuestionID"] as? String{
                if questionId == "1"
                {
                    genderDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "GenderVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
                if questionId == "2"
                {
                    ageDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "AgeVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
                if questionId == "3"
                {
                    locationDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "LocationVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
                if questionId == "4"
                {
                    skillsDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "SkillsVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
                if questionId == "5"
                {
                    experinceDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "ExperinceVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
                if questionId == "6"
                {
                    currentSalaryDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "CurrentSalaryVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
                if questionId == "7"
                {
                    expectedSalaryDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "ExpectedSalaryVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
                if questionId == "8"
                {
                    jobTypeDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "JobTypeVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
                if questionId == "9"
                {
                    jobRoleDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "JobRoleVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
                if questionId == "10"
                {
                    personalDetailDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "PersonalDetailVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
                if questionId == "11"
                {
                    otpDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "SignUpOTPVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
                if questionId == "14"
                {
                    educationDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "EducationVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
                if questionId == "15"
                {
                    languageDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "LanguageVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
                if questionId == "17"
                {
                    profilePicDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "ProfilePicVC" as AnyObject?
                    viewControllerOrder.append(tempDict)
                }
            }
        }
        resetAllDictionaryAndArray()
    }
    
//MARK: - VC push method
    
    func pushViewControllerBasedOnSequence(_ viewController:UIViewController)
    {
        if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "1"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "GenderVC") as! GenderVC
            viewcontroller.editFlag = false
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        else if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "2"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "AgeVC") as! AgeVC
            viewcontroller.editFlag = false
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        else if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "3"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "LocationVC") as! LocationVC
            viewcontroller.editFlag = false
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        else if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "4"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "SkillsVC") as! SkillsVC
            viewcontroller.editFlag = false
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        else if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "5"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "ExperinceVC") as! ExperinceVC
            viewcontroller.editFlag = false
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        else if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "6"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "CurrentSalaryVC") as! CurrentSalaryVC
            viewcontroller.editFlag = false
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        else if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "7"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "ExpectedSalaryVC") as! ExpectedSalaryVC
            viewcontroller.editFlag = false
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        else if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "8"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "JobTypeVC") as! JobTypeVC
            viewcontroller.editFlag = false
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        else if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "9"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "JobRoleVC") as! JobRoleVC
            viewcontroller.editFlag = false
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        else if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "10"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "PersonalDetailVC") as! PersonalDetailVC
            viewcontroller.editFlag = false
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        else if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "11"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "SignUpOTPVC") as! SignUpOTPVC
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        else if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "14"
        {
            let storyBoard = UIStoryboard(name: "PostLogin", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "EducationVC") as! EducationVC
            viewcontroller.editFlag = false
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        else if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "15"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "LanguageVC") as! LanguageVC
            viewcontroller.editFlag = false
            viewcontroller.afterSignUpFlag = false
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        else if viewControllerOrder[(viewController.navigationController?.viewControllers.count)!-1]["id"] as! String  == "17"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "ProfilePicVC") as! ProfilePicVC
            viewcontroller.editFlag = false
            viewcontroller.afterSignUpFlag = false
            viewController.navigationController?.pushViewController(viewcontroller, animated: true)
        }
    }
    
//MARK: - Reset All Selected Dictonaies and Arrays
    
    func resetAllDictionaryAndArray()
    {
        genderSelectedDict = [String:AnyObject]()
        ageSelectedDict = [String:AnyObject]()
        locationSelectedDict = [[String:AnyObject]]()
        skillsSelectedArray = [[String:AnyObject]]()
        experinceSelectedDict = [String:AnyObject]()
        currentSalarySelectedDict = [String:AnyObject]()
        expectedSalarySelectedDict = [String:AnyObject]()
        jobTypeSelecedArray = [[String:AnyObject]]()
        jobRoleSelectedArray = [[String:AnyObject]]()
        personalDetailSelectedDict = [String:AnyObject]()
        languageSelectedDict = [[String:AnyObject]]()
        profilePicSelectedDict = [String:AnyObject]()
        educationSelectedDict = [String:AnyObject]()
    }
    
//MARK: - Initialize each dictionary post login
    
    func createSeperateObjectsForEachQuestionPostLogin(_ questionArray:[AnyObject])
    {
        for element in questionArray
        {
            let object = element as! [String:AnyObject]
            if let questionId = object["obQuestionID"] as? String
            {
                if questionId == "12"
                {
                    availabilityDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "AvailablityVC" as AnyObject?
                    viewControllerOrderPostLogin.append(tempDict)
                }
                if questionId == "13"
                {
                    profileAvailabilityDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "ProfileAvailablityVC" as AnyObject?
                    viewControllerOrderPostLogin.append(tempDict)
                }
                if questionId == "14"
                {
                    educationDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "EducationVC" as AnyObject?
                    viewControllerOrderPostLogin.append(tempDict)
                }
                if questionId == "15"
                {
                    languageDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "LanguageVC" as AnyObject?
                    viewControllerOrderPostLogin.append(tempDict)
                }
                if questionId == "16"
                {
                    brandDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "BrandVC" as AnyObject?
                    viewControllerOrderPostLogin.append(tempDict)
                }
                if questionId == "17"
                {
                    profilePicDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "ProfilePicVC" as AnyObject?
                    viewControllerOrderPostLogin.append(tempDict)
                }
                if questionId == "18"
                {
                    videoDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "VideoVC" as AnyObject?
                    viewControllerOrderPostLogin.append(tempDict)
                }
                if questionId == "19"
                {
                    bioDict = object
                    var tempDict = [String:AnyObject]()
                    tempDict["id"] = questionId as AnyObject?
                    tempDict["viewController"] = "BioVC" as AnyObject?
                    viewControllerOrderPostLogin.append(tempDict)
                }
            }
        }
        resetAllDictionaryAndArrayPostLogin()
    }
    
    
//MARK: - VC push method Post Login
    
    func pushViewControllerBasedOnSequencePostLogin(_ navController:UINavigationController)
    {
        if navController.viewControllers.count-1 < viewControllerOrderPostLogin.count{
            if viewControllerOrderPostLogin[(navController.viewControllers.count-1)]["id"] as! String  == "12"
            {
                let storyBoard = UIStoryboard(name: "PostLogin", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "AvailablityVC") as! AvailablityVC
                viewcontroller.editFlag = false
                navController.pushViewController(viewcontroller, animated: true)
            }
            else if viewControllerOrderPostLogin[(navController.viewControllers.count-1)]["id"] as! String  == "13"
            {
                let storyBoard = UIStoryboard(name: "PostLogin", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "ProfileAvailablityVC") as! ProfileAvailablityVC
                viewcontroller.editFlag = false
                navController.pushViewController(viewcontroller, animated: true)
            }
            else if viewControllerOrderPostLogin[(navController.viewControllers.count-1)]["id"] as! String  == "14"
            {
                let storyBoard = UIStoryboard(name: "PostLogin", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "EducationVC") as! EducationVC
                viewcontroller.editFlag = false
                navController.pushViewController(viewcontroller, animated: true)
            }
            else if viewControllerOrderPostLogin[navController.viewControllers.count-1]["id"] as! String  == "15"
            {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "LanguageVC") as! LanguageVC
                viewcontroller.editFlag = false
                viewcontroller.afterSignUpFlag = true
                navController.pushViewController(viewcontroller, animated: true)
            }
            else if viewControllerOrderPostLogin[(navController.viewControllers.count-1)]["id"] as! String  == "16"
            {
                let storyBoard = UIStoryboard(name: "PostLogin", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "BrandVC") as! BrandVC
                viewcontroller.editFlag = false
                navController.pushViewController(viewcontroller, animated: true)
            }
            else if viewControllerOrderPostLogin[navController.viewControllers.count-1]["id"] as! String  == "17"
            {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "ProfilePicVC") as! ProfilePicVC
                viewcontroller.editFlag = false
                viewcontroller.afterSignUpFlag = true
                navController.pushViewController(viewcontroller, animated: true)
            }
            else if viewControllerOrderPostLogin[(navController.viewControllers.count-1)]["id"] as! String  == "18"
            {
                let storyBoard = UIStoryboard(name: "PostLogin", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "VideoVC") as! VideoVC
                viewcontroller.editFlag = false
                navController.pushViewController(viewcontroller, animated: true)
            }
            else if viewControllerOrderPostLogin[(navController.viewControllers.count-1)]["id"] as! String  == "19"
            {
                let storyBoard = UIStoryboard(name: "PostLogin", bundle: nil)
                let viewcontroller = storyBoard.instantiateViewController(withIdentifier: "BioVC") as! BioVC
                viewcontroller.editFlag = false
                navController.pushViewController(viewcontroller, animated: true)
            }
            else
            {
                let _ = navController.popToRootViewController(animated: true)
            }
        }
        else
        {
            let _ = navController.popToRootViewController(animated: true)
        }
        
    }
    
//MARK: - Reset All Selected Dictonaies and Arrays Post Login
    
    func resetAllDictionaryAndArrayPostLogin()
    {
        availabilitySelectedArray = [[String:AnyObject]]()
        profileAvailabilitySelectedArray = [[String:AnyObject]]()
        educationSelectedDict = [String:AnyObject]()
        brandSelectedArray = [[String:AnyObject]]()
        videoSelectedDict = [String:AnyObject]()
        bioSelectedDict = [String:AnyObject]()
        languageSelectedDict = [[String:AnyObject]]()
        profilePicSelectedDict = [String:AnyObject]()
    }
    
//MARK: - Reset All Selected Dictonaies and Arrays Post Login
   
    func resetAllDictionaryAndArrayPreLoginAndPostLogin()
    {
        viewControllerOrder = [[String:AnyObject]]()
        viewControllerOrderPostLogin = [[String:AnyObject]]()
        genderSelectedDict = [String:AnyObject]()
        ageSelectedDict = [String:AnyObject]()
        locationSelectedDict = [[String:AnyObject]]()
        skillsSelectedArray = [[String:AnyObject]]()
        experinceSelectedDict = [String:AnyObject]()
        currentSalarySelectedDict = [String:AnyObject]()
        expectedSalarySelectedDict = [String:AnyObject]()
        jobTypeSelecedArray = [[String:AnyObject]]()
        jobRoleSelectedArray = [[String:AnyObject]]()
        personalDetailSelectedDict = [String:AnyObject]()
        languageSelectedDict = [[String:AnyObject]]()
        profilePicSelectedDict = [String:AnyObject]()
        availabilitySelectedArray = [[String:AnyObject]]()
        profileAvailabilitySelectedArray = [[String:AnyObject]]()
        educationSelectedDict = [String:AnyObject]()
        brandSelectedArray = [[String:AnyObject]]()
        videoSelectedDict = [String:AnyObject]()
        bioSelectedDict = [String:AnyObject]()
        languageSelectedDict = [[String:AnyObject]]()
        profilePicSelectedDict = [String:AnyObject]()
    }
}
