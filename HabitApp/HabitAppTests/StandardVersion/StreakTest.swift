//
//  StreakTest.swift
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

final class StreakTest: XCTestCase {
    
    // MARK: - Test de HabitStreakFeature inicializacion
    
    func testHabitStreakFeatureInitialization() {
        // Arrange
        let habitId = UUID()
        
        // Act
        let streakFeature = HabitStreakFeature(habitId: habitId, streak: 5, maxStreak: 10)
        
        // Assert
        XCTAssertEqual(streakFeature.habitId, habitId)
        XCTAssertEqual(streakFeature.streak, 5)
        XCTAssertEqual(streakFeature.maxStreak, 10)
        XCTAssertNil(streakFeature.nextDay)
    }
    
    func testHabitStreakFeatureInitializationWithNextDay() {
        // Arrange
        let habitId = UUID()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        // Act
        let streakFeature = HabitStreakFeature(habitId: habitId, streak: 3, maxStreak: 5, nextDay: tomorrow)
        
        // Assert
        XCTAssertEqual(streakFeature.habitId, habitId)
        XCTAssertEqual(streakFeature.streak, 3)
        XCTAssertEqual(streakFeature.maxStreak, 5)
        XCTAssertNotNil(streakFeature.nextDay)
        XCTAssertEqual(
            Calendar.current.startOfDay(for: streakFeature.nextDay!),
            Calendar.current.startOfDay(for: tomorrow)
        )
    }
    
    func testHabitStreakFeatureDefaultValues() {
        // Arrange
        let habitId = UUID()
        
        // Act
        let streakFeature = HabitStreakFeature(habitId: habitId)
        
        // Assert
        XCTAssertEqual(streakFeature.streak, 0)
        XCTAssertEqual(streakFeature.maxStreak, 0)
        XCTAssertNil(streakFeature.nextDay)
    }
    
    // MARK: - Test de nextDay property
    
    func testNextDayGetter() {
        // Arrange
        let habitId = UUID()
        let date = Date()
        let streakFeature = HabitStreakFeature(habitId: habitId, nextDay: date)
        
        // Assert
        XCTAssertNotNil(streakFeature.nextDay)
        XCTAssertEqual(
            Calendar.current.startOfDay(for: streakFeature.nextDay!),
            Calendar.current.startOfDay(for: date)
        )
    }
    
    func testNextDaySetter() {
        // Arrange
        let habitId = UUID()
        let streakFeature = HabitStreakFeature(habitId: habitId)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        // Act
        streakFeature.nextDay = tomorrow
        
        // Assert
        XCTAssertNotNil(streakFeature.nextDay)
        XCTAssertEqual(
            Calendar.current.startOfDay(for: streakFeature.nextDay!),
            Calendar.current.startOfDay(for: tomorrow)
        )
    }
    
    func testNextDaySetToNil() {
        // Arrange
        let habitId = UUID()
        let streakFeature = HabitStreakFeature(habitId: habitId, nextDay: Date())
        
        // Act
        streakFeature.nextDay = nil
        
        // Assert
        XCTAssertNil(streakFeature.nextDay)
    }
    
    // MARK: - Test de nextDayTimestamp
    
    func testNextDayTimestamp_ConversionToDate() {
        // Arrange
        let habitId = UUID()
        let date = Date()
        let streakFeature = HabitStreakFeature(habitId: habitId)
        
        // Act
        streakFeature.nextDay = date
        
        // Assert
        XCTAssertNotNil(streakFeature.nextDayTimestamp)
        let reconstructedDate = Date(timeIntervalSince1970: streakFeature.nextDayTimestamp!)
        XCTAssertEqual(
            Calendar.current.startOfDay(for: reconstructedDate),
            Calendar.current.startOfDay(for: date)
        )
    }
    
    func testNextDayTimestamp_NilWhenNextDayIsNil() {
        // Arrange
        let habitId = UUID()
        let streakFeature = HabitStreakFeature(habitId: habitId)
        
        // Assert
        XCTAssertNil(streakFeature.nextDayTimestamp)
        XCTAssertNil(streakFeature.nextDay)
    }
    
    // MARK: - Test de Habit Extension - getStreak
    
