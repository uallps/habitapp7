import SwiftUI
import SwiftData

struct HabitModifyView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
    var habitToEdit: Habit?
    
    @State private var title = ""
    @State private var dueDate = Date()
    @State private var priority: Priority? = nil
    @State private var selectedDays: Set<Weekday> = []
    @State private var selectedCategory: Category?
    @State private var availableCategories: [Category] = []
    
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
                    
                    Picker("Categoría", selection: $selectedCategory) {
                        Text("Sin categoría").tag(nil as Category?)
                        ForEach(availableCategories, id: \.id) { category in
                            Text(category.name).tag(category as Category?)
                        }
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
                            // Actualizar hábito existente directamente (no crear uno nuevo)
                            existingHabit.title = title
                            existingHabit.priority = priority
                            existingHabit.frequency = Array(selectedDays)
                            existingHabit.category = selectedCategory
                            
                            // Notificar al ViewModel para que persista
                            viewModel.updateHabit(existingHabit)
                        } else {
                            // Crear nuevo hábito
                            let newHabit = Habit(
                                title: title,
                                priority: priority,
                                completed: [],
                                frequency: Array(selectedDays)
                            )
                            // Asignar categoría
                            newHabit.category = selectedCategory
                            viewModel.addHabit(newHabit)
                        }
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                // Cargar categorías disponibles desde SwiftData
                if let context = SwiftDataContext.shared {
                    let descriptor = FetchDescriptor<Category>()
                    availableCategories = (try? context.fetch(descriptor)) ?? []
                }
                
                // Cargar datos del hábito si estamos editando
                if let habit = habitToEdit {
                    title = habit.title
                    priority = habit.priority
                    selectedDays = Set(habit.frequency)
                    selectedCategory = habit.category
                }
            }
        }
    }
}

