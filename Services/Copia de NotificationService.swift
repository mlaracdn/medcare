import Foundation
import UserNotifications

final class NotificationService {

    static let shared = NotificationService()
    private init() {}

    // MARK: - Public

    func programar(medicina: Medicina) {
        //cancelarNotificaciones(medicinaID: medicina.id)

        let dias = medicina.dias_semana
        let frecuencia = max(medicina.frecuencia_horas, 1)

        guard let horaBase = obtenerHoraMinuto(medicina.hora_inicio) else {
            print("❌ Hora inválida")
            return
        }

        for dia in dias {
            let weekday = weekdayNumber(from: dia)

            var hora = horaBase.hour
            let minuto = horaBase.minute

            while hora < 24 {
                crearNotificacion(
                    medicina: medicina,
                    weekday: weekday,
                    hour: hora,
                    minute: minuto
                )

                hora += frecuencia
            }
        }
    }

    func cancelarNotificaciones(medicinaID: Int) {
        UNUserNotificationCenter.current()
            .getPendingNotificationRequests { requests in
                let ids = requests
                    .filter { $0.identifier.hasPrefix("med_\(medicinaID)_") }
                    .map { $0.identifier }

                UNUserNotificationCenter.current()
                    .removePendingNotificationRequests(withIdentifiers: ids)

                print("🗑 Notificaciones eliminadas: \(ids.count)")
            }
    }

    // MARK: - Private

    private func crearNotificacion(
        medicina: Medicina,
        weekday: Int,
        hour: Int,
        minute: Int
    ) {
        let content = UNMutableNotificationContent()
        content.title = "💊 Hora de tu medicina"

        let dosisTexto = formatoDosis(medicina.dosis)

        if dosisTexto.isEmpty {
            content.body = medicina.nombre
        } else {
            content.body = "\(medicina.nombre) – \(dosisTexto)"
        }
        
        
        content.sound = .default

        
        // 🔥 CLAVE
        content.userInfo = [
            "medicina_id": medicina.id
        ]
        
        var date = DateComponents()
        date.weekday = weekday
        date.hour = hour
        date.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: date,
            repeats: true
        )

        let id = "med_\(medicina.id)_\(weekday)_\(hour)\(minute)"

        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: id,
                content: content,
                trigger: trigger
            )
        )

        print("🔔 Notificación programada: \(id) → día \(weekday) \(hour):\(minute)")
    }

    private func obtenerHoraMinuto(_ hora: String) -> (hour: Int, minute: Int)? {
        let parts = hora.split(separator: ":")
        guard parts.count >= 2,
              let h = Int(parts[0]),
              let m = Int(parts[1]) else { return nil }
        return (h, m)
    }

    /*private func weekdayNumber(from dia: String) -> Int {
        switch dia.lowercased() {
        case "domingo": return 1
        case "lunes": return 2
        case "martes": return 3
        case "miércoles", "miercoles": return 4
        case "jueves": return 5
        case "viernes": return 6
        case "sábado", "sabado": return 7
        default: return 1
        }
    }
     */
    private func weekdayNumber(from dia: String) -> Int {
        let normalizado = dia
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch normalizado {
        case "domingo": return 1
        case "lunes": return 2
        case "martes": return 3
        case "miércoles", "miercoles": return 4
        case "jueves": return 5
        case "viernes": return 6
        case "sábado", "sabado": return 7
        default:
            print("⚠️ Día no reconocido:", dia)
            return 1
        }
    }

    private func formatoDosis(_ dosis: String?) -> String {
        guard let dosis = dosis?.trimmingCharacters(in: .whitespacesAndNewlines),
              !dosis.isEmpty else {
            return ""
        }

        return dosis
    }
            
}

