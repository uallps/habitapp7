//
//  Streak.swift
//  HabitApp
//
//  Created by Francisco José García García on 16/11/25.
//
import Foundation
import SwiftData

// MARK: - Modelo intermedio para SwiftData

@Model
final class HabitStreakFeature {
    @Attribute(.unique) var id: UUID
    var habitId: UUID
    var streak: Int
    var maxStreak: Int
    var nextDayTimestamp: Double?
    
    // Relación inversa con Habit
    var habit: Habit?
    
    init(habitId: UUID, streak: Int = 0, maxStreak: Int = 0, nextDay: Date? = nil) {
        self.id = UUID()
        self.habitId = habitId
        self.streak = streak
        self.maxStreak = maxStreak
        self.nextDayTimestamp = nextDay?.timeIntervalSince1970
    }
    
    var nextDay: Date? {
        get {
            guard let timestamp = nextDayTimestamp else { return nil }
            return Date(timeIntervalSince1970: timestamp)
        }
        set {
            nextDayTimestamp = newValue?.timeIntervalSince1970
        }
    }
}

// MARK: - Extensión de Habit con computed properties

extension Habit {
    var streak: Int {
        get {
            return streakFeature?.streak ?? 0
        }
        set {
            if let feature = streakFeature {
                feature.streak = newValue
            } else {
                let newFeature = HabitStreakFeature(habitId: self.id, streak: newValue)
                newFeature.habit = self
                self.streakFeature = newFeature
            }
        }
    }
    
    var maxStreak: Int {
        get {
            return streakFeature?.maxStreak ?? 0
        }
        set {
            if let feature = streakFeature {
                feature.maxStreak = newValue
            } else {
                let newFeature = HabitStreakFeature(habitId: self.id, maxStreak: newValue)
                newFeature.habit = self
                self.streakFeature = newFeature
            }
        }
    }
    
    var nextDay: Date? {
        get {
            return streakFeature?.nextDay
        }
        set {
            if let feature = streakFeature {
                feature.nextDay = newValue
            } else {
                let newFeature = HabitStreakFeature(habitId: self.id, nextDay: newValue)
                newFeature.habit = self
                self.streakFeature = newFeature
            }
        }
    }
    
     func checkAndUpdateStreak() { //aqui ponia mutating
        let today = Calendar.current.startOfDay(for: Date())
        
        guard let next = nextDay else {
            // Primera vez, inicializar nextDay
            nextDay = calculateNextDay(from: today)
            return
        }
        
        let nextDayStart = Calendar.current.startOfDay(for: next)
        
        // Si hoy es el día esperado
        if Calendar.current.isDate(today, inSameDayAs: nextDayStart) {
            if isCompletedToday {
                // Completado: incrementar streak y calcular siguiente día
                streak += 1
                
                // Actualizar maxStreak si el actual es mayor
                if streak > maxStreak {
                    maxStreak = streak
                }
                
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
