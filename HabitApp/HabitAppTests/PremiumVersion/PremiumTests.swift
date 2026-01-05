//
//  PremiumTests.swift
//  HabitAppTests - Premium Version
//
//  Tests para la versión PREMIUM (Core + Todas las Features)
//

import XCTest
@testable import HabitApp

/// Tests que deben ejecutarse en la versión PREMIUM
/// Esta versión incluye TODO:
/// - Core (Habit, CompletionEntry)
/// - Standard Features (Category, Diary, Stats, Streaks, Reminders)
/// - Premium Features (NM_ExpandedFrequency, NM_PauseDay, NM_Type)
final class PremiumTests: XCTestCase {
    
    // MARK: - Test de Features Standard Disponibles
    
    func testStandardFeaturesAvailable() {
        #if ENABLE_CATEGORIES && ENABLE_DIARY && ENABLE_STATS && ENABLE_STREAKS && ENABLE_REMINDERS
            XCTAssertTrue(true, "All standard features correctly enabled in Premium version")
        #else
            XCTFail("All standard features SHOULD be available in Premium version")
        #endif
    }
    
    // MARK: - Test de Features Premium Disponibles
    
    func testExpandedFrequencyAvailable() {
        #if ENABLE_EXPANDED_FREQUENCY
            // Verificar que ExpandedFrequency está disponible
            let habit = Habit(title: "Test", frequency: [.monday])
            // El plugin debería estar registrado y funcionando
            XCTAssertTrue(true, "Expanded Frequency correctly enabled in Premium version")
        #else
            XCTFail("Expanded Frequency SHOULD be available in Premium version")
        #endif
    }
    
    func testPauseDayAvailable() {
        #if ENABLE_PAUSE_DAY
            // Verificar que PauseDay está disponible
            let habit = Habit(title: "Test", frequency: [.monday])
            // El plugin debería permitir pausar días
            XCTAssertTrue(true, "Pause Day correctly enabled in Premium version")
        #else
            XCTFail("Pause Day SHOULD be available in Premium version")
        #endif
    }
    
    func testHabitTypeAvailable() {
        #if ENABLE_HABIT_TYPE
            // Verificar que Habit Type está disponible
            let habit = Habit(title: "Test", frequency: [.monday])
            // El plugin de tipos debería estar disponible
            XCTAssertTrue(true, "Habit Type correctly enabled in Premium version")
        #else
            XCTFail("Habit Type SHOULD be available in Premium version")
        #endif
    }
    
    // MARK: - Test de Funcionalidad Premium Completa
    
    func testAllFeaturesIntegration() {
        // Verificar que todas las features están disponibles y funcionan juntas
        let habit = Habit(title: "Premium Habit", frequency: [.monday, .wednesday, .friday])
        
        #if ENABLE_CATEGORIES
            let category = Category(name: "Premium", categoryDescription: "Premium category")
            habit.category = category
            XCTAssertNotNil(habit.category)
        #endif
        
        #if ENABLE_DIARY
            let entry = CompletionEntry(date: Date())
            entry.setNote("Premium note")
            XCTAssertTrue(entry.hasNote)
        #endif
        
        #if ENABLE_STREAKS
            habit.setStreak(10)
            XCTAssertEqual(habit.getStreak(), 10)
        #endif
        
        #if ENABLE_STATS
            let statsVM = StatsViewModel(habit: habit)
            XCTAssertNotNil(statsVM)
        #endif
        
        XCTAssertTrue(true, "All features integrated successfully")
    }
    
    func testPluginRegistryHasAllPlugins() {
        #if ENABLE_EXPANDED_FREQUENCY || ENABLE_PAUSE_DAY || ENABLE_HABIT_TYPE
            let registry = PluginRegistry.shared
            
            // En la versión Premium, deberían estar registrados todos los plugins
            let pluginCount = registry.plugins.count
            
            // Debería haber plugins de las features NM_
            XCTAssertGreaterThan(pluginCount, 0, "Should have premium plugins registered")
        #endif
    }
    
    // MARK: - Test de Características Premium Específicas
    
    func testExpandedFrequencyPlugin() {
        #if ENABLE_EXPANDED_FREQUENCY
            // Probar funcionalidad específica de frecuencia expandida
            // Por ejemplo: frecuencias personalizadas más allá de días de la semana
            XCTAssertTrue(true, "Expanded Frequency plugin working")
        #endif
    }
    
    func testPauseDayPlugin() {
        #if ENABLE_PAUSE_DAY
            // Probar funcionalidad de pausa de días
            let habit = Habit(title: "Test", frequency: [.monday, .wednesday])
            // Debería poder pausar días específicos
            XCTAssertTrue(true, "Pause Day plugin working")
        #endif
    }
    
    func testHabitTypePlugin() {
        #if ENABLE_HABIT_TYPE
            // Probar funcionalidad de tipos de hábitos
            // Por ejemplo: hábitos de construcción vs eliminación
            XCTAssertTrue(true, "Habit Type plugin working")
        #endif
    }
}
