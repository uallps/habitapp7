import SwiftUI

struct HabitModifyView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
    var habitToEdit: Habit?
    
    @State private var title = ""
    @State private var dueDate = Date()
    @State private var priority: Priority? = nil
    @State private var selectedDays: Set<Weekday> = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información del Hábito") {
                    TextField("Título", text: $title)
                    
                    DatePicker("Fecha límite", selection: $dueDate, displayedComponents: .date)
                    
                    Picker("Prioridad", selection: $priority) {
                        Text("Ninguna").tag(nil as Priority?)
                        Text("Baja").tag(Priority.low as Priority?)
                        Text("Media").tag(Priority.medium as Priority?)
                        Text("Alta").tag(Priority.high as Priority?)
                    }
                }
                
                Section("Frecuencia") {
                    ForEach(Weekday.allCases, id: \.self) { day in
                        Toggle(day.rawValue, isOn: Binding(
                            get: { selectedDays.contains(day) },
                            set: { isSelected in
                                if isSelected {
                                    selectedDays.insert(day)
                                } else {
                                    selectedDays.remove(day)
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle(habitToEdit == nil ? "Nuevo Hábito" : "Modificar Hábito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        if let existingHabit = habitToEdit {

                            // 🔥 Habit reconstruido conservando el ID del original
                            let updatedHabit = Habit(
                                id: existingHabit.id,
                                title: title,
                                priority: priority,
                                completed: existingHabit.completed,
                                frequency: Array(selectedDays)
                            )
                            
                            viewModel.updateHabit(updatedHabit)
                        } else {
                            let newHabit = Habit(
                                title: title,
                                priority: priority,
                                completed: [],
                                frequency: Array(selectedDays)
                            )
                            viewModel.addHabit(newHabit)
                        }
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let habit = habitToEdit {
                    title = habit.title
                    priority = habit.priority
                    selectedDays = Set(habit.frequency)
                }
            }
        }
    }
}

