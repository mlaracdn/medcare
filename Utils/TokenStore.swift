//
//  TokenStore.swift
//  MedCare
//
//  Created by Romi on 29/1/26.
//

import Foundation

class TokenStore {
    static let shared = TokenStore()

    var token: String? {
        get { UserDefaults.standard.string(forKey: "jwt_token") }
        set { UserDefaults.standard.set(newValue, forKey: "jwt_token") }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: "jwt_token")
    }
}

