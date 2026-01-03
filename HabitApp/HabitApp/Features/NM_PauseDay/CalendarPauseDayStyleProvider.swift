import SwiftUI

protocol CalendarPauseDayStyleProvider {
    func calendarDayStyle(for habit: Habit, date: Date) -> CalendarDayStyle?
}

struct CalendarDayStyle {
    var foregroundColor: Color?
    var backgroundColor: Color?
    var opacity: Double?

    init(
        foregroundColor: Color? = nil,
        backgroundColor: Color? = nil,
        opacity: Double? = nil
    ) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.opacity = opacity
    }
}
