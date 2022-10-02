//
//  NCAPI.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 14/09/22.
//

import Foundation

enum APIType {
    case login
    case register
    case checkUsername
    case checkEmailId
    case isValidUser
    case chatList
    case friendList
}

class NCAPI {
    
    static let baseURL         = "https://chitchat20.herokuapp.com"
    static let connectionURL   = "/api"
    
    static func getAPI(for type: APIType) -> String {
        var api = baseURL + connectionURL
        
        switch type {
        case .login:
            api += "/login"
        case .register:
            api += "/register"
        case .checkUsername:
            api += "/user/check?user_name="
        case .checkEmailId:
            api += "/user/check?email_id="
        case .isValidUser:
            api += "/user"
        case .chatList:
            api += "/chats?limit="
        case .friendList:
            api += "/user/friends"
        }
        
        return api
    }
}
