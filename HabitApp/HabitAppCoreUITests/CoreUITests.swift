//
//  CoreUITests.swift
//  HabitAppCoreUITests
//
//  UI Tests para HabitApp Core Version
//

import XCTest

final class CoreUITests: UITestBase {
    
    override var launchArguments: [String] {
        return ["UI-Testing", "Core-Version"]
    }
    
    var workflows: UIWorkflows {
        return UIWorkflows(app: app)
    }
    
    override func setUp() {
        super.setUp()
        // Configurar la app para que termine rápidamente si hay problemas
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Limpiar después de cada test
        // La app ya habrá terminado en el super.tearDown()
        super.tearDown()
    }
    
    // MARK: - Test de Lanzamiento
    
    func testAppLaunches() {
        assertAppIsRunning()
    }
    
    
    
    // MARK: - Test de Funcionalidad Básica Core
    
    
    
    func testCreateBasicHabit() {
        let result = workflows.createBasicHabit(title: "Habito Basico")
        XCTAssertTrue(result, "Debe poder crear un habito basico")
    }
    
    func testToggleHabitCompletion() {
        workflows.toggleFirstHabitCompletion()
    }
    
    // MARK: - Test de Features NO Disponibles en Core
    
    func testCategoryFeatureNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.category,
                                 message: "No debe haber categorías en Core")
    }
    
    func testStatsFeatureNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.stats,
                                 message: "No debe haber estadísticas en Core")
    }
    
    func testDiaryFeatureNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.diary,
                                 message: "No debe haber diario en Core")
    }
    
    // MARK: - Test de Performance
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
}
