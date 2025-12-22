//
//  StatsView.swift
//  HabitApp
//
//  Created by Francisco José García García on 19/11/25.
//
import SwiftUI

struct StatsView: View {
    @StateObject var viewModel: StatsViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Nombre del hábito
                    Text(viewModel.habit.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    Divider()
                    
                    // Estadísticas
                    VStack(spacing: 16) {
                        StatRow(
                            title: "Primer día cumplido",
                            value: formatDate(viewModel.firstCompletionDate)
                        )
                        
                        StatRow(
                            title: "Último día cumplido",
                            value: formatDate(viewModel.lastCompletionDate)
                        )
                        
                        StatRow(
                            title: "Días activo",
                            value: "\(viewModel.totalDaysActive) días"
                        )
                        
                        StatRow(
                            title: "Días cumplidos",
                            value: "\(viewModel.totalDaysCompleted) días"
                        )
                        
                        StatRow(
                            title: "Porcentaje de completitud",
                            value: String(format: "%.1f%%", viewModel.completionPercentage)
                        )
                        
                        // MARK: - Streak Stats (preparadas para cuando ambas features estén activas)
                        
                        StatRow(
                            title: "Racha actual",
                            value: "\(viewModel.currentStreak) días"
                        )
                        
                        StatRow(
                            title: "Racha más larga",
                            value: "\(viewModel.longestStreak) días"
                        )
                        
                        StatRow(
                            title: "Día(s) más cumplido",
                            value: formatWeekdays(viewModel.mostCompletedWeekdays)
                        )
                        
                        StatRow(
                            title: "Día(s) menos cumplido",
                            value: formatWeekdays(viewModel.leastCompletedWeekdays)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatWeekdays(_ weekdays: [Weekday]) -> String {
        guard !weekdays.isEmpty else { return "N/A" }
        return weekdays.map { $0.rawValue }.joined(separator: ", ")
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    let sampleHabit = Habit(
        title: "Hacer ejercicio",
        priority: .high,
        completed: [
            CompletionEntry(date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!),
            CompletionEntry(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!),
            CompletionEntry(date: Date())
        ],
        frequency: [.monday, .wednesday, .friday]
    )
    
    StatsView(viewModel: StatsViewModel(habit: sampleHabit))
}
