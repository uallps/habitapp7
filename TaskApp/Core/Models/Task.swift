//
//  Task.swift
//  TaskApp
//
//  Created by Francisco José García García on 15/10/25.
//
import Foundation

struct Task: Identifiable { 
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
    var dueDate: Date? 
    var priority: Priority?
}

enum Priority: String, Codable {
    case low, medium, high
}
