import Foundation
import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let toggleCompletion: () -> Void
    let onEdit: () -> Void
    
    @State private var showDiaryEntry = false
    @State private var showStats = false
    
    @EnvironmentObject private var appConfig: AppConfig

    var body: some View {
        let accessoryViews = PluginRegistry.shared.getHabitRowAccessoryViews(habit: habit)
        let customCompletion = PluginRegistry.shared.getHabitRowCompletionView(
            habit: habit,
            toggleAction: toggleCompletion
        )
        let isCompletedToday = habit.isCompletedToday
        let streak = habit.getStreak()
        let todayEntry = isCompletedToday ? getTodayCompletionEntry() : nil

        return HStack {
            // 🔌 PLUGINS: Completion View (ej. Checkbox, Contador, Timer)
            if let customCompletion = customCompletion {
                customCompletion
            } else {
                Button(action: toggleCompletion) {
                    Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading) {
                Text(habit.title)
                    .strikethrough(isCompletedToday)

                // Feature flag: mostrar prioridad solo si está habilitado
                if appConfig.showPriorities, let priority = habit.priority {
                    Text("Prioridad: \(priority.rawValue)")
                        .font(.caption)
                        .foregroundColor(priorityColor(for: priority))
                }
                
                // Feature flag: mostrar racha solo si está habilitado
                if appConfig.enableStreaks && streak > 1 {
                    Text("🔥 Racha: \(streak) días")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                // 🔌 PLUGINS: Accessory Views (ej. Etiquetas extra)
                ForEach(accessoryViews.indices, id: \.self) { index in
                    accessoryViews[index]
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button("Modificar") {
                    onEdit()
                }
                .buttonStyle(.bordered)

                // Feature flag: botón de estadísticas solo si está habilitado
                if appConfig.enableStats {
                    Button("Estadísticas") {
                        showStats = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.purple)
                }

                // Feature flag: botón de diario solo si está habilitado
                if appConfig.enableDiary, let todayEntry = todayEntry {
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
            if let todayEntry = todayEntry {
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
