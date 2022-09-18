//
//  UIViewControllerExtension.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 18/09/22.
//

import UIKit

extension UIViewController {
    
    func presentNCAlertViewInMainThread(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertVC = NCAlertVC(title: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle  = .overFullScreen
            alertVC.modalTransitionStyle    = .crossDissolve
            self.present(alertVC, animated: true)
        }
    }
}
