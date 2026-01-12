//
//  HabitTypeTest.swift
//  HabitAppTests - Premium Version
//
//  Tests para NM_Type (solo disponible en Premium)
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

#if HABIT_TYPE_FEATURE

@MainActor
final class HabitTypeTest: XCTestCase {

    private func makeInMemoryContext(models: [any PersistentModel.Type]) throws -> ModelContext {
        let schema = Schema(models)
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        let context = ModelContext(container)
        SwiftDataContext.shared = context
        return context
    }

    // MARK: - Test de Modelo HabitType

    func testHabitCompletionTypeCases() {
        XCTAssertEqual(HabitCompletionType.allCases.count, 3)
        XCTAssertTrue(HabitCompletionType.allCases.contains(.binary))
        XCTAssertTrue(HabitCompletionType.allCases.contains(.count))
        XCTAssertTrue(HabitCompletionType.allCases.contains(.timer))
    }

    func testHabitTypeInitialization() {
        let habitId = UUID()
        let model = HabitType(habitID: habitId, type: .count, targetValue: 5, unit: "minutos")

        XCTAssertEqual(model.habitID, habitId)
        XCTAssertEqual(model.type, .count)
        XCTAssertEqual(model.targetValue, 5)
        XCTAssertEqual(model.unit, "minutos")
    }

    // MARK: - Test de HabitTypeViewModel

    func testHabitTypeViewModelInitialization() throws {
        let context = try makeInMemoryContext(models: [HabitType.self])
        let habitId = UUID()
        let viewModel = HabitTypeViewModel(habitID: habitId, context: context)

        XCTAssertEqual(viewModel.selectedType, .binary)
    }

    func testChangeHabitType() throws {
        let context = try makeInMemoryContext(models: [HabitType.self])
        let habitId = UUID()
        let viewModel = HabitTypeViewModel(habitID: habitId, context: context)

        viewModel.saveType(.timer)
        XCTAssertEqual(viewModel.selectedType, .timer)
    }

    func testSaveTargetValue() throws {
        let context = try makeInMemoryContext(models: [HabitType.self])
        let habitId = UUID()
        let viewModel = HabitTypeViewModel(habitID: habitId, context: context)

        viewModel.saveTargetValue("5")
        XCTAssertEqual(viewModel.targetValue, "5")
    }

    func testSaveTime() throws {
        let context = try makeInMemoryContext(models: [HabitType.self])
        let habitId = UUID()
        let viewModel = HabitTypeViewModel(habitID: habitId, context: context)

        viewModel.saveTime(minutes: 1, seconds: 30)
        XCTAssertEqual(viewModel.selectedMinutes, 1)
        XCTAssertEqual(viewModel.selectedSeconds, 30)
        XCTAssertEqual(viewModel.targetValue, "90")
    }

    func testSaveUnit() throws {
        let context = try makeInMemoryContext(models: [HabitType.self])
        let habitId = UUID()
        let viewModel = HabitTypeViewModel(habitID: habitId, context: context)

        viewModel.saveUnit("minutos")
        XCTAssertEqual(viewModel.unit, "minutos")
    }

    // MARK: - Test de HabitCompletionViewModel

    func testHabitCompletionViewModelLoadsType() throws {
        let context = try makeInMemoryContext(models: [Habit.self, HabitType.self, ExpandedFrequency.self])
        let habit = Habit(title: "Test", frequency: [.monday])
        context.insert(habit)
        let habitType = HabitType(habitID: habit.id, type: .count, targetValue: 2, unit: "minutos")
        context.insert(habitType)

        let viewModel = HabitCompletionViewModel(habit: habit, context: context) {}
        XCTAssertNotNil(viewModel.habitType)
    }

    func testHabitCompletionViewModelProgressTriggersToggle() throws {
        let context = try makeInMemoryContext(models: [Habit.self, HabitType.self, ExpandedFrequency.self])
        let habit = Habit(title: "Test", frequency: [.monday])
        context.insert(habit)
        let habitType = HabitType(habitID: habit.id, type: .count, targetValue: 2, unit: "minutos")
        context.insert(habitType)

        var toggled = false
        let viewModel = HabitCompletionViewModel(habit: habit, context: context) {
            toggled = true
        }

        viewModel.updateProgress(2)
        XCTAssertTrue(toggled)
    }

    // MARK: - Test de Plugin

    func testHabitTypePluginRegistered() {
        let registry = PluginRegistry.shared
        let hasPlugin = registry.plugins.contains { plugin in
            plugin is HabitTypePlugin
        }

        XCTAssertTrue(hasPlugin, "HabitTypePlugin should be registered")
    }
}

#else

final class HabitTypeTest: XCTestCase {
    func testHabitTypeNotAvailable() {
        XCTAssertTrue(true, "HabitType correctly disabled in non-Premium versions")
    }
}

#endif


