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
    case none
}

enum NotificationObserverName {
    static let newMessageKey    = "newMessageKey"
    static let newChatKey       = "newChatKey"
    static let messageTypingKey = "messageTypingKey"
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
                let notificationName = Notification.Name(NotificationObserverName.messageTypingKey)
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: dataDict)
            case .newMessage:
                guard let newMessageDict = self.prepareNewMessageData(jsonDict: dataDict) else { return }
                let notificationName = Notification.Name(NotificationObserverName.newMessageKey)
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: newMessageDict)
            case .newChat:
                guard let chat = self.getChatData(jsonDict: dataDict) else { return }
                ChatUtils.shared.createNewChat(chat: chat)
                let notificationName = Notification.Name(NotificationObserverName.newChatKey)
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["chat":chat])
            case .status:
                print(jsonDict)
            case .none:
                print(jsonDict)
            }
        })
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
