//
//  NCError.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 14/09/22.
//

import Foundation

enum NCError : String, Error {
    case networkConnection  = "Kindly check your internet connection."
    case inavlidResponse    = "Invalid response from the server. Please try again."
    case invalidData        = "The data received from the server is invalid. Please try again."
    case invalidLoginUrl    = "This username / password created an invalid request. Please try again."
    case unknown            = "Something went wrong! Please try again."
}
