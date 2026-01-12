//
//  UITestBase.swift
//  HabitAppTestsAux
//
//  Clase base compartida para todos los tests UI
//  IMPORTANTE: Este archivo debe agregarse a los Target Membership de:
//  - HabitAppCoreUITests
//  - HabitAppStandardUITests
//  - HabitAppPremiumUITests
//

import XCTest

/// Clase base para tests UI con funcionalidad común
class UITestBase: XCTestCase {
    
    var app: XCUIApplication!
    
    /// Override en subclases para especificar argumentos de launch específicos
    var launchArguments: [String] {
        return ["UI-Testing"]
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = launchArguments
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods Comunes
    
    /// Espera a que un elemento aparezca
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
    
    /// Encuentra un botón por múltiples criterios de búsqueda
    func findButton(matching predicates: [String]) -> XCUIElement? {
        for predicate in predicates {
            let button = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", predicate)).firstMatch
            if button.exists {
                return button
            }
        }
        return nil
    }
    
    /// Encuentra el botón de crear/añadir
    func findAddButton() -> XCUIElement? {
        return findButton(matching: ["crear", "añadir", "agregar", "add", "new"])
    }
    
    /// Encuentra el botón de guardar
    func findSaveButton() -> XCUIElement? {
        let navBarSave = app.navigationBars.buttons["Guardar"]
        if navBarSave.exists {
            return navBarSave
        }
        return app.buttons["Guardar"]
    }
    
    /// Encuentra el botón de categoría
    func findCategoryButton() -> XCUIElement? {
        // Buscar por identificador específico
        if app.buttons["CreateCategoryButton"].exists {
            return app.buttons["CreateCategoryButton"]
        }
        
        // Buscar por predicado
        let buttonsByLabel = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'categor'"))
        if buttonsByLabel.count > 0 {
            return buttonsByLabel.firstMatch
        }
        
        // Buscar en toolbar
        let toolbarButtons = app.toolbars.buttons
        for index in 0..<toolbarButtons.count {
            let button = toolbarButtons.element(boundBy: index)
            if button.label.lowercased().contains("categor") {
                return button
            }
        }
        
        // Buscar en navigation bar
        let navButtons = app.navigationBars.buttons
        for index in 0..<navButtons.count {
            let button = navButtons.element(boundBy: index)
            if button.label.lowercased().contains("categor") {
                return button
            }
        }
        
        return nil
    }
    
    /// Verifica que la app esté en primer plano
    func assertAppIsRunning() {
        XCTAssertTrue(app.state == .runningForeground, "La aplicación debe estar ejecutándose")
    }
    
    /// Verifica que exista la vista principal
    func assertMainViewExists() {
        let mainView = app.otherElements["HabitListView"]
        XCTAssertTrue(mainView.waitForExistence(timeout: 5), "La vista principal debe existir")
    }
    
    /// Tap en un texto field y escribe texto
    func typeText(in textField: XCUIElement, text: String) {
        textField.tap()
        sleep(1)
        textField.typeText(text)
    }
    
    /// Guarda el formulario actual
    func saveCurrentForm() {
        if let saveButton = findSaveButton() {
            saveButton.tap()
            sleep(1)
        }
    }
    
    // MARK: - Assertions de Features
    
    /// Verifica que una feature NO esté disponible buscando elementos relacionados
    func assertFeatureNotAvailable(keywords: [String], message: String) {
        var totalCount = 0
        
        for keyword in keywords {
            let buttons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", keyword)).count
            let texts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", keyword)).count
            totalCount += buttons + texts
        }
        
        XCTAssertEqual(totalCount, 0, message)
    }
    
    /// Verifica que una feature SÍ esté disponible
    func assertFeatureAvailable(keywords: [String], message: String) {
        var found = false
        
        for keyword in keywords {
            let buttons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", keyword))
            let texts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", keyword))
            
            if buttons.count > 0 || texts.count > 0 {
                found = true
                break
            }
        }
        
        XCTAssertTrue(found, message)
    }
}
