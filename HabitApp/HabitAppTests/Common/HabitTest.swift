//
//  HabitTest.swift
//  HabitAppTests
//

import XCTest
@testable import HabitApp

final class HabitTest: XCTestCase {
    
    // MARK: - Test de inicialización básica
    
    func testHabitInitialization() {
        // Arrange & Act
        let habit = Habit(
            title: "Ejercicio diario",
            priority: .high,
            completed: [],
            frequency: [.monday, .wednesday, .friday]
        )
        
        // Assert
        XCTAssertEqual(habit.title, "Ejercicio diario")
        XCTAssertEqual(habit.priority, .high)
        XCTAssertEqual(habit.completed.count, 0)
        XCTAssertEqual(habit.frequency.count, 3)
        XCTAssertTrue(habit.frequency.contains(.monday))
        XCTAssertTrue(habit.frequency.contains(.wednesday))
        XCTAssertTrue(habit.frequency.contains(.friday))
    }
    
    func testHabitInitializationWithDefaults() {
        // Arrange & Act
        let habit = Habit(title: "Leer libros")
        
        // Assert
        XCTAssertEqual(habit.title, "Leer libros")
        XCTAssertNil(habit.priority)
        XCTAssertEqual(habit.completed.count, 0)
        XCTAssertEqual(habit.frequency.count, 0)
    }
    
    // MARK: - Test de Priority
    
    func testPriorityRawValuePersistence() {
        // Arrange & Act
        let habitLow = Habit(title: "Test", priority: .low)
        let habitMedium = Habit(title: "Test", priority: .medium)
        let habitHigh = Habit(title: "Test", priority: .high)
        
        // Assert
        XCTAssertEqual(habitLow.priority, .low)
        XCTAssertEqual(habitMedium.priority, .medium)
        XCTAssertEqual(habitHigh.priority, .high)
    }
    
    // MARK: - Test de isCompletedToday
    
    func testIsCompletedToday_WhenNotCompleted() {
        // Arrange
        let habit = Habit(title: "Meditar", frequency: [.monday])
        
        // Act & Assert
        XCTAssertFalse(habit.isCompletedToday)
    }
    
    func testIsCompletedToday_WhenCompletedToday() {
        // Arrange
        let habit = Habit(title: "Meditar", frequency: [.monday])
        let today = Date()
        let entry = CompletionEntry(date: today)
        habit.completed.append(entry)
        
        // Act & Assert
        XCTAssertTrue(habit.isCompletedToday)
    }
    
    func testIsCompletedToday_WhenCompletedYesterday() {
        // Arrange
        let habit = Habit(title: "Meditar", frequency: [.monday])
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let entry = CompletionEntry(date: yesterday)
        habit.completed.append(entry)
        
        // Act & Assert
        XCTAssertFalse(habit.isCompletedToday)
    }
    
    // MARK: - Test de Weekday
    
    func testWeekdayFromDate() {
        // Arrange
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        
        // Act & Assert - Probar diferentes días de la semana
        // Nota: Los números dependen del calendario, pero podemos probar la consistencia
        
        // Crear una fecha conocida (e.g., 2024-01-01 es lunes)
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
        // Arrange & Act
        let allWeekdays = Weekday.allCases
        
        // Assert
        XCTAssertEqual(allWeekdays.count, 7)
        XCTAssertTrue(allWeekdays.contains(.monday))
        XCTAssertTrue(allWeekdays.contains(.sunday))
    }
    
    // MARK: - Test de Reminders Extension (shouldBeCompletedOn)
    