    func testGetStreak_WithNoStreakFeature() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Assert
        XCTAssertEqual(habit.getStreak(), 0)
    }
    
    func testGetStreak_ReturnsCorrectValue() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        habit.setStreak(7)
        
        // Assert
        XCTAssertEqual(habit.getStreak(), 7)
    }
    
    // MARK: - Test de Habit Extension - setStreak
    
    func testSetStreak_CreatesFeature() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Act
        habit.setStreak(5)
        
        // Assert
        XCTAssertEqual(habit.getStreak(), 5)
    }
    
    func testSetStreak_UpdatesExistingFeature() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        habit.setStreak(3)
        
        // Act
        habit.setStreak(10)
        
        // Assert
        XCTAssertEqual(habit.getStreak(), 10)
    }
    
    func testSetStreak_CanSetToZero() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        habit.setStreak(5)
        
        // Act
        habit.setStreak(0)
        
        // Assert
        XCTAssertEqual(habit.getStreak(), 0)
    }
    
    // MARK: - Test de Habit Extension - getMaxStreak
    
    func testGetMaxStreak_WithNoStreakFeature() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Assert
        XCTAssertEqual(habit.getMaxStreak(), 0)
    }
    
    func testGetMaxStreak_ReturnsCorrectValue() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        habit.setMaxStreak(15)
        
        // Assert
        XCTAssertEqual(habit.getMaxStreak(), 15)
    }
    
    // MARK: - Test de Habit Extension - setMaxStreak
    
    func testSetMaxStreak_CreatesFeature() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Act
        habit.setMaxStreak(20)
        
        // Assert
        XCTAssertEqual(habit.getMaxStreak(), 20)
    }
    
    func testSetMaxStreak_UpdatesExistingFeature() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        habit.setMaxStreak(10)
        
        // Act
        habit.setMaxStreak(25)
        
        // Assert
        XCTAssertEqual(habit.getMaxStreak(), 25)
    }
    
    // MARK: - Test de Habit Extension - getNextDay / setNextDay
    
    func testGetNextDay_WithNoStreakFeature() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Assert
        XCTAssertNil(habit.getNextDay())
    }
    
    func testSetNextDay_CreatesFeature() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        // Act
        habit.setNextDay(tomorrow)
        
        // Assert
        XCTAssertNotNil(habit.getNextDay())
        XCTAssertEqual(
            Calendar.current.startOfDay(for: habit.getNextDay()!),
            Calendar.current.startOfDay(for: tomorrow)
        )
    }
    
    func testSetNextDay_UpdatesExistingFeature() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let dayAfterTomorrow = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        
        habit.setNextDay(tomorrow)
        
        // Act
        habit.setNextDay(dayAfterTomorrow)
        
        // Assert
        XCTAssertEqual(
            Calendar.current.startOfDay(for: habit.getNextDay()!),
            Calendar.current.startOfDay(for: dayAfterTomorrow)
        )
    }
    
    func testSetNextDay_CanSetToNil() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        habit.setNextDay(Date())
        
        // Act
        habit.setNextDay(nil)
        
        // Assert
        XCTAssertNil(habit.getNextDay())
    }
    
    // MARK: - Test de checkAndUpdateStreak - Primera vez
    
    func testCheckAndUpdateStreak_FirstTime_CalculatesNextDay() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday, .wednesday, .friday])
        
        // Act
        habit.checkAndUpdateStreak()
        
        // Assert
        XCTAssertNotNil(habit.getNextDay(), "nextDay debe ser calculado la primera vez")
    }
    
    // MARK: - Test de checkAndUpdateStreak - Completado en dia esperado
    
    func testCheckAndUpdateStreak_CompletedOnExpectedDay_IncrementsStreak() {
        // Arrange
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let habit = Habit(title: "Test", frequency: [Weekday.from(date: today)])
        
        habit.setNextDay(today)
        habit.setStreak(0)
        
        let entry = CompletionEntry(date: today)
        habit.completed.append(entry)
        
        // Act
        habit.checkAndUpdateStreak(on: today)
        
        // Assert
        XCTAssertEqual(habit.getStreak(), 1, "La racha debe incrementarse")
        XCTAssertNotNil(habit.getNextDay(), "nextDay debe recalcularse")
    }
    
    func testCheckAndUpdateStreak_UpdatesMaxStreak() {
        // Arrange
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let habit = Habit(title: "Test", frequency: [Weekday.from(date: today)])
        
        habit.setNextDay(today)
        habit.setStreak(5)
        habit.setMaxStreak(5)
        
        let entry = CompletionEntry(date: today)
        habit.completed.append(entry)
        
        // Act
        habit.checkAndUpdateStreak(on: today)
        
        // Assert
        XCTAssertEqual(habit.getStreak(), 6)
        XCTAssertEqual(habit.getMaxStreak(), 6, "maxStreak debe actualizarse")
    }
    
    func testCheckAndUpdateStreak_DoesNotUpdateMaxStreakIfLower() {
        // Arrange
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let habit = Habit(title: "Test", frequency: [Weekday.from(date: today)])
        
        habit.setNextDay(today)
        habit.setStreak(3)
        habit.setMaxStreak(10)
        
        let entry = CompletionEntry(date: today)
        habit.completed.append(entry)
        
        // Act
        habit.checkAndUpdateStreak(on: today)
        
        // Assert
        XCTAssertEqual(habit.getStreak(), 4)
        XCTAssertEqual(habit.getMaxStreak(), 10, "maxStreak no debe cambiar")
    }
    
    // MARK: - Test de checkAndUpdateStreak - No completado en dia esperado
    
    func testCheckAndUpdateStreak_NotCompletedOnExpectedDay_ResetsStreak() {
        // Arrange
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let habit = Habit(title: "Test", frequency: [Weekday.from(date: today)])
        
        habit.setNextDay(today)
        habit.setStreak(5)
        
        // No agregar CompletionEntry (no completado)
        
        // Act
        habit.checkAndUpdateStreak(on: today)
        
        // Assert
        XCTAssertEqual(habit.getStreak(), 0, "La racha debe resetearse")
        XCTAssertNotNil(habit.getNextDay())
    }
    
    // MARK: - Test de checkAndUpdateStreak - Día perdido
    
    func testCheckAndUpdateStreak_MissedDay_ResetsStreak() {
        // Arrange
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let habit = Habit(title: "Test", frequency: [Weekday.from(date: yesterday)])
        
        habit.setNextDay(yesterday)
        habit.setStreak(3)
        
        // Act (verificar hoy, pero el dia esperado fue ayer)
        habit.checkAndUpdateStreak(on: today)
        
        // Assert
        XCTAssertEqual(habit.getStreak(), 0, "La racha debe resetearse por dia perdido")
    }
    
    // MARK: - Test de valores extremos
    
    func testStreak_LargeValues() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Act
        habit.setStreak(1000)
        habit.setMaxStreak(5000)
        
        // Assert
        XCTAssertEqual(habit.getStreak(), 1000)
        XCTAssertEqual(habit.getMaxStreak(), 5000)
    }
    
    func testStreak_NegativeValues() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Act
        habit.setStreak(-5)
        
        // Assert
        // Debería permitir valores negativos (aunque no tenga sentido logicamente)
        XCTAssertEqual(habit.getStreak(), -5)
    }
    
    // MARK: - Test de multiples actualizaciones
    
    func testMultipleStreakUpdates() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Act
        habit.setStreak(1)
        habit.setStreak(2)
        habit.setStreak(3)
        habit.setStreak(4)
        habit.setStreak(5)
        
        // Assert
        XCTAssertEqual(habit.getStreak(), 5)
    }
    
    func testStreakReset_MultipleTimes() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Act & Assert
        habit.setStreak(10)
        XCTAssertEqual(habit.getStreak(), 10)
        
        habit.setStreak(0)
        XCTAssertEqual(habit.getStreak(), 0)
        
        habit.setStreak(5)
        XCTAssertEqual(habit.getStreak(), 5)
        
        habit.setStreak(0)
        XCTAssertEqual(habit.getStreak(), 0)
    }
    
    // MARK: - Test de integracion con Habit
    
    func testStreak_PersistsAcrossAccess() {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Act
        habit.setStreak(7)
        let firstRead = habit.getStreak()
        let secondRead = habit.getStreak()
        
        // Assert
        XCTAssertEqual(firstRead, 7)
        XCTAssertEqual(secondRead, 7)
    }
    
    func testHabitStreakFeature_IdIsUnique() {
        // Arrange & Act
        let feature1 = HabitStreakFeature(habitId: UUID())
        let feature2 = HabitStreakFeature(habitId: UUID())
        
        // Assert
        XCTAssertNotEqual(feature1.id, feature2.id)
    }
}




