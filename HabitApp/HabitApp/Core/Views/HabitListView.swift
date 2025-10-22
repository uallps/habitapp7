//
//  HabitListView.swift
//  HabitApp
//
//  Created by Francisco José García García on 15/10/25.
//
import Foundation
import SwiftUI

struct HabitListView: View {
    @StateObject var viewModel = HabitListViewModel()
    
    @State private var isAddingHabit = false
    @State private var newHabitTitle = ""

    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.habits) { habit in
                    HabitRowView(habit: habit, toggleCompletion: {
                        viewModel.toggleCompletion(habit: habit)
                    })
                }

                // Campo de texto y botón para añadir hábito nuevo
                if isAddingHabit {
                    HStack {
                        TextField("Nombre del hábito", text: $newHabitTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button("Guardar") {
                            let trimmedTitle = newHabitTitle.trimmingCharacters(in: .whitespaces)
                            if !trimmedTitle.isEmpty {
                                viewModel.addHabit(trimmedTitle)
                                newHabitTitle = ""
                                isAddingHabit = false
                            }
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                Button("Añadir Tarea") {
                    withAnimation {
                        isAddingHabit.toggle()
                    }
                }
            }
            .navigationTitle("Tareas")
        }
    }
}

#Preview {
    HabitListView()
}

