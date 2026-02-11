//
//  AppDelegate.swift
//  MedCare
//
//  Created by Romi on 30/1/26.
//
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        UNUserNotificationCenter.current().delegate = self
        print("🚀 AppDelegate listo y delegado asignado")
        requestNotificationPermission() // <-- aquí pedimos permiso al inicio
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {

        let id = response.notification.request.identifier
        print("👉 TAP en notificación:", id)

        if id.hasPrefix("med_") {
            print("📣 Publicando evento abrirVocabulario")
            NotificationCenter.default.post(name: .abrirVocabulario, object: nil)
        }

        completionHandler()
    }
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Error pidiendo permiso:", error)
            } else {
                print("🔔 Permiso de notificaciones:", granted)
            }
        }
    }
}

