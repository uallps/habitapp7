import SwiftUI
import SwiftData

struct PauseDaySelectionView: View {
    @StateObject private var viewModel: PauseDayViewModel

    init(habitID: UUID, context: ModelContext, existingPauseDays: HabitPauseDays? = nil) {
        _viewModel = StateObject(
            wrappedValue: PauseDayViewModel(
                habitId: habitID,
                context: context,
                existingPauseDays: existingPauseDays
            )
        )
    }

    var body: some View {
        let sortedDates = viewModel.sortedDates

        Section("Dias de pausa (sin habito)") {
            DatePicker("Dia", selection: $viewModel.dateToAdd, in: viewModel.today..., displayedComponents: .date)
            Button("Agregar dia") {
                viewModel.addDate()
            }
            .disabled(!viewModel.canAddDate)

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
                            viewModel.removeDate(date)
                        }
                    }
                }
            }

            Text("Estos dias no cuentan para la racha si no completas el habito.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
