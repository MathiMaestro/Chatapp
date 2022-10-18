//
//  NCTabBarController.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 26/09/22.
//

import UIKit

class NCTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        viewControllers     = [createChatListVC(),createContactsVC(),createSettingsVC()]
    }
    
    deinit {
        print("NCTabBarController deinitialized")
    }
    
    private func createChatListVC() -> UINavigationController {
        let chatListVC          = ChatListVC()
        chatListVC.tabBarItem   = UITabBarItem(title: "Chats", image: UIImage(systemName: "message"), tag: 0)
        return UINavigationController(rootViewController: chatListVC)
    }
    
    private func createContactsVC() -> UINavigationController {
        let contactsVC          = ContactsVC()
        contactsVC.tabBarItem   = UITabBarItem(tabBarSystemItem: .contacts, tag: 1)
        return UINavigationController(rootViewController: contactsVC)
    }
    
    private func createSettingsVC() -> UINavigationController {
        let settingsVC          = SettingsVC()
        settingsVC.tabBarItem   = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 2)
        return UINavigationController(rootViewController: settingsVC)
    }
}
