import SwiftUI
import SwiftData

struct PauseDaySelectionView: View {
    let habitID: UUID
    let context: ModelContext

    @State private var selectedDates: Set<Date> = []
    @State private var dateToAdd = Date()
    @State private var pauseDays: HabitPauseDays?

    var body: some View {
        let sortedDates = selectedDates.sorted()

        Section("Dias de pausa (sin habito)") {
            DatePicker("Dia", selection: $dateToAdd, displayedComponents: .date)
            Button("Agregar dia") {
                addDate()
            }
            .disabled(selectedDates.contains(Calendar.current.startOfDay(for: dateToAdd)))

            if sortedDates.isEmpty {
                Text("No hay dias en pausa.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sortedDates, id: \.self) { date in
                    HStack {
                        Text(date, style: .date)
                        Spacer()
                        Button("Quitar") {
                            removeDate(date)
                        }
                    }
                }
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
            let normalized = existing.pauseDates.map {
                Calendar.current.startOfDay(for: $0)
            }
            selectedDates = Set(normalized)
        } else {
            let newPauseDays = HabitPauseDays(habitId: habitID, pauseDates: [])
            context.insert(newPauseDays)
            pauseDays = newPauseDays
            selectedDates = []
        }
    }

    private func saveSelection() {
        pauseDays?.pauseDates = selectedDates.sorted()
    }

    private func addDate() {
        let date = Calendar.current.startOfDay(for: dateToAdd)
        if selectedDates.insert(date).inserted {
            saveSelection()
        }
    }

    private func removeDate(_ date: Date) {
        selectedDates.remove(date)
        saveSelection()
    }
}
