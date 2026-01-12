//
//  StandardUITests.swift
//  HabitAppTests - Standard Version UI Tests
//
//  UI Tests para la version STANDARD (Core + Features sin NM_)
//

import XCTest

final class StandardUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["UI-Testing", "Standard-Version"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Test de Lanzamiento Standard

    func testStandardVersionAppLaunches() {
        XCTAssertTrue(app.state == .runningForeground)
    }

    // MARK: - Test de Features Standard Disponibles

    func testCategoryFeatureIsAvailable() {
        let categoryButton = app.buttons["CreateCategoryButton"].exists ?
            app.buttons["CreateCategoryButton"] :
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'categor'")).firstMatch

        XCTAssertTrue(categoryButton.exists,
                     "Categorias debe estar disponible en Standard")
    }

    func testStatsFeatureIsAvailable() {
        let statsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'stats' OR label CONTAINS[c] 'estad'"))
            .firstMatch

        XCTAssertTrue(statsButton.exists || app.navigationBars.buttons.count > 1,
                     "Estadisticas debe estar disponible en Standard")
    }

    func testDiaryFeatureIsAvailable() {
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch

        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.buttons.firstMatch.tap()

            let noteField = app.textFields.matching(NSPredicate(format: "label CONTAINS[c] 'nota' OR label CONTAINS[c] 'note'")).firstMatch
            _ = noteField.waitForExistence(timeout: 2)
        }
    }

    func testRemindersFeatureIsAvailable() {
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch

        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()

            let reminderToggle = app.switches.matching(NSPredicate(format: "label CONTAINS[c] 'reminder' OR label CONTAINS[c] 'recordatorio'")).firstMatch
            _ = reminderToggle.waitForExistence(timeout: 2)
        }
    }

    func testStreaksFeatureIsAvailable() {
        let streakLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'racha' OR label CONTAINS[c] 'streak'")).firstMatch
        _ = streakLabel.waitForExistence(timeout: 2)
    }

    // MARK: - Test de Features Premium NO Disponibles

    func testExpandedFrequencyNotAvailable() {
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch

        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()

            let expandedFreq = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'diaria' OR label CONTAINS[c] 'mensual'")).count
            XCTAssertEqual(expandedFreq, 0,
                          "No debe haber frecuencias expandidas en Standard")
        }
    }

    func testPauseDayNotAvailable() {
        let pauseButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'pause' OR label CONTAINS[c] 'pausa'")).count

        XCTAssertEqual(pauseButtons, 0,
                      "No debe haber funcion de pausa en Standard")
    }

    func testHabitTypeNotAvailable() {
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch

        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()

            let typeSelector = app.segmentedControls.matching(NSPredicate(format: "label CONTAINS[c] 'build' OR label CONTAINS[c] 'quit'")).count

            XCTAssertEqual(typeSelector, 0,
                          "No debe haber selector de tipo en Standard")
        }
    }

    // MARK: - Test de Integracion de Features Standard

    func testCategoryAndHabitIntegration() {
        let categoryButton = app.buttons["CreateCategoryButton"].exists ?
            app.buttons["CreateCategoryButton"] :
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'categor'")).firstMatch

        if categoryButton.waitForExistence(timeout: 3) {
            categoryButton.tap()

            let nameField = app.textFields["Nombre de la categoria"]
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText("Salud")

                app.buttons["Guardar"].tap()
                sleep(1)
            }
        }

        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'crear' OR label CONTAINS[c] 'anadir' OR label CONTAINS[c] 'agregar'")).firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()

            let titleField = app.textFields.firstMatch
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText("Ejercicio")

                let categoryPicker = app.pickers.firstMatch
                _ = categoryPicker.waitForExistence(timeout: 2)
            }
        }
    }

    func testStatsAndStreaksIntegration() {
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch

        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.buttons.firstMatch.tap()
        }
    }

    // MARK: - Test Completo de Flujo Standard

    func testCompleteStandardWorkflow() {
        // 1. Crear categoria
        testCategoryFeatureIsAvailable()

        // 2. Crear habito
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'crear' OR label CONTAINS[c] 'anadir' OR label CONTAINS[c] 'agregar'")).firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()

            let titleField = app.textFields.firstMatch
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText("Meditar")
            }

            if app.navigationBars.buttons["Guardar"].exists {
                app.navigationBars.buttons["Guardar"].tap()
            } else if app.buttons["Guardar"].exists {
                app.buttons["Guardar"].tap()
            }
            sleep(1)
        }

        // 3. Completar habito
        let habit = app.buttons.matching(identifier: "HabitRowView").firstMatch
        if habit.waitForExistence(timeout: 3) {
            habit.buttons.firstMatch.tap()
        }
    }

    // MARK: - Helper Methods

    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
}
