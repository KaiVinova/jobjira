//
//  Messages.swift
//  JobJira
//
//  Created by Vaibhav on 04/02/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//
internal class Messages {
    
    //MARK: Variables

    internal let createdTime: String
    internal let from: String
    internal let message: String
    internal let name: String
    internal let profilePicture: String
    internal let employerID: String
    internal let jobSeekerID: String
    internal let photoURL: String
    
    //MARK: Initializer

    init(createdTime: String, from: String, message: String, name: String, profilePicture: String, employerID: String, jobSeekerID: String, photoURL: String) {
        self.createdTime = createdTime
        self.from = from
        self.message = message
        self.name = name
        self.profilePicture = profilePicture
        self.employerID = employerID
        self.jobSeekerID = jobSeekerID
        self.photoURL = photoURL
    }
}
