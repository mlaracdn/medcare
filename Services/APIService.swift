import Foundation

class ApiService {
    static let shared = ApiService()
    let baseURL = "https://medcare.mlconsultores.com/api"

    private init() {}

    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["email": email.trimmingCharacters(in: .whitespacesAndNewlines),
                                   "password": password]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        print("📤 LOGIN BODY:", body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }

            let raw = String(data: data, encoding: .utf8) ?? ""
            print("📦 LOGIN RAW RESPONSE:", raw) // <-- <--- agrega este log

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = json["token"] as? String {
                completion(.success(token))
            } else {
                completion(.failure(NSError(domain: "LoginError", code: 0)))
            }
        }.resume()
    }

    // MARK: - Request genérico
    func request(endpoint: String, method: String = "GET", body: [String: Any]? = nil, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
/*
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Token enviado: \(token.prefix(20))...")
        }
*/
        if let token = TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Token enviado: \(token.prefix(20))...")
        }
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            print("📤 Body enviado: \(body)")
        }

        print("📡 \(method) \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            if let http = response as? HTTPURLResponse {
                print("📤 Status code: \(http.statusCode)")
                /*
                if http.statusCode == 401 {
                    print("⚠️ Unauthorized - revisar token")
                }
                 */
                /*
                if http.statusCode == 401 {
                    print("⚠️ Token expirado, intentando refresh")

                    SessionManager.shared.refreshToken { success in
                        if success {
                            print("🔁 Reintentando request")
                            self.request(endpoint: endpoint, method: method, body: body, completion: completion)
                        } else {
                            SessionManager.shared.logout()
                        }
                    }
                    return
                }
                 */
                if http.statusCode == 401 {
                    print("⚠️ Token expirado, intentando refresh")
                    
                    AuthService.shared.refreshToken { success in
                        DispatchQueue.main.async {
                            if success {
                                print("♻️ Refresh exitoso, reintentando request")
                                self.request(endpoint: endpoint, method: method, body: body, completion: completion)
                            } else {
                                print("❌ Refresh falló, logout")
                                NotificationCenter.default.post(name: .logout, object: nil)
                                completion(.failure(NSError(domain: "Auth", code: 401)))
                            }
                        }
                    }
                    return
                }

            }
            if let data = data {
                let raw = String(data: data, encoding: .utf8) ?? ""
                print("📦 Response cruda:", raw)
                completion(.success(data))
            }
        }.resume()
    }

    // MARK: - DELETE
    func delete(endpoint: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                let success = (response as? HTTPURLResponse)?.statusCode == 200
                completion(.success(success))
            }
        }.resume()
    }
}

