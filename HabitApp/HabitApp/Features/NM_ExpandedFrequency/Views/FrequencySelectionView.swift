import SwiftUI
import SwiftData

struct FrequencySelectionView: View {
    var habitID: UUID
    var context: ModelContext
    
    @State private var selectedType: FrequencyType = .daily
    @State private var expandedFrequency: ExpandedFrequency?
    
    var body: some View {
        Section("Frecuencia Extendida (Plugin)") {
            Picker("Tipo de Frecuencia", selection: $selectedType) {
                ForEach(FrequencyType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .onChange(of: selectedType) { newValue in
                saveSelection(newValue)
            }
            
            if selectedType == .daily {
                Text("Usa la sección de Frecuencia arriba para seleccionar los días.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("La selección de días de arriba será ignorada.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if selectedType == .addiction {
                Text("El hábito se marcará como completado automáticamente. Pulsa para registrar una recaída.")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        // Intentar buscar existente
        let descriptor = FetchDescriptor<ExpandedFrequency>(
            predicate: #Predicate { $0.habitID == habitID }
        )
        
        if let existing = try? context.fetch(descriptor).first {
            expandedFrequency = existing
            selectedType = existing.type
        } else {
            // No existe, creamos uno nuevo
            let newFreq = ExpandedFrequency(habitID: habitID, type: .daily)
            context.insert(newFreq)
            expandedFrequency = newFreq
            selectedType = .daily
        }
    }
    
    private func saveSelection(_ type: FrequencyType) {
        if let expandedFrequency = expandedFrequency {
            expandedFrequency.type = type
        } else {
            let newFreq = ExpandedFrequency(habitID: habitID, type: type)
            context.insert(newFreq)
            expandedFrequency = newFreq
        }
    }
}
