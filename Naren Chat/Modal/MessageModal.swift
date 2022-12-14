//
//  MessageModal.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 07/10/22.
//

import Foundation


struct MessagesOrderedData {
    var sectionData : [String: [Message]]
    var sectionOrder : [String]
    var hasMore : Bool
    
    init(sectionData: [String: [Message]] = [:], sectionOrder: [String] = [], hasMore: Bool = true) {
        self.sectionData = sectionData
        self.sectionOrder = sectionOrder
        self.hasMore = hasMore
    }
}


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
    var isRead      : Bool?
    let type        : String?
    
    init(_id: String? = nil, senderId: String? = nil, text: String? = nil, time: Double? = nil, isDelivered: Bool? = nil, isRead: Bool? = nil, type: String? = nil) {
        self._id = _id
        self.senderId = senderId
        self.text = text
        self.time = time
        self.isDelivered = isDelivered
        self.isRead = isRead
        self.type = type
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs._id == rhs._id && lhs.senderId == rhs.senderId && lhs.text == rhs.text && lhs.time == rhs.time && lhs.isDelivered == rhs.isDelivered && lhs.isRead == rhs.isRead && lhs.type == rhs.type
    }
    
    func isReceived() -> Bool {
         return senderId != UserDetailUtil.shared.userData?.id
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
