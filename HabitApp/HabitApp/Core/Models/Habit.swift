import Foundation
import SwiftData

@Model
final class Habit: Identifiable {
    // Persistimos un UUID controlado por nosotros
    @Attribute(.unique) var id: UUID

    // Propiedades basicas
    var title: String
    var endDate: Date?
    // Almacenamos el rawValue de Priority para compatibilidad con SwiftData
    private var priorityRaw: String?
    // API amigable para priority
    var priority: Priority? {
        get { priorityRaw.flatMap { Priority(rawValue: $0) } }
        set { priorityRaw = newValue?.rawValue }
    }

    // Completados: relacion to-many sin orden garantizado
    @Relationship(deleteRule: .cascade)
    var completed: [CompletionEntry]

    // Guardamos los rawValues de Weekday
    private var frequencyRaw: [String]
    var frequency: [Weekday] {
        get { frequencyRaw.compactMap { Weekday(rawValue: $0) } }
        set { frequencyRaw = newValue.map { $0.rawValue } }
    }

    // Inicializacion
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

    // Propiedad derivada: esta completada hoy?
    var isCompletedToday: Bool {
        return isCompleted(on: Date())
    }
    
    /// Determina si el habito esta completado en una fecha especifica
    /// - Parameter date: Fecha a verificar (por defecto: hoy)
    /// - Returns: true si el habito esta completado en esa fecha
    func isCompleted(on date: Date = Date()) -> Bool {
        // NO PLUGINS: Permitir que un plugin determine si esta completado (ej. Adiccion = !entry)
        if let pluginResult = PluginRegistry.shared.isHabitCompleted(habit: self, date: date) {
            return pluginResult
        }
        return completed.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}

enum Priority: String, Codable {
    case low, medium, high
}

enum Weekday: String, Codable, CaseIterable {
    case monday = "Lunes"
    case tuesday = "Martes"
    case wednesday = "Mi\u{00E9}rcoles"
    case thursday = "Jueves"
    case friday = "Viernes"
    case saturday = "S\u{00E1}bado"
    case sunday = "Domingo"
    
    /// Obtiene el Weekday correspondiente a un Date
    static func from(date: Date) -> Weekday {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        
        // Calendar.weekday: 1 = Domingo, 2 = Lunes, ..., 7 = Sabado
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
    /// Determina si este habito debe completarse en una fecha especifica
    /// - Parameter date: Fecha a verificar
    /// - Returns: true si el habito debe hacerse ese dia
    func shouldBeCompletedOn(date: Date) -> Bool {
        // NO PLUGINS: Permitir que un plugin determine si se debe completar hoy (ej. Frecuencia extendida)
        if let pluginResult = PluginRegistry.shared.shouldHabitBeCompletedOn(habit: self, date: date) {
            return pluginResult
        }
        
        // Si no hay frecuencia definida, no se debe completar
        guard !frequency.isEmpty else {
            return false
        }
        
        // Obtener el dia de la semana de la fecha
        let weekday = Weekday.from(date: date)
        
        // Verificar si el dia esta en la frecuencia del habito
        return frequency.contains(weekday)
    }
}
