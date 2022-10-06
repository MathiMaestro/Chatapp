//
//  ChatListModal.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 28/09/22.
//

import Foundation

class ChatListData : Codable {
    let chats   : [Chat]
    let hasMore : Bool
}

class Chat : Codable, Hashable {
    let _id              : String
    let participants    : [Participant]
    let totalMessages   : Int
    var unreadCount     : Int
    var lastMessage     : Message
    let createdTime     : Double
    let lastActiveTime  : Double
    var isTyping        : Bool?
    
    func updateLastMessage(message: Message) {
        self.lastMessage    = message
        self.unreadCount    += 1
        self.isTyping       = false
    }
    
    func getSender() -> Participant? {
        return participants.filter({$0._id != UserDetailUtil.shared.userData?.id}).first
    }
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        lhs._id == rhs._id && lhs.participants == rhs.participants && lhs.totalMessages == rhs.totalMessages && lhs.unreadCount == rhs.unreadCount && lhs.lastMessage == rhs.lastMessage && lhs.createdTime == rhs.createdTime && lhs.lastActiveTime == rhs.lastActiveTime && lhs.isTyping == rhs.isTyping
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
        hasher.combine(participants)
        hasher.combine(totalMessages)
        hasher.combine(unreadCount)
        hasher.combine(lastMessage)
        hasher.combine(createdTime)
        hasher.combine(lastActiveTime)
        hasher.combine(isTyping)
    }
    
}

class Participant : Codable,Hashable {
    let _id          : String
    let userName    : String
    let imgUrl      : String
    
    static func == (lhs: Participant, rhs: Participant) -> Bool {
        lhs._id == rhs._id && lhs.userName == rhs.userName &&  lhs.imgUrl == rhs.imgUrl
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
        hasher.combine(userName)
        hasher.combine(imgUrl)
    }
}
