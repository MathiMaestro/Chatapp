//
//  ContactsUtils.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 02/10/22.
//

import Foundation

class ContactsUtils {
    
    static let shared = ContactsUtils()
    
    var friendList : [UserData] = []
    
//    func addContact(newContact: UserData) {
//        friendList.append(newContact)
//    }
//
    func fetchFriendsList(completed: @escaping (Result<Bool,NCError>) -> Void) {
        guard let url = URL(string: NCAPI.getAPI(for: .friendList)), let token = PersistenceManager.token else {
            completed(.failure(.invalidToken))
            return
        }
        
        NetworkManager.shared.makeRequest(with: url, httpMethod: .get, token: token) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let jsonDict = jsonObj as? [String:Any], let dictData = jsonDict["data"] as? [[String: Any]], let friendsListData = NCNetworkUtils.getData(from: dictData) else {
                        completed(.failure(.invalidResponse))
                        return
                    }
                    self.friendList = try NCNetworkUtils.decoder.decode([UserData].self, from: friendsListData)
                    completed(.success(true))
                } catch {
                    completed(.failure(.invalidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
}
