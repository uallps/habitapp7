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
        HStack {
            // 🔌 PLUGINS: Completion View (ej. Checkbox, Contador, Timer)
            if let customCompletion = PluginRegistry.shared.getHabitRowCompletionView(habit: habit, toggleAction: toggleCompletion) {
                customCompletion
            } else {
                Button(action: toggleCompletion) {
                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading) {
                Text(habit.title)
                    .strikethrough(habit.isCompletedToday)

                // Feature flag: mostrar prioridad solo si está habilitado
                if appConfig.showPriorities, let priority = habit.priority {
                    Text("Prioridad: \(priority.rawValue)")
                        .font(.caption)
                        .foregroundColor(priorityColor(for: priority))
                }
                
                // Feature flag: mostrar racha solo si está habilitado
                if appConfig.enableStreaks && habit.getStreak() > 1 {
                    Text("🔥 Racha: \(habit.getStreak()) días")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                // 🔌 PLUGINS: Accessory Views (ej. Etiquetas extra)
                ForEach(PluginRegistry.shared.getHabitRowAccessoryViews(habit: habit).indices, id: \.self) { index in
                    PluginRegistry.shared.getHabitRowAccessoryViews(habit: habit)[index]
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
                if appConfig.enableDiary && habit.isCompletedToday, let todayEntry = getTodayCompletionEntry() {
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

