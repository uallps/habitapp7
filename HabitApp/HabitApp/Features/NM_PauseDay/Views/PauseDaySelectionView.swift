import SwiftUI
import SwiftData

struct PauseDaySelectionView: View {
    let habitID: UUID
    let context: ModelContext

    @State private var selectedDays: Set<Weekday> = []
    @State private var pauseDays: HabitPauseDays?

    var body: some View {
        Section("Dias de pausa (sin habito)") {
            ForEach(Weekday.allCases, id: \.self) { day in
                Toggle(day.rawValue, isOn: Binding(
                    get: { selectedDays.contains(day) },
                    set: { isSelected in
                        if isSelected {
                            selectedDays.insert(day)
                        } else {
                            selectedDays.remove(day)
                        }
                        saveSelection()
                    }
                ))
            }
            Text("Estos dias no cuentan para la racha si no completas el habito.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        let descriptor = FetchDescriptor<HabitPauseDays>(
            predicate: #Predicate { $0.habitId == habitID }
        )

        if let existing = try? context.fetch(descriptor).first {
            pauseDays = existing
            selectedDays = Set(existing.pauseDays)
        } else {
            let newPauseDays = HabitPauseDays(habitId: habitID, pauseDays: [])
            context.insert(newPauseDays)
            pauseDays = newPauseDays
            selectedDays = []
        }
    }

    private func saveSelection() {
        pauseDays?.pauseDays = Array(selectedDays)
    }
}
