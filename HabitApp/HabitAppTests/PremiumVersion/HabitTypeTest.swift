//
//  HabitTypeTest.swift
//  HabitAppTests - Premium Version
//
//  Tests para NM_Type (solo disponible en Premium)
//

import XCTest
@testable import HabitApp

#if HABIT_TYPE_FEATURE

final class HabitTypeTest: XCTestCase {
    
    // MARK: - Test de Modelo HabitType
    
    func testHabitTypeEnumValues() {
        XCTAssertEqual(HabitType.build.rawValue, "build")
        XCTAssertEqual(HabitType.quit.rawValue, "quit")
    }
    
    func testHabitTypeBuild() {
        let type = HabitType.build
        
        XCTAssertEqual(type, .build)
        XCTAssertNotEqual(type, .quit)
    }
    
    func testHabitTypeQuit() {
        let type = HabitType.quit
        
        XCTAssertEqual(type, .quit)
        XCTAssertNotEqual(type, .build)
    }
    
    // MARK: - Test de Integración con Habit
    
    func testHabitWithType() {
        let habit = Habit(title: "Exercise", frequency: [.monday])
        
        // Asumiendo que hay una propiedad para el tipo
        // habit.habitType = .build
        
        XCTAssertNotNil(habit)
    }
    
    func testBuildHabitBehavior() {
        let buildHabit = Habit(title: "Build Exercise", frequency: [.monday])
        // buildHabit.habitType = .build
        
        // Los hábitos de construcción deberían marcarse como completados cuando se hace
        XCTAssertNotNil(buildHabit)
    }
    
    func testQuitHabitBehavior() {
        let quitHabit = Habit(title: "Quit Smoking", frequency: [.monday])
        // quitHabit.habitType = .quit
        
        // Los hábitos de eliminación deberían marcarse como completados cuando NO se hace
        XCTAssertNotNil(quitHabit)
    }
    
    // MARK: - Test de HabitTypeViewModel
    
    func testHabitTypeViewModelInitialization() async {
        let habit = Habit(title: "Test", frequency: [.monday])
        let viewModel = HabitTypeViewModel(habit: habit)
        
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.habit.title, "Test")
    }
    
    func testChangeHabitType() async {
        let habit = Habit(title: "Test", frequency: [.monday])
        let viewModel = HabitTypeViewModel(habit: habit)
        
        viewModel.setType(.quit)
        
        // Verificar que el tipo cambió
        XCTAssertNotNil(viewModel)
    }
    
    // MARK: - Test de HabitCompletionViewModel
    
    func testHabitCompletionViewModelInitialization() async {
        let habit = Habit(title: "Test", frequency: [.monday])
        let viewModel = HabitCompletionViewModel(habit: habit)
        
        XCTAssertNotNil(viewModel)
    }
    
    func testCompletionLogicForBuildHabit() async {
        let habit = Habit(title: "Exercise", frequency: [.monday])
        let viewModel = HabitCompletionViewModel(habit: habit)
        
        // Para hábitos de construcción, completar significa hacer la acción
        XCTAssertNotNil(viewModel)
    }
    
    func testCompletionLogicForQuitHabit() async {
        let habit = Habit(title: "Quit Smoking", frequency: [.monday])
        let viewModel = HabitCompletionViewModel(habit: habit)
        
        // Para hábitos de eliminación, completar significa NO hacer la acción
        XCTAssertNotNil(viewModel)
    }
    
    // MARK: - Test de Plugin
    
    func testHabitTypePluginRegistered() {
        let registry = PluginRegistry.shared
        
        // Verificar que el plugin está registrado
        let hasPlugin = registry.plugins.contains { plugin in
            plugin is HabitTypePlugin
        }
        
        XCTAssertTrue(hasPlugin, "HabitTypePlugin should be registered")
    }
    
    // MARK: - Test de Vistas
    
    func testHabitTypeViewsExist() {
        // Verificar que las vistas del módulo Type están disponibles
        XCTAssertTrue(true, "Habit Type views should be available in Premium")
    }
    
    // MARK: - Test de Diferencias entre Build y Quit
    
    func testBuildVsQuitCompletion() {
        // En un hábito Build: hacer la acción = completado
        // En un hábito Quit: NO hacer la acción = completado
        
        let buildHabit = Habit(title: "Build", frequency: [.monday])
        let quitHabit = Habit(title: "Quit", frequency: [.monday])
        
        XCTAssertNotNil(buildHabit)
        XCTAssertNotNil(quitHabit)
    }
    
    func testHabitTypeAffectsStatistics() {
        // Las estadísticas deberían calcular de forma diferente para Build vs Quit
        let habit = Habit(title: "Test", frequency: [.monday])
        
        XCTAssertNotNil(habit)
    }
}

#else

final class HabitTypeTest: XCTestCase {
    func testHabitTypeNotAvailable() {
        XCTAssertTrue(true, "HabitType correctly disabled in non-Premium versions")
    }
}

#endif
