//
//  AppConfig.swift
//  HabitApp
//
//  Created by Francisco José García García on 15/10/25.
//

import SwiftUI
import SwiftData
import Combine

class AppConfig: ObservableObject {
    // MARK: - Core Features (siempre activas)
    // Habit básico con completions
    
    // MARK: - UI Flags (afectan solo visualización)
    @AppStorage("showPriorities")
    var showPriorities: Bool = true
    
    // MARK: - Feature Flags (afectan funcionalidad completa)
    
    #if CATEGORY_FEATURE
    @AppStorage("showCategories")
    var showCategories: Bool = true
    #else
    var showCategories: Bool { false }
    #endif
    
    #if DIARY_FEATURE
    @AppStorage("enableDiary")
    var enableDiary: Bool = true
    #else
    var enableDiary: Bool { false }
    #endif
    
    #if REMINDERS_FEATURE
    @AppStorage("enableReminders")
    var enableReminders: Bool = true
    #else
    var enableReminders: Bool { false }
    #endif
    
    #if STATS_FEATURE
    @AppStorage("enableStats")
    var enableStats: Bool = true
    #else
    var enableStats: Bool { false }
    #endif
    
    #if STREAKS_FEATURE
    @AppStorage("enableStreaks")
    var enableStreaks: Bool = true
    #else
    var enableStreaks: Bool { false }
    #endif

    // MARK: - Storage Provider
    
    private lazy var swiftDataProvider: SwiftDataStorageProvider = {
        // 🔌 Descubrir plugins antes de inicializar SwiftData
        PluginDiscovery.discoverAndRegisterPlugins()
        
        // Modelos base del Core (siempre incluidos)
        var schemas: [any PersistentModel.Type] = [Habit.self, CompletionEntry.self]
        
        // Agregar modelos de features habilitadas mediante compilación condicional
        #if CATEGORY_FEATURE
        if showCategories {
            schemas.append(Category.self)
            schemas.append(HabitCategoryFeature.self)
        }
        #endif
        
        #if DIARY_FEATURE
        if enableDiary {
            schemas.append(DiaryNoteFeature.self)
        }
        #endif
        
        #if STREAKS_FEATURE
        if enableStreaks {
            schemas.append(HabitStreakFeature.self)
        }
        #endif
        
        // 🔌 Agregar modelos de plugins descubiertos dinámicamente
        schemas.append(contentsOf: PluginRegistry.shared.getPluginSchemas())
        
        let schema = Schema(schemas)
        print("📦 Schemas registrados: \(schemas)")
        print("🎯 Features activas en compilación:")
        #if CATEGORY_FEATURE
        print("   ✅ CATEGORY_FEATURE")
        #endif
        #if DIARY_FEATURE
        print("   ✅ DIARY_FEATURE")
        #endif
        #if REMINDERS_FEATURE
        print("   ✅ REMINDERS_FEATURE")
        #endif
        #if STATS_FEATURE
        print("   ✅ STATS_FEATURE")
        #endif
        #if STREAKS_FEATURE
        print("   ✅ STREAKS_FEATURE")
        #endif
        
        return SwiftDataStorageProvider(schema: schema)
    }()

    var storageProvider: StorageProvider {
        swiftDataProvider
    }
}
