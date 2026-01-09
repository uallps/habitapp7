import Foundation
import Combine
import SwiftData

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var categories: [Category] = []

    private let storage: StorageProvider
    private var groupedHabitsCache: [String: [Habit]] = [:]
    private var isGroupedCacheDirty = true
    private var cachedCategoryHabitIds: Set<UUID> = []
    private var cachedCategoriesByHabitId: [UUID: Category] = [:]
    private var isCategoryCacheDirty = true

    init(storageProvider: StorageProvider) {
        self.storage = storageProvider

        Task { @MainActor in
            do {
                let loaded = try await storage.loadHabits()
                self.habits = loaded
                self.markGroupingDirty()
                self.markCategoryCacheDirty()
            } catch {
                print("Error cargando habitos: \(error)")
            }
        }
    }

    func addCategory(_ category: Category) {
        categories.append(category)
        markGroupingDirty()
        markCategoryCacheDirty()
    }

    func addHabit(_ habit: Habit) {
        habits.append(habit)
        markGroupingDirty()
        markCategoryCacheDirty()

        Task {
            do {
                try await storage.saveHabits(habits: habits)
                await MainActor.run {
                    self.reloadHabits()
                }
            } catch {
                print("Error guardando habitos: \(error)")
            }
        }
    }

    func reloadHabits() {
        Task { @MainActor in
            do {
                let loaded = try await storage.loadHabits()
                self.habits = loaded
                self.markGroupingDirty()
                self.markCategoryCacheDirty()
            } catch {
                print("Error recargando habitos: \(error)")
            }
        }
    }

    func deleteHabit(_ habit: Habit) {
        if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
            habits.remove(at: idx)
            markGroupingDirty()
            markCategoryCacheDirty()
            persist()
        }
    }

    func toggleCompletion(habit: Habit, on date: Date = Date()) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        let targetDate = Calendar.current.startOfDay(for: date)

        if habits[index].completed.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: targetDate) }) {
            habits[index].completed.removeAll { Calendar.current.isDate($0.date, inSameDayAs: targetDate) }
        } else {
            let entry = CompletionEntry(date: targetDate)
            habits[index].completed.append(entry)
        }
        persist()
    }

    func updateHabit(_ habit: Habit) {
        markGroupingDirty()
        markCategoryCacheDirty()
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
        }
        persist()
    }

    func groupedHabitsByCategory() -> [String: [Habit]] {
        if !isGroupedCacheDirty {
            return groupedHabitsCache
        }

        groupedHabitsCache = buildGroupedHabits()
        isGroupedCacheDirty = false
        return groupedHabitsCache
    }

    private func buildGroupedHabits() -> [String: [Habit]] {
        let categoryNameByHabitId = buildCategoryNameMap(for: habits)
        var groupedHabits: [String: [Habit]] = [:]

        for habit in habits {
            let categoryName = categoryNameByHabitId[habit.id] ?? "Sin categoria"
            groupedHabits[categoryName, default: []].append(habit)
        }

        return groupedHabits
    }

    private func buildCategoryNameMap(for habits: [Habit]) -> [UUID: String] {
        guard let context = SwiftDataContext.shared else {
            return [:]
        }

        let habitIds = habits.map(\.id)
        guard !habitIds.isEmpty else {
            return [:]
        }

        let descriptor = FetchDescriptor<HabitCategoryFeature>(
            predicate: #Predicate { habitIds.contains($0.habitId) }
        )
        let features = (try? context.fetch(descriptor)) ?? []
        var categoryNames: [UUID: String] = [:]

        for feature in features {
            if let name = feature.category?.name {
                categoryNames[feature.habitId] = name
            }
        }

        return categoryNames
    }

    func categoryByHabitId(for habits: [Habit]) -> [UUID: Category] {
        let habitIds = Set(habits.map(\.id))
        if !isCategoryCacheDirty, habitIds == cachedCategoryHabitIds {
            return cachedCategoriesByHabitId
        }

        guard let context = SwiftDataContext.shared else {
            return [:]
        }

        guard !habitIds.isEmpty else {
            cachedCategoriesByHabitId = [:]
            cachedCategoryHabitIds = []
            isCategoryCacheDirty = false
            return [:]
        }

        let habitIdsList = Array(habitIds)
        let descriptor = FetchDescriptor<HabitCategoryFeature>(
            predicate: #Predicate { habitIdsList.contains($0.habitId) }
        )
        let features = (try? context.fetch(descriptor)) ?? []
        var categoriesByHabitId: [UUID: Category] = [:]

        for feature in features {
            if let category = feature.category {
                categoriesByHabitId[feature.habitId] = category
            }
        }

        cachedCategoriesByHabitId = categoriesByHabitId
        cachedCategoryHabitIds = habitIds
        isCategoryCacheDirty = false
        return categoriesByHabitId
    }

    func splitHabitsForToday(_ habits: [Habit], on date: Date) -> (today: [Habit], other: [Habit]) {
        var todayHabits: [Habit] = []
        var otherHabits: [Habit] = []
        todayHabits.reserveCapacity(habits.count)
        otherHabits.reserveCapacity(habits.count)

        for habit in habits {
            if habit.shouldBeCompletedOn(date: date) {
                todayHabits.append(habit)
            } else {
                otherHabits.append(habit)
            }
        }

        return (sortHabitsByTitle(todayHabits), sortHabitsByTitle(otherHabits))
    }

    private func markGroupingDirty() {
        isGroupedCacheDirty = true
    }

    private func markCategoryCacheDirty() {
        isCategoryCacheDirty = true
    }

    private func sortHabitsByTitle(_ habits: [Habit]) -> [Habit] {
        habits.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }

    private func persist() {
        Task {
            do {
                try await storage.saveHabits(habits: habits)
                ReminderManager.shared.scheduleDailyHabitNotificationDebounced()
            } catch {
                print("Error guardando habitos: \(error)")
            }
        }
    }
}
