//
//  CoreTestSuite.swift
//  HabitAppTestsAux
//
//  Tests de funcionalidad Core - Compartidos por múltiples targets
//  IMPORTANTE: Este archivo debe agregarse a los Target Membership de:
//  - HabitAppCoreTests
//  - HabitAppStandardTests  
//  - HabitAppPremiumTests
//

import Testing

// Import condicional según el target que compile
#if canImport(HabitApp_Premium)
@testable import HabitApp_Premium
#elseif canImport(HabitApp_Standard)
@testable import HabitApp_Standard
#elseif canImport(HabitApp_Core)
@testable import HabitApp_Core
#else
@testable import HabitApp
#endif

/// Tests de funcionalidad Core
/// Este archivo es compartido por Core, Standard y Premium
@Suite("Core Functionality Tests")
struct CoreTestSuite {

    // MARK: - Test de Modelos Core

    @Test("Habit basic model initialization")
    func habitBasicModel() {
        let habit = Habit(title: "Test Habit", frequency: [.monday])

        #expect(habit.title == "Test Habit")
        #expect(habit.frequency.count == 1)
        #expect(habit.id != nil)
    }

    @Test("CompletionEntry initialization")
    func completionEntry() {
        let entry = CompletionEntry(date: Date())

        #expect(entry.id != nil)
        #expect(entry.date != nil)
    }

    @Test("HabitListViewModel basic functionality")
    @MainActor
    func habitListViewModel() async {
        let mockStorage = MockStorageProvider()
        let viewModel = HabitListViewModel(storageProvider: mockStorage)

        let habit = Habit(title: "Core Habit", frequency: [.monday])
        viewModel.addHabit(habit)

        #expect(viewModel.habits.count == 1)
    }
}
