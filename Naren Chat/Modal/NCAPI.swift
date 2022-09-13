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
}

class NCAPI {
    
    static let baseURL         = "https://chitchat20.herokuapp.com"
    static let connectionURL   = "/api"
    
    static func getAPI(for type: APIType) -> String {
        var api = baseURL + connectionURL
        
        switch type {
        case .login:
            api += "/user/check"
        case .register:
            api += "/register"
        }
        
        return api
    }
}
