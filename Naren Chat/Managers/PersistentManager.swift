//
//  PersistentManager.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 18/09/22.
//

import Foundation

enum PersistenceManager {
    static private let defaults = UserDefaults.standard
    
    static var token : String? {
        get {
            return getToken()
        }
        set {
            if let newValue {
                updateToken(with: newValue)
            }
            else {
                removeToken()
            }
        }
    }
    
    private static func updateToken(with token: String?) {
        do {
            let encoder = JSONEncoder()
            let encodedToken = try encoder.encode(token)
            defaults.set(encodedToken, forKey: "token")
        } catch {
            print(error)
        }
    }
    
    private static func getToken() -> String? {
        guard let decodedToken = defaults.object(forKey: "token") as? Data else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(String.self, from: decodedToken)
        } catch {
            return nil
        }
    }
    
    static func removeToken() {
        defaults.removeObject(forKey: "token")
    }
}
