//
//  UserDetailUtil.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 21/09/22.
//

import Foundation

class UserDetailUtil {
    
    static let shared           = UserDetailUtil()
    var userData : UserData?    = nil
    
    func removeUserData() {
        PersistenceManager.token    = nil
        userData                    = nil
    }
    
    func isUserLoggedinAlready() -> Bool {
        guard let _ = PersistenceManager.token else { return false }
        return true
    }
    
    func getUserDetails(completed: @escaping (NCError?) -> Void) {
        LoginNetworkManager.shared.getUserDetails { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let userData):
                self.userData = userData
                completed(nil)
            case .failure(let error):
                completed(error)
            }
        }
    }
    
}

