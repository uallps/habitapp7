import Foundation
import Combine
import SwiftData

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var categories: [Category] = []   // Lista de categorias

    private let storage: StorageProvider
    private var groupedHabitsCache: [String: [Habit]] = [:]
    private var isGroupedCacheDirty = true

    // Inyección de dependencias pura, como el profesor
    init(storageProvider: StorageProvider) {
        self.storage = storageProvider
        
        // Cargar hábitos al iniciar
        Task { @MainActor in
            do {
                let loaded = try await storage.loadHabits()
                self.habits = loaded
                self.markGroupingDirty()
            } catch {
                print("Error cargando hábitos: \(error)")
            }
        }
    }

    // Añadir categoría al sistema
    func addCategory(_ category: Category) {
        categories.append(category)
        markGroupingDirty()
    }
    
    // Añadir hábito
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        markGroupingDirty()
        
        // Persistir y luego recargar para asegurar consistencia
        Task {
            do {
                try await storage.saveHabits(habits: habits)
                await MainActor.run {
                    self.reloadHabits()
                }
            } catch {
                print("Error guardando hábitos: \(error)")
            }
        }
    }
    
    func reloadHabits() {
        Task { @MainActor in
            do {
                let loaded = try await storage.loadHabits()
                self.habits = loaded
                self.markGroupingDirty()
            } catch {
                print("Error recargando hábitos: \(error)")
            }
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
            habits.remove(at: idx)
            markGroupingDirty()
            persist()
        }
    }
    
    // Marcar/desmarcar completado
    func toggleCompletion(habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        let today = Calendar.current.startOfDay(for: Date())
        
        if habits[index].completed.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            habits[index].completed.removeAll { Calendar.current.isDate($0.date, inSameDayAs: today) }
        } else {
            let entry = CompletionEntry(date: today)
            habits[index].completed.append(entry)
        }
        persist()
    }
    
    // Actualizar hábito (solo persiste, los cambios ya están aplicados en el objeto)
    func updateHabit(_ habit: Habit) {
        // El objeto ya está modificado, solo necesitamos persistir
        markGroupingDirty()
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
            let categoryName = categoryNameByHabitId[habit.id] ?? "Sin categoría"
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
        var categoriesByHabitId: [UUID: Category] = [:]

        for feature in features {
            if let category = feature.category {
                categoriesByHabitId[feature.habitId] = category
            }
        }

        return categoriesByHabitId
    }

    private func markGroupingDirty() {
        isGroupedCacheDirty = true
    }

    private func persist() {
        Task {
            do {
                try await storage.saveHabits(habits: habits)
                ReminderManager.shared.scheduleDailyHabitNotificationDebounced()
            } catch {
                print("Error guardando hábitos: \(error)")
            }
        }
    }
}
