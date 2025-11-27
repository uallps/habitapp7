//
//  HabitExtendedCategory.swift
//  HabitApp
//
//  Created by Aula03 on 19/11/25.
//

import Foundation

extension Habit {
    
    // Key única basada en el ID del hábito
    private var categoryKey: String {
        "habit_category_\(id.uuidString)"
    }
    
    /// Categoría almacenada en UserDefaults (igual que streak y nextDay)
    var category: Category? {
        get {
            if let data = UserDefaults.standard.data(forKey: categoryKey),
               let decoded = try? JSONDecoder().decode(Category.self, from: data) {
                return decoded
            }
            return nil
        }
        set {
            if let category = newValue,
               let encoded = try? JSONEncoder().encode(category) {
                UserDefaults.standard.set(encoded, forKey: categoryKey)
            } else {
                UserDefaults.standard.removeObject(forKey: categoryKey)
            }
        }
    }
    
    /// Agrupa hábitos por categoría
    /// - Parameter habits: Array de hábitos a agrupar
    /// - Returns: Diccionario donde la clave es el nombre de la categoría (o "Sin categoría") y el valor es un array de hábitos
    static func groupByCategory(_ habits: [Habit]) -> [String: [Habit]] {
        var groupedHabits: [String: [Habit]] = [:]
        
        for habit in habits {
            let categoryName = habit.category?.name ?? "Sin categoría"
            
            if groupedHabits[categoryName] == nil {
                groupedHabits[categoryName] = []
            }
            groupedHabits[categoryName]?.append(habit)
        }
        
        return groupedHabits
    }
}
