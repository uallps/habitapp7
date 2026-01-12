//
//  HabitAppUITests.swift
//  HabitAppUITests
//
//  UI Tests para HabitApp - Similar a Selenium
//

import XCTest

final class HabitAppUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Deshabilitar continuar después de un fallo
        continueAfterFailure = false
        
        // Lanzar la aplicación para cada test
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Test de Lanzamiento
    
    func testAppLaunches() throws {
        // Verificar que la app se lanza correctamente
        XCTAssertTrue(app.state == .runningForeground)
    }
    
    func testNavigationBarExists() throws {
        // Verificar que existe la barra de navegación principal
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.exists, "La barra de navegación debe existir")
    }
    
    // MARK: - Test de Crear Categoría (Flujo completo similar a Selenium)
    
    func testCreateCategoryFlow() throws {
        // Paso 1: Verificar que la app está en la pantalla principal
        let habitListView = app.otherElements["HabitListView"]
        XCTAssertTrue(habitListView.waitForExistence(timeout: 5), "Debe aparecer la vista de lista de hábitos")
        
        // Paso 2: Buscar y tocar el botón de añadir/crear categoría
        // Esto depende de cómo esté implementado en tu UI. Aquí buscaremos un botón con texto o icono
        let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'añadir' OR label CONTAINS[c] 'crear'")).firstMatch
        
        // Si no encontramos por texto, buscar por identificador de accesibilidad
        let categoryButton = app.buttons["CreateCategoryButton"].exists ? 
            app.buttons["CreateCategoryButton"] : addButton
        
        if categoryButton.exists {
            categoryButton.tap()
            
            // Paso 3: Verificar que aparece la vista de crear categoría
            let createCategoryView = app.otherElements["CreateCategoryView"]
            XCTAssertTrue(createCategoryView.waitForExistence(timeout: 3), "Debe aparecer la vista de crear categoría")
            
            // Paso 4: Verificar que existe el campo de texto para el nombre
            let nameTextField = app.textFields["Nombre de la categoria"]
            XCTAssertTrue(nameTextField.exists, "Debe existir el campo de texto para el nombre")
            
            // Paso 5: Escribir el nombre de la categoría
            nameTextField.tap()
            nameTextField.typeText("Salud y Bienestar")
            
            // Paso 6: Verificar que el texto se escribió correctamente
            XCTAssertEqual(nameTextField.value as? String, "Salud y Bienestar", "El texto debe coincidir")
            
            // Paso 7: Buscar y tocar el botón de guardar
            let saveButton = app.buttons["Guardar"]
            XCTAssertTrue(saveButton.exists, "Debe existir el botón de guardar")
            XCTAssertTrue(saveButton.isEnabled, "El botón de guardar debe estar habilitado")
            
            saveButton.tap()
            
            // Paso 8: Verificar que volvemos a la pantalla principal
            XCTAssertTrue(habitListView.waitForExistence(timeout: 3), "Debe volver a la lista de hábitos")
            
            // Paso 9: Verificar que la categoría se creó (opcional: buscar en la lista)
            // Esto dependerá de cómo muestres las categorías en tu UI
        } else {
            XCTFail("No se encontró el botón para crear categoría")
        }
    }
    
    func testCreateCategoryWithEmptyName() throws {
        // Similar al anterior pero verificando validación
        let categoryButton = app.buttons["CreateCategoryButton"]
        
        if categoryButton.exists {
            categoryButton.tap()
            
            let nameTextField = app.textFields["Nombre de la categoria"]
            XCTAssertTrue(nameTextField.waitForExistence(timeout: 3))
            
            // No escribir nada
            nameTextField.tap()
            
            // Intentar guardar con nombre vacío
            let saveButton = app.buttons["Guardar"]
            if saveButton.exists {
                // El botón debería estar deshabilitado o mostrar un error
                if saveButton.isEnabled {
                    saveButton.tap()
                    
                    // Verificar que muestra un error o no se cierra la vista
                    let alert = app.alerts.firstMatch
                    XCTAssertTrue(alert.exists || nameTextField.exists, 
                                "Debe mostrar un error o permanecer en la vista")
                }
            }
        }
    }
    
    // MARK: - Test de Eliminar Categoría
    
    func testDeleteCategoryFlow() throws {
        // Primero crear una categoría para eliminar
        try testCreateCategoryFlow()
        
        // Abrir la vista de categorías
        let categoryButton = app.buttons["CreateCategoryButton"]
        if categoryButton.exists {
            categoryButton.tap()
            
            // Cambiar al modo de eliminar
            let deleteSegment = app.buttons["Eliminar"]
            XCTAssertTrue(deleteSegment.waitForExistence(timeout: 3))
            deleteSegment.tap()
            
            // Verificar que existe la lista de categorías
            let picker = app.pickers.firstMatch
            if picker.exists {
                picker.tap()
                
                // Seleccionar la primera categoría disponible
                let firstCategory = app.pickerWheels.firstMatch
                if firstCategory.exists {
                    firstCategory.adjust(toPickerWheelValue: "Salud y Bienestar")
                }
                
                // Tocar el botón de eliminar
                let deleteButton = app.buttons["Eliminar categoria seleccionada"]
                XCTAssertTrue(deleteButton.exists)
                
                if deleteButton.isEnabled {
                    deleteButton.tap()
                    
                    // Verificar confirmación o que la categoría fue eliminada
                }
            }
        }
    }
    
    // MARK: - Test de Navegación entre vistas
    
    func testNavigationToCreateCategory() throws {
        // Verificar la navegación básica
        let toolbar = app.toolbars.firstMatch
        
        if toolbar.exists {
            let buttons = toolbar.buttons
            
            // Buscar cualquier botón que contenga "categoría" o "añadir"
            for i in 0..<buttons.count {
                let button = buttons.element(boundBy: i)
                let label = button.label.lowercased()
                
                if label.contains("categoría") || label.contains("categoria") {
                    button.tap()
                    
                    // Verificar que se abre una nueva vista
                    let sheet = app.sheets.firstMatch
                    let navigationView = app.navigationBars.firstMatch
                    
                    XCTAssertTrue(sheet.waitForExistence(timeout: 3) || navigationView.exists,
                                "Debe aparecer una nueva vista")
                    
                    // Cerrar la vista (buscar botón cancelar o atrás)
                    let cancelButton = app.buttons["Cancelar"].firstMatch
                    if cancelButton.exists {
                        cancelButton.tap()
                    }
                    
                    break
                }
            }
        }
    }
    
    // MARK: - Test de Verificación de Elementos UI
    
    func testCategoryViewContainsRequiredElements() throws {
        let categoryButton = app.buttons["CreateCategoryButton"]
        
        if categoryButton.exists {
            categoryButton.tap()
            
            // Verificar que existen todos los elementos requeridos
            let elements = [
                "Picker Modo": app.segmentedControls.firstMatch,
                "Campo de texto": app.textFields.firstMatch,
                "Botón Guardar": app.buttons["Guardar"]
            ]
            
            for (name, element) in elements {
                XCTAssertTrue(element.waitForExistence(timeout: 3), 
                            "\(name) debe existir en la vista")
            }
        }
    }
    
    func testCategoryViewModeSwitching() throws {
        let categoryButton = app.buttons["CreateCategoryButton"]
        
        if categoryButton.exists {
            categoryButton.tap()
            
            // Verificar que existe el segmented control
            let modeSegment = app.segmentedControls.firstMatch
            XCTAssertTrue(modeSegment.waitForExistence(timeout: 3))
            
            // Cambiar a modo Crear
            let createButton = modeSegment.buttons["Crear"]
            if createButton.exists {
                createButton.tap()
                
                // Verificar que se muestra el campo de texto
                let textField = app.textFields["Nombre de la categoria"]
                XCTAssertTrue(textField.waitForExistence(timeout: 2))
            }
            
            // Cambiar a modo Eliminar
            let deleteButton = modeSegment.buttons["Eliminar"]
            if deleteButton.exists {
                deleteButton.tap()
                
                // Verificar que se muestra el picker
                let picker = app.pickers.firstMatch
                XCTAssertTrue(picker.waitForExistence(timeout: 2) || 
                            app.staticTexts["No hay categorias creadas"].exists)
            }
        }
    }
    
    // MARK: - Test de Hábitos (Bonus)
    
    func testCreateHabitFlow() throws {
        // Verificar que existe el botón de añadir hábito
        let addHabitButton = app.buttons["Añadir Tarea"].firstMatch
        
        if addHabitButton.exists {
            addHabitButton.tap()
            
            // Verificar que se abre la vista de crear hábito
            let habitForm = app.otherElements["HabitModifyView"]
            XCTAssertTrue(habitForm.waitForExistence(timeout: 3))
            
            // Escribir el nombre del hábito
            let titleField = app.textFields.firstMatch
            if titleField.exists {
                titleField.tap()
                titleField.typeText("Hacer ejercicio")
                
                // Guardar
                let saveButton = app.navigationBars.buttons["Guardar"]
                if saveButton.exists {
                    saveButton.tap()
                    
                    // Verificar que volvemos a la lista
                    let habitList = app.otherElements["HabitListView"]
                    XCTAssertTrue(habitList.waitForExistence(timeout: 3))
                }
            }
        }
    }
    
    func testToggleHabitCompletion() throws {
        // Buscar el primer hábito en la lista
        let firstHabitRow = app.buttons.matching(identifier: "HabitRowView").firstMatch
        
        if firstHabitRow.waitForExistence(timeout: 3) {
            // Tocar el checkbox/círculo de completado
            let completionButton = firstHabitRow.buttons.firstMatch
            if completionButton.exists {
                completionButton.tap()
                
                // Verificar que cambia el estado (esto dependerá de tu implementación)
                // Podría ser verificar un ícono diferente o un cambio de color
            }
        }
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
    
    func typeTextSlowly(_ text: String, into element: XCUIElement) {
        element.tap()
        for character in text {
            element.typeText(String(character))
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
}
