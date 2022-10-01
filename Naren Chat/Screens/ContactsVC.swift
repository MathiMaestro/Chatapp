//
//  ContactsVC.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 26/09/22.
//

import UIKit

class ContactsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Contacts"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
    }

}
