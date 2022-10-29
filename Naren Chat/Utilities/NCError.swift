//
//  NCError.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 14/09/22.
//

import Foundation

enum NCError : String, Error {
    case networkConnection  = "Kindly check your internet connection."
    case invalidResponse    = "Invalid response from the server. Please try again."
    case invalidData        = "The data received from the server is invalid. Please try again."
    case invalidPassowrd    = "The password you entered is incorrect. Kindly enter a correct passowrd"
    case invalidUser        = "The username you entered is incorrect. Kindly enter a valid username"
    case existedUser        = "This username is already in use. Kindly enter a another one"
    case existedEmail       = "This email id already registered. Kindly go to login page"
    case registerFail       = "Sorry!. Something went wrong. Unable to register your account."
    case registerSuccess    = "Account created successfully! Please go to login page"
    case invalidToken       = "Session expired. Logging out"
    case unknown            = "Something went wrong! Please try again."
    case deleteFailure      = "Sorry!. Something went wrong! Unable to delete your account."
    case profilePicUpdate   = "Sorry!. Something went wrong! Unable to update your profile pic"
}
