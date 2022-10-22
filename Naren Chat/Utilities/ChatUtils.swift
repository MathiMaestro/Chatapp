//
//  ChatUtils.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 29/09/22.
//

import Foundation

class ChatUtils {
    
    static let shared = ChatUtils()
    
    var chatList : [Chat]       = []
    var createdChatList: [Chat] = []
    var allList: [Chat]         = []
    
    private func updateNewMessage(chatId: String, message: Message) {
        if var newChat = createdChatList.filter({$0._id == chatId}).first, let index = createdChatList.firstIndex(of: newChat) {
            createdChatList.remove(at: index)
            newChat.updateLastMessage(message: message)
            chatList.insert(newChat, at: 0)
        } else if var chat = chatList.filter({$0._id == chatId}).first, let index = chatList.firstIndex(of: chat) {
            chat.updateLastMessage(message: message)
            chatList.remove(at: index)
            chatList.insert(chat, at: 0)
        }
    }
    
    func getChatList(listCount : Int, completed: @escaping (Result<ChatListData,NCError>) -> Void) {
        
        guard let url = URL(string: NCAPI.getAPI(for: .chatList(limit: listCount))), let token = PersistenceManager.token else {
            completed(.failure(.unknown))
            return
        }
        
        NetworkManager.shared.makeRequest(with: url, httpMethod: .get, token: token) { [unowned self] result in
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data)
                    guard let jsonDict = jsonData as? [String: Any], let dictData = jsonDict["data"] as? [String: Any], let chatListDictData = NCNetworkUtils.getData(from: dictData) else {
                        completed(.failure(.invalidResponse))
                        return
                    }
                    let chatListData    = try NCNetworkUtils.decoder.decode(ChatListData.self, from: chatListDictData)
                    chatListData.chats  = getValidChatList(chatList: chatListData.chats)
                    completed(.success(chatListData))
                } catch {
                    completed(.failure(.invalidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    private func getValidChatList(chatList: [Chat]) -> [Chat] {
        var createdChatList: [Chat] = []
        var validChatList: [Chat]   = []
        
        validChatList = chatList.filter { chat in
            if chat.lastMessage._id != nil {
                return true
            } else {
                createdChatList.append(chat)
                return false
            }
        }
        self.allList            = chatList
        self.createdChatList    = createdChatList
        self.chatList           = validChatList
        return validChatList
    }
    
    func reset() {
        chatList        = []
        allList         = []
        createdChatList = []
    }
}

//MARK: Websocket updates
extension ChatUtils {
    
    func createNewChat(chat: Chat) {
        createdChatList.insert(chat, at: 0)
    }
    
    func updatelastMessageAsRead(for chatId: String) {
        guard let chat = chatList.filter({$0._id == chatId}).first,let index = chatList.firstIndex(of: chat) else {
            return
        }
        chatList[index].lastMessage.isRead  = true
        chatList[index].unreadCount         = 0
    }
    
    func updateMessage(for messageDict: [String:Any]) {
        guard let chatId = messageDict["chatId"] as? String, let message = messageDict["message"] as? Message else { return }
        
        updateNewMessage(chatId: chatId, message: message)
        MessageUtils.shared.updateMessagesFor(chatId: chatId, message: message)
    }
    
    func getChat(for contact: UserData) -> Chat? {
        guard let chat = allList.filter({$0.getSender()?._id == contact._id}).first else { return nil }
        return chat
    }
    
    func updateTyping(for typingDict: [String:Any]) {
        guard let chatId = typingDict["chat_id"] as? String, let isTyping = typingDict["is_typing"] as? Bool, let chat = chatList.filter({$0._id == chatId}).first,let index = chatList.firstIndex(of: chat) else {
            return
        }
        chatList[index].isTyping = isTyping
    }
}
