import SwiftUI
import SwiftData
import Combine

class HabitTypeViewModel: ObservableObject {
    var habitID: UUID
    var context: ModelContext
    
    @Published var selectedType: HabitCompletionType = .binary
    @Published var targetValue: String = ""
    @Published var unit: String = ""
    
    // Variables auxiliares para el Timer Picker
    @Published var selectedMinutes: Int = 0
    @Published var selectedSeconds: Int = 0
    
    private var habitTypeModel: HabitType?
    
    init(habitID: UUID, context: ModelContext) {
        self.habitID = habitID
        self.context = context
        loadData()
    }
    
    func loadData() {
        let id = habitID
        let descriptor = FetchDescriptor<HabitType>(predicate: #Predicate { $0.habitID == id })
        
        if let existing = try? context.fetch(descriptor).first {
            habitTypeModel = existing
            selectedType = existing.type
            if let val = existing.targetValue {
                targetValue = String(format: "%.0f", val)
                
                // Cargar minutos y segundos
                let totalSeconds = Int(val)
                selectedMinutes = totalSeconds / 60
                selectedSeconds = totalSeconds % 60
            }
            unit = existing.unit ?? ""
        } else {
            let new = HabitType(habitID: habitID)
            context.insert(new)
            habitTypeModel = new
        }
    }
    
    func saveType(_ type: HabitCompletionType) {
        selectedType = type
        habitTypeModel?.type = type
    }
    
    func saveTargetValue(_ value: String) {
        targetValue = value
        habitTypeModel?.targetValue = Double(value)
    }
    
    func saveTime(minutes: Int, seconds: Int) {
        selectedMinutes = minutes
        selectedSeconds = seconds
        let total = Double((minutes * 60) + seconds)
        targetValue = String(format: "%.0f", total)
        habitTypeModel?.targetValue = total
    }
    
    func saveUnit(_ value: String) {
        unit = value
        habitTypeModel?.unit = value
    }
}
