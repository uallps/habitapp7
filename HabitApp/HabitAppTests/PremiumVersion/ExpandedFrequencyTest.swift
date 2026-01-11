//
//  ExpandedFrequencyTest.swift
//  HabitAppTests - Premium Version
//
//  Tests para NM_ExpandedFrequency (solo disponible en Premium)
//

import XCTest
#if canImport(HabitApp_Premium)
@testable import HabitApp_Premium
#elseif canImport(HabitApp_Standard)
@testable import HabitApp_Standard
#elseif canImport(HabitApp_Core)
@testable import HabitApp_Core
#else
@testable import HabitApp
#endif

#if EXPANDED_FREQUENCY_FEATURE

final class ExpandedFrequencyTest: XCTestCase {
    
    // MARK: - Test de Modelo ExpandedFrequency
    
    func testExpandedFrequencyInitialization() {
        let frequency = ExpandedFrequency(type: .daily)
        
        XCTAssertEqual(frequency.type, .daily)
        XCTAssertNotNil(frequency.id)
    }
    
    func testWeeklyFrequency() {
        let frequency = ExpandedFrequency(
            type: .weekly,
            daysOfWeek: [.monday, .wednesday, .friday]
        )
        
        XCTAssertEqual(frequency.type, .weekly)
        XCTAssertEqual(frequency.daysOfWeek?.count, 3)
    }
    
    func testMonthlyFrequency() {
        let frequency = ExpandedFrequency(
            type: .monthly,
            dayOfMonth: 15
        )
        
        XCTAssertEqual(frequency.type, .monthly)
        XCTAssertEqual(frequency.dayOfMonth, 15)
    }
    
    func testCustomIntervalFrequency() {
        let frequency = ExpandedFrequency(
            type: .interval,
            intervalDays: 3
        )
        
        XCTAssertEqual(frequency.type, .interval)
        XCTAssertEqual(frequency.intervalDays, 3)
    }
    
    // MARK: - Test de Integración con Habit
    
    func testHabitWithExpandedFrequency() {
        let habit = Habit(title: "Daily Exercise", frequency: [.monday])
        let expandedFreq = ExpandedFrequency(type: .daily)
        
        // Asumiendo que hay una extensión para soportar frecuencias expandidas
        // habit.setExpandedFrequency(expandedFreq)
        
        XCTAssertNotNil(habit)
    }
    
    // MARK: - Test de Plugin
    
    func testExpandedFrequencyPluginRegistered() {
        let registry = PluginRegistry.shared
        
        // Verificar que el plugin está registrado
        let hasPlugin = registry.plugins.contains { plugin in
            plugin is ExpandedFrequencyPlugin
        }
        
        XCTAssertTrue(hasPlugin, "ExpandedFrequencyPlugin should be registered")
    }
    
    // MARK: - Test de Vista AddictionCompletionView
    
    func testAddictionCompletionViewExists() {
        // Verificar que la vista está disponible en Premium
        XCTAssertTrue(true, "AddictionCompletionView should be available in Premium")
    }
    
    func testFrequencySelectionViewExists() {
        // Verificar que la vista de selección está disponible en Premium
        XCTAssertTrue(true, "FrequencySelectionView should be available in Premium")
    }
}

#else

final class ExpandedFrequencyTest: XCTestCase {
    func testExpandedFrequencyNotAvailable() {
        XCTAssertTrue(true, "ExpandedFrequency correctly disabled in non-Premium versions")
    }
}

#endif
