//
//  HabitTest.swift
//  HabitAppTests
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

final class HabitTest: XCTestCase {

    private func makeInMemoryContext(models: [any PersistentModel.Type]) throws -> ModelContext {
        let schema = Schema(models)
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        let context = ModelContext(container)
        SwiftDataContext.shared = context
        return context
    }

    // MARK: - Test de inicializacion basica

    func testHabitInitialization() {
        let habit = Habit(
            title: "Ejercicio diario",
            priority: .high,
            completed: [],
            frequency: [.monday, .wednesday, .friday]
        )

        XCTAssertEqual(habit.title, "Ejercicio diario")
        XCTAssertEqual(habit.priority, .high)
        XCTAssertEqual(habit.completed.count, 0)
        XCTAssertEqual(habit.frequency.count, 3)
        XCTAssertTrue(habit.frequency.contains(.monday))
        XCTAssertTrue(habit.frequency.contains(.wednesday))
        XCTAssertTrue(habit.frequency.contains(.friday))
    }

    func testHabitInitializationWithDefaults() {
        let habit = Habit(title: "Leer libros")

        XCTAssertEqual(habit.title, "Leer libros")
        XCTAssertNil(habit.priority)
        XCTAssertEqual(habit.completed.count, 0)
        XCTAssertEqual(habit.frequency.count, 0)
    }

    // MARK: - Test de Priority

    func testPriorityRawValuePersistence() {
        let habitLow = Habit(title: "Test", priority: .low)
        let habitMedium = Habit(title: "Test", priority: .medium)
        let habitHigh = Habit(title: "Test", priority: .high)

        XCTAssertEqual(habitLow.priority, .low)
        XCTAssertEqual(habitMedium.priority, .medium)
        XCTAssertEqual(habitHigh.priority, .high)
    }

    // MARK: - Test de isCompletedToday

    func testIsCompletedToday_WhenNotCompleted() {
        let habit = Habit(title: "Meditar", frequency: [.monday])
        XCTAssertFalse(habit.isCompletedToday)
    }

    func testIsCompletedToday_WhenCompletedToday() {
        let habit = Habit(title: "Meditar", frequency: [.monday])
        let today = Date()
        let entry = CompletionEntry(date: today)
        habit.completed.append(entry)

        XCTAssertTrue(habit.isCompletedToday)
    }

    func testIsCompletedToday_WhenCompletedYesterday() {
        let habit = Habit(title: "Meditar", frequency: [.monday])
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let entry = CompletionEntry(date: yesterday)
        habit.completed.append(entry)

        XCTAssertFalse(habit.isCompletedToday)
    }

    // MARK: - Test de Weekday

