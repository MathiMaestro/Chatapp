//
//  SessionUtil.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 02/10/22.
//

import UIKit

enum SessionUtil {
    
    static func goToLogin() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
            window.rootViewController = UINavigationController(rootViewController: LoginVC())
        }
    }
    
}
