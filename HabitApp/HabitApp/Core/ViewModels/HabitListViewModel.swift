//
//  HabitListViewModel.swift
//  HabitApp
//
//  Created by Francisco José García García on 15/10/25.
//
import Foundation
import Combine

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = [
       
    ]
    
    func addHabit(_ title: String) {
        var completed : [Date] = []
        habits.append(Habit(title: title,completed: completed))
    }
    
    func toggleCompletion(habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        let today = Calendar.current.startOfDay(for: Date())
        
        if habits[index].completed.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            // Si ya está completado hoy, lo quitamos
            habits[index].completed.removeAll { Calendar.current.isDate($0, inSameDayAs: today) }
        } else {
            // Si no, lo añadimos
            habits[index].completed.append(today)
        }
    }

}
