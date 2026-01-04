//
//  StatsViewModel.swift
//  HabitApp
//
//  Created by Francisco José García García on 19/11/25.
//
import Foundation
import Combine

class StatsViewModel: ObservableObject {
    @Published var habit: Habit
    
    init(habit: Habit) {
        self.habit = habit
    }
    
    var firstCompletionDate: Date? {
        habit.completed.map { $0.date }.min()
    }
    
    var lastCompletionDate: Date? {
        habit.completed.map { $0.date }.max()
    }
    
    var totalDaysActive: Int {
        return totalDaysActive(until: Date())
    }
    
    func totalDaysActive(until date: Date = Date()) -> Int {
        // Permitir que un plugin calcule los periodos activos
        if let pluginResult = PluginRegistry.shared.calculateTotalPeriodsActive(habit: habit, until: date) {
            return pluginResult.value
        }
        
        // Lógica por defecto (días)
        guard let firstDate = firstCompletionDate else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: firstDate, to: date)
        return (components.day ?? 0) + 1
    }
    
    var totalPeriodsActiveLabel: String {
        if let pluginResult = PluginRegistry.shared.calculateTotalPeriodsActive(habit: habit, until: Date()) {
            return pluginResult.label
        }
        return "dias"
    }
    
    var totalDaysCompleted: Int {
        // Permitir que un plugin calcule los periodos completados
        if let pluginResult = PluginRegistry.shared.calculateTotalPeriodsCompleted(habit: habit) {
            return pluginResult.value
        }
        
        // Lógica por defecto (días)
        return habit.completed.count
    }
    
    var totalPeriodsCompletedLabel: String {
        if let pluginResult = PluginRegistry.shared.calculateTotalPeriodsCompleted(habit: habit) {
            return pluginResult.label
        }
        return "dias"
    }
    
    var completionPercentage: Double {
        guard totalDaysActive > 0 else { return 0.0 }
        return (Double(totalDaysCompleted) / Double(totalDaysActive)) * 100.0
    }
    
    // MARK: - Streak Stats (preparado para cuando Streaks esté activo)
    
    var currentStreak: Int {
        return habit.getStreak()
    }
    
    var longestStreak: Int {
        return habit.getMaxStreak()
    }
    
    var streakLabel: String {
        // Permitir que un plugin determine la unidad de la racha
        if let label = PluginRegistry.shared.getStreakLabel(habit: habit) {
            return label
        }
        return "dias"
    }
    
    var mostCompletedWeekdays: [Weekday] {
        let weekdayCounts = getWeekdayCompletionCounts()
        guard let maxCount = weekdayCounts.values.max(), maxCount > 0 else { return [] }
        
        return weekdayCounts
            .filter { $0.value == maxCount }
            .map { $0.key }
            .sorted { $0.rawValue < $1.rawValue }
    }
    
    var leastCompletedWeekdays: [Weekday] {
        let weekdayCounts = getWeekdayCompletionCounts()
        
        // Incluir todos los días de la frecuencia, incluso con 0 completaciones
        var allDayCounts: [Weekday: Int] = [:]
        for day in habit.frequency {
            allDayCounts[day] = weekdayCounts[day] ?? 0
        }
        
        guard let minCount = allDayCounts.values.min() else { return [] }
        
        return allDayCounts
            .filter { $0.value == minCount }
            .map { $0.key }
            .sorted { $0.rawValue < $1.rawValue }
    }
    
    private func getWeekdayCompletionCounts() -> [Weekday: Int] {
        var counts: [Weekday: Int] = [:]
        let calendar = Calendar.current
        
        for completion in habit.completed {
            let weekdayNumber = calendar.component(.weekday, from: completion.date)
            
            let weekday: Weekday
            switch weekdayNumber {
            case 1: weekday = .sunday
            case 2: weekday = .monday
            case 3: weekday = .tuesday
            case 4: weekday = .wednesday
            case 5: weekday = .thursday
            case 6: weekday = .friday
            case 7: weekday = .saturday
            default: continue
            }
            
            counts[weekday, default: 0] += 1
        }
        
        return counts
    }
}
