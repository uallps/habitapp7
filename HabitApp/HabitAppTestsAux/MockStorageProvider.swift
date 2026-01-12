//
//  MockStorageProvider.swift
//  HabitAppTestsAux
//
//  Mock del StorageProvider para tests
//  IMPORTANTE: Este archivo debe agregarse a los Target Membership de:
//  - HabitAppCoreTests
//  - HabitAppStandardTests
//  - HabitAppPremiumTests
//

import Foundation


#if canImport(HabitApp)
@testable import HabitApp
#elseif canImport(HabitApp_Standard)
@testable import HabitApp_Standard
#elseif canImport(HabitApp_Core)
@testable import HabitApp_Core
#endif

@MainActor
class MockStorageProvider: StorageProvider {
    var habits: [Habit] = []
    var saveCalledCount = 0
    var loadCalledCount = 0
    var shouldFailOnSave = false
    var shouldFailOnLoad = false
    
    init() {}
    
    func loadHabits() async throws -> [Habit] {
        loadCalledCount += 1
        
        if shouldFailOnLoad {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Load failed"])
        }
        
        return habits
    }
    
    func saveHabits(habits: [Habit]) async throws {
        saveCalledCount += 1
        
        if shouldFailOnSave {
            throw NSError(domain: "TestError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Save failed"])
        }
        
        self.habits = habits
    }
}
