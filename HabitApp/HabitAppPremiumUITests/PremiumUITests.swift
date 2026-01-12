//
//  PremiumUITests.swift
//  HabitAppPremiumUITests
//
//  UI Tests para la version PREMIUM (todas las features)
//

import XCTest

final class PremiumUITests: UITestBase {
    
    override var launchArguments: [String] {
        return ["UI-Testing", "Premium-Version"]
    }
    
    var workflows: UIWorkflows {
        return UIWorkflows(app: app)
    }

    // MARK: - Test de Lanzamiento Premium

    func testPremiumVersionAppLaunches() {
        assertAppIsRunning()
    }

    // MARK: - Test de Features Premium Disponibles

    func testAllStandardFeaturesAvailable() {
        XCTAssertNotNil(findCategoryButton(), "Categorias debe estar en Premium")
    }

    func testExpandedFrequencyIsAvailable() {
        if let addButton = app.addButton, addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            assertFeatureAvailable(keywords: UIPredicates.expandedFrequency,
                                  message: "Debe haber opciones de frecuencia expandida")
        }
    }

    func testPauseDayIsAvailable() {
        if app.firstHabit.waitForExistence(timeout: 3) {
            app.firstHabit.tap()
            assertFeatureAvailable(keywords: UIPredicates.pauseDay,
                                  message: "Debe haber funcion de pausa en Premium")
        }
    }

    func testHabitTypeIsAvailable() {
        if let addButton = app.addButton, addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            assertFeatureAvailable(keywords: UIPredicates.habitType,
                                  message: "Debe haber selector de tipo en Premium")
        }
    }

    // MARK: - Test de ExpandedFrequency UI

    func testCreateHabitWithDailyFrequency() {
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'crear' OR label CONTAINS[c] 'anadir' OR label CONTAINS[c] 'agregar'")).firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()

            let titleField = app.textFields.firstMatch
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText("Habito Diario")
            }

            let frequencyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'frecuencia'")).firstMatch
            if frequencyButton.waitForExistence(timeout: 3) {
                frequencyButton.tap()

                let dailyOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'diaria'")).firstMatch
                if dailyOption.exists {
                    dailyOption.tap()
                }
        XCTAssertTrue(workflows.createHabitWithExpandedFrequency(title: "Habito Diario", frequency: "diaria"),
                     "Debe poder crear habito con frecuencia diaria")
    }

    func testCreateHabitWithMonthlyFrequency() {
        XCTAssertTrue(workflows.createHabitWithExpandedFrequency(title: "Habito Mensual", frequency: "mensual"),
                     "Debe poder crear habito con frecuencia mensual")
    }

    // MARK: - Test de PauseDay UI

    func testPauseAndResumeDay() {
        XCTAssertTrue(workflows.pauseFirstHabit(),
                     "Debe poder pausar un habito")
    }

    // MARK: - Test de HabitType UI

    func testCreateBuildTypeHabit() {
        guard let addButton = app.addButton, addButton.waitForExistence(timeout: 3) else {
            XCTFail("No se encontro boton de añadir")
            return
        }
        
        addButton.tap()
        
        let titleField = app.habitTitleField
        if titleField.waitForExistence(timeout: 2) {
            typeText(in: titleField, text: "Construir: Ejercicio")
        }
        
        let typeSegment = app.segmentedControls.firstMatch
        if typeSegment.waitForExistence(timeout: 3) {
            let buildButton = typeSegment.buttons["Build"]
            if buildButton.exists {
                buildButton.tap()
            }
        }
        
        saveCurrentForm()
    }

    func testCreateQuitTypeHabit() {
        guard let addButton = app.addButton, addButton.waitForExistence(timeout: 3) else {
            XCTFail("No se encontro boton de añadir")
            return
        }
        
        addButton.tap()
        
        let titleField = app.habitTitleField
        if titleField.waitForExistence(timeout: 2) {
            typeText(in: titleField, text: "Dejar: Fumar")
        }
        
        let typeSegment = app.segmentedControls.firstMatch
        if typeSegment.waitForExistence(timeout: 3) {
            let quitButton = typeSegment.buttons["Quit"]
            if quitButton.exists {
                quitButton.tap()
            }
        }
        
        saveCurrentForm()
    }

    // MARK: - Test Completo de Flujo Premium

    func testCompletePremiumWorkflow() {
        testCreateHabitWithMonthlyFrequency(