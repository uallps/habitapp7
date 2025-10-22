//
//  TaskListRowView.swift
//  TaskApp
//
//  Created by Francisco José García García on 15/10/25.
//

import SwiftUI

struct TaskRowView: View {
    
    let task: Task
    let toggleCompletion : () -> Void
    
    
    var body: some View {
        HStack {
            Button(action: toggleCompletion){
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
            }.buttonStyle(.plain)
            VStack(alignment: .leading) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                if AppConfig.showDueDates, let dueDate = task.dueDate {
                    Text("Vence: \(dueDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if AppConfig.showPriorities, let priority = task.priority {
                    Text("Prioridad: \(priority.rawValue)")
                        .font(.caption)
                        .foregroundColor(priorityColor(for: priority))
                }
            }
        }
    }
    
    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
}
