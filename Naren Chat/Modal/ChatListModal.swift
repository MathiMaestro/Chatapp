//
//  ChatListModal.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 28/09/22.
//

import Foundation

struct ChatListData : Codable {
    let chats   : [Chat]
    let hasMore : Bool
}

struct Chat : Codable, Hashable {
    let _id              : String
    let participants    : [Participant]
    let totalMessages   : Int
    let unreadCount     : Int
    let lastMessage     : Message
    let createdTime     : Double
    let lastActiveTime  : Double
    
    func getSender() -> Participant? {
        if let participant = participants.filter({$0._id == lastMessage.senderId}).first {
            return participant
        } else {
            return participants.filter({$0._id != UserDetailUtil.shared.userData?.id}).first
        }
    }
}

struct Participant : Codable, Hashable {
    let _id          : String
    let userName    : String
    let imgUrl      : String
}

struct Message : Codable, Hashable {
    let _id          : String?
    let senderId    : String?
    let text        : String?
    let time        : Double?
    let isDelivered : Bool?
    let isRead      : Bool?
    let type        : String?
}
