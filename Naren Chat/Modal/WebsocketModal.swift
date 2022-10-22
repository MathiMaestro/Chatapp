//
//  WebsocketModal.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 23/10/22.
//

import Foundation

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
