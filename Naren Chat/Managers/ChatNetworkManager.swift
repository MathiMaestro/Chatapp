//
//  ChatNetworkManager.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 07/10/22.
//

import Foundation

class ChatNetworkManager {
    
    typealias sectionData = [String: [Message]]
    static let shared = ChatNetworkManager()
    
    func getMessages(chatId: String, limit: Int, completed: @escaping (Result<MessagesOrderedData,NCError>) -> Void) {
        guard let url = URL(string: NCAPI.getAPI(for: .messages(chatId: chatId, limit: limit))), let token = PersistenceManager.token else {
            completed(.failure(.invalidToken))
            return
        }
        
        NetworkManager.shared.makeRequest(with: url, httpMethod: .get, token: token) { [unowned self] result in
            switch result {
            case .success(let data):
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let jsonDict = jsonObj as? [String:Any], let dictData = jsonDict["data"] as? [String: Any], let mesageDictData = NCNetworkUtils.getData(from: dictData) else {
                        completed(.failure(.invalidResponse))
                        return
                    }
                    let messagesData = try NCNetworkUtils.decoder.decode(MessagesData.self, from: mesageDictData)
                    let orderedMessagesData = self.prepareMessageData(messagesData: messagesData)
                    completed(.success(orderedMessagesData))
                } catch {
                    completed(.failure(.invalidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    private func prepareMessageData(messagesData: MessagesData) -> MessagesOrderedData {
        var sectionOrder : [String]     = []
        var sectionData : sectionData   = [:]
        for message in messagesData.messages.reversed() {
            if let dateString = message.time?.convertToDate()?.convertToDateString() {
                if !sectionOrder.contains(dateString) {
                    sectionOrder.append(dateString)
                }
                if var messages = sectionData[dateString] {
                    messages.append(message)
                    sectionData[dateString] = messages
                } else {
                    sectionData[dateString] = [message]
                }
            }
        }
        return MessagesOrderedData(sectionData: sectionData, sectionOrder: sectionOrder, hasMore: messagesData.hasMore)
    }
    
}
