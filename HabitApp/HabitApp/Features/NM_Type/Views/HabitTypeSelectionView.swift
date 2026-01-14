import SwiftUI
import SwiftData
import Combine

struct HabitTypeSelectionView: View {
    @StateObject private var viewModel: HabitTypeViewModel
    
    init(habitID: UUID, context: ModelContext) {
        _viewModel = StateObject(wrappedValue: HabitTypeViewModel(habitID: habitID, context: context))
    }
    
    var body: some View {
        Section("Tipo de Completado (Plugin)") {
            Picker("Tipo", selection: Binding(
                get: { viewModel.selectedType },
                set: { viewModel.saveType($0) }
            )) {
                ForEach(HabitCompletionType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            
            if viewModel.selectedType == .count {
                HStack {
                    TextField("Objetivo (ej. 10)", text: Binding(
                        get: { viewModel.targetValue },
                        set: { viewModel.saveTargetValue($0) }
                    ))
                    .keyboardType(.numberPad)
                    
                    TextField("Unidad (ej. páginas)", text: Binding(
                        get: { viewModel.unit },
                        set: { viewModel.saveUnit($0) }
                    ))
                }
            }
            
            if viewModel.selectedType == .timer {
                HStack {
                    Picker("Minutos", selection: Binding(
                        get: { viewModel.selectedMinutes },
                        set: { viewModel.saveTime(minutes: $0, seconds: viewModel.selectedSeconds) }
                    )) {
                        ForEach(0..<121) { m in
                            Text("\(m) min").tag(m)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)
                    
                    Picker("Segundos", selection: Binding(
                        get: { viewModel.selectedSeconds },
                        set: { viewModel.saveTime(minutes: viewModel.selectedMinutes, seconds: $0) }
                    )) {
                        ForEach(0..<60) { s in
                            Text("\(s) s").tag(s)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)
                }
            }
        }
    }
}
