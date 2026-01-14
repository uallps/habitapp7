//
//  StandardUITests.swift
//  HabitAppStandardUITests
//
//  UI Tests para HabitApp Standard Version
//  Incluye: Core + Category + Stats + Diary + Reminders + Streaks
//  Excluye: Plugins NM_* (ExpandedFrequency, PauseDay, Type, Calendary, SuggestedHabit)
//

import XCTest

final class StandardUITests: UITestBase {
    
    override var launchArguments: [String] {
        return ["UI-Testing", "Standard-Version"]
    }
    
    var workflows: UIWorkflows {
        return UIWorkflows(app: app)
    }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Test de Lanzamiento
    
    func testAppLaunches() {
        assertAppIsRunning()
    }
    
    // MARK: - Test de Funcionalidad Básica Standard
    
    
    func testCreateBasicHabit() {
        let result = workflows.createBasicHabit(title: "Habito Standard")
        XCTAssertTrue(result, "Debe poder crear un habito basico")
    }
    
    func testToggleHabitCompletion() {
        // Primero crear un hábito con todos los días activos
        workflows.createBasicHabit(title: "Habito a Completar", activateAllFrequencyDays: true)
        
        // Luego marcarlo como completado
        let success = workflows.toggleFirstHabitCompletion()
        XCTAssertTrue(success, "Debe poder marcar habito como completado")
    }
    
    // MARK: - Test de Features Standard DISPONIBLES
    
    func testCategoryFeatureAvailable() {
        XCTAssertNotNil(findCategoryButton(), "Debe existir boton de categorias en Standard")
    }
    
    // MARK: - Test de Features Premium NO Disponibles
    
    func testExpandedFrequencyNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.expandedFrequency,
                                 message: "No debe haber frecuencia expandida en Standard")
    }
    
    func testPauseDayNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.pauseDay,
                                 message: "No debe haber funcion de pausa en Standard")
    }
    
    func testHabitTypeNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.habitType,
                                 message: "No debe haber selector de tipo en Standard")
    }
    
    func testCalendaryNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.calendary,
                                 message: "No debe haber calendario en Standard")
    }
    
    func testSuggestedHabitNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.suggestedHabit,
                                 message: "No debe haber habitos sugeridos en Standard")
    }
    
    
    // MARK: - Test de Performance
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
}
