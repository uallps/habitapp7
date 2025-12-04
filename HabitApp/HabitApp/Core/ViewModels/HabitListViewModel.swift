import Foundation
import Combine
import SwiftData

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var categories: [Category] = []   // ← Lista de categorías

    private let storage: StorageProvider

    // Inyección de dependencias pura, como el profesor
    init(storageProvider: StorageProvider) {
        self.storage = storageProvider
        
        // Cargar hábitos al iniciar
        Task { @MainActor in
            do {
                let loaded = try await storage.loadHabits()
                self.habits = loaded
            } catch {
                print("Error cargando hábitos: \(error)")
            }
        }
    }

    // Añadir categoría al sistema
    func addCategory(_ category: Category) {
        categories.append(category)
    }
    
    // Añadir hábito
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        persist()
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
    
    // Actualizar hábito
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].title = habit.title
            habits[index].priority = habit.priority
            habits[index].frequency = habit.frequency
            
            // Guardar categoría usando tu extensión Habit.category
            habits[index].category = habit.category

            persist()
        }
    }

    private func persist() {
        Task {
            do {
                try await storage.saveHabits(habits: habits)
            } catch {
                print("Error guardando hábitos: \(error)")
            }
        }
    }
}
