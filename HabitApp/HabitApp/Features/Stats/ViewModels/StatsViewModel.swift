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
        guard let firstDate = firstCompletionDate else { return 0 }
        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: firstDate, to: today)
        return (components.day ?? 0) + 1
    }
    
    var totalDaysCompleted: Int {
        habit.completed.count
    }
    
    var completionPercentage: Double {
        guard totalDaysActive > 0 else { return 0.0 }
        return (Double(totalDaysCompleted) / Double(totalDaysActive)) * 100.0
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
