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
    @AppStorage("showCategories")
    var showCategories: Bool = true

    @AppStorage("showPriorities")
    var showPriorities: Bool = true

    @AppStorage("enableDiary")
    var enableDiary: Bool = true

    // #if PREMIUM
    @AppStorage("enableReminders")
    var enableReminders: Bool = true
    // #else
    // var enableReminders: Bool { false }
    // #endif

    @AppStorage("enableStats")
    var enableStats: Bool = true

    @AppStorage("enableStreaks")
    var enableStreaks: Bool = true

    @AppStorage("storageType")
    var storageType: StorageType = .swiftData

    // MARK: - Storage Provider
    
    private lazy var swiftDataProvider: SwiftDataStorageProvider = {
        // Modelos base del Core
        var schemas: [any PersistentModel.Type] = [Habit.self, CompletionEntry.self]
        
        // Agregar modelos de features habilitadas
        // (Por ahora todos están habilitados por defecto, en LPS se filtraría por flags)
        if showCategories {
            schemas.append(Category.self)
            schemas.append(HabitCategoryFeature.self)
        }
        
        if enableDiary {
            schemas.append(DiaryNoteFeature.self)
        }
        
        if enableStreaks {
            schemas.append(HabitStreakFeature.self)
        }
        
        let schema = Schema(schemas)
        print("📦 Schemas registrados: \(schemas)")
        
        return SwiftDataStorageProvider(schema: schema)
    }()

    var storageProvider: StorageProvider {
        switch storageType {
        case .swiftData:
            return swiftDataProvider
        case .json:
            return JSONStorageProvider.shared
        }
    }
}

enum StorageType: String, CaseIterable, Identifiable {
    case swiftData = "SwiftData Storage"
    case json = "JSON Storage"

    var id: String { self.rawValue }
}
