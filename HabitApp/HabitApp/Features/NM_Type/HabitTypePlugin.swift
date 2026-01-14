import SwiftUI
import SwiftData

class HabitTypePlugin: NSObject, FeaturePlugin, ViewPlugin {
    var id: String { "NM_Type" }
    var models: [any PersistentModel.Type] { [HabitType.self] }
    
    func configure() {
        print("🔌 NM_Type plugin configured")
    }
    
    // MARK: - ViewPlugin
    
    func habitModificationSection(habit: Habit, context: ModelContext) -> AnyView? {
        AnyView(HabitTypeSelectionView(habitID: habit.id, context: context))
    }
    
    func habitRowCompletionView(habit: Habit, toggleAction: @escaping () -> Void) -> AnyView? {
        guard let context = habit.modelContext else { return nil }
        
        let habitID = habit.id
        
        // 1. Verificar si es Adicción (Prioridad Alta)
        // Si es adicción, este plugin se retira para dejar que NM_ExpandedFrequency maneje la vista
        let freqDescriptor = FetchDescriptor<ExpandedFrequency>(predicate: #Predicate { $0.habitID == habitID })
        if let freq = try? context.fetch(freqDescriptor).first, freq.type == .addiction {
            return nil
        }
        
        // 2. Verificar si tiene un tipo especial configurado
        let descriptor = FetchDescriptor<HabitType>(predicate: #Predicate { $0.habitID == habitID })
        
        if let type = try? context.fetch(descriptor).first, type.type != .binary {
            return AnyView(HabitTypeCompletionView(habit: habit, context: context, toggleAction: toggleAction))
        }
        
        return nil
    }
    
    func onHabitSave(habit: Habit, context: ModelContext) {
        // La persistencia se maneja en el ViewModel de la vista de selección
    }
}
