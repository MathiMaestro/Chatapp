//
//  MessageModal.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 07/10/22.
//

import Foundation

class MessagesData : Codable {
    let messages: [Message]
    let hasMore : Bool
    
    init(messages: [Message], hasMore: Bool) {
        self.messages   = messages
        self.hasMore    = hasMore
    }
}

class Message : Codable, Hashable {
    let _id          : String?
    let senderId    : String?
    let text        : String?
    let time        : Double?
    let isDelivered : Bool?
    let isRead      : Bool?
    let type        : String?
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs._id == rhs._id && lhs.senderId == rhs.senderId && lhs.text == rhs.text && lhs.time == rhs.time && lhs.isDelivered == rhs.isDelivered && lhs.isRead == rhs.isRead && lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
        hasher.combine(senderId)
        hasher.combine(text)
        hasher.combine(time)
        hasher.combine(isDelivered)
        hasher.combine(isRead)
        hasher.combine(type)
    }
}
