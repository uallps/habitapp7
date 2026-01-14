//
//  StatsView.swift
//  HabitApp
//
//  Created by Francisco Jose Garcia Garcia on 19/11/25.
//
import SwiftUI

struct StatsView: View {
    @StateObject var viewModel: StatsViewModel
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var appConfig: AppConfig
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(viewModel.habit.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        VStack(spacing: 12) {
                            StatRow(
                                title: "Primer dia cumplido",
                                value: formatDate(viewModel.firstCompletionDate)
                            )
                            
                            StatRow(
                                title: "Ultimo dia cumplido",
                                value: formatDate(viewModel.lastCompletionDate)
                            )
                            
                            StatRow(
                                title: viewModel.totalPeriodsActiveLabel + " activo",
                                value: "\(viewModel.totalDaysActive) \(viewModel.totalPeriodsActiveLabel)"
                            )
                            
                            StatRow(
                                title: viewModel.totalPeriodsCompletedLabel + " cumplidos",
                                value: "\(viewModel.totalDaysCompleted) \(viewModel.totalPeriodsCompletedLabel)"
                            )
                            
                            StatRow(
                                title: "Porcentaje de completitud",
                                value: String(format: "%.1f%%", viewModel.completionPercentage)
                            )
                            if appConfig.enableStreaks  {
                                
                                StatRow(
                                    title: "Racha mas larga",
                                    value: "\(viewModel.longestStreak) \(viewModel.streakLabel)"
                                )
                                
                            }

                            StatRow(
                                title: "Dia(s) mas cumplido",
                                value: formatWeekdays(viewModel.mostCompletedWeekdays)
                            )

                            
                            
                            StatRow(
                                title: "Dia(s) menos cumplido",
                                value: formatWeekdays(viewModel.leastCompletedWeekdays)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .tint(primaryColor)
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

    private var primaryColor: Color {
        Color(red: 242 / 255, green: 120 / 255, blue: 13 / 255)
    }

    private var backgroundColor: Color {
        colorScheme == .dark
            ? Color(red: 25 / 255, green: 18 / 255, blue: 14 / 255)
            : Color(red: 248 / 255, green: 247 / 255, blue: 245 / 255)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(secondaryTextColor)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(primaryTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
        .cornerRadius(12)
    }

    private var cardBackground: Color {
        colorScheme == .dark
            ? Color(red: 38 / 255, green: 26 / 255, blue: 20 / 255)
            : Color.white
    }

    private var borderColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.black.opacity(0.08)
    }

    private var primaryTextColor: Color {
        colorScheme == .dark
            ? Color(red: 248 / 255, green: 247 / 255, blue: 245 / 255)
            : Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)
    }

    private var secondaryTextColor: Color {
        colorScheme == .dark
            ? Color(red: 199 / 255, green: 186 / 255, blue: 176 / 255)
            : Color(red: 120 / 255, green: 120 / 255, blue: 120 / 255)
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
