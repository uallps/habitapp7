//
//  HabitExtendedCategory.swift
//  HabitApp
//
//  Created by Aula03 on 19/11/25.
//

import Foundation
import SwiftData

/// Modelo intermedio que relaciona Habit con Category
/// Esta clase permite almacenar la relación en SwiftData
@Model
final class HabitCategoryFeature {
    var habitId: UUID
    
    @Relationship(inverse: \Category.habitAssociations)
    var category: Category?
    
    init(habitId: UUID, category: Category? = nil) {
        self.habitId = habitId
        self.category = category
    }
}

extension Habit {
    
    private var activeContext: ModelContext? {
        return self.modelContext ?? SwiftDataContext.shared
    }

    /// Método para acceder a la categoría
    func getCategory() -> Category? {
        guard let context = activeContext else { return nil }
        let habitId = self.id
        let descriptor = FetchDescriptor<HabitCategoryFeature>(
            predicate: #Predicate { $0.habitId == habitId }
        )
        return try? context.fetch(descriptor).first?.category
    }
    
    /// Método para establecer la categoría
    func setCategory(_ newCategory: Category?) {
        guard let context = activeContext else { return }
        let habitId = self.id
        let descriptor = FetchDescriptor<HabitCategoryFeature>(
            predicate: #Predicate { $0.habitId == habitId }
        )
        
        do {
            let features = try context.fetch(descriptor)
            if let existingFeature = features.first {
                if let newCategory = newCategory {
                    existingFeature.category = newCategory
                } else {
                    context.delete(existingFeature)
                }
            } else if let newCategory = newCategory {
                let newFeature = HabitCategoryFeature(habitId: habitId, category: newCategory)
                context.insert(newFeature)
            }
        } catch {
            print("Error setting category: \(error)")
        }
    }
    
    /// Agrupa hábitos por categoría
    /// - Parameter habits: Array de hábitos a agrupar
    /// - Returns: Diccionario donde la clave es el nombre de la categoría (o "Sin categoría") y el valor es un array de hábitos
    static func groupByCategory(_ habits: [Habit]) -> [String: [Habit]] {
        var groupedHabits: [String: [Habit]] = [:]
        
        for habit in habits {
            let categoryName = habit.getCategory()?.name ?? "Sin categoría"
            
            if groupedHabits[categoryName] == nil {
                groupedHabits[categoryName] = []
            }
            groupedHabits[categoryName]?.append(habit)
        }
        
        return groupedHabits
    }
}

