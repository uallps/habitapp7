import SwiftUI
import SwiftData

class ExpandedFrequencyPlugin: NSObject, FeaturePlugin, ViewPlugin, LogicPlugin {
    var id: String { "NM_ExpandedFrequency" }
    var models: [any PersistentModel.Type] { [ExpandedFrequency.self] }

    private var frequencyCache: [UUID: ExpandedFrequency] = [:]
    
    // MARK: - ViewPlugin
    
    func habitModificationSection(habit: Habit, context: ModelContext) -> AnyView? {
        AnyView(FrequencySelectionView(habitID: habit.id, context: context))
    }
    
    func habitRowCompletionView(habit: Habit, toggleAction: @escaping () -> Void) -> AnyView? {
        if let freq = loadFrequency(for: habit), freq.type == .addiction {
            return AnyView(AddictionCompletionView(habit: habit, toggleAction: toggleAction))
        }
        
        return nil
    }
    
    func onHabitSave(habit: Habit, context: ModelContext) {
        // Invalidar caché para asegurar que se recarguen los cambios recientes
        frequencyCache.removeValue(forKey: habit.id)
        
        // Si es adicción, forzamos que el tipo sea binario para evitar conflictos con NM_Type
        if let freq = loadFrequency(for: habit), freq.type == .addiction {
            // Intentamos buscar si existe configuración de HabitType (del plugin NM_Type)
            // y la reseteamos a .binary para que la vista de adicción tenga prioridad.
            let habitID = habit.id
            let descriptor = FetchDescriptor<HabitType>(predicate: #Predicate { $0.habitID == habitID })
            
            if let type = try? context.fetch(descriptor).first {
                type.type = .binary
            }
        }
    }
    
    // MARK: - LogicPlugin
    
    func shouldHabitBeCompletedOn(habit: Habit, date: Date) -> Bool? {
        if let freq = loadFrequency(for: habit) {
            switch freq.type {
            case .daily:
                return nil // Use default logic
            case .weekly, .monthly, .addiction:
                return true // Show every day
            }
        }
        
        return nil
    }
    
    func isHabitCompleted(habit: Habit, date: Date) -> Bool? {
        if let freq = loadFrequency(for: habit), freq.type == .addiction {
            // Adicción: Completado (Éxito) si NO hay entrada hoy
            let hasEntry = habit.completed.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
            return !hasEntry
        }
        
        return nil
    }

    private func loadFrequency(for habit: Habit) -> ExpandedFrequency? {
        guard let context = habit.modelContext else { return nil }

        if let cached = frequencyCache[habit.id] {
            return cached
        }

        let habitID = habit.id
        let descriptor = FetchDescriptor<ExpandedFrequency>(
            predicate: #Predicate { $0.habitID == habitID }
        )

        if let freq = try? context.fetch(descriptor).first {
            frequencyCache[habitID] = freq
            return freq
        }

        return nil
    }
}
