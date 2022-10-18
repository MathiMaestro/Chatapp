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
    case checkUsername(userName: String)
    case checkEmailId(emailId: String)
    case isValidUser
    case chatList(limit: Int)
    case friendList
    case delete
    case messages(chatId: String,limit: Int)
    case messageRead(chatId: String)
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
        case .checkUsername(let userName):
            api += "/user/check?user_name=\(userName)"
        case .checkEmailId(let emailId):
            api += "/user/check?email_id=\(emailId)"
        case .isValidUser:
            api += "/user"
        case .chatList(let limit):
            api += "/chats?limit=\(limit)"
        case .friendList:
            api += "/user/friends"
        case .delete:
            api += "/user"
        case .messages(let chatId, let limit):
            api += "/chats/\(chatId)/messages?limit=\(limit)"
        case .messageRead(let chatId):
            api += "/chats/\(chatId)/read"
        }
        
        return api
    }
}