    func testWeekdayFromDate() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())

        components.year = 2024
        components.month = 1

        components.day = 1 // Lunes
        let monday = calendar.date(from: components)!
        XCTAssertEqual(Weekday.from(date: monday), .monday)

        components.day = 2 // Martes
        let tuesday = calendar.date(from: components)!
        XCTAssertEqual(Weekday.from(date: tuesday), .tuesday)

        components.day = 7 // Domingo
        let sunday = calendar.date(from: components)!
        XCTAssertEqual(Weekday.from(date: sunday), .sunday)
    }

    func testWeekdayAllCases() {
        let allWeekdays = Weekday.allCases
        XCTAssertEqual(allWeekdays.count, 7)
        XCTAssertTrue(allWeekdays.contains(.monday))
        XCTAssertTrue(allWeekdays.contains(.sunday))
    }

    // MARK: - Test de Reminders Extension (shouldBeCompletedOn)

    func testShouldBeCompletedOn_WithEmptyFrequency() {
        let habit = Habit(title: "Test", frequency: [])
        let date = Date()
        XCTAssertFalse(habit.shouldBeCompletedOn(date: date))
    }

    func testShouldBeCompletedOn_WithMatchingDay() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2024
        components.month = 1
        components.day = 1 // Lunes
        let monday = calendar.date(from: components)!

        let habit = Habit(title: "Test", frequency: [.monday, .wednesday])
        XCTAssertTrue(habit.shouldBeCompletedOn(date: monday))
    }

    func testShouldBeCompletedOn_WithNonMatchingDay() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2024
        components.month = 1
        components.day = 2 // Martes
        let tuesday = calendar.date(from: components)!

        let habit = Habit(title: "Test", frequency: [.monday, .wednesday])
        XCTAssertFalse(habit.shouldBeCompletedOn(date: tuesday))
    }

    // MARK: - Test de Streak Extension

    #if STREAKS_FEATURE

    func testStreakInitialValue() throws {
        let context = try makeInMemoryContext(models: [Habit.self, HabitStreakFeature.self])
        let habit = Habit(title: "Test", frequency: [.monday])
        context.insert(habit)

        XCTAssertEqual(habit.getStreak(), 0)
        XCTAssertEqual(habit.getMaxStreak(), 0)
        XCTAssertNil(habit.getNextDay())
    }

    func testStreakSetterCreatesFeature() throws {
        let context = try makeInMemoryContext(models: [Habit.self, HabitStreakFeature.self])
        let habit = Habit(title: "Test", frequency: [.monday])
        context.insert(habit)

        habit.setStreak(5)

        XCTAssertEqual(habit.getStreak(), 5)
        XCTAssertNotNil(habit.getStreakFeature())
    }

    func testMaxStreakSetterCreatesFeature() throws {
        let context = try makeInMemoryContext(models: [Habit.self, HabitStreakFeature.self])
        let habit = Habit(title: "Test", frequency: [.monday])
        context.insert(habit)

        habit.setMaxStreak(10)

        XCTAssertEqual(habit.getMaxStreak(), 10)
        XCTAssertNotNil(habit.getStreakFeature())
    }

    func testNextDaySetterCreatesFeature() throws {
        let context = try makeInMemoryContext(models: [Habit.self, HabitStreakFeature.self])
        let habit = Habit(title: "Test", frequency: [.monday])
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        context.insert(habit)

        habit.setNextDay(tomorrow)

        XCTAssertNotNil(habit.getNextDay())
        XCTAssertNotNil(habit.getStreakFeature())
        XCTAssertEqual(
            Calendar.current.startOfDay(for: habit.getNextDay()!),
            Calendar.current.startOfDay(for: tomorrow)
        )
    }

    func testCheckAndUpdateStreak_FirstTime() throws {
        let context = try makeInMemoryContext(models: [Habit.self, HabitStreakFeature.self])
        let habit = Habit(title: "Test", frequency: [.monday, .wednesday, .friday])
        context.insert(habit)

        habit.checkAndUpdateStreak()

        XCTAssertNotNil(habit.getNextDay(), "nextDay debe ser calculado la primera vez")
    }

    func testCheckAndUpdateStreak_CompletedOnExpectedDay() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let context = try makeInMemoryContext(models: [Habit.self, HabitStreakFeature.self])
        let habit = Habit(title: "Test", frequency: [Weekday.from(date: today)])
        context.insert(habit)

        habit.setNextDay(today)

        let entry = CompletionEntry(date: today)
        habit.completed.append(entry)

        habit.checkAndUpdateStreak(on: today)

        XCTAssertEqual(habit.getStreak(), 1, "La racha debe incrementarse")
        XCTAssertEqual(habit.getMaxStreak(), 1, "maxStreak debe actualizarse")
        XCTAssertNotNil(habit.getNextDay(), "nextDay debe recalcularse")
    }

    func testCheckAndUpdateStreak_NotCompletedOnExpectedDay() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let context = try makeInMemoryContext(models: [Habit.self, HabitStreakFeature.self])
        let habit = Habit(title: "Test", frequency: [Weekday.from(date: today)])
        context.insert(habit)

        habit.setStreak(5)
        habit.setNextDay(today)

        habit.checkAndUpdateStreak(on: today)

        XCTAssertEqual(habit.getStreak(), 0, "La racha debe resetearse")
        XCTAssertNotNil(habit.getNextDay(), "nextDay debe recalcularse")
    }

    func testCheckAndUpdateStreak_MissedDay() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let context = try makeInMemoryContext(models: [Habit.self, HabitStreakFeature.self])
        let habit = Habit(title: "Test", frequency: [Weekday.from(date: yesterday)])
        context.insert(habit)

        habit.setStreak(3)
        habit.setNextDay(yesterday)

        habit.checkAndUpdateStreak(on: today)

        XCTAssertEqual(habit.getStreak(), 0, "La racha debe resetearse por dia perdido")
    }

    #endif

    // MARK: - Test de Category Extension

    #if CATEGORY_FEATURE

    func testCategoryGetter_WhenNoCategory() throws {
        let context = try makeInMemoryContext(models: [Habit.self, Category.self, HabitCategoryFeature.self])
        let habit = Habit(title: "Test")
        context.insert(habit)

        XCTAssertNil(habit.getCategory())
    }

    func testCategorySetter_CreatesFeature() throws {
        let context = try makeInMemoryContext(models: [Habit.self, Category.self, HabitCategoryFeature.self])
        let habit = Habit(title: "Test")
        let category = Category(name: "Salud", categoryDescription: "Hábitos saludables")
        context.insert(habit)
        context.insert(category)

        habit.setCategory(category)

        XCTAssertEqual(habit.getCategory()?.name, "Salud")
    }

    func testCategorySetter_UpdatesExistingFeature() throws {
        let context = try makeInMemoryContext(models: [Habit.self, Category.self, HabitCategoryFeature.self])
        let habit = Habit(title: "Test")
        let category1 = Category(name: "Salud", categoryDescription: "Desc1")
        let category2 = Category(name: "Trabajo", categoryDescription: "Desc2")
        context.insert(habit)
        context.insert(category1)
        context.insert(category2)

        habit.setCategory(category1)
        habit.setCategory(category2)

        XCTAssertEqual(habit.getCategory()?.name, "Trabajo")
    }

    func testCategorySetter_RemovesFeature() throws {
        let context = try makeInMemoryContext(models: [Habit.self, Category.self, HabitCategoryFeature.self])
        let habit = Habit(title: "Test")
        let category = Category(name: "Salud", categoryDescription: "Desc")
        context.insert(habit)
        context.insert(category)

        habit.setCategory(category)
        habit.setCategory(nil)

        XCTAssertNil(habit.getCategory())
    }

    func testGroupByCategory_EmptyArray() {
        let habits: [Habit] = []
        let grouped = Habit.groupByCategory(habits)
        XCTAssertTrue(grouped.isEmpty)
    }

    func testGroupByCategory_WithCategories() throws {
        let context = try makeInMemoryContext(models: [Habit.self, Category.self, HabitCategoryFeature.self])
        let categoryHealth = Category(name: "Salud", categoryDescription: "Desc1")
        let categoryWork = Category(name: "Trabajo", categoryDescription: "Desc2")

        let habit1 = Habit(title: "Ejercicio")
        let habit2 = Habit(title: "Meditar")
        let habit3 = Habit(title: "Revisar email")

        context.insert(categoryHealth)
        context.insert(categoryWork)
        context.insert(habit1)
        context.insert(habit2)
        context.insert(habit3)

        habit1.setCategory(categoryHealth)
        habit2.setCategory(categoryHealth)
        habit3.setCategory(categoryWork)

        let grouped = Habit.groupByCategory([habit1, habit2, habit3])

        XCTAssertEqual(grouped.count, 2)
        XCTAssertEqual(grouped["Salud"]?.count, 2)
        XCTAssertEqual(grouped["Trabajo"]?.count, 1)
    }

    func testGroupByCategory_WithUncategorized() throws {
        let context = try makeInMemoryContext(models: [Habit.self, Category.self, HabitCategoryFeature.self])
        let category = Category(name: "Salud", categoryDescription: "Desc")

        let habit1 = Habit(title: "Ejercicio")
        let habit2 = Habit(title: "Sin categoria")

        context.insert(category)
        context.insert(habit1)
        context.insert(habit2)

        habit1.setCategory(category)

        let grouped = Habit.groupByCategory([habit1, habit2])

        XCTAssertEqual(grouped.count, 2)
        XCTAssertEqual(grouped["Salud"]?.count, 1)
        XCTAssertEqual(grouped["Sin categor\u{00ED}a"]?.count, 1)
    }

    #endif

    // MARK: - Test de Diary Extension (note)

    #if DIARY_FEATURE

    func testNoteGetter_WhenNoNote() throws {
        let context = try makeInMemoryContext(models: [CompletionEntry.self, DiaryNoteFeature.self])
        let entry = CompletionEntry(date: Date())
        context.insert(entry)

        XCTAssertNil(entry.getNote())
        XCTAssertFalse(entry.hasNote)
    }

    func testNoteSetter_CreatesFeature() throws {
        let context = try makeInMemoryContext(models: [CompletionEntry.self, DiaryNoteFeature.self])
        let entry = CompletionEntry(date: Date())
        context.insert(entry)

        entry.setNote("Hoy me sentí genial")

        XCTAssertEqual(entry.getNote(), "Hoy me sentí genial")
        XCTAssertTrue(entry.hasNote)
    }

    func testNoteSetter_UpdatesExistingNote() throws {
        let context = try makeInMemoryContext(models: [CompletionEntry.self, DiaryNoteFeature.self])
        let entry = CompletionEntry(date: Date())
        context.insert(entry)
        entry.setNote("Primera nota")

        entry.setNote("Nota actualizada")

        XCTAssertEqual(entry.getNote(), "Nota actualizada")
        XCTAssertTrue(entry.hasNote)
    }

    func testNoteSetter_RemovesFeatureWithEmptyString() throws {
        let context = try makeInMemoryContext(models: [CompletionEntry.self, DiaryNoteFeature.self])
        let entry = CompletionEntry(date: Date())
        context.insert(entry)
        entry.setNote("Alguna nota")

        entry.setNote("")

        XCTAssertNil(entry.getNote())
        XCTAssertFalse(entry.hasNote)
    }

    func testNoteSetter_RemovesFeatureWithNil() throws {
        let context = try makeInMemoryContext(models: [CompletionEntry.self, DiaryNoteFeature.self])
        let entry = CompletionEntry(date: Date())
        context.insert(entry)
        entry.setNote("Alguna nota")

        entry.setNote(nil)

        XCTAssertNil(entry.getNote())
        XCTAssertFalse(entry.hasNote)
    }

    #endif
}




