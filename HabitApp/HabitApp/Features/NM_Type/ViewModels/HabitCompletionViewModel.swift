import SwiftUI
import SwiftData
import Combine

class HabitCompletionViewModel: ObservableObject {
    let habit: Habit
    let context: ModelContext
    let toggleAction: () -> Void
    
    @Published var habitType: HabitType?
    @Published var progress: Double = 0
    @Published var isTimerRunning = false
    
    private var timer: AnyCancellable?
    
    init(habit: Habit, context: ModelContext, toggleAction: @escaping () -> Void) {
        self.habit = habit
        self.context = context
        self.toggleAction = toggleAction
        loadData()
    }
    
    func loadData() {
        // Cargar Configuración
        let id = habit.id
        let typeDescriptor = FetchDescriptor<HabitType>(predicate: #Predicate { $0.habitID == id })
        habitType = try? context.fetch(typeDescriptor).first
        
        // Verificar si el progreso es válido para el periodo actual
        if let type = habitType {
            let today = Calendar.current.startOfDay(for: Date())
            
            if let lastDate = type.lastLogDate, isSamePeriod(lastDate: lastDate, today: today) {
                // Es del mismo periodo (día, semana o mes), mantenemos el progreso
                progress = type.currentValue
            } else {
                // Es de otro periodo, resetear visualmente
                progress = 0
            }
        }
    }
    
    /// Determina si dos fechas pertenecen al mismo periodo de completado
    /// basándose en la configuración de ExpandedFrequency si existe.
    private func isSamePeriod(lastDate: Date, today: Date) -> Bool {
        let id = habit.id
        
        // Intentar buscar configuración de frecuencia extendida
        // Nota: Asumimos que ExpandedFrequency está disponible en el proyecto
        let descriptor = FetchDescriptor<ExpandedFrequency>(
            predicate: #Predicate { $0.habitID == id }
        )
        
        if let freq = try? context.fetch(descriptor).first {
            switch freq.type {
            case .weekly:
                return Calendar.current.isDate(lastDate, equalTo: today, toGranularity: .weekOfYear)
            case .monthly:
                return Calendar.current.isDate(lastDate, equalTo: today, toGranularity: .month)
            case .daily, .addiction:
                return Calendar.current.isDate(lastDate, inSameDayAs: today)
            }
        }
        
        // Default: Diario
        return Calendar.current.isDate(lastDate, inSameDayAs: today)
    }
    
    func incrementProgress() {
        updateProgress(progress + 1)
    }
    
    func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.updateProgress((self?.progress ?? 0) + 1)
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func updateProgress(_ newValue: Double) {
        progress = newValue
        
        // Guardar en el modelo único
        if let type = habitType {
            type.currentValue = newValue
            type.lastLogDate = Date()
        }
        
        checkCompletion()
    }
    
    private func checkCompletion() {
        guard let type = habitType, let target = type.targetValue else { return }
        
        let isCompleted = progress >= target
        let currentlyMarked = habit.isCompletedToday
        
        if isCompleted && !currentlyMarked {
            toggleAction()
        } else if !isCompleted && currentlyMarked {
            toggleAction()
        }
    }
}
