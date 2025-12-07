import Foundation
import SwiftData

@Model
final class Habit: Identifiable {
    // Persistimos un UUID controlado por nosotros
    @Attribute(.unique) var id: UUID

    // Propiedades básicas
    var title: String

    // Almacenamos el rawValue de Priority para compatibilidad con SwiftData
    private var priorityRaw: String?
    // API amigable para priority
    var priority: Priority? {
        get { priorityRaw.flatMap { Priority(rawValue: $0) } }
        set { priorityRaw = newValue?.rawValue }
    }

    // Completados: relación to-many sin orden garantizado
    @Relationship(deleteRule: .cascade)
    var completed: [CompletionEntry]
    
    // Relación con la categoría (a través de HabitCategoryFeature)
    @Relationship(deleteRule: .cascade)
    var categoryFeature: HabitCategoryFeature?
    
    // Relación con streak (a través de HabitStreakFeature)
    @Relationship(deleteRule: .cascade)
    var streakFeature: HabitStreakFeature?

    // Guardamos los rawValues de Weekday
    private var frequencyRaw: [String]
    var frequency: [Weekday] {
        get { frequencyRaw.compactMap { Weekday(rawValue: $0) } }
        set { frequencyRaw = newValue.map { $0.rawValue } }
    }

    // Inicialización
    init(
        id: UUID = UUID(),
        title: String,
        priority: Priority? = nil,
        completed: [CompletionEntry] = [],
        frequency: [Weekday] = []
    ) {
        self.id = id
        self.title = title
        self.priorityRaw = priority?.rawValue
        self.completed = completed
        self.frequencyRaw = frequency.map { $0.rawValue }
    }

    // Propiedad derivada: ¿está completada hoy?
    var isCompletedToday: Bool {
        let today = Date()
        return completed.contains { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
}

enum Priority: String, Codable {
    case low, medium, high
}

enum Weekday: String, Codable, CaseIterable {
    case monday = "Lunes"
    case tuesday = "Martes"
    case wednesday = "Miércoles"
    case thursday = "Jueves"
    case friday = "Viernes"
    case saturday = "Sábado"
    case sunday = "Domingo"
    
    /// Obtiene el Weekday correspondiente a un Date
    static func from(date: Date) -> Weekday {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        
        // Calendar.weekday: 1 = Domingo, 2 = Lunes, ..., 7 = Sábado
        switch weekdayIndex {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }
}

// MARK: - Habit Extensions for Reminders

extension Habit {
    /// Determina si este hábito debe completarse en una fecha específica
    /// - Parameter date: Fecha a verificar
    /// - Returns: true si el hábito debe hacerse ese día
    func shouldBeCompletedOn(date: Date) -> Bool {
        // Si no hay frecuencia definida, no se debe completar
        guard !frequency.isEmpty else {
            return false
        }
        
        // Obtener el día de la semana de la fecha
        let weekday = Weekday.from(date: date)
        
        // Verificar si el día está en la frecuencia del hábito
        return frequency.contains(weekday)
    }
}
