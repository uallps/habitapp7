import Foundation
import SwiftUI
import UserNotifications

struct HabitListView: View {
    @StateObject private var viewModel: HabitListViewModel
    @EnvironmentObject private var appConfig: AppConfig
    
    @State private var isAddingHabit = false
    @State private var habitToEdit: Habit?
    @State private var isAddingCategory = false
    
    // Inicializador con inyección de dependencias
    init(storageProvider: StorageProvider) {
        _viewModel = StateObject(wrappedValue: HabitListViewModel(storageProvider: storageProvider))
    }
    
    var body: some View {
        let headerViews = PluginRegistry.shared.getHabitListHeaderViews()
        let footerViews = PluginRegistry.shared.getHabitListFooterViews()

        NavigationStack {
            ZStack {
                
                VStack(spacing: 0) {
                    // 🔌 PLUGINS: Header Views (ej. Motivación)
                    ForEach(headerViews.indices, id: \.self) { index in
                        headerViews[index]
                    }
                    
                    // Lista de hábitos
                    List {
                        if appConfig.showCategories {
                            // Agrupados por categoría
                            let groupedHabits = viewModel.groupedHabitsByCategory()
                            
                            ForEach(groupedHabits.keys.sorted(), id: \.self) { categoryName in
                                Section(header: Text(categoryName)) {
                                    ForEach(groupedHabits[categoryName] ?? []) { habit in
                                        HabitRowView(
                                            habit: habit,
                                            toggleCompletion: {
                                                viewModel.toggleCompletion(habit: habit)
                                            },
                                            onEdit: {
                                                habitToEdit = habit
                                            }
                                        )
                                    }
                                }
                            }
                        } else {
                            // Lista plana sin categorías
                            ForEach(viewModel.habits) { habit in
                                HabitRowView(
                                    habit: habit,
                                    toggleCompletion: {
                                        viewModel.toggleCompletion(habit: habit)
                                    },
                                    onEdit: {
                                        habitToEdit = habit
                                    }
                                )
                            }
                        }
                    }
                    
                    // -------------------------------------------------
                    //   BOTÓN FLOTANTE: AÑADIR CATEGORÍA + PLUGINS
                    // -------------------------------------------------
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            // 🔌 PLUGINS: Footer Views (ej. Calendario, Menú Motivación)
                            ForEach(footerViews.indices, id: \.self) { index in
                                footerViews[index]
                                    .padding(.trailing, 10)
                                    .padding(.bottom, 20)
                            }
                            
                            if appConfig.showCategories {
                                Button(action: {
                                    isAddingCategory = true
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 56, height: 56)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
                .toolbar {
                    Button("Añadir Hábito") {
                        isAddingHabit = true
                    }
                }
                
                // Modal para añadir hábito
                .sheet(isPresented: $isAddingHabit) {
                    HabitModifyView(viewModel: viewModel)
                }
                
                // Modal para editar hábito
                .sheet(item: $habitToEdit) { habit in
                    HabitModifyView(viewModel: viewModel, habitToEdit: habit)
                }
                
                // Modal para crear categoría
                .sheet(isPresented: $isAddingCategory) {
                    CreateCategoryView { newCategory in
                        print("Categoría creada: \(newCategory.name)")
                    } onDelete: {
                        // Recargar hábitos para que los grupos se actualicen
                        viewModel.reloadHabits()
                    }
                }
                
                .navigationTitle("Hábitos")
            }
            .onAppear {
                // Feature flag: configurar ReminderManager solo si está habilitado
                if appConfig.enableReminders {
                    UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
                    
                    if let context = SwiftDataContext.shared {
                        ReminderManager.shared.configure(
                            modelContext: context,
                            enableReminders: appConfig.enableReminders
                        )
                        
                        Task {
                            await ReminderManager.shared.scheduleDailyHabitNotification()
                        }
                    }
                }
            }
        }
    }
    
}
