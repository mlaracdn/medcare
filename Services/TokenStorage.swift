//
//  TokenStorage.swift
//  MedCare
//
//  Created by Romi on 30/1/26.
//

import Foundation

final class TokenStorage {

    static let shared = TokenStorage()
    private let tokenKey = "token"

    private init() {}

    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}


