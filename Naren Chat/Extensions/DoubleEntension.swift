//
//  DoubleEntension.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 01/10/22.
//

import Foundation

extension Double {
    
    func convertToDate() -> Date? {
        return Date(timeIntervalSince1970: self/1000)
    }
    
}
