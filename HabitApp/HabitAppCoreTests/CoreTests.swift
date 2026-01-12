//
//  CoreTests.swift
//  HabitAppCoreTests
//
//  Tests para la version CORE (solo modelos basicos)
//

import XCTest
@testable import HabitApp_Core

/// Tests que solo deben ejecutarse en la version CORE
/// Esta version incluye UNICAMENTE:
/// - Habit (modelo basico)
/// - CompletionEntry
/// - HabitListViewModel (funcionalidad basica)
@MainActor
final class CoreTests: XCTestCase {

    // MARK: - Test de Modelos Core

    func testHabitBasicModel() {
        let habit = Habit(title: "Test Habit", frequency: [.monday])

        XCTAssertEqual(habit.title, "Test Habit")
        XCTAssertEqual(habit.frequency.count, 1)
        XCTAssertNotNil(habit.id)
    }

    func testCompletionEntry() {
        let entry = CompletionEntry(date: Date())

        XCTAssertNotNil(entry.id)
        XCTAssertNotNil(entry.date)
    }

    func testHabitListViewModel() async {
        let mockStorage = MockStorageProvider()
        let viewModel = HabitListViewModel(storageProvider: mockStorage)

        let habit = Habit(title: "Core Habit", frequency: [.monday])
        viewModel.addHabit(habit)

        XCTAssertEqual(viewModel.habits.count, 1)
    }

    // MARK: - Test de Features NO Disponibles en Core

    func testCategoryFeatureNotAvailable() {
        #if CATEGORY_FEATURE
            XCTFail("Categories should NOT be available in Core version")
        #else
            XCTAssertTrue(true, "Categories correctly disabled in Core version")
        #endif
    }

    func testDiaryFeatureNotAvailable() {
        #if DIARY_FEATURE
            XCTFail("Diary should NOT be available in Core version")
        #else
            XCTAssertTrue(true, "Diary correctly disabled in Core version")
        #endif
    }

    func testStatsFeatureNotAvailable() {
        #if STATS_FEATURE
            XCTFail("Stats should NOT be available in Core version")
        #else
            XCTAssertTrue(true, "Stats correctly disabled in Core version")
        #endif
    }

    func testStreaksFeatureNotAvailable() {
        #if STREAKS_FEATURE
            XCTFail("Streaks should NOT be available in Core version")
        #else
            XCTAssertTrue(true, "Streaks correctly disabled in Core version")
        #endif
    }

    func testRemindersFeatureNotAvailable() {
        #if REMINDERS_FEATURE
            XCTFail("Reminders should NOT be available in Core version")
        #else
            XCTAssertTrue(true, "Reminders correctly disabled in Core version")
        #endif
    }

    func testExpandedFrequencyNotAvailable() {
        #if EXPANDED_FREQUENCY_FEATURE
            XCTFail("Expanded Frequency should NOT be available in Core version")
        #else
            XCTAssertTrue(true, "Expanded Frequency correctly disabled in Core version")
        #endif
    }

    func testPauseDayNotAvailable() {
        #if PAUSE_DAY_FEATURE
            XCTFail("Pause Day should NOT be available in Core version")
        #else
            XCTAssertTrue(true, "Pause Day correctly disabled in Core version")
        #endif
    }

    func testHabitTypeNotAvailable() {
        #if HABIT_TYPE_FEATURE
            XCTFail("Habit Type should NOT be available in Core version")
        #else
            XCTAssertTrue(true, "Habit Type correctly disabled in Core version")
        #endif
    }
}
