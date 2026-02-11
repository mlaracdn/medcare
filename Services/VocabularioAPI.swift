//
//  VocabularioAPI.swift
//  MedCare
//
//  Created by Romi on 30/1/26.
//

import Foundation

final class VocabularioAPI {

    static let shared = VocabularioAPI()
    private init() {}
    //private let baseURL = "\(baseURL)/api/vocabulario"
    private let baseURL = ApiService.shared.baseURL + "/vocabulario"

    // 🔹 GET siguiente palabra
    func obtenerSiguiente(completion: @escaping (Vocabulario?) -> Void) {

        let urlString = "\(ApiService.shared.baseURL)/vocabulario/siguiente"
        print("🌐 URL:", urlString)

        guard let url = URL(string: urlString) else {
            print("❌ URL inválida")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
/*
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Token enviado")
        } else {
            print("❌ NO hay token")
        }
*/
        if let token = TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Token enviado: \(token.prefix(20))...")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("❌ Error de red:", error.localizedDescription)
                completion(nil)
                return
            }

            if let http = response as? HTTPURLResponse {
                print("📡 Status code:", http.statusCode)
            }

            guard let data = data else {
                print("❌ No llegó data")
                completion(nil)
                return
            }

            print("📦 Respuesta RAW:")
            print(String(data: data, encoding: .utf8) ?? "No UTF8")

            do {
                let palabra = try JSONDecoder().decode(Vocabulario.self, from: data)
                completion(palabra)
            } catch {
                print("❌ Error decoding:", error)
                completion(nil)
            }

        }.resume()
    }

    // 🔹 POST marcar como mostrada
    func marcarVocabulario(vocabularioId: Int, completion: @escaping (Bool) -> Void) {
        
        let urlString = "\(ApiService.shared.baseURL)/vocabulario/marcar"
        print("🌐 POST:", urlString)
        
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        /*if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }*/
        if let token = TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Token enviado: \(token.prefix(20))...")
        }
        
        // 👇 BODY QUE FALTABA
        let body: [String: Any] = [
            "vocabulario_id": vocabularioId
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("📤 Body enviado:", body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("❌ Error marcar:", error.localizedDescription)
                completion(false)
                return
            }
            
            if let http = response as? HTTPURLResponse {
                print("📡 Status marcar:", http.statusCode)
                if http.statusCode != 200 {
                    completion(false)
                    return
                }
            }
            
            guard let data = data else {
                completion(false)
                return
            }
            
            print("📦 Respuesta marcar:")
            print(String(data: data, encoding: .utf8) ?? "no utf8")
            
            completion(true)
            
        }.resume()
    }
}
