//
//  HabitAppTest.swift
//  HabitAppTests
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

@MainActor
final class HabitAppTest: XCTestCase {

    // MARK: - Test de modelos basicos

    func testCompletionEntryInitialization() {
        let date = Date()

        let entry = CompletionEntry(date: date)

        XCTAssertNotNil(entry.id)
        XCTAssertEqual(
            Calendar.current.startOfDay(for: entry.date),
            Calendar.current.startOfDay(for: date)
        )
    }

    func testCompletionEntry_UniqueIds() {
        let date = Date()

        let entry1 = CompletionEntry(date: date)
        let entry2 = CompletionEntry(date: date)

        XCTAssertNotEqual(entry1.id, entry2.id)
    }

    // MARK: - Test de Priority enum

    func testPriorityAllCases() {
        let priorities: [Priority] = [.low, .medium, .high]
        XCTAssertEqual(priorities.count, 3)
    }

    func testPriorityRawValues() {
        XCTAssertEqual(Priority.low.rawValue, "low")
        XCTAssertEqual(Priority.medium.rawValue, "medium")
        XCTAssertEqual(Priority.high.rawValue, "high")
    }

    func testPriorityFromRawValue() {
        XCTAssertEqual(Priority(rawValue: "low"), .low)
        XCTAssertEqual(Priority(rawValue: "medium"), .medium)
        XCTAssertEqual(Priority(rawValue: "high"), .high)
        XCTAssertNil(Priority(rawValue: "invalid"))
    }

    // MARK: - Test de Weekday enum

    func testWeekdayAllCases() {
        let weekdays = Weekday.allCases
        XCTAssertEqual(weekdays.count, 7)
    }

    func testWeekdayRawValues() {
        XCTAssertEqual(Weekday.monday.rawValue, "Lunes")
        XCTAssertEqual(Weekday.tuesday.rawValue, "Martes")
        XCTAssertEqual(Weekday.wednesday.rawValue, "Mi\u{00E9}rcoles")
        XCTAssertEqual(Weekday.thursday.rawValue, "Jueves")
        XCTAssertEqual(Weekday.friday.rawValue, "Viernes")
        XCTAssertEqual(Weekday.saturday.rawValue, "S\u{00E1}bado")
        XCTAssertEqual(Weekday.sunday.rawValue, "Domingo")
    }

    func testWeekdayFromRawValue() {
        XCTAssertEqual(Weekday(rawValue: "Lunes"), .monday)
        XCTAssertEqual(Weekday(rawValue: "Martes"), .tuesday)
        XCTAssertEqual(Weekday(rawValue: "Mi\u{00E9}rcoles"), .wednesday)
        XCTAssertEqual(Weekday(rawValue: "Jueves"), .thursday)
        XCTAssertEqual(Weekday(rawValue: "Viernes"), .friday)
        XCTAssertEqual(Weekday(rawValue: "S\u{00E1}bado"), .saturday)
        XCTAssertEqual(Weekday(rawValue: "Domingo"), .sunday)
        XCTAssertNil(Weekday(rawValue: "Invalid"))
    }

    func testWeekdayFromDate_Monday() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2024
        components.month = 1
        components.day = 1
        let monday = calendar.date(from: components)!

        let weekday = Weekday.from(date: monday)

