//
//  WebSocketManager.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 26/09/22.
//

import SocketIO

enum MessageType {
    case typing
    case newMessage
    case status
    case newChat
    case sentMessageRead
    case none
}

enum NotificationObserverName {
    static let newMessageKey            = Notification.Name("newMessageKey")
    static let newChatKey               = Notification.Name("newChatKey")
    static let messageTypingKey         = Notification.Name("messageTypingKey")
    static let activeStatusKey          = Notification.Name("activeStatusKey")
    static let sentMessageReadKey       = Notification.Name("messageReadKey")
}

class IOSocketManager {

    static let shared = IOSocketManager()
    
    private var manager : SocketManager?    = nil
    private var socket: SocketIOClient?     = nil

    init() {
        setupSocket()
        socket?.connect()
    }

    func stop() {
        socket?.removeAllHandlers()
    }

    private func setupSocket() {
        manager = SocketManager(socketURL: URL(string: "\(NCAPI.baseURL)")!, config: [.log(false), .compress,.connectParams(["user_id" : "\(UserDetailUtil.shared.userData?.id ?? "")"])])
        socket = manager?.defaultSocket
    }
    
    private func getType(for typeString: String) -> MessageType {
        switch typeString {
        case "typing":
            return .typing
        case "newmessage":
            return .newMessage
        case "status":
            return .status
        case "newchat":
            return .newChat
        case "chatmeta","msgmeta":
            return .sentMessageRead
        default:
            return .none
        }
    }

    func connectSocket() {
        socket?.on(clientEvent: .connect) {data, ack in
            print("connected successfully")
        }
        
        socket?.on("incoming", callback: { [weak self] data, ack in
            guard let self, let jsonDicts = data as? [[String:Any]], let jsonDict = jsonDicts.first, let mode = jsonDict["$mode"] as? String, let dataDict = jsonDict["data"] as? [String:Any] else {
                return
            }
            let messageType = self.getType(for: mode)
            switch messageType {
            case .typing:
                ChatUtils.shared.updateTyping(for: dataDict)
                NotificationCenter.default.post(name: NotificationObserverName.messageTypingKey, object: nil, userInfo: dataDict)
            case .newMessage:
                guard let newMessageDict    = self.prepareNewMessageData(jsonDict: dataDict) else { return }
                ChatUtils.shared.updateMessage(for: newMessageDict)
                NotificationCenter.default.post(name: NotificationObserverName.newMessageKey, object: nil, userInfo: newMessageDict)
            case .newChat:
                guard let chat = self.getChatData(jsonDict: dataDict) else { return }
                ChatUtils.shared.createNewChat(chat: chat)
                ContactsUtils.shared.fetchFriendsList { result in
                    switch result {
                    case .success(_):
                        NotificationCenter.default.post(name: NotificationObserverName.newChatKey, object: nil, userInfo: ["chat":chat])
                    case .failure(let error):
                        print(error)
                    }
                }
            case .status:
                guard let userStatusDetail = self.getStatusData(jsonDict: dataDict) else { return }
                ContactsUtils.shared.updateContactStatus(with: userStatusDetail)
                NotificationCenter.default.post(name: NotificationObserverName.activeStatusKey, object: nil)
            case .sentMessageRead:
                if let chatId = dataDict["chat_id"] as? String, let isRead = dataDict["read"] as? Bool, isRead {
                    self.updateSentMessageRead(chatId: chatId)
                } else if let chatId = dataDict["chat_id"] as? String, let isRead = dataDict["is_read"] as? Bool, isRead{
                    self.updateSentMessageRead(chatId: chatId)
                }
            case .none:
                print(jsonDict)
            }
        })
    }
    
    private func updateSentMessageRead(chatId: String) {
        ChatUtils.shared.updatelastMessageAsRead(for: chatId)
        NotificationCenter.default.post(name: NotificationObserverName.sentMessageReadKey, object: nil, userInfo: ["chat_id":chatId])
    }
    
    private func prepareNewMessageData(jsonDict: [String:Any]) -> [String:Any]? {
        var newMessageDict : [String:Any] = [:]
        guard let chatId = jsonDict["chat_id"] as? String, let messageDict = jsonDict["message"] as? [String:Any], let data = NCNetworkUtils.getData(from: messageDict) else { return nil }
        do {
            let message                 = try NCNetworkUtils.decoder.decode(Message.self, from: data)
            newMessageDict["chatId"]    = chatId
            newMessageDict["message"]   = message
            return newMessageDict
        } catch {
            return nil
        }
    }
    
    private func getChatData(jsonDict: [String:Any]) -> Chat? {
        guard let data = NCNetworkUtils.getData(from: jsonDict) else { return nil }
        do {
            let chat = try NCNetworkUtils.decoder.decode(Chat.self, from: data)
            return chat
        } catch {
            return nil
        }
    }
    
    private func getStatusData(jsonDict: [String:Any])  -> UserStatusDetail? {
        guard let data = NCNetworkUtils.getData(from: jsonDict) else { return nil }
        do {
            let userStatusDetail = try NCNetworkUtils.decoder.decode(UserStatusDetail.self, from: data)
            return userStatusDetail
        } catch {
            return nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


struct UserStatusDetail : Codable {
    let status: String
    let lastOnline: Double
    let id: String
}
