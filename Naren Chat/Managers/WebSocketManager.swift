//
//  WebSocketManager.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 26/09/22.
//

import SocketIO

class IOSocketManager {

    let manager = SocketManager(socketURL: URL(string: "\(NCAPI.baseURL)")!, config: [.log(false), .compress,.connectParams(["user_id" : "\(UserDetailUtil.shared.userData?.id ?? "")"])])
    var socket: SocketIOClient? = nil

    init() {
//        self.delegate = delegate
        setupSocket()
        setupSocketEvents()
        socket?.connect()
    }

    func stop() {
        socket?.removeAllHandlers()
    }

    func setupSocket() {
        self.socket = manager.defaultSocket
    }

    
    func setupSocketEvents() {

        socket?.on(clientEvent: .connect) {data, ack in
//            self.delegate?.didConnect()
            print(data)
        }
        
        socket?.on("incoming", callback: { data, ack in
            print(data)
        })
    }

}
