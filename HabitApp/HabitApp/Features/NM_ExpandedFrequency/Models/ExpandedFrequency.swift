import Foundation
import SwiftData

enum FrequencyType: String, Codable, CaseIterable {
    case daily = "Diaria"
    case weekly = "Semanal"
    case monthly = "Mensual"
    case addiction = "Adiccion"
}

@Model
class ExpandedFrequency {
    @Attribute(.unique) var habitID: UUID
    var type: FrequencyType
    
    init(habitID: UUID, type: FrequencyType = .daily) {
        self.habitID = habitID
        self.type = type
    }
}
