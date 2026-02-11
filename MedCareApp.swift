/*
import SwiftUI

@main
struct MedCareApp: App {
    @State private var isLoggedIn: Bool = false

    init() {
        // Comprobar si ya hay un token válido
        if let _ = UserDefaults.standard.string(forKey: "token") {
            _isLoggedIn = State(initialValue: true)
        }
    }

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                HomeView(isLoggedIn: $isLoggedIn)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
    
}
*/
/*
import SwiftUI

@main
struct MedCareApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isLoggedIn = false
    @State private var abrirVocabulario: Bool = false

    init() {
        if UserDefaults.standard.string(forKey: "token") != nil {
            _isLoggedIn = State(initialValue: true)
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isLoggedIn {
                    HomeView(isLoggedIn: $isLoggedIn)
                        .navigationDestination(isPresented: $abrirVocabulario) {
                            VocabularioView()
                        }
                } else {
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .abrirVocabulario)) { _ in
                print("📥 Evento abrirVocabulario recibido en App")
                abrirVocabulario = true
            }
        }
    }

}
*/

import SwiftUI

@main
struct MedCareApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isLoggedIn = false
    @State private var abrirVocabulario: Bool = false

    init() {
        if UserDefaults.standard.string(forKey: "token") != nil {
            _isLoggedIn = State(initialValue: true)
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isLoggedIn {
                    HomeView(isLoggedIn: $isLoggedIn)
                        .navigationDestination(isPresented: $abrirVocabulario) {
                            VocabularioView()
                        }
                } else {
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            }
            // 🔔 abrir vocabulario desde notificación
            .onReceive(NotificationCenter.default.publisher(for: .abrirVocabulario)) { _ in
                print("📥 Evento abrirVocabulario recibido en App")
                abrirVocabulario = true
            }
            // 🚪 logout automático por token expirado
            .onReceive(NotificationCenter.default.publisher(for: .logout)) { _ in
                print("🚪 Logout recibido en App")
                isLoggedIn = false
                abrirVocabulario = false
            }
        }
    }
}
