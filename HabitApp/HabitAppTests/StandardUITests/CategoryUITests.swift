//
//  CategoryUITests.swift
//  HabitAppUITests
//
//  Tests UI especificos para la funcionalidad de Categorias
//

import XCTest

final class CategoryUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["UI-Testing", "Reset-Categories"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Test Completo de Categoria (Similar a Selenium)

    func testCompleteCreateCategoryWorkflow() {
        // PASO 1: Verificar que la aplicacion esta en la pantalla principal
        let mainView = app.otherElements["HabitListView"]
        XCTAssertTrue(mainView.waitForExistence(timeout: 5),
                     "La vista principal debe existir")

        // PASO 2: Navegar al menu de categorias
        guard let categoryButton = findCategoryButton() else {
            XCTFail("Debe existir un boton para crear categorias")
            return
        }

        categoryButton.tap()

        // PASO 3: Verificar que se abrio la vista de categorias
        let categoryView = app.sheets.firstMatch.exists ?
            app.sheets.firstMatch : app.otherElements["CreateCategoryView"]

        XCTAssertTrue(categoryView.waitForExistence(timeout: 3),
                     "Debe aparecer la vista de crear categoria")

        // PASO 4: Verificar que esta en modo Crear
        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.exists, "Debe existir el control de modo")

        let createButton = segmentedControl.buttons["Crear"]
        if createButton.exists && !createButton.isSelected {
            createButton.tap()
        }

        // PASO 5: Verificar elementos del formulario
        let nameTextField = app.textFields["Nombre de la categoria"]
        XCTAssertTrue(nameTextField.waitForExistence(timeout: 2),
                     "Debe existir el campo de nombre")
        XCTAssertTrue(nameTextField.isEnabled,
                     "El campo de nombre debe estar habilitado")

        // PASO 6: Ingresar el nombre de la categoria
        let categoryName = "Salud y Fitness"

        nameTextField.tap()
        sleep(1)
        nameTextField.typeText(categoryName)

        // Verificar que el texto se ingreso correctamente
        let textValue = nameTextField.value as? String ?? ""
        XCTAssertEqual(textValue, categoryName,
                      "El texto ingresado debe coincidir")

        // PASO 7: Verificar que el boton Guardar existe y esta habilitado
        let saveButton = app.buttons["Guardar"]
        XCTAssertTrue(saveButton.exists, "Debe existir el boton Guardar")
        XCTAssertTrue(saveButton.isEnabled, "El boton Guardar debe estar habilitado")

        // PASO 8: Guardar la categoria
        saveButton.tap()
        sleep(1)

        // PASO 9: Verificar que volvimos a la vista principal
        XCTAssertTrue(mainView.waitForExistence(timeout: 3),
                     "Debe volver a la vista principal")
    }

    func testCreateMultipleCategories() {
        let categories = [
            "Trabajo",
            "Personal",
            "Deporte",
            "Estudio"
        ]

        for category in categories {
            guard let button = findCategoryButton() else {
                XCTFail("Debe existir un boton para crear categorias")
                return
            }

            button.tap()

            let nameField = app.textFields["Nombre de la categoria"]
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText(category)

                app.buttons["Guardar"].tap()
                sleep(1)
            }
        }
    }

    func testDeleteCategoryWorkflow() {
        // Primero crear una categoria para eliminar
        testCompleteCreateCategoryWorkflow()

        // Abrir vista de categorias
        guard let button = findCategoryButton() else {
            XCTFail("Debe existir un boton para crear categorias")
            return
        }

        button.tap()

        // Cambiar a modo Eliminar
        let deleteSegment = app.buttons["Eliminar"]
        XCTAssertTrue(deleteSegment.waitForExistence(timeout: 3),
                     "Debe existir el boton Eliminar")
        deleteSegment.tap()

        // Verificar elementos de la seccion de eliminar
        let picker = app.pickers.firstMatch
        let hasCategories = picker.waitForExistence(timeout: 2)

        if hasCategories {
            picker.tap()

            let pickerWheel = app.pickerWheels.firstMatch
            if pickerWheel.exists {
                pickerWheel.adjust(toPickerWheelValue: "Salud y Fitness")
            }

            let deleteButton = app.buttons["Eliminar categoria seleccionada"]
            XCTAssertTrue(deleteButton.exists,
                        "Debe existir el boton de eliminar categoria")

            if deleteButton.isEnabled {
                deleteButton.tap()
                sleep(1)
            }
        } else {
            let noCategories = app.staticTexts["No hay categorias creadas"]
            XCTAssertTrue(noCategories.exists,
                        "Debe mostrar mensaje de no categorias")
        }
    }

    func testCategoryValidation() {
        guard let button = findCategoryButton() else {
            XCTFail("Debe existir un boton para crear categorias")
            return
        }

        button.tap()

        // Intentar guardar sin nombre
        let nameField = app.textFields["Nombre de la categoria"]
        if nameField.waitForExistence(timeout: 2) {
            nameField.tap()

            let saveButton = app.buttons["Guardar"]
            let initiallyEnabled = saveButton.isEnabled

            if initiallyEnabled {
                saveButton.tap()
                sleep(1)

                let stillInView = nameField.exists
                let hasAlert = app.alerts.count > 0

                XCTAssertTrue(stillInView || hasAlert,
                            "Debe permanecer en la vista o mostrar error")
            }
        }
    }

    func testCategorySwitchBetweenModes() {
        guard let button = findCategoryButton() else {
            XCTFail("Debe existir un boton para crear categorias")
            return
        }

        button.tap()

        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.waitForExistence(timeout: 3))

        let createButton = segmentedControl.buttons["Crear"]
        createButton.tap()
        sleep(1)

        let nameField = app.textFields["Nombre de la categoria"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2),
                     "Debe mostrar campo de texto en modo Crear")

        let deleteButton = segmentedControl.buttons["Eliminar"]
        deleteButton.tap()
        sleep(1)

        let picker = app.pickers.firstMatch
        let noCategories = app.staticTexts["No hay categorias creadas"]

        XCTAssertTrue(picker.waitForExistence(timeout: 2) || noCategories.exists,
                     "Debe mostrar picker o mensaje en modo Eliminar")
    }

    func testCategoryWithSpecialCharacters() {
        let specialCategories = [
            "Habitos 2024",
            "Trabajo & Estudio",
            "Salud (Fisica)",
            "Familia/Amigos"
        ]

        for category in specialCategories {
            guard let button = findCategoryButton() else {
                XCTFail("Debe existir un boton para crear categorias")
                return
            }

            button.tap()

            let nameField = app.textFields["Nombre de la categoria"]
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText(category)

                app.buttons["Guardar"].tap()
                sleep(1)
            }
        }
    }

    // MARK: - Helper Methods

    private func findCategoryButton() -> XCUIElement? {
        if app.buttons["CreateCategoryButton"].exists {
            return app.buttons["CreateCategoryButton"]
        }

        let buttonsByLabel = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'categor'"))
        if buttonsByLabel.count > 0 {
            return buttonsByLabel.firstMatch
        }

        let toolbarButtons = app.toolbars.buttons
        for index in 0..<toolbarButtons.count {
            let button = toolbarButtons.element(boundBy: index)
            if button.label.lowercased().contains("categor") {
                return button
            }
        }

        let navButtons = app.navigationBars.buttons
        for index in 0..<navButtons.count {
            let button = navButtons.element(boundBy: index)
            if button.label.lowercased().contains("categor") {
                return button
            }
        }

        return nil
    }
}
