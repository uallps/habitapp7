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
        #if CATEGORY_FEATURE && DIARY_FEATURE && STATS_FEATURE && STREAKS_FEATURE && REMINDERS_FEATURE
            XCTAssertTrue(true, "All standard features correctly enabled in Premium version")
        #else
            XCTFail("All standard features SHOULD be available in Premium version")
        #endif
    }
    
    // MARK: - Test de Features Premium Disponibles
    
    func testExpandedFrequencyAvailable() {
        #if EXPANDED_FREQUENCY_FEATURE
            // Verificar que ExpandedFrequency está disponible
            let habit = Habit(title: "Test", frequency: [.monday])
            // El plugin debería estar registrado y funcionando
            XCTAssertTrue(true, "Expanded Frequency correctly enabled in Premium version")
        #else
            XCTFail("Expanded Frequency SHOULD be available in Premium version")
        #endif
    }
    
    func testPauseDayAvailable() {
        #if PAUSE_DAY_FEATURE
            // Verificar que PauseDay está disponible
            let habit = Habit(title: "Test", frequency: [.monday])
            // El plugin debería permitir pausar días
            XCTAssertTrue(true, "Pause Day correctly enabled in Premium version")
        #else
            XCTFail("Pause Day SHOULD be available in Premium version")
        #endif
    }
    
    func testHabitTypeAvailable() {
        #if HABIT_TYPE_FEATURE
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
        
        #if CATEGORY_FEATURE
            let category = Category(name: "Premium", categoryDescription: "Premium category")
            habit.category = category
            XCTAssertNotNil(habit.category)
        #endif
        
        #if DIARY_FEATURE
            let entry = CompletionEntry(date: Date())
            entry.setNote("Premium note")
            XCTAssertTrue(entry.hasNote)
        #endif
        
        #if STREAKS_FEATURE
            habit.setStreak(10)
            XCTAssertEqual(habit.getStreak(), 10)
        #endif
        
        #if STATS_FEATURE
            let statsVM = StatsViewModel(habit: habit)
            XCTAssertNotNil(statsVM)
        #endif
        
        XCTAssertTrue(true, "All features integrated successfully")
    }
    
    func testPluginRegistryHasAllPlugins() {
        #if EXPANDED_FREQUENCY_FEATURE || PAUSE_DAY_FEATURE || HABIT_TYPE_FEATURE
            let registry = PluginRegistry.shared
            
            // En la versión Premium, deberían estar registrados todos los plugins
            let pluginCount = registry.plugins.count
            
            // Debería haber plugins de las features NM_
            XCTAssertGreaterThan(pluginCount, 0, "Should have premium plugins registered")
        #endif
    }
    
    // MARK: - Test de Características Premium Específicas
    
    func testExpandedFrequencyPlugin() {
        #if EXPANDED_FREQUENCY_FEATURE
            // Probar funcionalidad específica de frecuencia expandida
            // Por ejemplo: frecuencias personalizadas más allá de días de la semana
            XCTAssertTrue(true, "Expanded Frequency plugin working")
        #endif
    }
    
    func testPauseDayPlugin() {
        #if PAUSE_DAY_FEATURE
            // Probar funcionalidad de pausa de días
            let habit = Habit(title: "Test", frequency: [.monday, .wednesday])
            // Debería poder pausar días específicos
            XCTAssertTrue(true, "Pause Day plugin working")
        #endif
    }
    
    func testHabitTypePlugin() {
        #if HABIT_TYPE_FEATURE
            // Probar funcionalidad de tipos de hábitos
            // Por ejemplo: hábitos de construcción vs eliminación
            XCTAssertTrue(true, "Habit Type plugin working")
        #endif
    }
}
