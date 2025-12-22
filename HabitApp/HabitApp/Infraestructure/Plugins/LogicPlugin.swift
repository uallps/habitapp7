import Foundation

/// Protocolo para plugins que modifican la lógica de negocio del Core
protocol LogicPlugin: FeaturePlugin {
    
    /// Determina si un hábito debe completarse en una fecha específica.
    /// Devuelve `true` o `false` si el plugin maneja la lógica, o `nil` para usar la lógica por defecto.
    func shouldHabitBeCompletedOn(habit: Habit, date: Date) -> Bool?
    
    /// Determina si un hábito se considera completado/satisfecho en una fecha específica.
    /// Devuelve `true` (completado), `false` (no completado) o `nil` (usar lógica por defecto: chequear array completed).
    func isHabitCompleted(habit: Habit, date: Date) -> Bool?
}

// Implementación por defecto
extension LogicPlugin {
    func shouldHabitBeCompletedOn(habit: Habit, date: Date) -> Bool? { nil }
    func isHabitCompleted(habit: Habit, date: Date) -> Bool? { nil }
}
