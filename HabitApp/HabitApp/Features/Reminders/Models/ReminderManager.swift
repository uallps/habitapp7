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
    private var modelContext: ModelContext?
    private var enableReminders: Bool = true
    private var lastScheduledDayKey: String?
    private var lastScheduledMessage: String?
    private let dailyNotificationIdentifier = "daily_habits_notification"
    
    private init() {}
    
    /// Configura el contexto necesario para acceder a los hábitos
    func configure(modelContext: ModelContext, enableReminders: Bool) {
        self.modelContext = modelContext
        self.enableReminders = enableReminders
    }

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
        guard enableReminders else {
            print("Reminders deshabilitados en AppConfig")
            return
        }
        
        // Verificar que tenemos contexto configurado
        guard let context = modelContext else {
            print("ModelContext no configurado en ReminderManager")
            return
        }
        
        do {
            let descriptor = FetchDescriptor<Habit>()
            let habits = try context.fetch(descriptor)
            let today = Date()
            let message = generateHabitListMessage(habits: habits, for: today)
            let dayKey = dayKey(for: today)

            if lastScheduledDayKey == dayKey, lastScheduledMessage == message {
                if await hasPendingDailyNotification() {
                    return
                }
            }
            
            let scheduled = await scheduleNotification(message: message)
            if scheduled {
                lastScheduledDayKey = dayKey
                lastScheduledMessage = message
            }
        } catch {
            print("Error cargando hábitos para notificaciones: \(error)")
        }
    }
    
    /// Programa la notificación diaria
    private func scheduleNotification(message: String) async -> Bool {
        await requestAuthorizationIfNeeded()

        await UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [dailyNotificationIdentifier])

        var dateComponents = DateComponents()
        dateComponents.hour = 0
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "Hábitos de Hoy"
        content.body = message
        content.sound = .default
        content.categoryIdentifier = "HABIT_REMINDER"

        let request = UNNotificationRequest(
            identifier: dailyNotificationIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Notificación diaria programada a las 00:00")
            return true
        } catch {
            print("Error programando notificación diaria: \(error)")
            return false
        }
    }

    private func hasPendingDailyNotification() async -> Bool {
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return pending.contains { $0.identifier == dailyNotificationIdentifier }
    }

    private func dayKey(for date: Date) -> String {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return String(Int(startOfDay.timeIntervalSince1970))
    }
    
    private func generateHabitListMessage(habits: [Habit], for date: Date) -> String {
        let todayHabits = habits.filter { habit in
            habit.shouldBeCompletedOn(date: date)
        }
        
        guard !todayHabits.isEmpty else {
            return "No tienes hábitos programados para hoy. Disfruta tu día!"
        }
        
        let habitList = todayHabits
            .map { " \($0.title)" }
            .joined(separator: "\n")
        
        let count = todayHabits.count
        let header = count == 1 ? "Tienes 1 hábito hoy:" : "Tienes \(count) hábitos hoy:"
        
        return "\(header)\n\(habitList)"
    }
    
    // MARK: - Cancellation
    
    func cancelDailyHabitNotification() async {
        await UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [dailyNotificationIdentifier])
        print("Notificación diaria cancelada")
    }
    
    func cancelAllNotifications() async {
        await UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Todas las notificaciones canceladas")
    }
}
