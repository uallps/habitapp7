import Foundation

struct Habit: Identifiable {
    let id: UUID
    var title: String
    var priority: Priority?
    var completed: [CompletionEntry]
    var frequency: [Weekday]

    // Inicializador completo (permite usar el id existente)
    init(
        id: UUID = UUID(),
        title: String,
        priority: Priority?,
        completed: [CompletionEntry],
        frequency: [Weekday]
    ) {
        self.id = id
        self.title = title
        self.priority = priority
        self.completed = completed
        self.frequency = frequency
    }

    var isCompleted: Bool {
        completed.contains { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
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
}

