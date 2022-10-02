//
//  ContactsNetworkManager.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 02/10/22.
//

import Foundation

class ContactsNetworkManager {
    
    static let shared = ContactsNetworkManager()
    
    func getFriendsList(completed: @escaping (Result<[UserData],NCError>) -> Void) {
        guard let url = URL(string: NCAPI.getAPI(for: .friendList)), let token = PersistenceManager.token else {
            completed(.failure(.invalidToken))
            return
        }
        var urlRequest = NCNetworkUtils.createUrlRequest(for: url, httpMethod: .get)
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        
        NetworkManager.shared.makeRequest(with: urlRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let jsonDict = jsonObj as? [String:Any], let dictData = jsonDict["data"] as? [[String: Any]], let friendsListData = NCNetworkUtils.getData(from: dictData) else {
                        completed(.failure(.invalidResponse))
                        return
                    }
                    let friendsList = try NCNetworkUtils.decoder.decode([UserData].self, from: friendsListData)
                    completed(.success(friendsList))
                } catch {
                    completed(.failure(.invalidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
}
