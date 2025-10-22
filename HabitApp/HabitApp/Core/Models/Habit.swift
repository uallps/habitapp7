//
//  Task.swift
//  TaskApp
//
//  Created by Francisco José García García on 15/10/25.
//
import Foundation

struct Habit: Identifiable {
    let id = UUID()
    var title: String
    var dueDate: Date? 
    var priority: Priority?
    var completed: [Date]
    
    var isCompleted: Bool {
            completed.contains { Calendar.current.isDate($0, inSameDayAs: Date()) }
        }
}

enum Priority: String, Codable {
    case low, medium, high
}
