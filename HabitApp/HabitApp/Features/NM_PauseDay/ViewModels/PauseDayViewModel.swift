import Foundation
import SwiftData

@MainActor
final class PauseDayViewModel: ObservableObject {
    @Published var selectedDates: Set<Date>
    @Published var dateToAdd: Date

    private let habitId: UUID
    private let context: ModelContext
    private var pauseDays: HabitPauseDays?

    init(
        habitId: UUID,
        context: ModelContext,
        existingPauseDays: HabitPauseDays? = nil
    ) {
        self.habitId = habitId
        self.context = context
        self.dateToAdd = Date()

        if let existingPauseDays = existingPauseDays {
            self.pauseDays = existingPauseDays
            self.selectedDates = Set(existingPauseDays.pauseDates.map {
                Calendar.current.startOfDay(for: $0)
            })
        } else {
            let descriptor = FetchDescriptor<HabitPauseDays>(
                predicate: #Predicate { $0.habitId == habitId }
            )

            if let existing = try? context.fetch(descriptor).first {
                self.pauseDays = existing
                self.selectedDates = Set(existing.pauseDates.map {
                    Calendar.current.startOfDay(for: $0)
                })
            } else {
                let newPauseDays = HabitPauseDays(habitId: habitId, pauseDates: [])
                context.insert(newPauseDays)
                self.pauseDays = newPauseDays
                self.selectedDates = []
            }
        }
    }

    var sortedDates: [Date] {
        selectedDates.sorted()
    }

    var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    var normalizedDateToAdd: Date {
        Calendar.current.startOfDay(for: dateToAdd)
    }

    var canAddDate: Bool {
        normalizedDateToAdd >= today && !selectedDates.contains(normalizedDateToAdd)
    }

    func addDate() {
        let date = normalizedDateToAdd
        guard date >= today else { return }
        if selectedDates.insert(date).inserted {
            saveSelection()
        }
    }

    func removeDate(_ date: Date) {
        selectedDates.remove(date)
        saveSelection()
    }

    private func saveSelection() {
        pauseDays?.pauseDates = selectedDates.sorted()
    }
}
