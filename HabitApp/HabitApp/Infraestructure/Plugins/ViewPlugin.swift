import SwiftUI
import SwiftData

/// Protocolo para plugins que inyectan vistas en la UI del Core
protocol ViewPlugin: FeaturePlugin {
    
    // MARK: - Habit List Injection Points
    
    /// Vistas a mostrar en la cabecera de la lista de hábitos (ej. Frases motivacionales)
    func habitListHeaderView() -> AnyView?
    
    /// Vistas a mostrar en el pie de la lista o como botones flotantes extra (ej. Calendario, Menú Motivación)
    func habitListFooterView() -> AnyView?
    
    // MARK: - Habit Modification Injection Points
    
    /// Secciones a añadir al formulario de creación/edición de hábitos
    /// - Parameters:
    ///   - habit: El hábito que se está editando (o creando)
    ///   - context: Contexto de SwiftData para guardar cambios
    func habitModificationSection(habit: Habit, context: ModelContext) -> AnyView?
    
    /// Acción a ejecutar cuando se guarda el hábito (para persistir datos del plugin)
    func onHabitSave(habit: Habit, context: ModelContext)
    
    // MARK: - Habit Row Injection Points
    
    /// Vista personalizada para completar el hábito (reemplaza el checkbox por defecto si se devuelve algo)
    func habitRowCompletionView(habit: Habit, toggleAction: @escaping () -> Void) -> AnyView?
    
    /// Vista accesoria para mostrar en la fila del hábito (ej. Iconos extra, contadores)
    func habitRowAccessoryView(habit: Habit) -> AnyView?
}

// Implementación por defecto (opcional)
extension ViewPlugin {
    func habitListHeaderView() -> AnyView? { nil }
    func habitListFooterView() -> AnyView? { nil }
    func habitModificationSection(habit: Habit, context: ModelContext) -> AnyView? { nil }
    func onHabitSave(habit: Habit, context: ModelContext) {}
    func habitRowCompletionView(habit: Habit, toggleAction: @escaping () -> Void) -> AnyView? { nil }
    func habitRowAccessoryView(habit: Habit) -> AnyView? { nil }
}
