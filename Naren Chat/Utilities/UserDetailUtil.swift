//
//  UserDetailUtil.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 21/09/22.
//

import UIKit

class UserDetailUtil {
    
    static let shared           = UserDetailUtil()
    var userData : UserData?    = nil
    let cache = NSCache<NSString,UIImage>()
    
    func removeUserData() {
        PersistenceManager.token = nil
        reset()
        ChatUtils.shared.reset()
        ContactsUtils.shared.reset()
        IOSocketManager.shared.stop()
    }
    
    func isUserLoggedinAlready() -> Bool {
        guard let _ = PersistenceManager.token else { return false }
        return true
    }
    
    func getUserDetails(completed: @escaping (NCError?) -> Void) {
        LoginNetworkManager.shared.getUserDetails { [unowned self] result in
            switch result {
            case .success(let userData):
                self.userData = userData
                completed(nil)
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    func reset() {
        cache.removeAllObjects()
        userData = nil
    }
    
}

struct UserStatusDetail : Codable {
    let status: String
    let lastOnline: Double
    let id: String
}
