//
//  ReminderManager.swift
//  HabitApp
//
//  Created by Aula03 on 3/12/25.
//

import Foundation
import UserNotifications
import SwiftData

final class ReminderManager {
    static let shared = ReminderManager()
    private init() {}

    // MARK: - Authorization
    
    func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus != .authorized else { return }

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                print("Permiso de notificaciones concedido")
            } else {
                print("Permiso de notificaciones denegado")
            }
        } catch {
            print("Error solicitando autorizacion: \(error)")
        }
    }

    // MARK: - Daily Habit Notification
    
    /// Carga los hábitos y programa la notificación diaria a las 00:00
    func scheduleDailyHabitNotification() async {
        guard AppConfig.enableReminders else {
            print("Reminders deshabilitados en AppConfig")
            return
        }
        
        // Cargar hábitos desde SwiftData
        guard let context = SwiftDataContext.shared else {
            print("SwiftDataContext no disponible para notificaciones")
            return
        }
        
        do {
            let descriptor = FetchDescriptor<Habit>()
            let habits = try context.fetch(descriptor)
            
            // Programar notificación con los hábitos cargados
            await scheduleNotification(with: habits)
        } catch {
            print("Error cargando hábitos para notificaciones: \(error)")
        }
    }
    
    /// Programa la notificación diaria con los hábitos proporcionados
    private func scheduleNotification(with habits: [Habit]) async {
        await requestAuthorizationIfNeeded()

        let identifier = "daily_habits_notification"

        await UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])

        var dateComponents = DateComponents()
        dateComponents.hour = 0
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "Habitos de Hoy"
        content.body = generateHabitListMessage(habits: habits, for: Date())
        content.sound = .default
        content.categoryIdentifier = "HABIT_REMINDER"

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Notificacion diaria programada a las 00:00")
        } catch {
            print("Error programando notificacion diaria: \(error)")
        }
    }
    
    private func generateHabitListMessage(habits: [Habit], for date: Date) -> String {
        let todayHabits = habits.filter { habit in
            habit.shouldBeCompletedOn(date: date)
        }
        
        guard !todayHabits.isEmpty else {
            return "No tienes habitos programados para hoy. Disfruta tu dia!"
        }
        
        let habitList = todayHabits
            .map { " \(.title)" }
            .joined(separator: "\n")
        
        let count = todayHabits.count
        let header = count == 1 ? "Tienes 1 habito hoy:" : "Tienes \(count) habitos hoy:"
        
        return "\(header)\n\(habitList)"
    }
    
    // MARK: - Cancellation
    
    func cancelDailyHabitNotification() async {
        let identifier = "daily_habits_notification"
        await UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Notificacion diaria cancelada")
    }
    
    func cancelAllNotifications() async {
        await UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Todas las notificaciones canceladas")
    }
}
