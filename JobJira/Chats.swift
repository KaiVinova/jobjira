//
//  Chats.swift
//  JobJira
//
//  Created by Vaibhav on 03/02/17.
//  Copyright © 2017 Vaibhav. All rights reserved.
//

internal class Chats {
    
    //MARK: Variables

    internal let chatRoomID: String
    internal let lastMessage: String
    internal let upadtedTime: Int
    internal let jobAppliedTime: String
    internal let jobPostedTime: String
    internal let isClosed: String
    internal let companyName: String
    internal let lastOnline: String
    internal let name: String
    internal let online: String
    internal let profilePicture: String
    internal let isRemoved: String
    internal let employerID: String
    internal let title: String
    internal let jobSeekerID: String
    internal let employerJobActionTypeID: String
    internal let jobStatus: String

    //MARK: Initializer

    init(chatRoomID: String, lastMessage: String, upadtedTime: Int, jobAppliedTime: String, jobPostedTime: String, isClosed: String, companyName: String, lastOnline: String, name: String, online: String, profilePicture: String, isRemoved: String, employerID: String, title: String, jobSeekerID: String, employerJobActionTypeID: String, jobStatus: String) {
        self.chatRoomID = chatRoomID
        self.lastMessage = lastMessage
        self.upadtedTime = upadtedTime
        self.jobAppliedTime = jobAppliedTime
        self.jobPostedTime = jobPostedTime
        self.isClosed = isClosed
        self.companyName = companyName
        self.lastOnline = lastOnline
        self.name = name
        self.online = online
        self.profilePicture = profilePicture
        self.isRemoved = isRemoved
        self.employerID = employerID
        self.title = title
        self.jobSeekerID = jobSeekerID
        self.employerJobActionTypeID = employerJobActionTypeID
        self.jobStatus = jobStatus

    }
}
