//
//  PremiumTests.swift
//  HabitAppPremiumTests
//
//  Tests para la version PREMIUM (Core + Todas las Features)
//

import XCTest
import SwiftData
@testable import HabitApp

/// Tests que deben ejecutarse en la version PREMIUM
/// Esta version incluye TODO:
/// - Core (Habit, CompletionEntry)
/// - Standard Features (Category, Diary, Stats, Streaks, Reminders)
/// - Premium Features (NM_ExpandedFrequency, NM_PauseDay, NM_Type)
final class PremiumTests: SwiftDataTestCase {
    private var container: ModelContainer?

    private func makeInMemoryContext(models: [any PersistentModel.Type]) throws -> ModelContext {
        let context = SwiftDataTestStack.makeContext()
        container = SwiftDataTestStack.container
        return context
    }

    // MARK: - Test de Features Standard Disponibles

    func testStandardFeaturesAvailable() {
        // Verificar que todas las features standard están disponibles
        let category = Category(name: "Test", categoryDescription: "Test")
        XCTAssertNotNil(category)
        
        let entry = CompletionEntry(date: Date())
        let diaryFeature = DiaryNoteFeature(completionEntryId: entry.id, note: "Test")
        XCTAssertNotNil(diaryFeature)
        
        let statsType = StatsViewModel.self
        XCTAssertNotNil(statsType)
        
        let manager = ReminderManager.shared
        XCTAssertNotNil(manager)
    }

    // MARK: - Test de Features Premium Disponibles

    func testExpandedFrequencyAvailable() {
        let habit = Habit(title: "Test", frequency: [.monday])
        let expandedFreq = ExpandedFrequency(habitID: habit.id)
        XCTAssertNotNil(expandedFreq)
    }

    func testPauseDayAvailable() {
        let pauseDays = HabitPauseDays(habitId: UUID())
        XCTAssertNotNil(pauseDays)
    }

    func testHabitTypeAvailable() {
        let habitType = HabitType(habitID: UUID(), type: .binary)
        XCTAssertNotNil(habitType)
    }

    // MARK: - Test de Funcionalidad Premium Completa

    func testAllFeaturesIntegration() throws {
        // Test Category
        let contextCat = try makeInMemoryContext(models: [Habit.self, Category.self, HabitCategoryFeature.self])
        let habit1 = Habit(title: "Premium Habit", frequency: [.monday, .wednesday, .friday])
        let category = Category(name: "Premium", categoryDescription: "Premium category")
        contextCat.insert(habit1)
        contextCat.insert(category)

        habit1.setCategory(category)
        XCTAssertNotNil(habit1.getCategory())

        // Test Diary
        let contextDiary = try makeInMemoryContext(models: [CompletionEntry.self, DiaryNoteFeature.self])
        let entry = CompletionEntry(date: Date())
        contextDiary.insert(entry)

        entry.setNote("Premium note")
        XCTAssertTrue(entry.hasNote)

        // Test Streaks
        let contextStreak = try makeInMemoryContext(models: [Habit.self, HabitStreakFeature.self])
        let habit2 = Habit(title: "Premium Habit", frequency: [.monday, .wednesday, .friday])
        contextStreak.insert(habit2)

        habit2.setStreak(10)
        XCTAssertEqual(habit2.getStreak(), 10)

        // Test Stats
        let statsType = StatsViewModel.self
        XCTAssertNotNil(statsType)
    }

    func testPluginRegistryHasAllPlugins() {
        let registry = PluginRegistry.shared
        let pluginCount = registry.plugins.count
        XCTAssertGreaterThan(pluginCount, 0, "Should have premium plugins registered")
    }

    // MARK: - Test de Caracteristicas Premium Especificas

    func testExpandedFrequencyPlugin() {
        let registry = PluginRegistry.shared
        let hasPlugin = registry.plugins.contains { plugin in
            plugin is ExpandedFrequencyPlugin
        }
        XCTAssertTrue(hasPlugin, "ExpandedFrequencyPlugin should be registered")
    }

    func testPauseDayPlugin() {
        let registry = PluginRegistry.shared
        let hasPlugin = registry.plugins.contains { plugin in
            plugin is PauseDayPlugin
        }
        XCTAssertTrue(hasPlugin, "PauseDayPlugin should be registered")
    }

    func testHabitTypePlugin() {
        let registry = PluginRegistry.shared
        let hasPlugin = registry.plugins.contains { plugin in
            plugin is HabitTypePlugin
        }
        XCTAssertTrue(hasPlugin, "HabitTypePlugin should be registered")
    }

    override func tearDown() {
        SwiftDataContext.shared = nil
        SwiftDataContext.sharedContainer = nil
        container = nil
        super.tearDown()
    }
}
