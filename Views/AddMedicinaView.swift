import SwiftUI

struct AddMedicinaView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var dosis = ""
    @State private var frecuencia = 8
    @State private var horaInicio = Date()
    @State private var diasSeleccionados: Set<String> = []

    private let diasSemana = ["lunes","martes","miércoles","jueves","viernes","sábado","domingo"]
    private let frecuencias = [2,4,6,8,12,24]

    var body: some View {
        Form {

            Section(header: Text("Información")) {
                TextField("Nombre", text: $nombre)
                TextField("Dosis", text: $dosis)
            }

            Section(header: Text("Frecuencia")) {
                Picker("Cada cuántas horas", selection: $frecuencia) {
                    ForEach(frecuencias, id: \.self) { f in
                        Text(f == 24 ? "1 vez al día" : "Cada \(f) horas").tag(f)
                    }
                }
                .pickerStyle(.menu)
            }

            Section(header: Text("Hora de inicio")) {
                DatePicker(
                    "Hora",
                    selection: $horaInicio,
                    displayedComponents: .hourAndMinute
                )
            }

            Section(header: Text("Días de la semana")) {
                ForEach(diasSemana, id: \.self) { dia in
                    Toggle(dia.capitalized, isOn: Binding(
                        get: { diasSeleccionados.contains(dia) },
                        set: { activo in
                            if activo {
                                diasSeleccionados.insert(dia)
                            } else {
                                diasSeleccionados.remove(dia)
                            }
                        }
                    ))
                }
            }

            Button("Guardar") {
                guardar()
            }
            .disabled(nombre.isEmpty || diasSeleccionados.isEmpty)
        }
        .navigationTitle("Nueva Medicina")
    }

    private func guardar() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let body: [String: Any] = [
            "nombre": nombre,
            "dosis": dosis,
            "frecuencia_horas": frecuencia,
            "hora_inicio": formatter.string(from: horaInicio),
            "dias_semana": Array(diasSeleccionados)
        ]

        print("📤 Enviando medicina:", body)

        ApiService.shared.request(
            endpoint: "/medicinas",
            method: "POST",
            body: body
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Medicina creada → volver a la lista")
                    dismiss()   // 🔥 ESTO ES TODO LO QUE HAY QUE HACER
                case .failure(let error):
                    print("❌ Error:", error.localizedDescription)
                }
            }
        }
    }
}

