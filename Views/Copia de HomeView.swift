import SwiftUI

struct HomeView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack(spacing: 10) {
            // Logo
            Image("logo_medcare")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)

            // Título
            /*
            Text("MedCare")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)
*/
            // Botones
            NavigationLink("💊 Medicinas", destination: MedicinasView())
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
/*
            Button("Forzar refresh") {
                AuthService.shared.refreshToken { success in
                    print("Refresh token result:", success)
                }
            }
            .buttonStyle(.bordered)
*/
            
            Button("📋 Mostrar notificaciones activas") {
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    print("🔔 Notificaciones pendientes: \(requests.count)")
                    for req in requests {
                        let id = req.identifier
                        let title = req.content.title
                        let body = req.content.body
                        let trigger: String
                        if let t = req.trigger as? UNCalendarNotificationTrigger,
                           let date = t.nextTriggerDate() {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm"
                            trigger = formatter.string(from: date)
                        } else {
                            trigger = "desconocido"
                        }
                        print("➡️ ID: \(id) | Título: \(title) | Body: \(body) | Próximo trigger: \(trigger)")
                    }
                }
            }
            .buttonStyle(.bordered)

            
            Button("🚪 Cerrar sesión") {
                UserDefaults.standard.removeObject(forKey: "token")
                isLoggedIn = false
            }
            .foregroundColor(.red)
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("MedCare")
        .navigationBarTitleDisplayMode(.inline) // evita duplicación de título
        .onAppear {
            print("🔐 HomeView cargado. Token:", UserDefaults.standard.string(forKey: "token") ?? "nil")
            programarNotificaciones()
        }
    }
    /*
    private func programarNotificaciones() {
        print("🔔 Programando notificaciones desde HomeView…")
        ApiService.shared.request(endpoint: "/medicinas") { result in
            switch result {
            case .success(let data):
                if let medicinas = try? JSONDecoder().decode([Medicina].self, from: data) {
                    for med in medicinas {
                        NotificationService.shared.programar(medicina: med)
                    }
                    print("🔔 Todas las notificaciones programadas desde Home")
                } else {
                    print("⚠️ No se pudo decodificar medicinas")
                }
            case .failure(let error):
                print("❌ Error cargando medicinas para notificaciones:", error)
            }
        }
    }*/
    private func programarNotificaciones() {
        print("🔔 Programando notificaciones desde HomeView…")
        ApiService.shared.request(endpoint: "/medicinas") { result in
            switch result {
            case .success(let data):
                if let medicinas = try? JSONDecoder().decode([Medicina].self, from: data) {
                    NotificationService.shared.programarTodas(medicinas: medicinas)
                } else {
                    print("⚠️ No se pudo decodificar medicinas")
                }
            case .failure(let error):
                print("❌ Error cargando medicinas para notificaciones:", error)
            }
        }
    }

}


