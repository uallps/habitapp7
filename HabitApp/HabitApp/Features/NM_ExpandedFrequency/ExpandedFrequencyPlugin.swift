import SwiftUI
import SwiftData

class ExpandedFrequencyPlugin: NSObject, FeaturePlugin, ViewPlugin, LogicPlugin {
    var id: String { "NM_ExpandedFrequency" }
    var models: [any PersistentModel.Type] { [ExpandedFrequency.self] }

    private var frequencyCache: [UUID: ExpandedFrequency] = [:]
    
    // MARK: - ViewPlugin
    
    func habitModificationSection(habit: Habit, context: ModelContext) -> AnyView? {
        AnyView(FrequencySelectionView(habitID: habit.id, context: context))
    }
    
    func habitRowCompletionView(habit: Habit, toggleAction: @escaping () -> Void) -> AnyView? {
        if let freq = loadFrequency(for: habit), freq.type == .addiction {
            return AnyView(AddictionCompletionView(habit: habit, toggleAction: toggleAction))
        }
        
        return nil
    }
    
    func onHabitSave(habit: Habit, context: ModelContext) {
        // Invalidar caché para asegurar que se recarguen los cambios recientes
        frequencyCache.removeValue(forKey: habit.id)
        
        // Si es adicción, forzamos que el tipo sea binario para evitar conflictos con NM_Type
        if let freq = loadFrequency(for: habit), freq.type == .addiction {
            // Intentamos buscar si existe configuración de HabitType (del plugin NM_Type)
            // y la reseteamos a .binary para que la vista de adicción tenga prioridad.
            let habitID = habit.id
            let descriptor = FetchDescriptor<HabitType>(predicate: #Predicate { $0.habitID == habitID })
            
            if let type = try? context.fetch(descriptor).first {
                type.type = .binary
            }
        }
    }
    
    // MARK: - LogicPlugin
    
    func shouldHabitBeCompletedOn(habit: Habit, date: Date) -> Bool? {
        if let freq = loadFrequency(for: habit) {
            switch freq.type {
            case .daily:
                return nil // Use default logic
            case .weekly, .monthly, .addiction:
                return true // Show every day
            }
        }
        
        return nil
    }
    
    func isHabitCompleted(habit: Habit, date: Date) -> Bool? {
        if let freq = loadFrequency(for: habit) {
            switch freq.type {
            case .daily:
                return nil // Usa lógica por defecto
                
            case .weekly:
                // Completado si hay AL MENOS UNA entrada en la semana actual
                return hasEntryInWeek(habit: habit, date: date)
                
            case .monthly:
                // Completado si hay AL MENOS UNA entrada en el mes actual
                return hasEntryInMonth(habit: habit, date: date)
                
            case .addiction:
                // Adicción: Completado (Éxito) si NO hay entrada ese día
                let hasEntry = habit.completed.contains { 
                    Calendar.current.isDate($0.date, inSameDayAs: date) 
                }
                return !hasEntry
            }
        }
        
        return nil
    }
    
    func getCompletionPeriodType(habit: Habit) -> CompletionPeriodType? {
        if let freq = loadFrequency(for: habit) {
            switch freq.type {
            case .daily:
                return .daily
            case .weekly:
                return .weekly
            case .monthly:
                return .monthly
            case .addiction:
                return .daily // Las adicciones se manejan día a día
            }
        }
        return nil
    }
    
    // MARK: - Streak Calculation
    
    func calculateCurrentStreak(habit: Habit, on date: Date) -> Int? {
        guard let freq = loadFrequency(for: habit), freq.type != .daily && freq.type != .addiction else {
            return nil // Usar lógica por defecto para diario y adicción
        }
        
        // Para weekly y monthly, calcular racha basada en el periodo
        return habit.getStreakFeature()?.streak ?? 0
    }
    
    func updateStreakOnCompletion(habit: Habit, on date: Date) -> Bool {
        guard let freq = loadFrequency(for: habit) else {
            return false // No manejado por este plugin
        }
        
        switch freq.type {
        case .daily, .addiction:
            return false // Usar lógica por defecto
            
        case .weekly:
            updateWeeklyStreak(habit: habit, on: date)
            return true
            
        case .monthly:
            updateMonthlyStreak(habit: habit, on: date)
            return true
        }
    }
    
    private func updateWeeklyStreak(habit: Habit, on date: Date) {
        let calendar = Calendar.current
        guard let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start else {
            return
        }
        
        let next = habit.getNextDay()
        
        guard let nextWeekStart = next else {
            // Primera vez
            habit.setNextDay(currentWeekStart)
            return
        }
        
        if calendar.isDate(currentWeekStart, inSameDayAs: nextWeekStart) {
            // Semana actual
            if habit.isCompleted(on: date) {
                var currentStreak = habit.getStreak()
                currentStreak += 1
                habit.setStreak(currentStreak)
                
                let currentMax = habit.getMaxStreak()
                if currentStreak > currentMax {
                    habit.setMaxStreak(currentStreak)
                }
                
                if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) {
                    habit.setNextDay(nextWeek)
                }
            }
        } else if currentWeekStart > nextWeekStart {
            // Semana pasada sin completar
            habit.setStreak(0)
            habit.setNextDay(currentWeekStart)
        }
    }
    