    func testShouldBeCompletedOn_WithEmptyFrequency() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [])
        let date = Date()
        
        // Act & Assert
        XCTAssertFalse(habit.shouldBeCompletedOn(date: date))
    }
    
    func testShouldBeCompletedOn_WithMatchingDay() {
        // Arrange
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2024
        components.month = 1
        components.day = 1 // Lunes
        let monday = calendar.date(from: components)!
        
        let habit = Habit(title: "Test", frequency: [.monday, .wednesday])
        
        // Act & Assert
        XCTAssertTrue(habit.shouldBeCompletedOn(date: monday))
    }
    
    func testShouldBeCompletedOn_WithNonMatchingDay() {
        // Arrange
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2024
        components.month = 1
        components.day = 2 // Martes
        let tuesday = calendar.date(from: components)!
        
        let habit = Habit(title: "Test", frequency: [.monday, .wednesday])
        
        // Act & Assert
        XCTAssertFalse(habit.shouldBeCompletedOn(date: tuesday))
    }
    
    // MARK: - Test de Streak Extension
    
    func testStreakInitialValue() {
        // Arrange & Act
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Assert
        XCTAssertEqual(habit.streak, 0)
        XCTAssertEqual(habit.maxStreak, 0)
        XCTAssertNil(habit.nextDay)
    }
    
    func testStreakSetterCreatesFeature() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Act
        habit.streak = 5
        
        // Assert
        XCTAssertEqual(habit.streak, 5)
        XCTAssertNotNil(habit.streakFeature)
    }
    
    func testMaxStreakSetterCreatesFeature() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Act
        habit.maxStreak = 10
        
        // Assert
        XCTAssertEqual(habit.maxStreak, 10)
        XCTAssertNotNil(habit.streakFeature)
    }
    
    func testNextDaySetterCreatesFeature() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        // Act
        habit.nextDay = tomorrow
        
        // Assert
        XCTAssertNotNil(habit.nextDay)
        XCTAssertNotNil(habit.streakFeature)
        XCTAssertEqual(
            Calendar.current.startOfDay(for: habit.nextDay!),
            Calendar.current.startOfDay(for: tomorrow)
        )
    }
    
    func testCheckAndUpdateStreak_FirstTime() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday, .wednesday, .friday])
        
        // Act
        habit.checkAndUpdateStreak()
        
        // Assert
        XCTAssertNotNil(habit.nextDay, "nextDay debe ser calculado la primera vez")
    }
    
    func testCheckAndUpdateStreak_CompletedOnExpectedDay() {
        // Arrange
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let habit = Habit(title: "Test", frequency: [Weekday.from(date: today)])
        
        // Establecer que hoy es el día esperado
        habit.nextDay = today
        
        // Completar hoy
        let entry = CompletionEntry(date: today)
        habit.completed.append(entry)
        
        // Act
        habit.checkAndUpdateStreak()
        
        // Assert
        XCTAssertEqual(habit.streak, 1, "La racha debe incrementarse")
        XCTAssertEqual(habit.maxStreak, 1, "maxStreak debe actualizarse")
        XCTAssertNotNil(habit.nextDay, "nextDay debe recalcularse")
    }
    
    func testCheckAndUpdateStreak_NotCompletedOnExpectedDay() {
        // Arrange
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let habit = Habit(title: "Test", frequency: [Weekday.from(date: today)])
        
        // Establecer racha previa
        habit.streak = 5
        habit.nextDay = today
        
        // NO completar hoy (no agregar CompletionEntry)
        
        // Act
        habit.checkAndUpdateStreak()
        
        // Assert
        XCTAssertEqual(habit.streak, 0, "La racha debe resetearse")
        XCTAssertNotNil(habit.nextDay, "nextDay debe recalcularse")
    }
    
    func testCheckAndUpdateStreak_MissedDay() {
        // Arrange
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let habit = Habit(title: "Test", frequency: [Weekday.from(date: yesterday)])
        
        // Establecer que ayer era el día esperado
        habit.streak = 3
        habit.nextDay = yesterday
        
        // Act (hoy, pero el día esperado fue ayer)
        habit.checkAndUpdateStreak()
        
        // Assert
        XCTAssertEqual(habit.streak, 0, "La racha debe resetearse por día perdido")
    }
    
    // MARK: - Test de Category Extension
    
    func testCategoryGetter_WhenNoCategory() {
        // Arrange
        let habit = Habit(title: "Test")
        
        // Act & Assert
        XCTAssertNil(habit.category)
    }
    
    func testCategorySetter_CreatesFeature() {
        // Arrange
        let habit = Habit(title: "Test")
        let category = Category(name: "Salud", categoryDescription: "Hábitos saludables")
        
        // Act
        habit.category = category
        
        // Assert
        XCTAssertNotNil(habit.categoryFeature)
        XCTAssertEqual(habit.category?.name, "Salud")
    }
    
    func testCategorySetter_UpdatesExistingFeature() {
        // Arrange
        let habit = Habit(title: "Test")
        let category1 = Category(name: "Salud", categoryDescription: "Desc1")
        let category2 = Category(name: "Trabajo", categoryDescription: "Desc2")
        
        habit.category = category1
        
        // Act
        habit.category = category2
        
        // Assert
        XCTAssertEqual(habit.category?.name, "Trabajo")
    }
    
    func testCategorySetter_RemovesFeature() {
        // Arrange
        let habit = Habit(title: "Test")
        let category = Category(name: "Salud", categoryDescription: "Desc")
        habit.category = category
        
        // Act
        habit.category = nil
        
        // Assert
        XCTAssertNil(habit.categoryFeature)
        XCTAssertNil(habit.category)
    }
    
    func testGroupByCategory_EmptyArray() {
        // Arrange
        let habits: [Habit] = []
        
        // Act
        let grouped = Habit.groupByCategory(habits)
        
        // Assert
        XCTAssertTrue(grouped.isEmpty)
    }
    
    func testGroupByCategory_WithCategories() {
        // Arrange
        let categoryHealth = Category(name: "Salud", categoryDescription: "Desc1")
        let categoryWork = Category(name: "Trabajo", categoryDescription: "Desc2")
        
        let habit1 = Habit(title: "Ejercicio")
        habit1.category = categoryHealth
        
        let habit2 = Habit(title: "Meditar")
        habit2.category = categoryHealth
        
        let habit3 = Habit(title: "Revisar email")
        habit3.category = categoryWork
        
        let habits = [habit1, habit2, habit3]
        
        // Act
        let grouped = Habit.groupByCategory(habits)
        
        // Assert
        XCTAssertEqual(grouped.count, 2)
        XCTAssertEqual(grouped["Salud"]?.count, 2)
        XCTAssertEqual(grouped["Trabajo"]?.count, 1)
    }
    
    func testGroupByCategory_WithUncategorized() {
        // Arrange
        let category = Category(name: "Salud", categoryDescription: "Desc")
        
        let habit1 = Habit(title: "Ejercicio")
        habit1.category = category
        
        let habit2 = Habit(title: "Sin categoría")
        // No asignamos categoría
        
        let habits = [habit1, habit2]
        
        // Act
        let grouped = Habit.groupByCategory(habits)
        
        // Assert
        XCTAssertEqual(grouped.count, 2)
        XCTAssertEqual(grouped["Salud"]?.count, 1)
        XCTAssertEqual(grouped["Sin categoría"]?.count, 1)
    }
    
    // MARK: - Test de Diary Extension (note)
    
    func testNoteGetter_WhenNoNote() {
        // Arrange
        let entry = CompletionEntry(date: Date())
        
        // Act & Assert
        XCTAssertNil(entry.note)
        XCTAssertFalse(entry.hasNote)
    }
    
    func testNoteSetter_CreatesFeature() {
        // Arrange
        let entry = CompletionEntry(date: Date())
        
        // Act
        entry.note = "Hoy me sentí genial"
        
        // Assert
        XCTAssertNotNil(entry.diaryFeature)
        XCTAssertEqual(entry.note, "Hoy me sentí genial")
        XCTAssertTrue(entry.hasNote)
    }
    
    func testNoteSetter_UpdatesExistingNote() {
        // Arrange
        let entry = CompletionEntry(date: Date())
        entry.note = "Primera nota"
        
        // Act
        entry.note = "Nota actualizada"
        
        // Assert
        XCTAssertEqual(entry.note, "Nota actualizada")
        XCTAssertTrue(entry.hasNote)
    }
    
    func testNoteSetter_RemovesFeatureWithEmptyString() {
        // Arrange
        let entry = CompletionEntry(date: Date())
        entry.note = "Alguna nota"
        
        // Act
        entry.note = ""
        
        // Assert
        XCTAssertNil(entry.diaryFeature)
        XCTAssertFalse(entry.hasNote)
    }
    
    func testNoteSetter_RemovesFeatureWithNil() {
        // Arrange
        let entry = CompletionEntry(date: Date())
        entry.note = "Alguna nota"
        
        // Act
        entry.note = nil
        
        // Assert
        XCTAssertNil(entry.diaryFeature)
        XCTAssertFalse(entry.hasNote)
    }
}
