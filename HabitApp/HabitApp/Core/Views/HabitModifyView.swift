import SwiftUI
import SwiftData

struct HabitModifyView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
    @EnvironmentObject private var appConfig: AppConfig
    @Environment(\.colorScheme) private var colorScheme
    var habitToEdit: Habit?
    
    @State private var title = ""
    @State private var priority: Priority? = nil
    @State private var selectedDays: Set<Weekday> = []
    @State private var selectedCategory: Category?
    @State private var availableCategories: [Category] = []
    @State private var showDeleteConfirmation = false
    
    // Hábito temporal para que los plugins puedan enlazar datos durante la edición/creación
    // Inicializar con el hábito existente si lo hay, o crear uno nuevo
    @State private var tempHabit: Habit
    
    init(viewModel: HabitListViewModel, habitToEdit: Habit? = nil) {
        self.viewModel = viewModel
        self.habitToEdit = habitToEdit
        // Inicializar tempHabit con el hábito existente o crear uno nuevo
        _tempHabit = State(initialValue: habitToEdit ?? Habit(title: "", completed: []))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información del Hábito") {
                    TextField("Título", text: $title)
                    
                    Picker("Prioridad", selection: $priority) {
                        Text("Ninguna").tag(nil as Priority?)
                        Text("Baja").tag(Priority.low as Priority?)
                        Text("Media").tag(Priority.medium as Priority?)
                        Text("Alta").tag(Priority.high as Priority?)
                    }
                    
                    // Feature flag: picker de categoría solo si está habilitado
                    if appConfig.showCategories {
                        Picker("Categoría", selection: $selectedCategory) {
                            Text("Sin categoría").tag(nil as Category?)
                            ForEach(availableCategories, id: \.id) { category in
                                Text(category.name).tag(category as Category?)
                            }
                        }
                    }
                }
                .listRowBackground(cardBackground)
                
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
                .listRowBackground(cardBackground)
                
                // 🔌 PLUGINS: Secciones de modificación (ej. Frecuencia extendida, Tipo de hábito)
                if let context = SwiftDataContext.shared {
                    let modificationSections =
                        PluginRegistry.shared.getHabitModificationSections(habit: tempHabit, context: context)
                    ForEach(modificationSections.indices, id: \.self) { index in
                        modificationSections[index]
                    }
                }
                
                // Sección de eliminación visible solo cuando estamos editando un hábito existente
                if habitToEdit != nil {
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Text("Eliminar Hábito")
                        }
                    }
                    .listRowBackground(cardBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .background(backgroundColor)
            .tint(primaryColor)
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
                        // Actualizar el hábito temporal con los datos del formulario base
                        tempHabit.title = title
                        tempHabit.priority = priority
                        tempHabit.frequency = Array(selectedDays)
                        
                        if appConfig.showCategories {
                            tempHabit.setCategory(selectedCategory)
                        }
                        
                        // Notificar a los plugins para que guarden sus datos
                        if let context = SwiftDataContext.shared {
                            PluginRegistry.shared.notifySave(habit: tempHabit, context: context)
                        }
                        
                        if let existingHabit = habitToEdit {
                            // Si editamos, tempHabit ya es existingHabit (por referencia en onAppear)
                            // Solo notificamos al VM
                            viewModel.updateHabit(existingHabit)
                        } else {
                            // Si es nuevo, tempHabit es el nuevo objeto
                            viewModel.addHabit(tempHabit)
                        }
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                // Feature flag: cargar categorías solo si está habilitado
                if appConfig.showCategories {
                    if let context = SwiftDataContext.shared {
                        let descriptor = FetchDescriptor<Category>()
                        availableCategories = (try? context.fetch(descriptor)) ?? []
                    }
                }
                
                // Cargar datos del hábito si estamos editando (tempHabit ya está asignado en init)
                if let habit = habitToEdit {
                    title = habit.title
                    priority = habit.priority
                    selectedDays = Set(habit.frequency)
                    
                    if appConfig.showCategories {
                        selectedCategory = habit.getCategory()
                    }
                }
            }
            .alert("Eliminar Hábito", isPresented: $showDeleteConfirmation) {
                Button("Eliminar", role: .destructive) {
                    if let existingHabit = habitToEdit {
                        viewModel.deleteHabit(existingHabit)
                    }
                    dismiss()
                }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Esta acción no se puede deshacer.")
            }
        }
    }

    private var primaryColor: Color {
        Color(red: 242 / 255, green: 120 / 255, blue: 13 / 255)
    }

    private var backgroundColor: Color {
        colorScheme == .dark
            ? Color(red: 25 / 255, green: 18 / 255, blue: 14 / 255)
            : Color(red: 248 / 255, green: 247 / 255, blue: 245 / 255)
    }

    private var cardBackground: Color {
        colorScheme == .dark
            ? Color(red: 38 / 255, green: 26 / 255, blue: 20 / 255)
            : Color.white
    }
}
