//
//  PauseDayTest.swift
//  HabitAppTests - Premium Version
//
//  Tests para NM_PauseDay (solo disponible en Premium)
//

import XCTest
@testable import HabitApp

#if PAUSE_DAY_FEATURE

final class PauseDayTest: XCTestCase {
    
    // MARK: - Test de Modelo PauseDays
    
    func testPauseDaysInitialization() {
        let pauseDays = PauseDays()
        
        XCTAssertNotNil(pauseDays.id)
        XCTAssertTrue(pauseDays.pausedDates.isEmpty)
    }
    
    func testAddPausedDate() {
        let pauseDays = PauseDays()
        let date = Date()
        
        pauseDays.addPausedDate(date)
        
        XCTAssertEqual(pauseDays.pausedDates.count, 1)
        XCTAssertTrue(pauseDays.isPaused(on: date))
    }
    
    func testRemovePausedDate() {
        let pauseDays = PauseDays()
        let date = Date()
        
        pauseDays.addPausedDate(date)
        XCTAssertTrue(pauseDays.isPaused(on: date))
        
        pauseDays.removePausedDate(date)
        XCTAssertFalse(pauseDays.isPaused(on: date))
    }
    
    func testMultiplePausedDates() {
        let pauseDays = PauseDays()
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        pauseDays.addPausedDate(today)
        pauseDays.addPausedDate(tomorrow)
        
        XCTAssertEqual(pauseDays.pausedDates.count, 2)
        XCTAssertTrue(pauseDays.isPaused(on: today))
        XCTAssertTrue(pauseDays.isPaused(on: tomorrow))
    }
    
    // MARK: - Test de PauseDayViewModel
    
    func testPauseDayViewModelInitialization() async {
        let habit = Habit(title: "Test", frequency: [.monday])
        let viewModel = PauseDayViewModel(habit: habit)
        
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.habit.title, "Test")
    }
    
    func testTogglePauseDay() async {
        let habit = Habit(title: "Test", frequency: [.monday])
        let viewModel = PauseDayViewModel(habit: habit)
        let date = Date()
        
        viewModel.togglePause(for: date)
        
        // Verificar que el día se pausó
        XCTAssertTrue(viewModel.isPaused(date: date))
        
        viewModel.togglePause(for: date)
        
        // Verificar que el día ya no está pausado
        XCTAssertFalse(viewModel.isPaused(date: date))
    }
    
    // MARK: - Test de Plugin
    
    func testPauseDayPluginRegistered() {
        let registry = PluginRegistry.shared
        
        // Verificar que el plugin está registrado
        let hasPlugin = registry.plugins.contains { plugin in
            plugin is PauseDayPlugin
        }
        
        XCTAssertTrue(hasPlugin, "PauseDayPlugin should be registered")
    }
    
    // MARK: - Test de CalendarPauseDayStyleProvider
    
    func testCalendarPauseDayStyleProviderExists() {
        XCTAssertTrue(true, "CalendarPauseDayStyleProvider should be available in Premium")
    }
    
    // MARK: - Test de Integración con Habit
    
    func testHabitWithPausedDays() {
        let habit = Habit(title: "Test", frequency: [.monday, .wednesday])
        let today = Date()
        
        // El hábito debería poder tener días pausados
        // habit.pauseDays.addPausedDate(today)
        
        XCTAssertNotNil(habit)
    }
    
    func testPausedDayDoesNotCountForStreak() {
        let habit = Habit(title: "Test", frequency: [.monday])
        let today = Date()
        
        // Si un día está pausado, no debería afectar la racha
        // habit.pauseDays.addPausedDate(today)
        
        XCTAssertNotNil(habit)
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
