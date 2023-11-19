//
//  SharedDefaults.swift
//  Glassnode At A Glance
//
//  Created by Ondrej Barta on 18.11.23.
//

import Foundation

struct SharedDefaults {
    static let userDefaults = UserDefaults(suiteName: "73N8SZQ662")
    
    private enum Keys {
        static let apiKey = "apiKey"
    }
    
    static func setApiKey(_ apiKey: String?) {
        userDefaults?.set(apiKey, forKey: Keys.apiKey)
    }
    
    static func getApiKey() -> String? {
        return userDefaults?.string(forKey: Keys.apiKey)
    }
}
