//
//  AppConstants.swift
//  GameMaster
//
//  Created by Akshay Rai on 12/02/16.
//  Copyright © 2016 AppInfy. All rights reserved.
//

import Foundation

let BaseURL = "http://jobjira.apphosthub.com/app/"
let BaseURLWeb = "http://jobjira.apphosthub.com/"
let ImageBaseURL = "http://jobjira.apphosthub.com/public/uploads/employer/profile_images/"

//let BaseURL = "http://jobjira.com/app/"
//let BaseURLWeb = "http://jobjira.com/"
//let ImageBaseURL = "http://jobjira.com/public/uploads/employer/profile_images/"


let AppKey  = "w54Oix0U8Py+a6MFgRGjbas1SC/0SBl4TBAoagdp4Ys="
let AppName = "JobJira"
let AlertOk = "OK"
let tokenid = "tokenid"
let linkColor = UIColor(red: 73.0/255.0, green: 60.0/255.0, blue: 228.0/255.0, alpha: 1.0)
let OrangeColor = UIColor(red: 253.0/255.0, green: 162.0/255.0, blue: 1.0/255.0, alpha: 1.0)
let LightBlueColor = UIColor(red: 0.0/255.0, green: 165.0/255.0, blue: 226.0/255.0, alpha: 1.0)

let CountryCodeArray = [["name":"Singapore","code":"+65","iso":"SG"], ["name":"India","code":"+91","iso":"IN"]]
//let CountryCodeArray = [["name":"Singapore","code":"+65","iso":"SG"]]

var Timestamp: String {
    return "\(NSDate().timeIntervalSince1970)"
}
//MARK:- Webservice

let MasterData                     = "account/begin_signup"
let SignUp                         = "account/signup"
let PostImage                      = "account/upload_file_guest"
let Login                          = "account/login"
let LoginWithoutPasswordEmail      = "account/login_by_email"
let LoginWithoutPasswordPhone      = "account/login_by_mobile"
let AnswerData                     = "account/user_answer_after_signup"
let UpdateProfile                  = "account/update_profile"
let CardData                       = "jobs/list_jobs"
let JobCardAction                  = "jobs/perform_action"
let ChangeSettings                 = "account/change_settings"
let ContactSupport                 = "account/contact_support"
let JobDetail                      = "jobs/job_details"
let OnDemandQuestions              = "account/on_demand_questions"
let OnDemandAnswer                 = "account/answer_on_demand_questions"
let CancelOnDemandAnswer           = "account/skip_on_demand_questions"
let EmailVerification              = "account/profile_actions"
let ResumeStatus                   = "account/get_dynamic_profile_updates"
let ResumeUpload                   = "account/send_email"


