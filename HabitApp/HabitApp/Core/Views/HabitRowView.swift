import Foundation
import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let toggleCompletion: () -> Void
    let onEdit: () -> Void
    
    @State private var showDiaryEntry = false
    @State private var showStats = false

    var body: some View {
        HStack {
            Button(action: toggleCompletion) {
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading) {
                Text(habit.title)
                    .strikethrough(habit.isCompleted)

                if AppConfig.showPriorities, let priority = habit.priority {
                    Text("Prioridad: \(priority.rawValue)")
                        .font(.caption)
                        .foregroundColor(priorityColor(for: priority))
                }
                
                // Mostrar racha solo si es mayor a 1
                if habit.streak > 1 {
                    Text("🔥 Racha: \(habit.streak) días")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button("Modificar") {
                    onEdit()
                }
                .buttonStyle(.bordered)

                Button("Estadísticas") {
                    showStats = true
                }
                .buttonStyle(.bordered)
                .tint(.purple)

                if habit.isCompleted, let todayEntry = getTodayCompletionEntry() {
                    Button("Escribir nota") {
                        showDiaryEntry = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }
            }
        }

        // Sheet para escribir nota
        .sheet(isPresented: $showDiaryEntry) {
            if let todayEntry = getTodayCompletionEntry() {
                DiaryEntryView(
                    viewModel: DiaryViewModel(completionEntry: todayEntry),
                    habitTitle: habit.title
                )
            }
        }

        // Sheet para Estadísticas
        .sheet(isPresented: $showStats) {
            StatsView(
                viewModel: StatsViewModel(habit: habit)
            )
        }
    }
    
    private func getTodayCompletionEntry() -> CompletionEntry? {
        let today = Date()
        return habit.completed.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
}

