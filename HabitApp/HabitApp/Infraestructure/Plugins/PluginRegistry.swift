import SwiftUI
import SwiftData
import Combine

/// Singleton que gestiona los plugins registrados
class PluginRegistry: ObservableObject {
    static let shared = PluginRegistry()
    
    @Published var plugins: [FeaturePlugin] = []
    
    private init() {}
    
    func register(_ plugin: FeaturePlugin) {
        plugins.append(plugin)
        print("🔌 Plugin registrado: \(plugin.id)")
        plugin.configure()
    }
    
    // MARK: - Helpers para Vistas
    
    var viewPlugins: [ViewPlugin] {
        plugins.compactMap { $0 as? ViewPlugin }
    }
    
    var logicPlugins: [LogicPlugin] {
        plugins.compactMap { $0 as? LogicPlugin }
    }
    
    // MARK: - Helpers para Lógica
    
    func shouldHabitBeCompletedOn(habit: Habit, date: Date) -> Bool? {
        for plugin in logicPlugins {
            if let result = plugin.shouldHabitBeCompletedOn(habit: habit, date: date) {
                return result
            }
        }
        return nil
    }
    
    func isHabitCompleted(habit: Habit, date: Date) -> Bool? {
        for plugin in logicPlugins {
            if let result = plugin.isHabitCompleted(habit: habit, date: date) {
                return result
            }
        }
        return nil
    }
    
    // MARK: - Helpers para Vistas
    
    func getHabitListHeaderViews() -> [AnyView] {
        viewPlugins.compactMap { $0.habitListHeaderView() }
    }
    
    func getHabitListFooterViews() -> [AnyView] {
        viewPlugins.compactMap { $0.habitListFooterView() }
    }
    
    func getHabitModificationSections(habit: Habit, context: ModelContext) -> [AnyView] {
        viewPlugins.compactMap { $0.habitModificationSection(habit: habit, context: context) }
    }
    
    func getHabitRowCompletionView(habit: Habit, toggleAction: @escaping () -> Void) -> AnyView? {
        for plugin in viewPlugins {
            if let view = plugin.habitRowCompletionView(habit: habit, toggleAction: toggleAction) {
                return view
            }
        }
        return nil
    }
    
    func getHabitRowAccessoryViews(habit: Habit) -> [AnyView] {
        viewPlugins.compactMap { $0.habitRowAccessoryView(habit: habit) }
    }
    
    func notifySave(habit: Habit, context: ModelContext) {
        viewPlugins.forEach { $0.onHabitSave(habit: habit, context: context) }
    }
    
    // MARK: - Schema Generation
    
    func getPluginSchemas() -> [any PersistentModel.Type] {
        plugins.flatMap { $0.models }
    }
}
