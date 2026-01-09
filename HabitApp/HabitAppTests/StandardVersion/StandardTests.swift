//
//  StandardTests.swift
//  HabitAppTests - Standard Version
//
//  Tests para la versión STANDARD (Core + Features sin NM_)
//

import XCTest
@testable import HabitApp

/// Tests que deben ejecutarse en la versión STANDARD
/// Esta versión incluye:
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
final class StandardTests: XCTestCase {
    
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
    
    func testStreaksAvailable() {
        #if STREAKS_FEATURE
            let habit = Habit(title: "Test", frequency: [.monday])
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
    
    func testCategoryIntegrationWithHabit() async {
        #if CATEGORY_FEATURE
            let habit = Habit(title: "Test Habit", frequency: [.monday])
            let category = Category(name: "Health", categoryDescription: "Health habits")
            
            habit.category = category
            
            XCTAssertNotNil(habit.category)
            XCTAssertEqual(habit.category?.name, "Health")
        #endif
    }
    
    func testDiaryIntegrationWithCompletion() {
        #if DIARY_FEATURE
            let entry = CompletionEntry(date: Date())
            entry.setNote("Completed successfully")
            
            XCTAssertEqual(entry.getNote(), "Completed successfully")
            XCTAssertTrue(entry.hasNote)
        #endif
    }
}
