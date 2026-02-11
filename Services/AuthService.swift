//
//  AuthService.swift
//  MedCare
//
//  Created by Romi on 30/1/26.
//

import Foundation
final class AuthService {
    static let shared = AuthService()

    private init() {}

    func refreshToken(completion: @escaping (Bool) -> Void) {
        guard let token = TokenStorage.shared.token else {
            completion(false)
            return
        }

        var request = URLRequest(url: URL(string: "\(ApiService.shared.baseURL)/refresh")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let http = response as? HTTPURLResponse else {
                completion(false)
                return
            }

            if http.statusCode == 200,
               let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let newToken = json["access_token"] as? String {

                TokenStorage.shared.token = newToken
                print("🔄 Token renovado")
                completion(true)
            } else {
                print("❌ Refresh falló")
                completion(false)
            }
        }.resume()
    }
}
