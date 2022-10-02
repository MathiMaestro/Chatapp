//
//  UserModal.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 23/09/22.
//

import Foundation

struct UserData : Codable, Hashable {
    var id              : String?
    var _id             : String?
    var userName        : String
    var emailId         : String?
    var imgUrl          : String
    var totalChats      : Int?
    var unreadChats     : Int?
    var joinedTime      : Int64?
    var lastOnline      : Int64
}
