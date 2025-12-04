//
//  Category.swift
//  HabitApp
//
//
import Foundation
import SwiftData

@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var categoryDescription: String
    
    // Relación inversa: todas las asociaciones de hábitos que usan esta categoría
    @Relationship(deleteRule: .cascade, inverse: \HabitCategoryFeature.category)
    var habitAssociations: [HabitCategoryFeature]
    
    init(id: UUID = UUID(), name: String, categoryDescription: String) {
        self.id = id
        self.name = name
        self.categoryDescription = categoryDescription
        self.habitAssociations = []
    }
}

