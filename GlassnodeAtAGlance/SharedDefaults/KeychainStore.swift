//
//  KeychainStore.swift
//  Glassnode At A Glance
//
//  Created by Ondrej Barta on 18.11.23.
//

import Foundation
import KeychainSwift

struct KeychainStore {
    static let shared = KeychainStore()
    private let keychainSwift = KeychainSwift()
    
    private enum Keys {
        static let apiKey = "apiKey"
    }
    
    private init() {
        keychainSwift.accessGroup = "com.bartaxyz.GlassnodeAtAGlance.keychain"
    }
    
    func setApiKey(_ apiKey: String?) {
        guard let apiKey = apiKey, !apiKey.isEmpty else { return }
        keychainSwift.set(apiKey, forKey: Keys.apiKey)
    }

    func getApiKey() -> String? {
        return keychainSwift.get(Keys.apiKey)
    }
}
