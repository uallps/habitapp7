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
    @Relationship(inverse: \Habit.categoryFeature)
    var habit: Habit?
    
    @Relationship(inverse: \Category.habitAssociations)
    var category: Category?
    
    init(habit: Habit? = nil, category: Category? = nil) {
        self.habit = habit
        self.category = category
    }
}

extension Habit {
    /// Propiedad computada para acceder fácilmente a la categoría
    /// Getter: Lee desde categoryFeature
    /// Setter: Usa el contexto global de SwiftData para persistir
    var category: Category? {
        get {
            return categoryFeature?.category
        }
        set {
            guard let context = SwiftDataContext.shared else {
                print("⚠️ SwiftDataContext no está inicializado")
                return
            }
            
            if let newCategory = newValue {
                // Si ya existe una feature, actualizar la categoría
                if let existingFeature = categoryFeature {
                    existingFeature.category = newCategory
                } else {
                    // Crear nueva feature
                    let newFeature = HabitCategoryFeature(habit: self, category: newCategory)
                    context.insert(newFeature)
                }
            } else {
                // Eliminar la feature si existe
                if let existingFeature = categoryFeature {
                    context.delete(existingFeature)
                }
            }
            
            // Guardar cambios
            try? context.save()
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
