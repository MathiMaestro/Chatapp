//
//  ChatVC.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 02/10/22.
//

import UIKit

class ChatVC: UIViewController {
    
    var chatId : String = ""
    
    init(chatId: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatId = chatId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Chat"
    }
}
