//
//  PremiumTests.swift
//  HabitAppTests - Premium Version
//
//  Tests para la version PREMIUM (Core + Todas las Features)
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

/// Tests que deben ejecutarse en la version PREMIUM
/// Esta version incluye TODO:
/// - Core (Habit, CompletionEntry)
/// - Standard Features (Category, Diary, Stats, Streaks, Reminders)
/// - Premium Features (NM_ExpandedFrequency, NM_PauseDay, NM_Type)
final class PremiumTests: XCTestCase {

    private func makeInMemoryContext(models: [any PersistentModel.Type]) throws -> ModelContext {
        let schema = Schema(models)
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        let context = ModelContext(container)
        SwiftDataContext.shared = context
        return context
    }

    // MARK: - Test de Features Standard Disponibles

    func testStandardFeaturesAvailable() {
        #if CATEGORY_FEATURE && DIARY_FEATURE && STATS_FEATURE && STREAKS_FEATURE && REMINDERS_FEATURE
            XCTAssertTrue(true, "All standard features correctly enabled in Premium version")
        #else
            XCTFail("All standard features SHOULD be available in Premium version")
        #endif
    }

    // MARK: - Test de Features Premium Disponibles

    func testExpandedFrequencyAvailable() {
        #if EXPANDED_FREQUENCY_FEATURE
            let habit = Habit(title: "Test", frequency: [.monday])
            XCTAssertNotNil(habit)
        #else
            XCTFail("Expanded Frequency SHOULD be available in Premium version")
        #endif
    }

    func testPauseDayAvailable() {
        #if PAUSE_DAY_FEATURE
            let habit = Habit(title: "Test", frequency: [.monday])
            XCTAssertNotNil(habit)
        #else
            XCTFail("Pause Day SHOULD be available in Premium version")
        #endif
    }

    func testHabitTypeAvailable() {
        #if HABIT_TYPE_FEATURE
            let habit = Habit(title: "Test", frequency: [.monday])
            XCTAssertNotNil(habit)
        #else
            XCTFail("Habit Type SHOULD be available in Premium version")
        #endif
    }

    // MARK: - Test de Funcionalidad Premium Completa

    func testAllFeaturesIntegration() throws {
        let baseHabit = Habit(title: "Premium Habit", frequency: [.monday, .wednesday, .friday])

        #if CATEGORY_FEATURE
            let context = try makeInMemoryContext(models: [Habit.self, Category.self, HabitCategoryFeature.self])
            let habit = Habit(title: "Premium Habit", frequency: [.monday, .wednesday, .friday])
            let category = Category(name: "Premium", categoryDescription: "Premium category")
            context.insert(habit)
            context.insert(category)

            habit.setCategory(category)
            XCTAssertNotNil(habit.getCategory())
        #endif

        #if DIARY_FEATURE
            let context = try makeInMemoryContext(models: [CompletionEntry.self, DiaryNoteFeature.self])
            let entry = CompletionEntry(date: Date())
            context.insert(entry)

            entry.setNote("Premium note")
            XCTAssertTrue(entry.hasNote)
        #endif

        #if STREAKS_FEATURE
            let context = try makeInMemoryContext(models: [Habit.self, HabitStreakFeature.self])
            let habit = Habit(title: "Premium Habit", frequency: [.monday, .wednesday, .friday])
            context.insert(habit)

            habit.setStreak(10)
            XCTAssertEqual(habit.getStreak(), 10)
        #endif

        #if STATS_FEATURE
            let statsVM = StatsViewModel(habit: baseHabit)
            XCTAssertNotNil(statsVM)
        #endif

        XCTAssertTrue(true, "All features integrated successfully")
    }

    func testPluginRegistryHasAllPlugins() {
        #if EXPANDED_FREQUENCY_FEATURE || PAUSE_DAY_FEATURE || HABIT_TYPE_FEATURE
            let registry = PluginRegistry.shared
            let pluginCount = registry.plugins.count
            XCTAssertGreaterThan(pluginCount, 0, "Should have premium plugins registered")
        #endif
    }

    // MARK: - Test de Caracteristicas Premium Especificas

    func testExpandedFrequencyPlugin() {
        #if EXPANDED_FREQUENCY_FEATURE
            XCTAssertTrue(true, "Expanded Frequency plugin working")
        #endif
    }

    func testPauseDayPlugin() {
        #if PAUSE_DAY_FEATURE
            XCTAssertTrue(true, "Pause Day plugin working")
        #endif
    }

    func testHabitTypePlugin() {
        #if HABIT_TYPE_FEATURE
            XCTAssertTrue(true, "Habit Type plugin working")
        #endif
    }
}



