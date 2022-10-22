//
//  MessageUtils.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 07/10/22.
//

import Foundation

class MessageUtils {
    
    typealias sectionData   = [String: [Message]]
    static let shared       = MessageUtils()
    private var messages    = [Message]()
    lazy var messageData    = MessagesOrderedData()
    var unreadMessages      = [Message]()
    private var chatId      = ""
    
    var orderedMessageData: MessagesOrderedData = MessagesOrderedData()
    
    func getMessages(chatId: String, limit: Int, completed: @escaping (Result<Bool,NCError>) -> Void) {
        guard let url = URL(string: NCAPI.getAPI(for: .messages(chatId: chatId, limit: limit))), let token = PersistenceManager.token else {
            completed(.failure(.invalidToken))
            return
        }
        self.chatId = chatId
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
                    self.messages           = messagesData.messages
                    self.prepareMessageData(messagesData: messagesData)
                    self.readUpdate(chatId: chatId)
                    completed(.success(true))
                } catch {
                    completed(.failure(.invalidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    func updateMessage(with messageDict: [String:Any], completed: @escaping (Result<Bool,NCError>) -> Void) {
        guard let url = URL(string: NCAPI.getAPI(for: .sendMessage(chatId: chatId))), let token = PersistenceManager.token else {
            completed(.failure(.invalidToken))
            return
        }
        let bodyData = NCNetworkUtils.getData(from: messageDict)
        NetworkManager.shared.makeRequest(with: url, httpMethod: .post, body: bodyData, token: token) { result in
            switch result {
            case .success(_):
                completed(.success(true))
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    private func readUpdate(chatId: String) {
        guard !unreadMessages.isEmpty else { return }
        updateMessageAsRead()
        ChatUtils.shared.updatelastMessageAsRead(for: chatId)
    }
    
    private func updateMessageAsRead() {
        guard let url = URL(string: NCAPI.getAPI(for: .messageRead(chatId: chatId))), let token = PersistenceManager.token else {
            print(NCError.invalidToken.rawValue)
            return
        }
        NetworkManager.shared.makeRequest(with: url, httpMethod: .post, token: token) { result in
            switch result {
            case .success(_):
               print("read successfully")
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
    
    private func prepareMessageData(messagesData: MessagesData) {
        
        var messageData     = getOrderedMessageData(messages: messagesData.messages)
        messageData.hasMore = messagesData.hasMore
        self.messageData    = messageData
    }
    
    private func setUnreadMessagesAsRead() {
        updateMessageAsRead()
        for message in unreadMessages {
            message.isRead = true
            
        }
    }
    
    func updateNewMessage(with message: Message, isSent: Bool) {
        if isSent {
            if let dateString = message.time?.convertToDate()?.convertToDateString() {
                if !messageData.sectionOrder.contains(dateString) {
                    messageData.sectionOrder.append(dateString)
                }
                if var messages = messageData.sectionData[dateString] {
                    messages.append(message)
                    messageData.sectionData[dateString] = messages
                } else {
                    messageData.sectionData[dateString] = [message]
                }
            }
        } else {
            let newMessagesection = "New messages"
            if !messageData.sectionOrder.contains(newMessagesection) {
                messageData.sectionOrder.append(newMessagesection)
            }
            if var messages = messageData.sectionData[newMessagesection] {
                messages.append(message)
                messageData.sectionData[newMessagesection] = messages
            } else {
                messageData.sectionData[newMessagesection] = [message]
            }
        }
        messages.insert(message, at: 0)
    }
    
    func getOrderedMessageData(messages: [Message]) -> MessagesOrderedData {
        var sectionOrder : [String]     = []
        var sectionData : sectionData   = [:]
        
        for message in messages.reversed() {
            if !(message.isRead ?? true) && message.senderId != UserDetailUtil.shared.userData?.id {
                let newMessagesection = "New messages"
                if !sectionOrder.contains(newMessagesection) {
                    sectionOrder.append(newMessagesection)
                }
                if var messages = sectionData[newMessagesection] {
                    messages.append(message)
                    sectionData[newMessagesection] = messages
                } else {
                    sectionData[newMessagesection] = [message]
                }
                unreadMessages.append(message)
            } else {
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
        }
        return MessagesOrderedData(sectionData: sectionData, sectionOrder: sectionOrder)
    }
    
    
    func removeNewMessages() {
        guard let messages = messageData.sectionData["New messages"], !messages.isEmpty else { return }
        for message in messages {
            if let dateString = message.time?.convertToDate()?.convertToDateString() {
                if !messageData.sectionOrder.contains(dateString) {
                    messageData.sectionOrder.append(dateString)
                }
                if var messages = messageData.sectionData[dateString] {
                    messages.append(message)
                    messageData.sectionData[dateString] = messages
                } else {
                    messageData.sectionData[dateString] = [message]
                }
            }
        }
        messageData.sectionOrder.removeLast()
        messageData.sectionData["New messages"] = nil
    }
    
    func updateMessagesFor(chatId: String, message: Message) {
        guard self.chatId == chatId else { return }
        removeNewMessages()
        if message.senderId != UserDetailUtil.shared.userData?.id {
            updateNewMessage(with: message, isSent: false)
            unreadMessages = []
            updateMessageAsRead()
            ChatUtils.shared.updatelastMessageAsRead(for: chatId)
        } else {
            updateNewMessage(with: message, isSent: true)
        }
    }
    
    func reset() {
        messages        = []
        messageData     = MessagesOrderedData()
        unreadMessages  = []
        chatId          = ""
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
