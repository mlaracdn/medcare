import Foundation

struct Medicina: Codable, Identifiable {
    let id: Int
    let usuario_id: Int
    let nombre: String
    let dosis: String?
    let inicio: String?
    let fin: String?
    let frecuencia_horas: Int
    let dias_semana: [String]
    let hora_inicio: String
    let created_at: String

    var diasOrdenados: [String] {
        let orden = ["lunes","martes","miércoles","jueves","viernes","sábado","domingo"]
        return orden.filter { dias_semana.contains($0) }
    }

    private enum CodingKeys: String, CodingKey {
        case id, usuario_id, nombre, dosis, inicio, fin, frecuencia_horas, dias_semana, hora_inicio, created_at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        usuario_id = try container.decode(Int.self, forKey: .usuario_id)
        nombre = try container.decode(String.self, forKey: .nombre)
        dosis = try? container.decode(String.self, forKey: .dosis)
        inicio = try? container.decode(String.self, forKey: .inicio)
        fin = try? container.decode(String.self, forKey: .fin)
        frecuencia_horas = try container.decode(Int.self, forKey: .frecuencia_horas)
        hora_inicio = try container.decode(String.self, forKey: .hora_inicio)
        created_at = try container.decode(String.self, forKey: .created_at)

        let diasString = try container.decode(String.self, forKey: .dias_semana)
        if let data = diasString.data(using: .utf8),
           let array = try? JSONDecoder().decode([String].self, from: data) {
            dias_semana = array
        } else {
            dias_semana = []
        }
    }
}

