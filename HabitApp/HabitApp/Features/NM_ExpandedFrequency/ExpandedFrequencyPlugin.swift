import SwiftUI
import SwiftData

class ExpandedFrequencyPlugin: NSObject, FeaturePlugin, ViewPlugin, LogicPlugin {
    var id: String { "NM_ExpandedFrequency" }
    var models: [any PersistentModel.Type] { [ExpandedFrequency.self] }
    
    // MARK: - ViewPlugin
    
    func habitModificationSection(habit: Habit, context: ModelContext) -> AnyView? {
        AnyView(FrequencySelectionView(habitID: habit.id, context: context))
    }
    
    func habitRowCompletionView(habit: Habit, toggleAction: @escaping () -> Void) -> AnyView? {
        guard let context = habit.modelContext else { return nil }
        
        let habitID = habit.id
        let descriptor = FetchDescriptor<ExpandedFrequency>(
            predicate: #Predicate { $0.habitID == habitID }
        )
        
        if let freq = try? context.fetch(descriptor).first, freq.type == .addiction {
            return AnyView(AddictionCompletionView(habit: habit, toggleAction: toggleAction))
        }
        
        return nil
    }
    
    func onHabitSave(habit: Habit, context: ModelContext) {
        // No action needed as View writes to context directly
    }
    
    // MARK: - LogicPlugin
    
    func shouldHabitBeCompletedOn(habit: Habit, date: Date) -> Bool? {
        guard let context = habit.modelContext else { return nil }
        
        let habitID = habit.id
        let descriptor = FetchDescriptor<ExpandedFrequency>(
            predicate: #Predicate { $0.habitID == habitID }
        )
        
        if let freq = try? context.fetch(descriptor).first {
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
        guard let context = habit.modelContext else { return nil }
        
        let habitID = habit.id
        let descriptor = FetchDescriptor<ExpandedFrequency>(
            predicate: #Predicate { $0.habitID == habitID }
        )
        
        if let freq = try? context.fetch(descriptor).first, freq.type == .addiction {
            // Adicción: Completado (Éxito) si NO hay entrada hoy
            let hasEntry = habit.completed.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
            return !hasEntry
        }
        
        return nil
    }
}
