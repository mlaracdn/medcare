import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var cargando = false
    @State private var errorMensaje: String?
    @State private var mostrarError: Bool = false

    var body: some View {
        VStack(spacing: 30) {
            // Logo
            Image("logo_medcare")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)

            Text("Bienvenido a MedCare")
                .font(.title)
                .bold()

            // Inputs
            TextField("Correo electrónico", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            SecureField("Contraseña", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            if let error = errorMensaje {
                Text(error)
                    .foregroundColor(.red)
            }

            // Botón login
            Button(action: login) {
                if cargando {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    Text("Iniciar sesión")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
        }
        .padding()
    }
/*
    private func login() {
        cargando = true
        errorMensaje = nil
        ApiService.shared.login(email: email, password: password) { success in
            DispatchQueue.main.async {
                self.cargando = false
                if success {
                    self.isLoggedIn = true
                    print("✅ Login exitoso")
                } else {
                    self.errorMensaje = "Correo o contraseña incorrecta"
                    print("❌ Login fallido")
                }
            }
        }
    }
 */
    func login() {
            guard !email.isEmpty, !password.isEmpty else {
                errorMensaje = "Por favor ingresa email y contraseña."
                mostrarError = true
                return
            }

            print("🔥 Login presionado")
            ApiService.shared.login(email: email, password: password) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let token):
                        // Guardamos el token
                        UserDefaults.standard.set(token, forKey: "token")
                        print("✅ Login exitoso, token guardado:", token.prefix(20), "...")

                        // Cambiamos estado de login
                        isLoggedIn = true

                    case .failure(let error):
                        errorMensaje = "Error al hacer login: \(error.localizedDescription)"
                        mostrarError = true
                        print("❌ Login failed:", error.localizedDescription)
                    }
                }
            }
        }
}

