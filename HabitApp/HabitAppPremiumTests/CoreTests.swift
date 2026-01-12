//
//  CoreTests.swift
//  HabitAppPremiumTests
//
//  Tests del Core ejecutados en Premium para verificar compatibilidad
//

import XCTest
@testable import HabitApp_Premium

/// Tests de funcionalidad Core ejecutados en Premium
/// Verifica que las funcionalidades básicas sigan funcionando en Premium
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
}
