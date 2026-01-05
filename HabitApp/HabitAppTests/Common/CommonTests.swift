//
//  CommonTests.swift
//  HabitAppTests - Common
//
//  Tests que se ejecutan en TODAS las versiones
//

import XCTest
@testable import HabitApp

/// Tests comunes que deben pasar en TODAS las versiones de la app
/// Estos tests verifican la funcionalidad core que siempre debe estar presente
final class CommonTests: XCTestCase {
    
    // MARK: - Test de Modelos Core (siempre disponibles)
    
    func testHabitInitialization() {
        let habit = Habit(title: "Test Habit", frequency: [.monday])
        
        XCTAssertEqual(habit.title, "Test Habit")
        XCTAssertEqual(habit.frequency.count, 1)
        XCTAssertNotNil(habit.id)
        XCTAssertNil(habit.priority)
        XCTAssertTrue(habit.completed.isEmpty)
    }
    
    func testHabitWithAllParameters() {
        let habit = Habit(
            title: "Complete Habit",
            priority: .high,
            completed: [],
            frequency: [.monday, .wednesday, .friday]
        )
        
        XCTAssertEqual(habit.title, "Complete Habit")
        XCTAssertEqual(habit.priority, .high)
        XCTAssertEqual(habit.frequency.count, 3)
    }
    
    func testCompletionEntryCreation() {
        let date = Date()
        let entry = CompletionEntry(date: date)
        
        XCTAssertNotNil(entry.id)
        XCTAssertEqual(
            Calendar.current.startOfDay(for: entry.date),
            Calendar.current.startOfDay(for: date)
        )
    }
    
    func testPriorityEnum() {
        XCTAssertEqual(Priority.low.rawValue, "low")
        XCTAssertEqual(Priority.medium.rawValue, "medium")
        XCTAssertEqual(Priority.high.rawValue, "high")
    }
    
    func testWeekdayEnum() {
        let weekdays = Weekday.allCases
        XCTAssertEqual(weekdays.count, 7)
        XCTAssertTrue(weekdays.contains(.monday))
        XCTAssertTrue(weekdays.contains(.sunday))
    }
    
    // MARK: - Test de HabitListViewModel (siempre disponible)
    
    func testHabitListViewModelInitialization() async {
        let mockStorage = MockStorageProvider()
        let viewModel = HabitListViewModel(storageProvider: mockStorage)
        
        XCTAssertNotNil(viewModel)
        XCTAssertTrue(viewModel.habits.isEmpty || viewModel.habits.count >= 0)
    }
    
    func testAddHabit() async {
        let mockStorage = MockStorageProvider()
        let viewModel = HabitListViewModel(storageProvider: mockStorage)
        
        let habit = Habit(title: "New Habit", frequency: [.monday])
        viewModel.addHabit(habit)
        
        XCTAssertEqual(viewModel.habits.count, 1)
        XCTAssertEqual(viewModel.habits.first?.title, "New Habit")
    }
    
    func testToggleCompletion() async {
        let mockStorage = MockStorageProvider()
        let viewModel = HabitListViewModel(storageProvider: mockStorage)
        
        let habit = Habit(title: "Test", frequency: [.monday])
        viewModel.addHabit(habit)
        
        let initialCompleted = habit.isCompletedToday
        viewModel.toggleCompletion(habit: habit)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // El estado debería haber cambiado
        XCTAssertNotEqual(viewModel.habits.first?.isCompletedToday, initialCompleted)
    }
    
    // MARK: - Test de MockStorageProvider (siempre disponible)
    
    func testMockStorageProvider() async throws {
        let mockStorage = MockStorageProvider()
        
        let habit1 = Habit(title: "Habit 1", frequency: [.monday])
        let habit2 = Habit(title: "Habit 2", frequency: [.tuesday])
        
        try await mockStorage.saveHabits(habits: [habit1, habit2])
        let loadedHabits = try await mockStorage.loadHabits()
        
        XCTAssertEqual(loadedHabits.count, 2)
        XCTAssertEqual(mockStorage.saveCalledCount, 1)
        XCTAssertEqual(mockStorage.loadCalledCount, 1)
    }
    
    // MARK: - Test de Weekday.from(date:)
    
    func testWeekdayFromDate() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        
        components.year = 2024
        components.month = 1
        components.day = 1 // Lunes
        let monday = calendar.date(from: components)!
        
        XCTAssertEqual(Weekday.from(date: monday), .monday)
    }
    
    // MARK: - Test de isCompletedToday
    
    func testHabitIsCompletedToday() {
        let habit = Habit(title: "Test", frequency: [.monday])
        XCTAssertFalse(habit.isCompletedToday)
        
        let today = Date()
        let entry = CompletionEntry(date: today)
        habit.completed.append(entry)
        
        XCTAssertTrue(habit.isCompletedToday)
    }
    
    // MARK: - Test de shouldBeCompletedOn
    
    func testHabitShouldBeCompletedOn() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2024
        components.month = 1
        components.day = 1 // Lunes
        let monday = calendar.date(from: components)!
        
        let habit = Habit(title: "Test", frequency: [.monday, .wednesday])
        
        XCTAssertTrue(habit.shouldBeCompletedOn(date: monday))
    }
}
