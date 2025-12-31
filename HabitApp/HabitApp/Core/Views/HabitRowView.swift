import Foundation
import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let toggleCompletion: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showDiaryEntry = false
    @State private var showStats = false

    @EnvironmentObject private var appConfig: AppConfig
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        let accessoryViews = PluginRegistry.shared.getHabitRowAccessoryViews(habit: habit)
        let customCompletion = PluginRegistry.shared.getHabitRowCompletionView(
            habit: habit,
            toggleAction: toggleCompletion
        )
        let isCompletedToday = habit.isCompletedToday
        let streak = habit.getStreak()
        let todayEntry = isCompletedToday ? getTodayCompletionEntry() : nil

        return HStack(spacing: isCompactLayout ? 8 : 12) {
            if let customCompletion = customCompletion {
                customCompletion
            } else {
                Button(action: toggleCompletion) {
                    Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: completionIconSize, weight: .semibold))
                        .foregroundColor(isCompletedToday ? primaryColor : secondaryTextColor)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(size: titleFontSize, weight: .bold))
                    .foregroundColor(primaryTextColor)
                    .strikethrough(isCompletedToday, color: secondaryTextColor)
                    .lineLimit(isCompactLayout ? 2 : 1)
                    .minimumScaleFactor(0.85)

                if appConfig.showPriorities, let priority = habit.priority {
                    Text("Prioridad: \(priority.rawValue)")
                        .font(.caption)
                        .foregroundColor(priorityColor(for: priority))
                }

                if appConfig.enableStreaks && streak > 1 {
                    Text("Racha: \(streak) dias")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                ForEach(accessoryViews.indices, id: \.self) { index in
                    accessoryViews[index]
                }
            }

            Spacer()

            if isCompactLayout {
                VStack(spacing: 6) {
                    editButton
                    deleteButton
                    overflowMenu(todayEntry: todayEntry)
                }
            } else {
                HStack(spacing: 6) {
                    editButton
                    deleteButton
                    overflowMenu(todayEntry: todayEntry)
                }
            }
        }
        .padding(isCompactLayout ? 12 : 16)
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.08),
            radius: 10,
            x: 0,
            y: 4
        )
        .sheet(isPresented: $showDiaryEntry) {
            if let todayEntry = todayEntry {
                DiaryEntryView(
                    viewModel: DiaryViewModel(completionEntry: todayEntry),
                    habitTitle: habit.title
                )
            }
        }
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

    private func iconButton(
        systemName: String,
        tint: Color,
        background: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: actionIconSize, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: actionButtonSize, height: actionButtonSize)
                .background(background)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var primaryColor: Color {
        Color(red: 242 / 255, green: 120 / 255, blue: 13 / 255)
    }

    private var backgroundLight: Color {
        Color(red: 248 / 255, green: 247 / 255, blue: 245 / 255)
    }

    private var taskDark: Color {
        Color(red: 38 / 255, green: 26 / 255, blue: 20 / 255)
    }

    private var surfaceDark: Color {
        Color(red: 66 / 255, green: 48 / 255, blue: 38 / 255)
    }

    private var surfaceColor: Color {
        colorScheme == .dark ? surfaceDark : backgroundLight
    }

    private var cardBackground: Color {
        colorScheme == .dark
            ? taskDark
            : Color.white
    }

    private var borderColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.05)
            : Color.black.opacity(0.08)
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? backgroundLight : Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)
    }

    private var secondaryTextColor: Color {
        colorScheme == .dark
            ? Color(red: 199 / 255, green: 186 / 255, blue: 176 / 255)
            : Color(red: 120 / 255, green: 120 / 255, blue: 120 / 255)
    }

    private var isCompactLayout: Bool {
        horizontalSizeClass == .compact
    }

    private var titleFontSize: CGFloat {
        isCompactLayout ? 16 : 18
    }

    private var completionIconSize: CGFloat {
        isCompactLayout ? 20 : 22
    }

    private var actionButtonSize: CGFloat {
        isCompactLayout ? 28 : 32
    }

    private var actionIconSize: CGFloat {
        isCompactLayout ? 14 : 16
    }

    private var editButton: some View {
        iconButton(
            systemName: "pencil",
            tint: primaryColor,
            background: surfaceColor,
            action: onEdit
        )
    }

    private var deleteButton: some View {
        iconButton(
            systemName: "trash",
            tint: .red,
            background: surfaceColor,
            action: onDelete
        )
    }

    @ViewBuilder
    private func overflowMenu(todayEntry: CompletionEntry?) -> some View {
        if appConfig.enableStats || (appConfig.enableDiary && todayEntry != nil) {
            Menu {
                if appConfig.enableStats {
                    Button("Estadisticas") {
                        showStats = true
                    }
                }
                if appConfig.enableDiary, todayEntry != nil {
                    Button("Escribir nota") {
                        showDiaryEntry = true
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: actionIconSize, weight: .semibold))
                    .foregroundColor(secondaryTextColor)
                    .frame(width: actionButtonSize, height: actionButtonSize)
                    .background(surfaceColor)
                    .clipShape(Circle())
            }
        }
    }
}
