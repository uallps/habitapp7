//
//  AppConfig.swift
//  HabitApp
//
//  Created by Francisco José García García on 15/10/25.
//

import SwiftData

class AppConfig {
    static let shared = AppConfig()
    
    // MARK: - Feature Flags
    static var showCategories: Bool = true
    static var enableDiary: Bool = true
    static var enableReminders: Bool = true
    static var enableStats: Bool = true
    static var enableStreaks: Bool = true
    
    // MARK: - Storage Provider
    
    /// Computed property que devuelve el StorageProvider configurado con todos los modelos necesarios
    var storageProvider: StorageProvider {
        // Modelos base del Core
        var schemas: [any PersistentModel.Type] = [Habit.self, CompletionEntry.self]
        
        // Agregar modelos de features habilitadas
        if AppConfig.showCategories {
            schemas.append(contentsOf: [Category.self, HabitCategoryFeature.self])
        }
        
        if AppConfig.enableDiary {
            schemas.append(DiaryNoteFeature.self)
        }
        
        if AppConfig.enableStreaks {
            schemas.append(HabitStreakFeature.self)
        }
        
        let schema = Schema(schemas)
        print("📦 Schemas registrados: \(schemas)")
        
        return SwiftDataStorageProvider(schema: schema)
    }
    
    private init() {}
}
