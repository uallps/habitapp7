import Foundation
import SwiftData

enum HabitCompletionType: String, Codable, CaseIterable {
    case binary = "Binario"
    case count = "N veces"
    case timer = "Cronómetro"
}

@Model
class HabitType {
    @Attribute(.unique) var habitID: UUID
    var type: HabitCompletionType
    var targetValue: Double? // Para N veces o Cronómetro (segundos)
    var unit: String? // Opcional, ej. "páginas", "minutos"
    
    // Estado diario
    var currentValue: Double = 0.0
    var lastLogDate: Date?
    
    init(habitID: UUID, type: HabitCompletionType = .binary, targetValue: Double? = nil, unit: String? = nil) {
        self.habitID = habitID
        self.type = type
        self.targetValue = targetValue
        self.unit = unit
        self.currentValue = 0.0
        self.lastLogDate = nil
    }
}
