//
//  DateExtension.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 01/10/22.
//

import Foundation

extension Date {
    
    func convertToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle                     = .short
        dateFormatter.dateStyle                     = .short
        dateFormatter.doesRelativeDateFormatting    = true
        return dateFormatter.string(from: self)
    }
    
    func convertToDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle                     = .none
        dateFormatter.dateStyle                     = .long
        dateFormatter.doesRelativeDateFormatting    = true
        return dateFormatter.string(from: self)
    }

    func convertToTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle                     = .short
        dateFormatter.dateStyle                     = .none
        dateFormatter.doesRelativeDateFormatting    = true
        return dateFormatter.string(from: self)
    }
}
