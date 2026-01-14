//
//  StandardTests.swift
//  HabitAppStandardTests
//
//  Tests para la version STANDARD (Core + Features sin NM_)
//

import XCTest
import SwiftData
@testable import HabitApp_Standard

/// Tests que deben ejecutarse en la version STANDARD
/// Esta version incluye:
/// - Core (Habit, CompletionEntry)
/// - Category
/// - Diary
/// - Stats
/// - Streaks
/// - Reminders
///
/// NO incluye features NM_:
/// - NM_ExpandedFrequency
/// - NM_PauseDay
/// - NM_Type
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

    // MARK: - Test de Features Disponibles

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

    // MARK: - Test de Features Premium NO Disponibles

    func testExpandedFrequencyNotAvailable() {
        #if EXPANDED_FREQUENCY_FEATURE
            XCTFail("Expanded Frequency should NOT be available in Standard version")
        #else
            XCTAssertTrue(true, "Expanded Frequency correctly disabled in Standard version")
        #endif
    }

    func testPauseDayNotAvailable() {
        #if PAUSE_DAY_FEATURE
            XCTFail("Pause Day should NOT be available in Standard version")
        #else
            XCTAssertTrue(true, "Pause Day correctly disabled in Standard version")
        #endif
    }

    func testHabitTypeNotAvailable() {
        #if HABIT_TYPE_FEATURE
            XCTFail("Habit Type should NOT be available in Standard version")
        #else
            XCTAssertTrue(true, "Habit Type correctly disabled in Standard version")
        #endif
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
