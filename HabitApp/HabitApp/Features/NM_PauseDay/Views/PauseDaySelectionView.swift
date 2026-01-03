import SwiftUI
import SwiftData

struct PauseDaySelectionView: View {
    let habitID: UUID
    let context: ModelContext

    @State private var selectedDates: Set<Date> = []
    @State private var dateToAdd = Date()
    @State private var pauseDays: HabitPauseDays?

    init(habitID: UUID, context: ModelContext, existingPauseDays: HabitPauseDays? = nil) {
        self.habitID = habitID
        self.context = context
        _pauseDays = State(initialValue: existingPauseDays)
        _selectedDates = State(initialValue: Set(existingPauseDays?.pauseDates.map {
            Calendar.current.startOfDay(for: $0)
        } ?? []))
    }

    var body: some View {
        let sortedDates = selectedDates.sorted()
        let today = Calendar.current.startOfDay(for: Date())
        let normalizedDateToAdd = Calendar.current.startOfDay(for: dateToAdd)

        Section("Dias de pausa (sin habito)") {
            DatePicker("Dia", selection: $dateToAdd, in: today..., displayedComponents: .date)
            Button("Agregar dia") {
                addDate()
            }
            .disabled(
                normalizedDateToAdd < today ||
                    selectedDates.contains(normalizedDateToAdd)
            )

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
            if pauseDays == nil {
                loadData()
            }
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
        let today = Calendar.current.startOfDay(for: Date())
        guard date >= today else { return }
        if selectedDates.insert(date).inserted {
            saveSelection()
        }
    }

    private func removeDate(_ date: Date) {
        selectedDates.remove(date)
        saveSelection()
    }
}
