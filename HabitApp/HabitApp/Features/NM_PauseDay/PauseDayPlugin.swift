import SwiftUI
import SwiftData

class PauseDayPlugin: NSObject, FeaturePlugin, ViewPlugin, LogicPlugin {
    var id: String { "NM_PauseDay" }
    var models: [any PersistentModel.Type] { [HabitPauseDays.self] }

    func habitRowAccessoryView(habit: Habit) -> AnyView? {
        AnyView(PauseDayRowButton(habit: habit))
    }

    func shouldHabitBeCompletedOn(habit: Habit, date: Date) -> Bool? {
        guard let pauseDays = loadPauseDays(for: habit) else { return nil }
        return pauseDays.isPaused(on: date) ? false : nil
    }

    private func loadPauseDays(for habit: Habit) -> HabitPauseDays? {
        guard let context = habit.modelContext ?? SwiftDataContext.shared else { return nil }

        let habitId = habit.id
        let descriptor = FetchDescriptor<HabitPauseDays>(
            predicate: #Predicate { $0.habitId == habitId }
        )

        return try? context.fetch(descriptor).first
    }
}
