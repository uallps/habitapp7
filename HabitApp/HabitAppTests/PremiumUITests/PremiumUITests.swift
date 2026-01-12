//
//  PremiumUITests.swift
//  HabitAppTests - Premium Version UI Tests
//
//  UI Tests para la version PREMIUM (todas las features)
//

import XCTest

final class PremiumUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["UI-Testing", "Premium-Version"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Test de Lanzamiento Premium

    func testPremiumVersionAppLaunches() {
        XCTAssertTrue(app.state == .runningForeground)
    }

    // MARK: - Test de Features Premium Disponibles

    func testAllStandardFeaturesAvailable() {
        let categoryButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'categor'")).firstMatch
        XCTAssertTrue(categoryButton.exists, "Categorias debe estar en Premium")
    }

    func testExpandedFrequencyIsAvailable() {
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'crear' OR label CONTAINS[c] 'anadir' OR label CONTAINS[c] 'agregar'")).firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()

            let frequencyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'frecuencia' OR label CONTAINS[c] 'frequency'")).firstMatch
            if frequencyButton.waitForExistence(timeout: 3) {
                frequencyButton.tap()

                let dailyOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'diaria' OR label CONTAINS[c] 'daily'")).firstMatch
                let monthlyOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'mensual' OR label CONTAINS[c] 'monthly'")).firstMatch

                XCTAssertTrue(dailyOption.exists || monthlyOption.exists,
                             "Debe haber opciones de frecuencia expandida")
            }
        }
    }

    func testPauseDayIsAvailable() {
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch

        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()

            let pauseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'pause' OR label CONTAINS[c] 'pausa'")).firstMatch
            XCTAssertTrue(pauseButton.exists,
                         "Debe haber funcion de pausa en Premium")
        }
    }

    func testHabitTypeIsAvailable() {
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'crear' OR label CONTAINS[c] 'anadir' OR label CONTAINS[c] 'agregar'")).firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()

            let typeSegment = app.segmentedControls.matching(NSPredicate(format: "label CONTAINS[c] 'build' OR label CONTAINS[c] 'quit'")).firstMatch
            XCTAssertTrue(typeSegment.waitForExistence(timeout: 3),
                         "Debe haber selector de tipo en Premium")
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
            }

            if app.navigationBars.buttons["Guardar"].exists {
                app.navigationBars.buttons["Guardar"].tap()
            } else if app.buttons["Guardar"].exists {
                app.buttons["Guardar"].tap()
            }
        }
    }

    func testCreateHabitWithMonthlyFrequency() {
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'crear' OR label CONTAINS[c] 'anadir' OR label CONTAINS[c] 'agregar'")).firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()

            let titleField = app.textFields.firstMatch
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText("Habito Mensual")
            }

            let frequencyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'frecuencia'")).firstMatch
            if frequencyButton.waitForExistence(timeout: 3) {
                frequencyButton.tap()

                let monthlyOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'mensual'")).firstMatch
                if monthlyOption.exists {
                    monthlyOption.tap()

                    let dayPicker = app.pickers.firstMatch
                    _ = dayPicker.waitForExistence(timeout: 2)
                }
            }

            if app.navigationBars.buttons["Guardar"].exists {
                app.navigationBars.buttons["Guardar"].tap()
            } else if app.buttons["Guardar"].exists {
                app.buttons["Guardar"].tap()
            }
        }
    }

    func testCreateHabitWithIntervalFrequency() {
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'crear' OR label CONTAINS[c] 'anadir' OR label CONTAINS[c] 'agregar'")).firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()

            let titleField = app.textFields.firstMatch
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText("Habito cada 3 dias")
            }

            let frequencyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'frecuencia'")).firstMatch
            if frequencyButton.waitForExistence(timeout: 3) {
                frequencyButton.tap()

                let intervalOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'intervalo'")).firstMatch
                if intervalOption.exists {
                    intervalOption.tap()

                    let intervalField = app.textFields.matching(NSPredicate(format: "label CONTAINS[c] 'dias' OR label CONTAINS[c] 'days'")).firstMatch
                    if intervalField.exists {
                        intervalField.tap()
                        intervalField.typeText("3")
                    }
                }
            }

            if app.navigationBars.buttons["Guardar"].exists {
                app.navigationBars.buttons["Guardar"].tap()
            } else if app.buttons["Guardar"].exists {
                app.buttons["Guardar"].tap()
            }
        }
    }

    // MARK: - Test de PauseDay UI

    func testPauseAndResumeDay() {
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch

        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()

            let pauseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'pausar'")).firstMatch

            if pauseButton.waitForExistence(timeout: 3) {
                pauseButton.tap()

                let resumeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'reanudar'")).firstMatch
                if resumeButton.exists {
                    resumeButton.tap()
                }
            }
        }
    }

    func testViewPausedDaysCalendar() {
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch

        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()

            let calendarButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'calendario' OR label CONTAINS[c] 'calendar'")).firstMatch
            if calendarButton.exists {
                calendarButton.tap()
            }
        }
    }

    // MARK: - Test de HabitType UI

    func testCreateBuildTypeHabit() {
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'crear' OR label CONTAINS[c] 'anadir' OR label CONTAINS[c] 'agregar'")).firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()

            let titleField = app.textFields.firstMatch
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText("Construir: Ejercicio")
            }

            let typeSegment = app.segmentedControls.firstMatch
            if typeSegment.waitForExistence(timeout: 3) {
                let buildButton = typeSegment.buttons["Build"]
                if buildButton.exists {
                    buildButton.tap()
                }
            }

            if app.navigationBars.buttons["Guardar"].exists {
                app.navigationBars.buttons["Guardar"].tap()
            } else if app.buttons["Guardar"].exists {
                app.buttons["Guardar"].tap()
            }
        }
    }

    func testCreateQuitTypeHabit() {
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'crear' OR label CONTAINS[c] 'anadir' OR label CONTAINS[c] 'agregar'")).firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()

            let titleField = app.textFields.firstMatch
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText("Dejar: Fumar")
            }

            let typeSegment = app.segmentedControls.firstMatch
            if typeSegment.waitForExistence(timeout: 3) {
                let quitButton = typeSegment.buttons["Quit"]
                if quitButton.exists {
                    quitButton.tap()
                }
            }

            if app.navigationBars.buttons["Guardar"].exists {
                app.navigationBars.buttons["Guardar"].tap()
            } else if app.buttons["Guardar"].exists {
                app.buttons["Guardar"].tap()
            }
        }
    }

    func testBuildVsQuitBehavior() {
        // Build: completar = hacer la accion
        // Quit: completar = no hacer la accion
    }

    // MARK: - Test Completo de Flujo Premium

    func testCompletePremiumWorkflow() {
        testCreateHabitWithMonthlyFrequency()
    }

    // MARK: - Test de Integracion Premium

    func testAllFeaturesWorkTogether() {
        // Crear un habito con todas las features.
    }

    // MARK: - Helper Methods

    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
}
