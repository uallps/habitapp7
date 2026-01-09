//
//  HabitAppTest.swift
//  HabitAppTests
//

import XCTest
@testable import HabitApp

final class HabitAppTest: XCTestCase {
    
    // MARK: - Test de modelos básicos
    
    func testCompletionEntryInitialization() {
        // Arrange
        let date = Date()
        
        // Act
        let entry = CompletionEntry(date: date)
        
        // Assert
        XCTAssertNotNil(entry.id)
        XCTAssertEqual(
            Calendar.current.startOfDay(for: entry.date),
            Calendar.current.startOfDay(for: date)
        )
    }
    
    func testCompletionEntry_UniqueIds() {
        // Arrange
        let date = Date()
        
        // Act
        let entry1 = CompletionEntry(date: date)
        let entry2 = CompletionEntry(date: date)
        
        // Assert
        XCTAssertNotEqual(entry1.id, entry2.id)
    }
    
    // MARK: - Test de Priority enum
    
    func testPriorityAllCases() {
        // Arrange & Act
        let priorities: [Priority] = [.low, .medium, .high]
        
        // Assert
        XCTAssertEqual(priorities.count, 3)
    }
    
    func testPriorityRawValues() {
        // Assert
        XCTAssertEqual(Priority.low.rawValue, "low")
        XCTAssertEqual(Priority.medium.rawValue, "medium")
        XCTAssertEqual(Priority.high.rawValue, "high")
    }
    
    func testPriorityFromRawValue() {
        // Act & Assert
        XCTAssertEqual(Priority(rawValue: "low"), .low)
        XCTAssertEqual(Priority(rawValue: "medium"), .medium)
        XCTAssertEqual(Priority(rawValue: "high"), .high)
        XCTAssertNil(Priority(rawValue: "invalid"))
    }
    
    // MARK: - Test de Weekday enum
    
    func testWeekdayAllCases() {
        // Arrange & Act
        let weekdays = Weekday.allCases
        
        // Assert
        XCTAssertEqual(weekdays.count, 7)
    }
    
    func testWeekdayRawValues() {
        // Assert
        XCTAssertEqual(Weekday.monday.rawValue, "Lunes")
        XCTAssertEqual(Weekday.tuesday.rawValue, "Martes")
        XCTAssertEqual(Weekday.wednesday.rawValue, "Miércoles")
        XCTAssertEqual(Weekday.thursday.rawValue, "Jueves")
        XCTAssertEqual(Weekday.friday.rawValue, "Viernes")
        XCTAssertEqual(Weekday.saturday.rawValue, "Sábado")
        XCTAssertEqual(Weekday.sunday.rawValue, "Domingo")
    }
    
    func testWeekdayFromRawValue() {
        // Act & Assert
        XCTAssertEqual(Weekday(rawValue: "Lunes"), .monday)
        XCTAssertEqual(Weekday(rawValue: "Martes"), .tuesday)
        XCTAssertEqual(Weekday(rawValue: "Miércoles"), .wednesday)
        XCTAssertEqual(Weekday(rawValue: "Jueves"), .thursday)
        XCTAssertEqual(Weekday(rawValue: "Viernes"), .friday)
        XCTAssertEqual(Weekday(rawValue: "Sábado"), .saturday)
        XCTAssertEqual(Weekday(rawValue: "Domingo"), .sunday)
        XCTAssertNil(Weekday(rawValue: "Invalid"))
    }
    
    func testWeekdayFromDate_Monday() {
        // Arrange
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2024
        components.month = 1
        components.day = 1 // 1 enero 2024 es lunes
        let monday = calendar.date(from: components)!
        
        // Act
        let weekday = Weekday.from(date: monday)
        
        // Assert
        XCTAssertEqual(weekday, .monday)
    }
    
    func testWeekdayFromDate_Sunday() {
        // Arrange
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2024
        components.month = 1
        components.day = 7 // 7 enero 2024 es domingo
        let sunday = calendar.date(from: components)!
        
        // Act
        let weekday = Weekday.from(date: sunday)
        
        // Assert
        XCTAssertEqual(weekday, .sunday)
    }
    
    func testWeekdayFromDate_AllDaysOfWeek() {
        // Arrange
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2024
        components.month = 1
        
        let expectedWeekdays: [(day: Int, weekday: Weekday)] = [
            (1, .monday),
            (2, .tuesday),
            (3, .wednesday),
            (4, .thursday),
            (5, .friday),
            (6, .saturday),
            (7, .sunday)
        ]
        
        // Act & Assert
        for expected in expectedWeekdays {
            components.day = expected.day
            let date = calendar.date(from: components)!
            let weekday = Weekday.from(date: date)
            XCTAssertEqual(weekday, expected.weekday, "Día \(expected.day) debe ser \(expected.weekday)")
        }
    }
    
    // MARK: - Test de StorageProvider protocol
    
    func testStorageProvider_MockImplementation() async throws {
        // Arrange
        let mockStorage = MockStorageProvider()
        let habit1 = Habit(title: "Test 1", frequency: [.monday])
        let habit2 = Habit(title: "Test 2", frequency: [.tuesday])
        
        // Act
        try await mockStorage.saveHabits(habits: [habit1, habit2])
        let loadedHabits = try await mockStorage.loadHabits()
        
        // Assert
        XCTAssertEqual(loadedHabits.count, 2)
        XCTAssertEqual(mockStorage.saveCalledCount, 1)
        XCTAssertEqual(mockStorage.loadCalledCount, 1)
    }
    
