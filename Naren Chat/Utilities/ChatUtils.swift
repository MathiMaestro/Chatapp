//
//  ChatUtils.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 29/09/22.
//

import Foundation

class ChatUtils {
    
    static let shared = ChatUtils()
    
    var chatList : [Chat] = []
    
    func createNewChat(chat: Chat) {
        chatList.insert(chat, at: 0)
    }
    
    func getChatList(listCount : Int, completed: @escaping (Result<ChatListData,NCError>) -> Void) {
        
        guard let url = URL(string: NCAPI.getAPI(for: .chatList) + "\(listCount)"), let token = PersistenceManager.token else {
            completed(.failure(.unknown))
            return
        }
        var urlRequest = NCNetworkUtils.createUrlRequest(for: url, httpMethod: .get)
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        
        NetworkManager.shared.makeRequest(with: urlRequest) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data)
                    guard let jsonDict = jsonData as? [String: Any], let dictData = jsonDict["data"] as? [String: Any], let chatListData = NCNetworkUtils.getData(from: dictData) else {
                        completed(.failure(.invalidResponse))
                        return
                    }
                    let chatList = try NCNetworkUtils.decoder.decode(ChatListData.self, from: chatListData)
                    self.chatList = chatList.chats
                    completed(.success(chatList))
                } catch {
                    completed(.failure(.invalidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
}
