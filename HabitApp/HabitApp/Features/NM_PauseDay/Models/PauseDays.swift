import Foundation
import SwiftData

@Model
final class HabitPauseDays {
    @Attribute(.unique) var habitId: UUID
    private var pauseDatesRaw: [String]

    var pauseDates: [Date] {
        get { pauseDatesRaw.compactMap { Self.dateFromKey($0) } }
        set { pauseDatesRaw = newValue.map { Self.dateKey(for: $0) } }
    }

    init(habitId: UUID, pauseDates: [Date] = []) {
        self.habitId = habitId
        self.pauseDatesRaw = pauseDates.map { Self.dateKey(for: $0) }
    }

    func isPaused(on date: Date) -> Bool {
        pauseDatesRaw.contains(Self.dateKey(for: date))
    }

    static func dateKey(for date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 1
        let day = components.day ?? 1
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    private static func dateFromKey(_ key: String) -> Date? {
        let parts = key.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else {
            return nil
        }

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)
            .map { Calendar.current.startOfDay(for: $0) }
    }
}
