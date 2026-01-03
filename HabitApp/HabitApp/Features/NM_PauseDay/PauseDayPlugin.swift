import SwiftUI
import SwiftData

class PauseDayPlugin: NSObject, FeaturePlugin, ViewPlugin, LogicPlugin, CalendarPauseDayStyleProvider {
    var id: String { "NM_PauseDay" }
    var models: [any PersistentModel.Type] { [HabitPauseDays.self] }
    private var pauseDaysCache: [UUID: HabitPauseDays] = [:]

    func habitRowAccessoryView(habit: Habit) -> AnyView? {
        AnyView(PauseDayRowButton(habit: habit))
    }

    func shouldHabitBeCompletedOn(habit: Habit, date: Date) -> Bool? {
        guard let pauseDays = loadPauseDays(for: habit) else { return nil }
        return pauseDays.isPaused(on: date) ? false : nil
    }

    func calendarDayStyle(for habit: Habit, date: Date) -> CalendarDayStyle? {
        guard let pauseDays = loadPauseDays(for: habit),
              pauseDays.isPaused(on: date) else {
            return nil
        }

        let primary = Color(red: 242 / 255, green: 120 / 255, blue: 13 / 255)
        return CalendarDayStyle(
            foregroundColor: primary.opacity(0.6),
            backgroundColor: primary.opacity(0.2),
            opacity: nil
        )
    }

    private func loadPauseDays(for habit: Habit) -> HabitPauseDays? {
        guard let context = habit.modelContext ?? SwiftDataContext.shared else { return nil }

        let habitId = habit.id
        if let cached = pauseDaysCache[habitId] {
            return cached
        }
        let descriptor = FetchDescriptor<HabitPauseDays>(
            predicate: #Predicate { $0.habitId == habitId }
        )

        if let pauseDays = try? context.fetch(descriptor).first {
            pauseDaysCache[habitId] = pauseDays
            return pauseDays
        }

        return nil
    }
}
