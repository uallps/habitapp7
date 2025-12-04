import Foundation
import SwiftUI

struct HabitListView: View {
    @StateObject private var viewModel: HabitListViewModel
    
    @State private var isAddingHabit = false
    @State private var habitToEdit: Habit?
    
    @State private var isAddingCategory = false

    // Inicializador con inyección de dependencias
    init(storageProvider: StorageProvider) {
        _viewModel = StateObject(wrappedValue: HabitListViewModel(storageProvider: storageProvider))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                
                // Lista de hábitos agrupados por categoría
                List {
                    let groupedHabits = Habit.groupByCategory(viewModel.habits)
                    
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
                }
                
                // -------------------------------------------------
                //   BOTÓN FLOTANTE: AÑADIR CATEGORÍA
                // -------------------------------------------------
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
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

            // Modal para crear categoría (SIN ERRORES)
            .sheet(isPresented: $isAddingCategory) {
                CreateCategoryView { newCategory in
                    print("Categoría creada: \(newCategory.name)")
                    // No hacemos nada más -> no da errores ✨
                }
            }

            .navigationTitle("Hábitos")
        }
    }
}

