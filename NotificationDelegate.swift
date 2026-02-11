import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationDelegate()
    var onVocabularyNotification: ((Int) -> Void)?

    private override init() {}

    // Cuando la app está en foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    // Cuando se toca la notificación
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo

        if let vocabID = userInfo["vocabulario_id"] as? Int {
            onVocabularyNotification?(vocabID)
        }

        completionHandler()
    }
}

