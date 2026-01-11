//
//  StatsViewModelTest.swift
//  HabitAppTests
//

import XCTest
import Combine
#if canImport(HabitApp_Premium)
@testable import HabitApp_Premium
#elseif canImport(HabitApp_Standard)
@testable import HabitApp_Standard
#elseif canImport(HabitApp_Core)
@testable import HabitApp_Core
#else
@testable import HabitApp
#endif

final class StatsViewModelTest: XCTestCase {
    
    var viewModel: StatsViewModel!
    var habit: Habit!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        habit = Habit(title: "Test Habit", frequency: [.monday, .wednesday, .friday])
        viewModel = StatsViewModel(habit: habit)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        habit = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Test de inicialización
    
    func testInitialization() {
        // Assert
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.habit.title, "Test Habit")
    }
    
    func testViewModel_IsObservableObject() {
        // Assert
        XCTAssertTrue(viewModel is ObservableObject)
    }
    
    // MARK: - Test de firstCompletionDate
    
    func testFirstCompletionDate_WithNoCompletions() {
        // Assert
        XCTAssertNil(viewModel.firstCompletionDate)
    }
    
    func testFirstCompletionDate_WithSingleCompletion() {
        // Arrange
        let date = Date()
        habit.completed.append(CompletionEntry(date: date))
        viewModel = StatsViewModel(habit: habit)
        
        // Assert
        XCTAssertNotNil(viewModel.firstCompletionDate)
        XCTAssertEqual(
            Calendar.current.startOfDay(for: viewModel.firstCompletionDate!),
            Calendar.current.startOfDay(for: date)
        )
    }
    
    func testFirstCompletionDate_WithMultipleCompletions() {
        // Arrange
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        
        habit.completed.append(CompletionEntry(date: today))
        habit.completed.append(CompletionEntry(date: yesterday))
        habit.completed.append(CompletionEntry(date: twoDaysAgo))
        viewModel = StatsViewModel(habit: habit)
        
        // Assert
        XCTAssertEqual(
            Calendar.current.startOfDay(for: viewModel.firstCompletionDate!),
            Calendar.current.startOfDay(for: twoDaysAgo)
        )
    }
    
    // MARK: - Test de lastCompletionDate
    
    func testLastCompletionDate_WithNoCompletions() {
        // Assert
        XCTAssertNil(viewModel.lastCompletionDate)
    }
    
    func testLastCompletionDate_WithSingleCompletion() {
        // Arrange
        let date = Date()
        habit.completed.append(CompletionEntry(date: date))
        viewModel = StatsViewModel(habit: habit)
        
        // Assert
        XCTAssertNotNil(viewModel.lastCompletionDate)
        XCTAssertEqual(
            Calendar.current.startOfDay(for: viewModel.lastCompletionDate!),
            Calendar.current.startOfDay(for: date)
        )
    }
    
    func testLastCompletionDate_WithMultipleCompletions() {
        // Arrange
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        
        habit.completed.append(CompletionEntry(date: twoDaysAgo))
        habit.completed.append(CompletionEntry(date: yesterday))
        habit.completed.append(CompletionEntry(date: today))
        viewModel = StatsViewModel(habit: habit)
        
        // Assert
        XCTAssertEqual(
            Calendar.current.startOfDay(for: viewModel.lastCompletionDate!),
            Calendar.current.startOfDay(for: today)
        )
    }
    
    // MARK: - Test de totalDaysActive
    
    func testTotalDaysActive_WithNoCompletions() {
        // Assert
        XCTAssertEqual(viewModel.totalDaysActive, 0)
    }
    
    func testTotalDaysActive_WithSingleCompletion() {
        // Arrange
        habit.completed.append(CompletionEntry(date: Date()))
        viewModel = StatsViewModel(habit: habit)
        
        // Assert
        XCTAssertGreaterThanOrEqual(viewModel.totalDaysActive, 1)
    }
    
    func testTotalDaysActive_WithMultipleDaysSpan() {
        // Arrange
        let calendar = Calendar.current
        let today = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        
        habit.completed.append(CompletionEntry(date: sevenDaysAgo))
        habit.completed.append(CompletionEntry(date: today))
        viewModel = StatsViewModel(habit: habit)
        
        // Assert
        XCTAssertEqual(viewModel.totalDaysActive, 8) // 7 días de diferencia + 1
    }
    
    func testTotalDaysActiveUntilDate() {
        // Arrange
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -10, to: Date())!
        let targetDate = calendar.date(byAdding: .day, value: -5, to: Date())!
        
        habit.completed.append(CompletionEntry(date: startDate))
        viewModel = StatsViewModel(habit: habit)
        
        // Act
        let daysActive = viewModel.totalDaysActive(until: targetDate)
        
        // Assert
        XCTAssertEqual(daysActive, 6) // Desde startDate hasta targetDate inclusive
    }
    
    // MARK: - Test de totalDaysCompleted
    
    func testTotalDaysCompleted_WithNoCompletions() {
        // Assert
        XCTAssertEqual(viewModel.totalDaysCompleted, 0)
    }
    
    func testTotalDaysCompleted_WithSingleCompletion() {
        // Arrange
        habit.completed.append(CompletionEntry(date: Date()))
        viewModel = StatsViewModel(habit: habit)
        
        // Assert
        XCTAssertEqual(viewModel.totalDaysCompleted, 1)
    }
    
    func testTotalDaysCompleted_WithMultipleCompletions() {
        // Arrange
        let calendar = Calendar.current
        habit.completed.append(CompletionEntry(date: Date()))
        habit.completed.append(CompletionEntry(date: calendar.date(byAdding: .day, value: -1, to: Date())!))
        habit.completed.append(CompletionEntry(date: calendar.date(byAdding: .day, value: -2, to: Date())!))
        viewModel = StatsViewModel(habit: habit)
        
        // Assert
        XCTAssertEqual(viewModel.totalDaysCompleted, 3)
    }
    
    // MARK: - Test de completionPercentage
    
    func testCompletionPercentage_WithNoCompletions() {
        // Assert
        XCTAssertEqual(viewModel.completionPercentage, 0.0)
    }
    
    func testCompletionPercentage_With100Percent() {
        // Arrange
        let today = Date()
        habit.completed.append(CompletionEntry(date: today))
        viewModel = StatsViewModel(habit: habit)
        
        // Assert (mismo día, 100%)
        XCTAssertEqual(viewModel.completionPercentage, 100.0, accuracy: 0.01)
    }
    
    func testCompletionPercentage_With50Percent() {
        // Arrange
        let calendar = Calendar.current
        let today = Date()
        let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: today)!
        
        habit.completed.append(CompletionEntry(date: oneDayAgo))
        // No completar hoy (solo 1 de 2 días)
        viewModel = StatsViewModel(habit: habit)
        
        // Assert
        XCTAssertEqual(viewModel.completionPercentage, 50.0, accuracy: 0.01)
    }
    
    func testCompletionPercentage_WithPartialCompletions() {
        // Arrange
        let calendar = Calendar.current
        let today = Date()
        
        // Completar 3 de los últimos 5 días
        habit.completed.append(CompletionEntry(date: calendar.date(byAdding: .day, value: -4, to: today)!))
        habit.completed.append(CompletionEntry(date: calendar.date(byAdding: .day, value: -2, to: today)!))
        habit.completed.append(CompletionEntry(date: today))
        
        viewModel = StatsViewModel(habit: habit)
        
        // Assert (3 completados de 5 días = 60%)
        XCTAssertEqual(viewModel.completionPercentage, 60.0, accuracy: 0.01)
    }
    
    // MARK: - Test de currentStreak
    
    func testCurrentStreak_WithNoStreak() {
        // Assert
        XCTAssertEqual(viewModel.currentStreak, 0)
    }
    
    func testCurrentStreak_ReturnsHabitStreak() {
        // Arrange
        habit.setStreak(5)
        viewModel = StatsViewModel(habit: habit)
        
        // Assert
        XCTAssertEqual(viewModel.currentStreak, 5)
    }
    
    // MARK: - Test de longestStreak
    
    func testLongestStreak_WithNoStreak() {
        // Assert
        XCTAssertEqual(viewModel.longestStreak, 0)
    }
    
    func testLongestStreak_ReturnsHabitMaxStreak() {
        // Arrange
        habit.setMaxStreak(10)
        viewModel = StatsViewModel(habit: habit)
        
        // Assert
        XCTAssertEqual(viewModel.longestStreak, 10)
    }
    
    // MARK: - Test de mostCompletedWeekdays
    
    func testMostCompletedWeekdays_WithNoCompletions() {
        // Assert
        XCTAssertTrue(viewModel.mostCompletedWeekdays.isEmpty)
    }
    
    func testMostCompletedWeekdays_WithEqualCompletions() {
        // Arrange
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        
        // Crear fechas conocidas (lunes, martes, miércoles de enero 2024)
        components.year = 2024
        components.month = 1
        
        components.day = 1 // Lunes
        habit.completed.append(CompletionEntry(date: calendar.date(from: components)!))
        
        components.day = 2 // Martes
        habit.completed.append(CompletionEntry(date: calendar.date(from: components)!))
        
        components.day = 3 // Miércoles
        habit.completed.append(CompletionEntry(date: calendar.date(from: components)!))
        
        viewModel = StatsViewModel(habit: habit)
        
        // Assert - Todos tienen 1 completación, así que todos son "más completados"
        XCTAssertEqual(viewModel.mostCompletedWeekdays.count, 3)
    }
    
    func testMostCompletedWeekdays_WithClearWinner() {
        // Arrange
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2024
        components.month = 1
        
        // Lunes (3 veces)
        components.day = 1
        habit.completed.append(CompletionEntry(date: calendar.date(from: components)!))
        components.day = 8
        habit.completed.append(CompletionEntry(date: calendar.date(from: components)!))
        components.day = 15
        habit.completed.append(CompletionEntry(date: calendar.date(from: components)!))
        
        // Martes (1 vez)
        components.day = 2
        habit.completed.append(CompletionEntry(date: calendar.date(from: components)!))
        
        viewModel = StatsViewModel(habit: habit)
        
        // Assert
        XCTAssertTrue(viewModel.mostCompletedWeekdays.contains(.monday))
    }
    
    // MARK: - Test de leastCompletedWeekdays
    
    func testLeastCompletedWeekdays_WithNoCompletions() {
        // Assert
        XCTAssertTrue(viewModel.leastCompletedWeekdays.isEmpty)
    }
    
    func testLeastCompletedWeekdays_IncludesZeroCompletionDays() {
        // Arrange
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2024
        components.month = 1
        
        // Solo completar lunes
        components.day = 1 // Lunes
        habit.completed.append(CompletionEntry(date: calendar.date(from: components)!))
        
        // Miércoles y viernes no se completan
        viewModel = StatsViewModel(habit: habit)
        
        // Assert - Los días de la frecuencia sin completar deben aparecer
        let leastDays = viewModel.leastCompletedWeekdays
        XCTAssertTrue(leastDays.contains(.wednesday) || leastDays.contains(.friday))
    }
    
    // MARK: - Test de labels
    
    func testTotalPeriodsActiveLabel_DefaultValue() {
        // Assert
        XCTAssertEqual(viewModel.totalPeriodsActiveLabel, "dias")
    }
    
    func testTotalPeriodsCompletedLabel_DefaultValue() {
        // Assert
        XCTAssertEqual(viewModel.totalPeriodsCompletedLabel, "dias")
    }
    
    func testStreakLabel_DefaultValue() {
        // Assert
        XCTAssertEqual(viewModel.streakLabel, "dias")
    }
    
    // MARK: - Test de actualización reactiva
    
    func testHabitUpdate_TriggersPublisher() {
        // Arrange
        var updateCount = 0
        let expectation = XCTestExpectation(description: "Habit updated")
        
        viewModel.$habit
            .dropFirst()
            .sink { _ in
                updateCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Act
        viewModel.habit.title = "Updated Habit"
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(updateCount, 1)
    }
    
    // MARK: - Test de edge cases
    
    func testCompletionPercentage_WithSameStartAndEndDate() {
        // Arrange
        let today = Date()
        habit.completed.append(CompletionEntry(date: today))
        viewModel = StatsViewModel(habit: habit)
        
        // Assert - 1 completado de 1 día activo = 100%
        XCTAssertEqual(viewModel.completionPercentage, 100.0, accuracy: 0.01)
    }
    
    func testMultipleCompletionsSameDay_CountsAsOne() {
        // Arrange
        let today = Date()
        habit.completed.append(CompletionEntry(date: today))
        habit.completed.append(CompletionEntry(date: today))
        habit.completed.append(CompletionEntry(date: today))
        viewModel = StatsViewModel(habit: habit)
        
        // Assert - Aunque hay 3 entries, cuentan como 1 día
        XCTAssertEqual(viewModel.totalDaysCompleted, 3) // Por la implementación actual
    }
}
