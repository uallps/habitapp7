//
//  StandardUITests.swift
//  HabitAppStandardUITests
//
//  UI Tests para la version STANDARD (Core + Features sin NM_)
//  Incluye tests de Categories integrados
//

import XCTest

final class StandardUITests: UITestBase {
    
    override var launchArguments: [String] {
        return ["UI-Testing", "Standard-Version"]
    }
    
    var workflows: UIWorkflows {
        return UIWorkflows(app: app)
    }

    // MARK: - Test de Lanzamiento Standard

    func testStandardVersionAppLaunches() {
        assertAppIsRunning()
    }

    // MARK: - Test de Features Standard Disponibles

    func testCategoryFeatureIsAvailable() {
        XCTAssertNotNil(findCategoryButton(), "Categorias debe estar disponible en Standard")
    }

    func testStatsFeatureIsAvailable() {
        assertFeatureAvailable(keywords: UIPredicates.stats, 
                              message: "Estadisticas debe estar disponible en Standard")
    }

    func testDiaryFeatureIsAvailable() {
        if app.firstHabit.waitForExistence(timeout: 3) {
            app.firstHabit.buttons.firstMatch.tap()
            assertFeatureAvailable(keywords: UIPredicates.diary,
                                  message: "Diario debe estar disponible en Standard")
        }
    }

    func testRemindersFeatureIsAvailable() {
        if app.firstHabit.waitForExistence(timeout: 3) {
            app.firstHabit.tap()
            assertFeatureAvailable(keywords: UIPredicates.reminder,
                                  message: "Recordatorios debe estar disponible en Standard")
        }
    }

    func testStreaksFeatureIsAvailable() {
        assertFeatureAvailable(keywords: UIPredicates.streak,
                              message: "Rachas debe estar disponible en Standard")
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

        assertFeatureNotAvailable(keywords: UIPredicates.expandedFrequency,
                                 message: "No debe haber frecuencias expandidas en Standard")
    }

    func testPauseDayNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.pauseDay,
                                 message: "No debe haber funcion de pausa en Standard")
    }

    func testHabitTypeNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.habitType,
                                 message: "No debe haber selector de tipo en Standard")   if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText("Salud")

                app.buttons["Guardar"].tap()
                sleep(1)
            }
        }

        XCTAssertTrue(workflows.createCategory(name: "Salud"), 
                     "Debe poder crear categoria")
        
        XCTAssertTrue(workflows.createBasicHabit(title: "Ejercicio"),
                     "Debe poder crear habito")
    }

    // MARK: - Test Completo de Flujo Standard

    func testCompleteStandardWorkflow() {
        XCTAssertTrue(workflows.createBasicHabit(title: "Meditar"),
                     "Debe poder crear habito")
        
        XCTAssertTrue(workflows.toggleFirstHabitCompletion(),
                     "Debe poder completar habito")
    }
    
    // MARK: - Tests de Categorias (integrados desde CategoryUITests)
    
    func testCompleteCreateCategoryWorkflow() {
        assertMainViewExists()
        
        guard let categoryButton = findCategoryButton() else {
            XCTFail("Debe existir un boton para crear categorias")
            return
        }
        
        categoryButton.tap()
        
        let categoryView = app.createCategoryView
        XCTAssertTrue(categoryView.waitForExistence(timeout: 3),
                     "Debe aparecer la vista de crear categoria")
        
        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.exists, "Debe existir el control de modo")
        
        let createButton = segmentedControl.buttons["Crear"]
        if createButton.exists && !createButton.isSelected {
            createButton.tap()
        }
        
        let nameTextField = app.categoryNameField
        XCTAssertTrue(nameTextField.waitForExistence(timeout: 2),
                     "Debe existir el campo de nombre")
        
        let categoryName = "Salud y Fitness"
        typeText(in: nameTextField, text: categoryName)
        
        let textValue = nameTextField.value as? String ?? ""
        XCTAssertEqual(textValue, categoryName,
                      "El texto ingresado debe coincidir")
        
        if let saveButton = findSaveButton() {
            XCTAssertTrue(saveButton.isEnabled, "El boton Guardar debe estar habilitado")
            saveButton.tap()
            sleep(1)
        }
        
        XCTAssertTrue(app.habitListView.waitForExistence(timeout: 3),
                     "Debe volver a la vista principal")
    }
    
    func testCreateMultipleCategories() {
        let categories = ["Trabajo", "Personal", "Deporte", "Estudio"]
        
        for category in categories {
            XCTAssertTrue(workflows.createCategory(name: category),
                         "Debe poder crear categoria: \(category)")
        }
    }
    
    func testDeleteCategoryWorkflow() {
        workflows.createCategory(name: "Categoria a Eliminar")
        
        XCTAssertTrue(workflows.deleteCategory(name: "Categoria a Eliminar"),
                     "Debe poder eliminar categoria")
    }
    
    func testCategoryValidation() {
        guard let button = findCategoryButton() else {
            XCTFail("Debe existir un boton para crear categorias")
            return
        }
        
        button.tap()
        
        let nameField = app.categoryNameField
        if nameField.waitForExistence(timeout: 2) {
            nameField.tap()
            
            if let saveButton = findSaveButton() {
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
        
        let nameField = app.categoryNameField
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
            workflows.createCategory(name: category)
        }