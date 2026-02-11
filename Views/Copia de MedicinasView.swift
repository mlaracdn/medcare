import SwiftUI

struct MedicinasView: View {

    @State private var medicinas: [Medicina] = []
    @State private var cargando = false
    @State private var error: String?

    var body: some View {
        List {

            if cargando {
                ProgressView("Cargando medicinas…")
            }

            ForEach(medicinas) { med in
                VStack(alignment: .leading, spacing: 6) {

                    Text(med.nombre)
                        .font(.headline)

                    if let dosis = med.dosis, !dosis.isEmpty {
                        Text("Dosis: \(dosis)")
                            .font(.subheadline)
                    }

                    Text(
                        med.frecuencia_horas == 24
                        ? "1 vez al día"
                        : "Cada \(med.frecuencia_horas) horas"
                    )

                    Text("Hora inicio: \(String(med.hora_inicio.prefix(5)))")
                        .font(.caption)

                    if !med.diasOrdenados.isEmpty {
                        Text("Días: \(med.diasOrdenados.map { $0.capitalized }.joined(separator: ", "))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: eliminar)

            if let error = error {
                Text("❌ \(error)")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Medicinas")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("➕", destination: AddMedicinaView())
            }
        }
        .onAppear {
            cargar()
        }
        .refreshable {
            cargar()
        }
    }

    // MARK: - API

    private func cargar() {
        print("📡 Cargando medicinas…")
        cargando = true
        error = nil

        ApiService.shared.request(endpoint: "/medicinas") { result in
            DispatchQueue.main.async {
                cargando = false

                switch result {
                case .success(let data):
                    print("📦 Response size:", data.count)

                    do {
                        medicinas = try JSONDecoder().decode([Medicina].self, from: data)
                        print("✅ Medicinas cargadas:", medicinas.count)
                        for med in medicinas {
                            NotificationService.shared.programar(medicina: med)
                        }

                    } catch {
                        self.error = "Error al leer las medicinas"
                        print("❌ Decode error:", error)
                    }

                case .failure(let err):
                    self.error = err.localizedDescription
                    print("❌ API error:", err.localizedDescription)
                }
            }
        }
    }

    private func eliminar(at offsets: IndexSet) {
        for index in offsets {
            let med = medicinas[index]
            print("🗑 Eliminando medicina:", med.id)

            ApiService.shared.delete(endpoint: "/medicinas/\(med.id)") { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let ok):
                        if ok {
                            medicinas.remove(at: index)
                            print("✅ Medicina eliminada")
                            NotificationService.shared.cancelarNotificaciones(medicinaID: med.id)


                            print("✅ Medicina eliminada y notificaciones canceladas")
                        } else {
                            print("⚠️ El backend respondió pero no eliminó")
                        }

                    case .failure(let error):
                        print("❌ Error al eliminar:", error.localizedDescription)
                    }
                }
            }
        }
    }
}

