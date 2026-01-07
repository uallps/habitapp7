import Foundation
import SwiftData

struct SuggestedHabitDraft: Codable {
    let title: String
    let details: String
}

@Model
final class SuggestedHabitSuggestion: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var details: String
    var createdAt: Date
    var sourceModel: String

    init(
        id: UUID = UUID(),
        title: String,
        details: String,
        createdAt: Date = Date(),
        sourceModel: String
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.createdAt = createdAt
        self.sourceModel = sourceModel
    }
}