        XCTAssertEqual(weekday, .monday)
    }

    func testWeekdayFromDate_Sunday() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2024
        components.month = 1
        components.day = 7
        let sunday = calendar.date(from: components)!

        let weekday = Weekday.from(date: sunday)

        XCTAssertEqual(weekday, .sunday)
    }

    func testWeekdayFromDate_AllDaysOfWeek() {
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

        for expected in expectedWeekdays {
            components.day = expected.day
            let date = calendar.date(from: components)!
            let weekday = Weekday.from(date: date)
            XCTAssertEqual(weekday, expected.weekday, "DÃ­a \(expected.day) debe ser \(expected.weekday)")
        }
    }

    // MARK: - Test de StorageProvider protocol

    func testStorageProvider_MockImplementation() async throws {
        let mockStorage = MockStorageProvider()
        let habit1 = Habit(title: "Test 1", frequency: [.monday])
        let habit2 = Habit(title: "Test 2", frequency: [.tuesday])

        try await mockStorage.saveHabits(habits: [habit1, habit2])
        let loadedHabits = try await mockStorage.loadHabits()

        XCTAssertEqual(loadedHabits.count, 2)
        let saveCount = mockStorage.saveCalledCount
        let loadCount = mockStorage.loadCalledCount
        XCTAssertEqual(saveCount, 1)
        XCTAssertEqual(loadCount, 1)
    }

    func testMockStorageProvider_SaveIncrementsSaveCount() async throws {
        let mockStorage = MockStorageProvider()
        let habit = Habit(title: "Test", frequency: [.monday])

        try await mockStorage.saveHabits(habits: [habit])
        try await mockStorage.saveHabits(habits: [habit])
        try await mockStorage.saveHabits(habits: [habit])

        let saveCount = mockStorage.saveCalledCount
        XCTAssertEqual(saveCount, 3)
    }

    func testMockStorageProvider_LoadIncrementsLoadCount() async throws {
        let mockStorage = MockStorageProvider()

        _ = try await mockStorage.loadHabits()
        _ = try await mockStorage.loadHabits()

        let loadCount = mockStorage.loadCalledCount
        XCTAssertEqual(loadCount, 2)
    }

    func testMockStorageProvider_ThrowsOnSaveWhenConfigured() async {
        let mockStorage = MockStorageProvider()
        mockStorage.shouldFailOnSave = true
        let habit = Habit(title: "Test", frequency: [.monday])

        do {
            try await mockStorage.saveHabits(habits: [habit])
            XCTFail("Deberia haber lanzado un error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testMockStorageProvider_ThrowsOnLoadWhenConfigured() async {
        let mockStorage = MockStorageProvider()
        mockStorage.shouldFailOnLoad = true

        do {
            _ = try await mockStorage.loadHabits()
            XCTFail("Deberia haber lanzado un error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Test de Calendar helpers

    func testCalendar_StartOfDay() {
        let calendar = Calendar.current
        let now = Date()

        let startOfDay = calendar.startOfDay(for: now)
        let components = calendar.dateComponents([.hour, .minute, .second], from: startOfDay)

        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testCalendar_IsDateInSameDay() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 12
        components.minute = 0
        components.second = 0
        let now = calendar.date(from: components)!
        let sameDay = calendar.date(byAdding: .hour, value: 2, to: now)!
        let differentDay = calendar.date(byAdding: .day, value: 1, to: now)!

        XCTAssertTrue(calendar.isDate(now, inSameDayAs: sameDay))
        XCTAssertFalse(calendar.isDate(now, inSameDayAs: differentDay))
    }

    // MARK: - Test de integracion basica

    func testHabitWithAllFeatures() {
        let habit = Habit(
            title: "HÃ¡bito completo",
            priority: .high,
            completed: [
                CompletionEntry(date: Date()),
                CompletionEntry(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
            ],
            frequency: [.monday, .wednesday, .friday]
        )

        XCTAssertEqual(habit.title, "HÃ¡bito completo")
        XCTAssertEqual(habit.priority, .high)
        XCTAssertEqual(habit.completed.count, 2)
        XCTAssertEqual(habit.frequency.count, 3)
        XCTAssertNotNil(habit.id)
    }

    func testMultipleHabitsWithDifferentConfigurations() {
        let habit1 = Habit(title: "Diario", frequency: Weekday.allCases)
        let habit2 = Habit(title: "Semanal", frequency: [.monday])
        let habit3 = Habit(title: "Fin de semana", frequency: [.saturday, .sunday])

        XCTAssertEqual(habit1.frequency.count, 7)
        XCTAssertEqual(habit2.frequency.count, 1)
        XCTAssertEqual(habit3.frequency.count, 2)

        XCTAssertNotEqual(habit1.id, habit2.id)
        XCTAssertNotEqual(habit2.id, habit3.id)
        XCTAssertNotEqual(habit1.id, habit3.id)
    }

    // MARK: - Test de Date utilities

    func testDateComparison_SameDay() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 12
        components.minute = 0
        components.second = 0
        let date1 = calendar.date(from: components)!
        let date2 = calendar.date(byAdding: .hour, value: 5, to: date1)!

        let areSameDay = calendar.isDate(date1, inSameDayAs: date2)

        XCTAssertTrue(areSameDay)
    }

    func testDateComparison_DifferentDays() {
        let calendar = Calendar.current
        let date1 = Date()
        let date2 = calendar.date(byAdding: .day, value: 1, to: date1)!

        let areSameDay = calendar.isDate(date1, inSameDayAs: date2)

        XCTAssertFalse(areSameDay)
    }

    func testDateAddition() {
        let calendar = Calendar.current
        let startDate = Date()

        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startDate)!
        let components = calendar.dateComponents([.day], from: startDate, to: nextWeek)

        XCTAssertEqual(components.day, 7)
    }

    // MARK: - Test de valores por defecto

    func testHabitDefaultValues() {
        let habit = Habit(title: "Valores por defecto")

        XCTAssertEqual(habit.title, "Valores por defecto")
        XCTAssertNil(habit.priority)
        XCTAssertTrue(habit.completed.isEmpty)
        XCTAssertTrue(habit.frequency.isEmpty)
        XCTAssertNotNil(habit.id)
    }

    func testCompletionEntryDefaultValues() {
        let entry = CompletionEntry(date: Date())

        XCTAssertNotNil(entry.id)
        XCTAssertNotNil(entry.date)
    }
}

