import Foundation

/// Tipo de periodo para cálculos de rachas y estadísticas
enum CompletionPeriodType {
    case daily      // Día a día (comportamiento por defecto)
    case weekly     // Semana a semana (lunes-domingo)
    case monthly    // Mes a mes
}

/// Protocolo para plugins que modifican la lógica de negocio del Core
protocol LogicPlugin: FeaturePlugin {
    
    /// Determina si un hábito debe completarse en una fecha específica.
    /// Devuelve `true` o `false` si el plugin maneja la lógica, o `nil` para usar la lógica por defecto.
    func shouldHabitBeCompletedOn(habit: Habit, date: Date) -> Bool?
    
    /// Determina si un hábito se considera completado/satisfecho en una fecha específica.
    /// Devuelve `true` (completado), `false` (no completado) o `nil` (usar lógica por defecto: chequear array completed).
    func isHabitCompleted(habit: Habit, date: Date) -> Bool?
    
    /// Determina el tipo de periodo para cálculos de rachas y estadísticas.
    /// Devuelve el tipo de periodo si el plugin lo maneja, o `nil` para usar el comportamiento por defecto (daily).
    func getCompletionPeriodType(habit: Habit) -> CompletionPeriodType?
    
    // MARK: - Streak Calculation Overrides
    
    /// Calcula la racha actual del hábito de forma personalizada.
    /// Devuelve el valor de la racha o `nil` para usar el cálculo por defecto.
    func calculateCurrentStreak(habit: Habit, on date: Date) -> Int?
    
    /// Actualiza la racha del hábito cuando se completa.
    /// Devuelve `true` si el plugin manejó la actualización, `false` para usar lógica por defecto.
    func updateStreakOnCompletion(habit: Habit, on date: Date) -> Bool
    
    // MARK: - Stats Calculation Overrides
    
    /// Calcula el total de periodos activos (días/semanas/meses).
    /// Devuelve el valor o `nil` para usar el cálculo por defecto.
    func calculateTotalPeriodsActive(habit: Habit, until date: Date) -> (value: Int, label: String)?
    
    /// Calcula el total de periodos completados.
    /// Devuelve el valor o `nil` para usar el cálculo por defecto.
    func calculateTotalPeriodsCompleted(habit: Habit) -> (value: Int, label: String)?
    
    /// Devuelve la etiqueta/unidad para las rachas (ej: "dias", "semanas", "meses").
    /// Devuelve `nil` para usar el valor por defecto ("dias").
    func getStreakLabel(habit: Habit) -> String?
}

// Implementación por defecto
extension LogicPlugin {
    func shouldHabitBeCompletedOn(habit: Habit, date: Date) -> Bool? { nil }
    func isHabitCompleted(habit: Habit, date: Date) -> Bool? { nil }
    func getCompletionPeriodType(habit: Habit) -> CompletionPeriodType? { nil }
    
    func calculateCurrentStreak(habit: Habit, on date: Date) -> Int? { nil }
    func updateStreakOnCompletion(habit: Habit, on date: Date) -> Bool { false }
    
    func calculateTotalPeriodsActive(habit: Habit, until date: Date) -> (value: Int, label: String)? { nil }
    func calculateTotalPeriodsCompleted(habit: Habit) -> (value: Int, label: String)? { nil }
    func getStreakLabel(habit: Habit) -> String? { nil }
}
