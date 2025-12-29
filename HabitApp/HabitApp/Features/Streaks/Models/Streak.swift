//
//  Streak.swift
//  HabitApp
//
//  Created by Francisco Jose Garcia Garcia on 16/11/25.
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

// MARK: - Extension de Habit con computed properties

extension Habit {
    
    private var activeContext: ModelContext? {
        return self.modelContext ?? SwiftDataContext.shared
    }
    
    private func getStreakFeature() -> HabitStreakFeature? {
        guard let context = activeContext else { return nil }
        let habitId = self.id
        let descriptor = FetchDescriptor<HabitStreakFeature>(
            predicate: #Predicate { $0.habitId == habitId }
        )
        return try? context.fetch(descriptor).first
    }
    
    private func getOrCreateStreakFeature() -> HabitStreakFeature? {
        guard let context = activeContext else { return nil }
        if let feature = getStreakFeature() {
            return feature
        }
        let newFeature = HabitStreakFeature(habitId: self.id)
        context.insert(newFeature)
        return newFeature
    }

    func getStreak() -> Int {
        return getStreakFeature()?.streak ?? 0
    }
    
    func setStreak(_ newValue: Int) {
        getOrCreateStreakFeature()?.streak = newValue
    }
    
    func getMaxStreak() -> Int {
        return getStreakFeature()?.maxStreak ?? 0
    }
    
    func setMaxStreak(_ newValue: Int) {
        getOrCreateStreakFeature()?.maxStreak = newValue
    }
    
    func getNextDay() -> Date? {
        return getStreakFeature()?.nextDay
    }
    
    func setNextDay(_ newValue: Date?) {
        getOrCreateStreakFeature()?.nextDay = newValue
    }
    
    func checkAndUpdateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let next = getNextDay()

        guard let nextDayVal = next else {
            // Primera vez, inicializar nextDay
            let calculated = calculateNextDay(from: today)
            setNextDay(calculated)
            return
        }

        let nextDayStart = Calendar.current.startOfDay(for: nextDayVal)

        // Si el siguiente dia esperado esta en pausa, avanzar sin afectar la racha
        if !shouldBeCompletedOn(date: nextDayStart) {
            setNextDay(calculateNextDay(from: nextDayStart))
            return
        }

        // Si hoy es el dia esperado
        if Calendar.current.isDate(today, inSameDayAs: nextDayStart) {
            if isCompletedToday {
                // Completado: incrementar streak y calcular siguiente dia
                var currentStreak = getStreak()
                currentStreak += 1
                setStreak(currentStreak)
                
                // Actualizar maxStreak si el actual es mayor
                let currentMax = getMaxStreak()
                if currentStreak > currentMax {
                    setMaxStreak(currentStreak)
                }
                
                setNextDay(calculateNextDay(from: today))
            } else {
                // No completado: resetear streak
                setStreak(0)
                setNextDay(calculateNextDay(from: today))
            }
        } else if today > nextDayStart {
            // Se paso el dia sin completar: resetear streak
            setStreak(0)
            setNextDay(calculateNextDay(from: today))
        }
    }
    
    private func calculateNextDay(from date: Date) -> Date? {
        guard !frequency.isEmpty else { return nil }

        var candidate = nextFrequencyDay(after: date)
        var attempts = 0

        while let candidateDate = candidate, attempts < 7 {
            if shouldBeCompletedOn(date: candidateDate) {
                return candidateDate
            }
            candidate = nextFrequencyDay(after: candidateDate)
            attempts += 1
        }

        return nil
    }

    private func nextFrequencyDay(after date: Date) -> Date? {
        guard !frequency.isEmpty else { return nil }

        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: date)

        // Convertir frequency a numeros de dia de la semana (1=Sunday, 2=Monday, etc.)
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
        
        // Buscar el siguiente dia en la frecuencia
        for weekday in frequencyWeekdays {
            if weekday > currentWeekday {
                let daysToAdd = weekday - currentWeekday
                return calendar.date(byAdding: .day, value: daysToAdd, to: date)
            }
        }
        
        // Si no hay ninguno mayor, el siguiente es el primero de la proxima semana
        if let firstWeekday = frequencyWeekdays.first {
            let daysToAdd = 7 - currentWeekday + firstWeekday
            return calendar.date(byAdding: .day, value: daysToAdd, to: date)
        }
        
        return nil
    }
}
