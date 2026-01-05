import SwiftUI
import SwiftData

struct FrequencySelectionView: View {
    @StateObject private var viewModel: ExpandedFrequencyViewModel

    init(habitID: UUID, context: ModelContext) {
        _viewModel = StateObject(
            wrappedValue: ExpandedFrequencyViewModel(
                habitId: habitID,
                context: context
            )
        )
    }

    var body: some View {
        Section("Frecuencia Extendida (Plugin)") {
            Picker("Tipo de Frecuencia", selection: $viewModel.selectedType) {
                ForEach(FrequencyType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .onChange(of: viewModel.selectedType) { newValue in
                viewModel.saveSelection(newValue)
            }

            if viewModel.isDaily {
                Text("Usa la seccion de Frecuencia arriba para seleccionar los dias.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("La seleccion de dias de arriba sera ignorada.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if viewModel.isAddiction {
                Text("El habito se marcara como completado automaticamente. Pulsa para registrar una recaida.")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
}
