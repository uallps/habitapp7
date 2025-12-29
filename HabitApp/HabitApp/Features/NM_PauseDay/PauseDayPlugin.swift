import SwiftUI
import SwiftData

class PauseDayPlugin: NSObject, FeaturePlugin, ViewPlugin, LogicPlugin {
    var id: String { "NM_PauseDay" }
    var models: [any PersistentModel.Type] { [HabitPauseDays.self] }

    func habitModificationSection(habit: Habit, context: ModelContext) -> AnyView? {
        AnyView(PauseDaySelectionView(habitID: habit.id, context: context))
    }

    func shouldHabitBeCompletedOn(habit: Habit, date: Date) -> Bool? {
        guard let pauseDays = loadPauseDays(for: habit) else { return nil }
        let weekday = Weekday.from(date: date)
        return pauseDays.pauseDays.contains(weekday) ? false : nil
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
