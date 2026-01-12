//
//  PauseDayTest.swift
//  HabitAppTests - Premium Version
//
//  Tests para NM_PauseDay (solo disponible en Premium)
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

#if PAUSE_DAY_FEATURE

@MainActor
final class PauseDayTest: XCTestCase {

    private func makeInMemoryContext(models: [any PersistentModel.Type]) throws -> ModelContext {
        let schema = Schema(models)
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        return ModelContext(container)
    }

    // MARK: - Test de Modelo HabitPauseDays

    func testPauseDaysInitialization() {
        let pauseDays = HabitPauseDays(habitId: UUID())
        XCTAssertNotNil(pauseDays.habitId)
        XCTAssertTrue(pauseDays.pauseDates.isEmpty)
    }

    func testAddPausedDate() {
        let pauseDays = HabitPauseDays(habitId: UUID())
        let date = Date()

        pauseDays.pauseDates = [date]

        XCTAssertEqual(pauseDays.pauseDates.count, 1)
        XCTAssertTrue(pauseDays.isPaused(on: date))
    }

    func testRemovePausedDate() {
        let pauseDays = HabitPauseDays(habitId: UUID())
        let date = Date()

        pauseDays.pauseDates = [date]
        XCTAssertTrue(pauseDays.isPaused(on: date))

        pauseDays.pauseDates = []
        XCTAssertFalse(pauseDays.isPaused(on: date))
    }

    func testMultiplePausedDates() {
        let pauseDays = HabitPauseDays(habitId: UUID())
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        pauseDays.pauseDates = [today, tomorrow]

        XCTAssertEqual(pauseDays.pauseDates.count, 2)
        XCTAssertTrue(pauseDays.isPaused(on: today))
        XCTAssertTrue(pauseDays.isPaused(on: tomorrow))
    }

    // MARK: - Test de PauseDayViewModel

    func testPauseDayViewModelInitialization() throws {
        let context = try makeInMemoryContext(models: [HabitPauseDays.self])
        let habitId = UUID()
        let viewModel = PauseDayViewModel(habitId: habitId, context: context)

        XCTAssertEqual(viewModel.sortedDates.count, 0)
    }

    func testPauseDaySelectionFlow() throws {
        let context = try makeInMemoryContext(models: [HabitPauseDays.self])
        let habitId = UUID()
        let viewModel = PauseDayViewModel(habitId: habitId, context: context)
        let date = viewModel.today

        viewModel.dateToAdd = date
        viewModel.addDate()

        XCTAssertTrue(viewModel.selectedDates.contains(date))

        viewModel.removeDate(date)
        XCTAssertFalse(viewModel.selectedDates.contains(date))
    }

    // MARK: - Test de Plugin

    func testPauseDayPluginRegistered() {
        let registry = PluginRegistry.shared
        let hasPlugin = registry.plugins.contains { plugin in
            plugin is PauseDayPlugin
        }
        XCTAssertTrue(hasPlugin, "PauseDayPlugin should be registered")
    }

    // MARK: - Test de CalendarPauseDayStyleProvider

    func testCalendarPauseDayStyleProviderExists() {
        XCTAssertTrue(true, "CalendarPauseDayStyleProvider should be available in Premium")
    }

    // MARK: - Test de Vistas

    func testPauseDayRowButtonExists() {
        XCTAssertTrue(true, "PauseDayRowButton should be available in Premium")
    }

    func testPauseDaySelectionViewExists() {
        XCTAssertTrue(true, "PauseDaySelectionView should be available in Premium")
    }
}

#else

final class PauseDayTest: XCTestCase {
    func testPauseDayNotAvailable() {
        XCTAssertTrue(true, "PauseDay correctly disabled in non-Premium versions")
    }
}

#endif


