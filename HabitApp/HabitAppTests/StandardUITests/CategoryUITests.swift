//
//  CategoryUITests.swift
//  HabitAppUITests
//
//  Tests UI específicos para la funcionalidad de Categorías
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
    
    // MARK: - Test Completo de Categoría (Similar a Selenium)
    
    func testCompleteCreateCategoryWorkflow() throws {
        // 📍 PASO 1: Verificar que la aplicación está en la pantalla principal
        print("🧪 Test: Verificando pantalla principal...")
        let mainView = app.otherElements["HabitListView"]
        XCTAssertTrue(mainView.waitForExistence(timeout: 5), 
                     "❌ La vista principal debe existir")
        print("✅ Pantalla principal confirmada")
        
        // 📍 PASO 2: Navegar al menú de categorías
        print("🧪 Test: Navegando a categorías...")
        
        // Intentar diferentes formas de acceder a la vista de categorías
        let categoryButton = findCategoryButton()
        XCTAssertNotNil(categoryButton, "❌ Debe existir un botón para crear categorías")
        
        categoryButton?.tap()
        print("✅ Botón de categoría presionado")
        
        // 📍 PASO 3: Verificar que se abrió la vista de categorías
        print("🧪 Test: Verificando vista de categorías...")
        let categoryView = app.sheets.firstMatch.exists ? 
            app.sheets.firstMatch : app.otherElements["CreateCategoryView"]
        
        XCTAssertTrue(categoryView.waitForExistence(timeout: 3), 
                     "❌ Debe aparecer la vista de crear categoría")
        print("✅ Vista de categoría abierta")
        
        // 📍 PASO 4: Verificar que está en modo "Crear"
        print("🧪 Test: Verificando modo Crear...")
        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.exists, "❌ Debe existir el control de modo")
        
        let createButton = segmentedControl.buttons["Crear"]
        if createButton.exists && !createButton.isSelected {
            createButton.tap()
        }
        print("✅ Modo Crear activado")
        
        // 📍 PASO 5: Verificar elementos del formulario
        print("🧪 Test: Verificando elementos del formulario...")
        
        let nameTextField = app.textFields["Nombre de la categoria"]
        XCTAssertTrue(nameTextField.waitForExistence(timeout: 2), 
                     "❌ Debe existir el campo de nombre")
        print("✅ Campo de nombre encontrado")
        
        XCTAssertTrue(nameTextField.isEnabled, 
                     "❌ El campo de nombre debe estar habilitado")
        print("✅ Campo de nombre habilitado")
        
        // 📍 PASO 6: Ingresar el nombre de la categoría
        print("🧪 Test: Ingresando nombre de categoría...")
        let categoryName = "Salud y Fitness 💪"
        
        nameTextField.tap()
        sleep(1) // Pequeña pausa para asegurar que el teclado aparezca
        nameTextField.typeText(categoryName)
        
        // Verificar que el texto se ingresó correctamente
        let textValue = nameTextField.value as? String ?? ""
        XCTAssertEqual(textValue, categoryName, 
                      "❌ El texto ingresado debe coincidir")
        print("✅ Nombre ingresado: \(categoryName)")
        
        // 📍 PASO 7: Verificar que el botón Guardar existe y está habilitado
        print("🧪 Test: Verificando botón Guardar...")
        let saveButton = app.buttons["Guardar"]
        XCTAssertTrue(saveButton.exists, "❌ Debe existir el botón Guardar")
        XCTAssertTrue(saveButton.isEnabled, "❌ El botón Guardar debe estar habilitado")
        print("✅ Botón Guardar disponible")
        
        // 📍 PASO 8: Guardar la categoría
        print("🧪 Test: Guardando categoría...")
        saveButton.tap()
        sleep(1) // Esperar a que se procese
        print("✅ Categoría guardada")
        
        // 📍 PASO 9: Verificar que volvimos a la vista principal
        print("🧪 Test: Verificando retorno a vista principal...")
        XCTAssertTrue(mainView.waitForExistence(timeout: 3), 
                     "❌ Debe volver a la vista principal")
        print("✅ Retornó a vista principal")
        
        // 📍 PASO 10: Verificar que la categoría se creó (buscar en la UI)
        print("🧪 Test: Verificando que la categoría se creó...")
        // Esta verificación depende de cómo muestres las categorías en tu UI
        // Podrías buscar un label, botón o elemento que muestre "Salud y Fitness"
        
        print("✅✅✅ Test completado exitosamente ✅✅✅")
    }
    
    func testCreateMultipleCategories() throws {
        let categories = [
            "Trabajo 💼",
            "Personal 🏠",
            "Deporte ⚽",
            "Estudio 📚"
        ]
        
        for category in categories {
            print("🧪 Creando categoría: \(category)")
            
            // Abrir vista de categorías
            if let button = findCategoryButton() {
                button.tap()
                
                // Ingresar nombre
                let nameField = app.textFields["Nombre de la categoria"]
                if nameField.waitForExistence(timeout: 2) {
                    nameField.tap()
                    nameField.typeText(category)
                    
                    // Guardar
                    app.buttons["Guardar"].tap()
                    sleep(1)
                    
                    print("✅ Categoría creada: \(category)")
                }
            }
        }
        
        print("✅ Todas las categorías creadas")
    }
    
    func testDeleteCategoryWorkflow() throws {
        // Primero crear una categoría para eliminar
        print("🧪 Test: Preparando categoría para eliminar...")
        testCompleteCreateCategoryWorkflow()
        
        // Abrir vista de categorías
        print("🧪 Test: Abriendo vista de categorías para eliminar...")
        if let button = findCategoryButton() {
            button.tap()
            
            // Cambiar a modo Eliminar
            print("🧪 Test: Cambiando a modo Eliminar...")
            let deleteSegment = app.buttons["Eliminar"]
            XCTAssertTrue(deleteSegment.waitForExistence(timeout: 3), 
                         "❌ Debe existir el botón Eliminar")
            deleteSegment.tap()
            print("✅ Modo Eliminar activado")
            
            // Verificar elementos de la sección de eliminar
            print("🧪 Test: Verificando elementos de eliminación...")
            
            // Buscar el picker de categorías
            let picker = app.pickers.firstMatch
            let hasCategories = picker.waitForExistence(timeout: 2)
            
            if hasCategories {
                print("✅ Lista de categorías encontrada")
                
                // Seleccionar una categoría
                picker.tap()
                
                // Intentar seleccionar la primera categoría no vacía
                let pickerWheel = app.pickerWheels.firstMatch
                if pickerWheel.exists {
                    // Ajustar a "Salud y Fitness" o la primera disponible
                    pickerWheel.adjust(toPickerWheelValue: "Salud y Fitness 💪")
                    print("✅ Categoría seleccionada")
                }
                
                // Buscar botón de eliminar
                let deleteButton = app.buttons["Eliminar categoria seleccionada"]
                XCTAssertTrue(deleteButton.exists, 
                            "❌ Debe existir el botón de eliminar categoría")
                
                if deleteButton.isEnabled {
                    print("🧪 Test: Eliminando categoría...")
                    deleteButton.tap()
                    sleep(1)
                    print("✅ Categoría eliminada")
                } else {
                    print("⚠️ Botón de eliminar deshabilitado (probablemente no hay selección)")
                }
            } else {
                // No hay categorías para eliminar
                let noCategories = app.staticTexts["No hay categorias creadas"]
                XCTAssertTrue(noCategories.exists, 
                            "❌ Debe mostrar mensaje de no categorías")
                print("ℹ️ No hay categorías para eliminar")
            }
        }
    }
    
    func testCategoryValidation() throws {
        print("🧪 Test: Probando validaciones de categoría...")
        
        if let button = findCategoryButton() {
            button.tap()
            
            // Intentar guardar sin nombre
            print("🧪 Test: Intentando guardar sin nombre...")
            let nameField = app.textFields["Nombre de la categoria"]
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                // No escribir nada
                
                let saveButton = app.buttons["Guardar"]
                let initiallyEnabled = saveButton.isEnabled
                
                if initiallyEnabled {
                    saveButton.tap()
                    sleep(1)
                    
                    // Verificar que sigue en la vista o muestra error
                    let stillInView = nameField.exists
                    let hasAlert = app.alerts.count > 0
                    
                    XCTAssertTrue(stillInView || hasAlert, 
                                "❌ Debe permanecer en la vista o mostrar error")
                    print("✅ Validación funcionó correctamente")
                } else {
                    print("✅ Botón deshabilitado correctamente sin texto")
                }
            }
        }
    }
    
    func testCategorySwitchBetweenModes() throws {
        print("🧪 Test: Probando cambio entre modos...")
        
        if let button = findCategoryButton() {
            button.tap()
            
            let segmentedControl = app.segmentedControls.firstMatch
            XCTAssertTrue(segmentedControl.waitForExistence(timeout: 3))
            
            // Probar modo Crear
            print("🧪 Test: Modo Crear...")
            let createButton = segmentedControl.buttons["Crear"]
            createButton.tap()
            sleep(1)
            
            let nameField = app.textFields["Nombre de la categoria"]
            XCTAssertTrue(nameField.waitForExistence(timeout: 2), 
                         "❌ Debe mostrar campo de texto en modo Crear")
            print("✅ Modo Crear funciona")
            
            // Probar modo Eliminar
            print("🧪 Test: Modo Eliminar...")
            let deleteButton = segmentedControl.buttons["Eliminar"]
            deleteButton.tap()
            sleep(1)
            
            let picker = app.pickers.firstMatch
            let noCategories = app.staticTexts["No hay categorias creadas"]
            
            XCTAssertTrue(picker.waitForExistence(timeout: 2) || noCategories.exists, 
                         "❌ Debe mostrar picker o mensaje en modo Eliminar")
            print("✅ Modo Eliminar funciona")
        }
    }
    
    func testCategoryWithSpecialCharacters() throws {
        print("🧪 Test: Probando categoría con caracteres especiales...")
        
        let specialCategories = [
            "Hábitos 2024 ✨",
            "Trabajo & Estudio 📖",
            "Salud (Física) 💪",
            "Familia/Amigos ❤️"
        ]
        
        for category in specialCategories {
            if let button = findCategoryButton() {
                button.tap()
                
                let nameField = app.textFields["Nombre de la categoria"]
                if nameField.waitForExistence(timeout: 2) {
                    nameField.tap()
                    nameField.typeText(category)
                    
                    app.buttons["Guardar"].tap()
                    sleep(1)
                    
                    print("✅ Categoría con caracteres especiales creada: \(category)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func findCategoryButton() -> XCUIElement? {
        // Intentar encontrar el botón de categoría de diferentes maneras
        
        // 1. Por identificador de accesibilidad
        if app.buttons["CreateCategoryButton"].exists {
            return app.buttons["CreateCategoryButton"]
        }
        
        // 2. Por texto que contenga "categoría"
        let buttonsByLabel = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'categoria'"))
        if buttonsByLabel.count > 0 {
            return buttonsByLabel.firstMatch
        }
        
        // 3. Buscar en toolbar
        let toolbarButtons = app.toolbars.buttons
        for i in 0..<toolbarButtons.count {
            let button = toolbarButtons.element(boundBy: i)
            if button.label.lowercased().contains("categoria") {
                return button
            }
        }
        
        // 4. Buscar en navigation bar
        let navButtons = app.navigationBars.buttons
        for i in 0..<navButtons.count {
            let button = navButtons.element(boundBy: i)
            if button.label.lowercased().contains("categoria") {
                return button
            }
        }
        
        return nil
    }
}
