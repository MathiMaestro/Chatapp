//
//  LoginViewController.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 10/09/22.
//

import UIKit

class LoginViewController: UIViewController {

    private let logoImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode   = .scaleAspectFill
        imageView.image         = UIImage(systemName: "person")
        imageView.tintColor     = .systemGray
        return imageView
    }()
    
    private let usernameTextField       = NCTextField(placeHolderName: "Enter a username", isPassword: false)
    private let passwordTextField       = NCTextField(placeHolderName: "Enter a password", isPassword: true)
    private let loginButton             = NCLoginButton(buttonTitle: "Login", buttonColor: .systemGray)
    private let signupDescriptionLabel  = NCSignupLabel(textColor: .secondaryLabel, text: "Don't you have an account yet?")
    private let signupLabel             = NCSignupLabel(textColor: .systemBlue, text: "Sign up")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
        configureTap()
    }
    
    private func configureUI() {
        view.addSubViews(logoImageView,usernameTextField,passwordTextField,loginButton,signupDescriptionLabel,signupLabel)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor,constant: 80),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 180),
            logoImageView.heightAnchor.constraint(equalToConstant: 180),
            
            usernameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            signupLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            signupLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            signupDescriptionLabel.bottomAnchor.constraint(equalTo: signupLabel.topAnchor, constant: -10),
            signupDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func configureTap() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        let signUpTap = UITapGestureRecognizer(target: self, action: #selector(signUpButtonTapped))
        signupLabel.addGestureRecognizer(signUpTap)
    }
    
    @objc func loginButtonTapped() {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        NetworkManager.shared.login(with: username, password: password) { result in
            print(result)
        }
    }
    
    @objc func signUpButtonTapped() {
        
    }
    
}

extension UIView {
    
    func addSubViews(_ views: UIView...) {
        for view in views { addSubview(view) }
    }
}
