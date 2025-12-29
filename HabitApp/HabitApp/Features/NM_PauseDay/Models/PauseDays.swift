import Foundation
import SwiftData

@Model
final class HabitPauseDays {
    @Attribute(.unique) var habitId: UUID
    private var pauseDaysRaw: [String]

    var pauseDays: [Weekday] {
        get { pauseDaysRaw.compactMap { Weekday(rawValue: $0) } }
        set { pauseDaysRaw = newValue.map { $0.rawValue } }
    }

    init(habitId: UUID, pauseDays: [Weekday] = []) {
        self.habitId = habitId
        self.pauseDaysRaw = pauseDays.map { $0.rawValue }
    }
}
