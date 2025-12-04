//
//  TaskAppApp.swift
//  TaskApp
//
//  Created by Francisco José García García on 15/10/25.
//

import SwiftUI
import UserNotifications
import SwiftData

@main
struct HabitApp: App {
    // Storage provider obtenido desde AppConfig (LPS-friendly)
    private var storageProvider: StorageProvider {
        AppConfig.shared.storageProvider
    }
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared

        // Programar notificación diaria al iniciar la app
        Task {
            // Cargar hábitos desde el storage provider
            do {
                let habits = try await AppConfig.shared.storageProvider.loadHabits()
                await ReminderManager.shared.scheduleDailyHabitNotification(habits: habits)
            } catch {
                print("Error cargando hábitos para notificaciones: \(error)")
                // Si falla la carga, programar con lista vacía
                await ReminderManager.shared.scheduleDailyHabitNotification(habits: [])
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            // Inyectar el storage provider desde AppConfig
            HabitListView(storageProvider: storageProvider)
        }
        
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    // Mostrar la notificación aunque la app esté en foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .list]
    }
}

