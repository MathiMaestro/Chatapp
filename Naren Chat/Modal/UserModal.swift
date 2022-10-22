//
//  UserModal.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 23/09/22.
//

import Foundation

class UserData : Codable, Hashable {
    
    var id              : String?
    var _id             : String?
    var userName        : String
    var emailId         : String?
    var imgUrl          : String
    var totalChats      : Int?
    var unreadChats     : Int?
    var joinedTime      : Double?
    var lastOnline      : Double
    var status          : String
    
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs._id == rhs._id && lhs.id == rhs.id && lhs.userName == rhs.userName && lhs.emailId == rhs.emailId && lhs.imgUrl == rhs.imgUrl && lhs.joinedTime == rhs.joinedTime
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
        hasher.combine(id)
        hasher.combine(userName)
        hasher.combine(emailId)
        hasher.combine(imgUrl)
        hasher.combine(joinedTime)
    }
}