    func testMockStorageProvider_SaveIncrementsSaveCount() async throws {
        // Arrange
        let mockStorage = MockStorageProvider()
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Act
        try await mockStorage.saveHabits(habits: [habit])
        try await mockStorage.saveHabits(habits: [habit])
        try await mockStorage.saveHabits(habits: [habit])
        
        // Assert
        XCTAssertEqual(mockStorage.saveCalledCount, 3)
    }
    
    func testMockStorageProvider_LoadIncrementsLoadCount() async throws {
        // Arrange
        let mockStorage = MockStorageProvider()
        
        // Act
        _ = try await mockStorage.loadHabits()
        _ = try await mockStorage.loadHabits()
        
        // Assert
        XCTAssertEqual(mockStorage.loadCalledCount, 2)
    }
    
    func testMockStorageProvider_ThrowsOnSaveWhenConfigured() async {
        // Arrange
        let mockStorage = MockStorageProvider()
        mockStorage.shouldFailOnSave = true
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Act & Assert
        do {
            try await mockStorage.saveHabits(habits: [habit])
            XCTFail("Debería haber lanzado un error")
        } catch {
            // Éxito: se lanzó el error esperado
            XCTAssertNotNil(error)
        }
    }
    
    func testMockStorageProvider_ThrowsOnLoadWhenConfigured() async {
        // Arrange
        let mockStorage = MockStorageProvider()
        mockStorage.shouldFailOnLoad = true
        
        // Act & Assert
        do {
            _ = try await mockStorage.loadHabits()
            XCTFail("Debería haber lanzado un error")
        } catch {
            // Éxito: se lanzó el error esperado
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Test de Calendar helpers
    
    func testCalendar_StartOfDay() {
        // Arrange
        let calendar = Calendar.current
        let now = Date()
        
        // Act
        let startOfDay = calendar.startOfDay(for: now)
        let components = calendar.dateComponents([.hour, .minute, .second], from: startOfDay)
        
        // Assert
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }
    
    func testCalendar_IsDateInSameDay() {
        // Arrange
        let calendar = Calendar.current
        let now = Date()
        let sameDay = calendar.date(byAdding: .hour, value: 2, to: now)!
        let differentDay = calendar.date(byAdding: .day, value: 1, to: now)!
        
        // Act & Assert
        XCTAssertTrue(calendar.isDate(now, inSameDayAs: sameDay))
        XCTAssertFalse(calendar.isDate(now, inSameDayAs: differentDay))
    }
    
    // MARK: - Test de integración básica
    
    func testHabitWithAllFeatures() {
        // Arrange & Act
        let habit = Habit(
            title: "Hábito completo",
            priority: .high,
            completed: [
                CompletionEntry(date: Date()),
                CompletionEntry(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
            ],
            frequency: [.monday, .wednesday, .friday]
        )
        
        // Assert
        XCTAssertEqual(habit.title, "Hábito completo")
        XCTAssertEqual(habit.priority, .high)
        XCTAssertEqual(habit.completed.count, 2)
        XCTAssertEqual(habit.frequency.count, 3)
        XCTAssertNotNil(habit.id)
    }
    
    func testMultipleHabitsWithDifferentConfigurations() {
        // Arrange & Act
        let habit1 = Habit(title: "Diario", frequency: Weekday.allCases)
        let habit2 = Habit(title: "Semanal", frequency: [.monday])
        let habit3 = Habit(title: "Fin de semana", frequency: [.saturday, .sunday])
        
        // Assert
        XCTAssertEqual(habit1.frequency.count, 7)
        XCTAssertEqual(habit2.frequency.count, 1)
        XCTAssertEqual(habit3.frequency.count, 2)
        
        // Todos deben tener IDs únicos
        XCTAssertNotEqual(habit1.id, habit2.id)
        XCTAssertNotEqual(habit2.id, habit3.id)
        XCTAssertNotEqual(habit1.id, habit3.id)
    }
    
    // MARK: - Test de Date utilities
    
    func testDateComparison_SameDay() {
        // Arrange
        let calendar = Calendar.current
        let date1 = Date()
        let date2 = calendar.date(byAdding: .hour, value: 5, to: date1)!
        
        // Act
        let areSameDay = calendar.isDate(date1, inSameDayAs: date2)
        
        // Assert
        XCTAssertTrue(areSameDay)
    }
    
    func testDateComparison_DifferentDays() {
        // Arrange
        let calendar = Calendar.current
        let date1 = Date()
        let date2 = calendar.date(byAdding: .day, value: 1, to: date1)!
        
        // Act
        let areSameDay = calendar.isDate(date1, inSameDayAs: date2)
        
        // Assert
        XCTAssertFalse(areSameDay)
    }
    
    func testDateAddition() {
        // Arrange
        let calendar = Calendar.current
        let startDate = Date()
        
        // Act
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startDate)!
        let components = calendar.dateComponents([.day], from: startDate, to: nextWeek)
        
        // Assert
        XCTAssertEqual(components.day, 7)
    }
    
    // MARK: - Test de valores por defecto
    
    func testHabitDefaultValues() {
        // Arrange & Act
        let habit = Habit(title: "Valores por defecto")
        
        // Assert
        XCTAssertEqual(habit.title, "Valores por defecto")
        XCTAssertNil(habit.priority)
        XCTAssertTrue(habit.completed.isEmpty)
        XCTAssertTrue(habit.frequency.isEmpty)
        XCTAssertNotNil(habit.id)
    }
    
    func testCompletionEntryDefaultValues() {
        // Arrange & Act
        let entry = CompletionEntry(date: Date())
        
        // Assert
        XCTAssertNotNil(entry.id)
        XCTAssertNotNil(entry.date)
    }
}
