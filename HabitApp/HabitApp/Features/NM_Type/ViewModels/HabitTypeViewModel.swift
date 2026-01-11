import SwiftUI
import SwiftData
import Combine

class HabitTypeViewModel: ObservableObject {
    var habitID: UUID
    var context: ModelContext
    
    @Published var selectedType: HabitCompletionType
    @Published var targetValue: String
    @Published var unit: String
    
    // Variables auxiliares para el Timer Picker
    @Published var selectedMinutes: Int
    @Published var selectedSeconds: Int
    
    private var habitTypeModel: HabitType?
    
    init(habitID: UUID, context: ModelContext) {
        self.habitID = habitID
        self.context = context
        
        // Cargar datos ANTES de inicializar @Published properties
        let id = habitID
        let descriptor = FetchDescriptor<HabitType>(predicate: #Predicate { $0.habitID == id })
        
        if let existing = try? context.fetch(descriptor).first {
            self.habitTypeModel = existing
            self.selectedType = existing.type
            
            if let val = existing.targetValue {
                self.targetValue = String(format: "%.0f", val)
                
                // Cargar minutos y segundos
                let totalSeconds = Int(val)
                self.selectedMinutes = totalSeconds / 60
                self.selectedSeconds = totalSeconds % 60
            } else {
                self.targetValue = ""
                self.selectedMinutes = 0
                self.selectedSeconds = 0
            }
            
            self.unit = existing.unit ?? ""
        } else {
            let new = HabitType(habitID: habitID)
            context.insert(new)
            self.habitTypeModel = new
            self.selectedType = .binary
            self.targetValue = ""
            self.unit = ""
            self.selectedMinutes = 0
            self.selectedSeconds = 0
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
