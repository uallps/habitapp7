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
    
    // MARK: - Test de Lanzamiento
    
    func testAppLaunches() {
        assertAppIsRunning()
    }
    
    func testNavigationBarExists() {
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.exists, "La barra de navegación debe existir")
    }
    
    // MARK: - Test de Funcionalidad Básica Core
    
    func testHabitListViewExists() {
        XCTAssertTrue(app.habitListView.waitForExistence(timeout: 5), 
                     "Debe aparecer la vista de lista de hábitos")
    }
    
    func testCreateBasicHabit() {
        XCTAssertTrue(workflows.createBasicHabit(title: "Habito Basico"),
                     "Debe poder crear un habito basico")
        
        XCTAssertTrue(app.habitListView.waitForExistence(timeout: 3),
                     "Debe volver a la vista principal")
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
