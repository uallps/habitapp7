//
//  CoreTests.swift
//  HabitAppTests - Core Version
//
//  Tests para la versión CORE (solo modelos básicos)
//

import XCTest
@testable import HabitApp

/// Tests que solo deben ejecutarse en la versión CORE
/// Esta versión incluye ÚNICAMENTE:
/// - Habit (modelo básico)
/// - CompletionEntry
/// - HabitListViewModel (funcionalidad básica)
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
    
    // MARK: - Test de Features NO Disponibles
    
    func testCategoryFeatureNotAvailable() {
        // En la versión Core, las categorías NO deben estar disponibles
        #if CATEGORY_FEATURE
            XCTFail("Categories should NOT be available in Core version")
        #else
            XCTAssertTrue(true, "Categories correctly disabled in Core version")
        #endif
    }
    
    func testDiaryFeatureNotAvailable() {
        // En la versión Core, el diario NO debe estar disponible
        #if DIARY_FEATURE
            XCTFail("Diary should NOT be available in Core version")
        #else
            XCTAssertTrue(true, "Diary correctly disabled in Core version")
        #endif
    }
    
    func testStatsFeatureNotAvailable() {
        // En la versión Core, las estadísticas NO deben estar disponibles
        #if STATS_FEATURE
            XCTFail("Stats should NOT be available in Core version")
        #else
            XCTAssertTrue(true, "Stats correctly disabled in Core version")
        #endif
    }
    
    func testStreaksFeatureNotAvailable() {
        // En la versión Core, las rachas NO deben estar disponibles
        #if STREAKS_FEATURE
            XCTFail("Streaks should NOT be available in Core version")
        #else
            XCTAssertTrue(true, "Streaks correctly disabled in Core version")
        #endif
    }
    
    func testRemindersFeatureNotAvailable() {
        // En la versión Core, los recordatorios NO deben estar disponibles
        #if REMINDERS_FEATURE
            XCTFail("Reminders should NOT be available in Core version")
        #else
            XCTAssertTrue(true, "Reminders correctly disabled in Core version")
        #endif
    }
    
    // MARK: - Test de Features Premium NO Disponibles
    
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
