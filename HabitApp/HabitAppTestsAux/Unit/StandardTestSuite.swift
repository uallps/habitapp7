//
//  StandardTestSuite.swift
//  HabitAppTestsAux
//
//  Tests de funcionalidad Standard - Compartidos por múltiples targets
//  IMPORTANTE: Este archivo debe agregarse a los Target Membership de:
//  - HabitAppStandardTests  
//  - HabitAppPremiumTests
//

import Testing
import SwiftData
import Foundation

// Import condicional según el target que compile
#if canImport(HabitApp)
@testable import HabitApp
#elseif canImport(HabitApp_Standard)
@testable import HabitApp_Standard
#elseif canImport(HabitApp_Core)
@testable import HabitApp_Core
#endif

/// Tests de funcionalidad Standard
/// Este archivo es compartido por Standard y Premium
@Suite("Standard Features Tests")
struct StandardTestSuite {
    
    // MARK: - Test de Features Standard Disponibles

    @Test("Categories feature is available")
    func categoriesAvailable() {
        let category = Category(name: "Test", categoryDescription: "Test")
        #expect(category.name == "Test")
    }

    @Test("Diary feature is available")
    func diaryAvailable() {
        let entry = CompletionEntry(date: Date())
        let diaryFeature = DiaryNoteFeature(completionEntryId: entry.id, note: "Test")
        #expect(diaryFeature.note == "Test")
    }

    @Test("Stats feature is available")
    func statsAvailable() {
        let statsType = StatsViewModel.self
        #expect(statsType != nil)
    }

    @Test("Streaks feature is available")
    @MainActor
    func streaksAvailable() throws {
        let context = SwiftDataTestStack.makeContext()
        let habit = Habit(title: "Test", frequency: [.monday])
        context.insert(habit)

        habit.setStreak(5)
        #expect(habit.getStreak() == 5)
    }

    @Test("Reminders feature is available")
    @MainActor
    func remindersAvailable() {
        let manager = ReminderManager.shared
        #expect(manager != nil)
    }

    // MARK: - Test de Funcionalidad Integrada

    @Test("Category integration with Habit")
    @MainActor    func categoryIntegrationWithHabit() throws {
        let context = SwiftDataTestStack.makeContext()
        let habit = Habit(title: "Test Habit", frequency: [.monday])
        let category = Category(name: "Health", categoryDescription: "Health habits")
        context.insert(habit)
        context.insert(category)

        habit.setCategory(category)

        let assignedCategory = habit.getCategory()
        #expect(assignedCategory != nil)
        #expect(assignedCategory?.name == "Health")
    }

    @Test("Diary integration with CompletionEntry")
    @MainActor
    func diaryIntegrationWithCompletion() throws {
        let context = SwiftDataTestStack.makeContext()
        let entry = CompletionEntry(date: Date())
        context.insert(entry)

        entry.setNote("Completed successfully")

        #expect(entry.getNote() == "Completed successfully")
        #expect(entry.hasNote == true)
    }
}
