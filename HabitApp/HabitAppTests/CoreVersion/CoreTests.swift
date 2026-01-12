//
//  CoreTests.swift
//  HabitAppTests - Core Version
//
//  Tests para la version CORE (solo modelos basicos)
//

import XCTest
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

    // MARK: - Test de Features NO Disponibles (solo Core)

    func testCategoryFeatureNotAvailable() throws {
        #if CORE_VERSION
            #if CATEGORY_FEATURE
                XCTFail("Categories should NOT be available in Core version")
            #else
                XCTAssertTrue(true, "Categories correctly disabled in Core version")
            #endif
        #else
            throw XCTSkip("Solo aplica en Core")
        #endif
    }

    func testDiaryFeatureNotAvailable() throws {
        #if CORE_VERSION
            #if DIARY_FEATURE
                XCTFail("Diary should NOT be available in Core version")
            #else
                XCTAssertTrue(true, "Diary correctly disabled in Core version")
            #endif
        #else
            throw XCTSkip("Solo aplica en Core")
        #endif
    }

    func testStatsFeatureNotAvailable() throws {
        #if CORE_VERSION
            #if STATS_FEATURE
                XCTFail("Stats should NOT be available in Core version")
            #else
                XCTAssertTrue(true, "Stats correctly disabled in Core version")
            #endif
        #else
            throw XCTSkip("Solo aplica en Core")
        #endif
    }

    func testStreaksFeatureNotAvailable() throws {
        #if CORE_VERSION
            #if STREAKS_FEATURE
                XCTFail("Streaks should NOT be available in Core version")
            #else
                XCTAssertTrue(true, "Streaks correctly disabled in Core version")
            #endif
        #else
            throw XCTSkip("Solo aplica en Core")
        #endif
    }

    func testRemindersFeatureNotAvailable() throws {
        #if CORE_VERSION
            #if REMINDERS_FEATURE
                XCTFail("Reminders should NOT be available in Core version")
            #else
                XCTAssertTrue(true, "Reminders correctly disabled in Core version")
            #endif
        #else
            throw XCTSkip("Solo aplica en Core")
        #endif
    }

    // MARK: - Test de Features Premium NO Disponibles (Core/Standard)

    func testExpandedFrequencyNotAvailable() throws {
        #if PREMIUM_VERSION
            throw XCTSkip("No aplica en Premium")
        #else
            #if EXPANDED_FREQUENCY_FEATURE
                XCTFail("Expanded Frequency should NOT be available in Core/Standard version")
            #else
                XCTAssertTrue(true, "Expanded Frequency correctly disabled in Core/Standard version")
            #endif
        #endif
    }

    func testPauseDayNotAvailable() throws {
        #if PREMIUM_VERSION
            throw XCTSkip("No aplica en Premium")
        #else
            #if PAUSE_DAY_FEATURE
                XCTFail("Pause Day should NOT be available in Core/Standard version")
            #else
                XCTAssertTrue(true, "Pause Day correctly disabled in Core/Standard version")
            #endif
        #endif
    }

    func testHabitTypeNotAvailable() throws {
        #if PREMIUM_VERSION
            throw XCTSkip("No aplica en Premium")
        #else
            #if HABIT_TYPE_FEATURE
                XCTFail("Habit Type should NOT be available in Core/Standard version")
            #else
                XCTAssertTrue(true, "Habit Type correctly disabled in Core/Standard version")
            #endif
        #endif
    }
}

