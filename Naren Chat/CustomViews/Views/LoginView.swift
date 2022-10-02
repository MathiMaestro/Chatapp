//
//  LoginView.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 17/09/22.
//

import UIKit

protocol LoginViewToVC : AnyObject {
    
    func actionButtonTapped()
    func actionLabelTapped()
}

class LoginView: UIView {

    private var isSignUp : Bool = false
    
    weak var delegate : LoginViewToVC?
    
    private let logoImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode   = .scaleAspectFill
        imageView.image         = UIImage(systemName: "person")
        imageView.tintColor     = .systemGray
        return imageView
    }()
    
    private let emailTextFieldContainer : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var emailTextFieldContainerHeight : NSLayoutConstraint? = nil
    
    private let usernameTextField   = NCTextField(placeHolderName: "Enter a username")
    private let passwordTextField   = NCTextField(placeHolderName: "Enter a passowrd")
    private let actionButton        = NCButton(buttonColor: .systemGray)
    private let descriptionLabel    = NCBodyLabel(textColor: .secondaryLabel, textAlignment: .center)
    private let actionLabel         = NCBodyLabel(textColor: .systemBlue, textAlignment: .center)
    private let emailTextField      = NCTextField(placeHolderName: "Enter a email id")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    convenience init(isSignUp : Bool) {
        self.init(frame: .zero)
        self.isSignUp = isSignUp
        configureProperties()
        configureActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoginView {
    
    private func configureActions() {
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        let actionLabelTap = UITapGestureRecognizer(target: self, action: #selector(actionLabelTapped))
        actionLabel.addGestureRecognizer(actionLabelTap)
        actionLabel.isUserInteractionEnabled = true
    }
    
    private func configureUI() {
        
        self.addSubViews(logoImageView,usernameTextField,passwordTextField,emailTextFieldContainer,actionButton,descriptionLabel,actionLabel)
        emailTextFieldContainer.addSubview(emailTextField)
        
        emailTextFieldContainerHeight = emailTextFieldContainer.heightAnchor.constraint(equalToConstant: 0)
        emailTextFieldContainerHeight?.isActive = true
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: self.topAnchor,constant: 80),
            logoImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 180),
            logoImageView.heightAnchor.constraint(equalToConstant: 180),
            
            usernameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            usernameTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            emailTextFieldContainer.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            emailTextFieldContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50),
            emailTextFieldContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50),
            
            emailTextField.topAnchor.constraint(equalTo: emailTextFieldContainer.topAnchor),
            emailTextField.leadingAnchor.constraint(equalTo: emailTextFieldContainer.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: emailTextFieldContainer.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextFieldContainer.bottomAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50),
            passwordTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            actionButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor,constant: 20),
            actionButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50),
            actionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            
            actionLabel.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            descriptionLabel.bottomAnchor.constraint(equalTo: actionLabel.topAnchor, constant: -10),
            descriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
    
    private func configureProperties() {
        if isSignUp {
            actionButton.set(title: "Signup")
            descriptionLabel.setTitle(with: "Already have an account?")
            actionLabel.setTitle(with: "login")
            emailTextFieldContainerHeight?.constant = 70
            emailTextFieldContainer.isHidden        = false
        }
        else {
            passwordTextField.configurePropertyForPassword()
            actionButton.set(title: "Login")
            descriptionLabel.setTitle(with: "Don't you have an account yet?")
            actionLabel.setTitle(with: "sign up")
            emailTextFieldContainerHeight?.constant = 0
            emailTextFieldContainer.isHidden        = true
        }
    }
}

extension LoginView {
    
    func getUsernameText() -> String? {
        return usernameTextField.text
    }
    
    func getPasswordText() -> String? {
        return passwordTextField.text
    }
    
    func getEmailIdText() -> String? {
        return emailTextField.text
    }
    
    func resetValues() {
        usernameTextField.text  = ""
        passwordTextField.text  = ""
        emailTextField.text     = ""
    }
    
    @objc func actionButtonTapped() {
        delegate?.actionButtonTapped()
    }
    
    @objc func actionLabelTapped() {
        delegate?.actionLabelTapped()
    }
}
