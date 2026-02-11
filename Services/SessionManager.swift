//
//  SessionManager.swift
//  MedCare
//
//  Created by Romi on 30/1/26.
//

import Foundation

final class SessionManager {

    static let shared = SessionManager()
    private init() {}

    func refreshToken(completion: @escaping (Bool) -> Void) {

        guard let token = TokenStorage.shared.token else {
            completion(false)
            return
        }

        guard let url = URL(string: "\(ApiService.shared.baseURL)/refresh") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        print("♻️ Intentando refresh token")

        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard
                let http = response as? HTTPURLResponse,
                http.statusCode == 200,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let newToken = json["token"] as? String
            else {
                print("❌ Refresh falló")
                completion(false)
                return
            }

            print("✅ Token refrescado")
            TokenStorage.shared.token = newToken
            completion(true)

        }.resume()
    }

    func logout() {
        print("🚪 Logout ejecutado")
        TokenStorage.shared.clear()
        NotificationCenter.default.post(name: .logout, object: nil)
    }
}

