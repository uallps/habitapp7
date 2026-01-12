//
//  StandardTests.swift
//  HabitAppPremiumTests
//
//  Tests de Standard ejecutados en Premium para verificar compatibilidad
//

import XCTest
import SwiftData
@testable import HabitApp_Premium

/// Tests de funcionalidad Standard ejecutados en Premium
/// Verifica que las features Standard sigan funcionando en Premium
@MainActor
final class StandardTests: SwiftDataTestCase {
    private var context: ModelContext?
    private var container: ModelContainer?

    private func makeInMemoryContext(models: [any PersistentModel.Type]) throws -> ModelContext {
        let context = SwiftDataTestStack.makeContext()
        container = SwiftDataTestStack.container
        return context
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = try makeInMemoryContext(models: [
            Habit.self,
            CompletionEntry.self,
            Category.self,
            HabitCategoryFeature.self,
            DiaryNoteFeature.self,
            HabitStreakFeature.self
        ])
    }

    override func tearDown() {
        context = nil
        container = nil
        SwiftDataContext.shared = nil
        SwiftDataContext.sharedContainer = nil
        super.tearDown()
    }

    // MARK: - Test de Features Standard Disponibles

    func testCategoriesAvailable() {
        let category = Category(name: "Test", categoryDescription: "Test")
        XCTAssertEqual(category.name, "Test")
    }

    func testDiaryAvailable() {
        let entry = CompletionEntry(date: Date())
        let diaryFeature = DiaryNoteFeature(completionEntryId: entry.id, note: "Test")
        XCTAssertEqual(diaryFeature.note, "Test")
    }

    func testStatsAvailable() {
        let statsType = StatsViewModel.self
        XCTAssertNotNil(statsType)
    }

    func testStreaksAvailable() throws {
        let context = try makeInMemoryContext(models: [Habit.self, HabitStreakFeature.self])
        let habit = Habit(title: "Test", frequency: [.monday])
        context.insert(habit)

        habit.setStreak(5)
        XCTAssertEqual(habit.getStreak(), 5)
    }

    func testRemindersAvailable() {
        let manager = ReminderManager.shared
        XCTAssertNotNil(manager)
    }

    // MARK: - Test de Funcionalidad Integrada

    func testCategoryIntegrationWithHabit() throws {
        let context = try makeInMemoryContext(models: [Habit.self, Category.self, HabitCategoryFeature.self])
        let habit = Habit(title: "Test Habit", frequency: [.monday])
        let category = Category(name: "Health", categoryDescription: "Health habits")
        context.insert(habit)
        context.insert(category)

        habit.setCategory(category)

        let assignedCategory = habit.getCategory()
        XCTAssertNotNil(assignedCategory)
        XCTAssertEqual(assignedCategory?.name, "Health")
    }

    func testDiaryIntegrationWithCompletion() throws {
        let context = try makeInMemoryContext(models: [CompletionEntry.self, DiaryNoteFeature.self])
        let entry = CompletionEntry(date: Date())
        context.insert(entry)

        entry.setNote("Completed successfully")

        XCTAssertEqual(entry.getNote(), "Completed successfully")
        XCTAssertTrue(entry.hasNote)
    }
}
