//
//  Streak.swift
//  HabitApp
//
//  Created by Francisco José García García on 16/11/25.
//
import Foundation

// Extensión de Streaks para Habit
extension Habit {
    private var streakKey: String {
        "habit_streak_\(id.uuidString)"
    }
    
    private var nextDayKey: String {
        "habit_nextday_\(id.uuidString)"
    }
    
    var streak: Int {
        get {
            UserDefaults.standard.integer(forKey: streakKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: streakKey)
        }
    }
    
    var nextDay: Date? {
        get {
            if let timestamp = UserDefaults.standard.object(forKey: nextDayKey) as? Double {
                return Date(timeIntervalSince1970: timestamp)
            }
            return nil
        }
        set {
            if let date = newValue {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: nextDayKey)
            } else {
                UserDefaults.standard.removeObject(forKey: nextDayKey)
            }
        }
    }
    
    mutating func checkAndUpdateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        guard let next = nextDay else {
            // Primera vez, inicializar nextDay
            nextDay = calculateNextDay(from: today)
            return
        }
        
        let nextDayStart = Calendar.current.startOfDay(for: next)
        
        // Si hoy es el día esperado
        if Calendar.current.isDate(today, inSameDayAs: nextDayStart) {
            if isCompleted {
                // Completado: incrementar streak y calcular siguiente día
                streak += 1
                nextDay = calculateNextDay(from: today)
            } else {
                // No completado: resetear streak
                streak = 0
                nextDay = calculateNextDay(from: today)
            }
        } else if today > nextDayStart {
            // Se pasó el día sin completar: resetear streak
            streak = 0
            nextDay = calculateNextDay(from: today)
        }
    }
    
    private func calculateNextDay(from date: Date) -> Date? {
        guard !frequency.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: date)
        
        // Convertir frequency a números de día de la semana (1=Sunday, 2=Monday, etc.)
        let frequencyWeekdays = frequency.map { weekday -> Int in
            switch weekday {
            case .sunday: return 1
            case .monday: return 2
            case .tuesday: return 3
            case .wednesday: return 4
            case .thursday: return 5
            case .friday: return 6
            case .saturday: return 7
            }
        }.sorted()
        
        // Buscar el siguiente día en la frecuencia
        for weekday in frequencyWeekdays {
            if weekday > currentWeekday {
                let daysToAdd = weekday - currentWeekday
                return calendar.date(byAdding: .day, value: daysToAdd, to: date)
            }
        }
        
        // Si no hay ninguno mayor, el siguiente es el primero de la próxima semana
        if let firstWeekday = frequencyWeekdays.first {
            let daysToAdd = 7 - currentWeekday + firstWeekday
            return calendar.date(byAdding: .day, value: daysToAdd, to: date)
        }
        
        return nil
    }
}
