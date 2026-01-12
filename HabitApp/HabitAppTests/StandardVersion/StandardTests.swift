//
//  StandardTests.swift
//  HabitAppTests - Standard Version
//
//  Tests para la version STANDARD (Core + Features sin NM_)
//

import XCTest
import SwiftData
#if CORE_VERSION
@testable import HabitApp_Core
#elseif STANDARD_VERSION
@testable import HabitApp_Standard
#elseif PREMIUM_VERSION
@testable import HabitApp_Premium
#elseif canImport(HabitApp_Premium)
@testable import HabitApp_Premium
#elseif canImport(HabitApp_Standard)
@testable import HabitApp_Standard
#elseif canImport(HabitApp_Core)
@testable import HabitApp_Core
#else
@testable import HabitApp
#endif

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
final class StandardTests: XCTestCase {

    private func makeInMemoryContext(models: [any PersistentModel.Type]) throws -> ModelContext {
        let schema = Schema(models)
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        let context = ModelContext(container)
        SwiftDataContext.shared = context
        return context
    }

    // MARK: - Test de Features Disponibles

    func testCategoriesAvailable() {
        #if CATEGORY_FEATURE
            let category = Category(name: "Test", categoryDescription: "Test")
            XCTAssertEqual(category.name, "Test")
            XCTAssertTrue(true, "Categories correctly enabled in Standard version")
        #else
            XCTFail("Categories SHOULD be available in Standard version")
        #endif
    }

    func testDiaryAvailable() {
        #if DIARY_FEATURE
            let entry = CompletionEntry(date: Date())
            let diaryFeature = DiaryNoteFeature(completionEntryId: entry.id, note: "Test")
            XCTAssertEqual(diaryFeature.note, "Test")
            XCTAssertTrue(true, "Diary correctly enabled in Standard version")
        #else
            XCTFail("Diary SHOULD be available in Standard version")
        #endif
    }

    func testStatsAvailable() {
        #if STATS_FEATURE
            let habit = Habit(title: "Test", frequency: [.monday])
            let statsVM = StatsViewModel(habit: habit)
            XCTAssertNotNil(statsVM)
            XCTAssertTrue(true, "Stats correctly enabled in Standard version")
        #else
            XCTFail("Stats SHOULD be available in Standard version")
        #endif
    }

    func testStreaksAvailable() throws {
        #if STREAKS_FEATURE
            let context = try makeInMemoryContext(models: [Habit.self, HabitStreakFeature.self])
            let habit = Habit(title: "Test", frequency: [.monday])
            context.insert(habit)

            habit.setStreak(5)
            XCTAssertEqual(habit.getStreak(), 5)
            XCTAssertTrue(true, "Streaks correctly enabled in Standard version")
        #else
            XCTFail("Streaks SHOULD be available in Standard version")
        #endif
    }

    func testRemindersAvailable() {
        #if REMINDERS_FEATURE
            let manager = ReminderManager.shared
            XCTAssertNotNil(manager)
            XCTAssertTrue(true, "Reminders correctly enabled in Standard version")
        #else
            XCTFail("Reminders SHOULD be available in Standard version")
        #endif
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
        #if CATEGORY_FEATURE
            let context = try makeInMemoryContext(models: [Habit.self, Category.self, HabitCategoryFeature.self])
            let habit = Habit(title: "Test Habit", frequency: [.monday])
            let category = Category(name: "Health", categoryDescription: "Health habits")
            context.insert(habit)
            context.insert(category)

            habit.setCategory(category)

            let assignedCategory = habit.getCategory()
            XCTAssertNotNil(assignedCategory)
            XCTAssertEqual(assignedCategory?.name, "Health")
        #endif
    }

    func testDiaryIntegrationWithCompletion() throws {
        #if DIARY_FEATURE
            let context = try makeInMemoryContext(models: [CompletionEntry.self, DiaryNoteFeature.self])
            let entry = CompletionEntry(date: Date())
            context.insert(entry)

            entry.setNote("Completed successfully")

            XCTAssertEqual(entry.getNote(), "Completed successfully")
            XCTAssertTrue(entry.hasNote)
        #endif
    }
}



