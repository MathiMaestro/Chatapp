//
//  ChatNetworkManager.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 07/10/22.
//

import Foundation

class ChatNetworkManager {
    
    static let shared = ChatNetworkManager()
    
    func getMessages(chatId: String, limit: Int, completed: @escaping (Result<MessagesData,NCError>) -> Void) {
        guard let url = URL(string: NCAPI.getAPI(for: .messages(chatId: chatId, limit: limit))), let token = PersistenceManager.token else {
            completed(.failure(.invalidToken))
            return
        }
        
        NetworkManager.shared.makeRequest(with: url, httpMethod: .get, token: token) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let jsonDict = jsonObj as? [String:Any], let dictData = jsonDict["data"] as? [String: Any], let mesageDictData = NCNetworkUtils.getData(from: dictData) else {
                        completed(.failure(.invalidResponse))
                        return
                    }
                    let messagesData = try NCNetworkUtils.decoder.decode(MessagesData.self, from: mesageDictData)
                    completed(.success(messagesData))
                } catch {
                    completed(.failure(.invalidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
}