    private func updateMonthlyStreak(habit: Habit, on date: Date) {
        let calendar = Calendar.current
        guard let currentMonthStart = calendar.dateInterval(of: .month, for: date)?.start else {
            return
        }
        
        let next = habit.getNextDay()
        
        guard let nextMonthStart = next else {
            // Primera vez
            habit.setNextDay(currentMonthStart)
            return
        }
        
        if calendar.isDate(currentMonthStart, inSameDayAs: nextMonthStart) {
            // Mes actual
            if habit.isCompleted(on: date) {
                var currentStreak = habit.getStreak()
                currentStreak += 1
                habit.setStreak(currentStreak)
                
                let currentMax = habit.getMaxStreak()
                if currentStreak > currentMax {
                    habit.setMaxStreak(currentStreak)
                }
                
                if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonthStart) {
                    habit.setNextDay(nextMonth)
                }
            }
        } else if currentMonthStart > nextMonthStart {
            // Mes pasado sin completar
            habit.setStreak(0)
            habit.setNextDay(currentMonthStart)
        }
    }
    
    // MARK: - Stats Calculation
    
    func calculateTotalPeriodsActive(habit: Habit, until date: Date) -> (value: Int, label: String)? {
        guard let freq = loadFrequency(for: habit) else {
            return nil
        }
        
        guard let firstDate = habit.completed.map({ $0.date }).min() else {
            return nil
        }
        
        let calendar = Calendar.current
        
        switch freq.type {
        case .daily, .addiction:
            return nil // Usar lógica por defecto
            
        case .weekly:
            let components = calendar.dateComponents([.weekOfYear], from: firstDate, to: date)
            let weeks = (components.weekOfYear ?? 0) + 1
            return (weeks, "semanas")
            
        case .monthly:
            let components = calendar.dateComponents([.month], from: firstDate, to: date)
            let months = (components.month ?? 0) + 1
            return (months, "meses")
        }
    }
    
    func calculateTotalPeriodsCompleted(habit: Habit) -> (value: Int, label: String)? {
        guard let freq = loadFrequency(for: habit) else {
            return nil
        }
        
        switch freq.type {
        case .daily, .addiction:
            return nil // Usar lógica por defecto
            
        case .weekly:
            let count = countUniqueWeeks(habit: habit)
            return (count, "semanas")
            
        case .monthly:
            let count = countUniqueMonths(habit: habit)
            return (count, "meses")
        }
    }
    
    func getStreakLabel(habit: Habit) -> String? {
        guard let freq = loadFrequency(for: habit) else {
            return nil
        }
        
        switch freq.type {
        case .daily, .addiction:
            return nil // Usar valor por defecto "dias"
            
        case .weekly:
            return "semanas"
            
        case .monthly:
            return "meses"
        }
    }
    
    private func countUniqueWeeks(habit: Habit) -> Int {
        let calendar = Calendar.current
        let uniqueWeeks = Set(habit.completed.compactMap { entry -> String? in
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: entry.date) else {
                return nil
            }
            let formatter = ISO8601DateFormatter()
            return formatter.string(from: weekInterval.start)
        })
        return uniqueWeeks.count
    }
    
    private func countUniqueMonths(habit: Habit) -> Int {
        let calendar = Calendar.current
        let uniqueMonths = Set(habit.completed.compactMap { entry -> String? in
            guard let monthInterval = calendar.dateInterval(of: .month, for: entry.date) else {
                return nil
            }
            let formatter = ISO8601DateFormatter()
            return formatter.string(from: monthInterval.start)
        })
        return uniqueMonths.count
    }
    
    private func hasEntryInWeek(habit: Habit, date: Date) -> Bool {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return false
        }
        return habit.completed.contains { entry in
            weekInterval.contains(entry.date)
        }
    }
    
    private func hasEntryInMonth(habit: Habit, date: Date) -> Bool {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return false
        }
        return habit.completed.contains { entry in
            monthInterval.contains(entry.date)
        }
    }

    private func loadFrequency(for habit: Habit) -> ExpandedFrequency? {
        guard let context = habit.modelContext else { return nil }

        if let cached = frequencyCache[habit.id] {
            return cached
        }

        let habitID = habit.id
        let descriptor = FetchDescriptor<ExpandedFrequency>(
            predicate: #Predicate { $0.habitID == habitID }
        )

        if let freq = try? context.fetch(descriptor).first {
            frequencyCache[habitID] = freq
            return freq
        }

        return nil
    }
}
