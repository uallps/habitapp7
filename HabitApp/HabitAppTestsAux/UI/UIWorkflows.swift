//
//  UIWorkflows.swift
//  HabitAppTestsAux
//
//  Flujos de trabajo completos compartidos para tests UI
//  IMPORTANTE: Este archivo debe agregarse a los Target Membership de:
//  - HabitAppCoreUITests
//  - HabitAppStandardUITests
//  - HabitAppPremiumUITests
//

import XCTest

/// Workflows comunes para tests UI
class UIWorkflows {
    
    let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // MARK: - Workflows de Hábitos
    
    /// Crea un hábito básico con título
    @discardableResult
    func createBasicHabit(title: String) -> Bool {
        // Paso 1: Buscar botón de añadir
        guard let addButton = app.addButton else {
            print("❌ No se encontró el botón de añadir")
            app.debugPrintButtons()
            return false
        }
        
        print("✅ Botón encontrado: '\(addButton.label)'")
        
        // Verificar que existe y es tappable
        guard addButton.waitForExistence(timeout: 3) else {
            print("❌ El botón no existe después de 3s")
            return false
        }
        
        // Esperar un momento antes de hacer tap
        Thread.sleep(forTimeInterval: 0.5)
        
        print("🔘 Haciendo tap en botón añadir...")
        addButton.tap()
        
        // Esperar a que aparezca la vista de modificación
        Thread.sleep(forTimeInterval: 1)
        
        // Paso 2: Buscar campo de título
        print("🔍 Buscando campo de título...")
        let titleField = app.habitTitleField
        
        guard titleField.waitForExistence(timeout: 3) else {
            print("❌ Campo de título no encontrado")
            app.debugPrintTextFields()
            return false
        }
        
        print("✅ Campo de título encontrado")
        
        // Hacer tap en el campo
        titleField.tap()
        Thread.sleep(forTimeInterval: 0.5)
        
        // Verificar que el teclado apareció
        var keyboardVisible = app.keyboards.count > 0
        if !keyboardVisible {
            print("⚠️ Teclado no visible, reintentando...")
            titleField.tap()
            Thread.sleep(forTimeInterval: 0.5)
            keyboardVisible = app.keyboards.count > 0
        }
        
        guard keyboardVisible else {
            print("❌ El teclado no apareció")
            return false
        }
        
        print("⌨️ Escribiendo: '\(title)'")
        titleField.typeText(title)
        Thread.sleep(forTimeInterval: 0.3)
        
        // Paso 3: Buscar botón guardar
        print("🔍 Buscando botón Guardar...")
        guard let saveButton = app.saveButton else {
            print("❌ Botón Guardar no encontrado")
            app.debugPrintButtons()
            return false
        }
        
        print("✅ Botón Guardar encontrado: '\(saveButton.label)'")
        
        guard saveButton.waitForExistence(timeout: 2) else {
            print("❌ Botón Guardar no existe")
            return false
        }
        
        guard saveButton.isEnabled else {
            print("❌ Botón Guardar está deshabilitado")
            return false
        }
        
        print("💾 Guardando hábito...")
        saveButton.tap()
        
        // Dar un momento para que se cierre el sheet y vuelva a la lista
        Thread.sleep(forTimeInterval: 1)
        
        // Verificar que volvemos a la lista
        // Intentar múltiples formas de verificar que estamos de vuelta
        var success = app.habitListView.waitForExistence(timeout: 2)
        
        if !success {
            print("⚠️ No se detectó HabitListView por identificador, buscando botón Crear...")
            // Si no encuentra la vista, verificar que el botón de crear existe (indica que estamos en la lista)
            success = app.addButton?.exists ?? false
        }
        
        if success {
            print("✅ Hábito creado exitosamente")
        } else {
            print("❌ No se pudo confirmar que se volvió a la lista principal")
            print("🔍 Estado actual de la app:")
            app.debugPrintButtons()
        }
        
        return success
    }
    
    /// Toggle de completitud del primer hábito
    @discardableResult
    func toggleFirstHabitCompletion() -> Bool {
        let firstHabit = app.firstHabit
        
        guard firstHabit.waitForExistence(timeout: 2) else { return false }
        
        let completionButton = firstHabit.buttons.firstMatch
        guard completionButton.exists else { return false }
        guard waitForElementToBeHittable(completionButton, timeout: 1) else { return false }
        
        completionButton.tap()
        return true
    }
    
    // MARK: - Workflows de Categorías
    
    /// Crea una categoría completa
    @discardableResult
    func createCategory(name: String) -> Bool {
        print("📁 Iniciando creación de categoría: '\(name)'")
        
        // Paso 1: Buscar botón de categoría
        guard let categoryButton = findCategoryButton() else {
            print("❌ No se encontró botón de categoría")
            app.debugPrintButtons()
            return false
        }
        
        print("✅ Botón de categoría encontrado: '\(categoryButton.label)'")
        
        guard categoryButton.waitForExistence(timeout: 2) else {
            print("❌ Botón de categoría no existe")
            return false
        }
        
        Thread.sleep(forTimeInterval: 0.5)
        print("🔘 Haciendo tap en botón de categoría...")
        categoryButton.tap()
        
        // Esperar a que aparezca la vista
        Thread.sleep(forTimeInterval: 1)
        
        // Paso 2: Verificar que apareció la vista de categoría
        let categoryView = app.createCategoryView
        guard categoryView.waitForExistence(timeout: 3) else {
            print("❌ Vista de categoría no apareció")
            return false
        }
        
        print("✅ Vista de categoría detectada")
        
        // Paso 3: Asegurar que estamos en modo Crear
        let segmentedControl = app.segmentedControls.firstMatch
        if segmentedControl.waitForExistence(timeout: 2) {
            print("🔄 Segmented control encontrado")
            let createButton = segmentedControl.buttons["Crear"]
            if createButton.exists {
                if !createButton.isSelected {
                    print("🔘 Seleccionando modo Crear...")
                    createButton.tap()
                    Thread.sleep(forTimeInterval: 0.5)
                } else {
                    print("✅ Ya está en modo Crear")
                }
            }
        }
        
        // Paso 4: Buscar campo de nombre
        print("🔍 Buscando campo de nombre...")
        let nameField = app.categoryNameField
        
        guard nameField.waitForExistence(timeout: 3) else {
            print("❌ Campo de nombre no encontrado")
            app.debugPrintTextFields()
            return false
        }
        
        print("✅ Campo de nombre encontrado")
        
        // Hacer tap en el campo
        nameField.tap()
        Thread.sleep(forTimeInterval: 0.5)
        
        // Verificar que el teclado apareció
        var keyboardVisible = app.keyboards.count > 0
        if !keyboardVisible {
            print("⚠️ Teclado no visible, reintentando...")
            nameField.tap()
            Thread.sleep(forTimeInterval: 0.5)
            keyboardVisible = app.keyboards.count > 0
        }
        
        guard keyboardVisible else {
            print("❌ El teclado no apareció")
            return false
        }
        
        print("⌨️ Escribiendo nombre: '\(name)'")
        nameField.typeText(name)
        Thread.sleep(forTimeInterval: 0.3)
        
        // Paso 5: Buscar y presionar botón Guardar
        print("🔍 Buscando botón Guardar...")
        guard let saveButton = app.saveButton else {
            print("❌ Botón Guardar no encontrado")
            app.debugPrintButtons()
            return false
        }
        
        print("✅ Botón Guardar encontrado")
        
        guard saveButton.waitForExistence(timeout: 2) else {
            print("❌ Botón Guardar no existe")
            return false
        }
        
        guard saveButton.isEnabled else {
            print("❌ Botón Guardar está deshabilitado")
            return false
        }
        
        print("💾 Guardando categoría...")
        saveButton.tap()
        
        // Dar tiempo para que se cierre
        Thread.sleep(forTimeInterval: 1)
        
        // Verificar que volvimos a la lista
        var success = app.habitListView.waitForExistence(timeout: 2)
        
        if !success {
            print("⚠️ No se detectó HabitListView, verificando botón Crear...")
            success = app.addButton?.exists ?? false
        }
        
        if success {
            print("✅ Categoría creada exitosamente")
        } else {
            print("❌ No se pudo confirmar creación de categoría")
        }
        
        return success
    }
    
    /// Elimina una categoría por nombre
    @discardableResult
    func deleteCategory(name: String) -> Bool {
        print("🗑️ Iniciando eliminación de categoría: '\(name)'")
        
        // Paso 1: Buscar botón de categoría
        guard let categoryButton = findCategoryButton() else {
            print("❌ No se encontró botón de categoría")
            return false
        }
        
        print("✅ Botón de categoría encontrado")
        categoryButton.tap()
        Thread.sleep(forTimeInterval: 1)
        
        // Paso 2: Buscar y seleccionar modo Eliminar
        print("🔍 Buscando modo Eliminar...")
        let deleteSegment = app.buttons["Eliminar"]
        
        guard deleteSegment.waitForExistence(timeout: 3) else {
            print("❌ Botón Eliminar no encontrado")
            return false
        }
        
        print("🔘 Seleccionando modo Eliminar...")
        deleteSegment.tap()
        Thread.sleep(forTimeInterval: 1)
        
        // Paso 3: Buscar picker
        print("🔍 Buscando picker de categorías...")
        let picker = app.pickers.firstMatch
        
        guard picker.waitForExistence(timeout: 2) else {
            print("❌ Picker no encontrado")
            return false
        }
        
        print("✅ Picker encontrado")
        picker.tap()
        Thread.sleep(forTimeInterval: 0.5)
        
        // Paso 4: Seleccionar categoría en picker wheel
        let pickerWheel = app.pickerWheels.firstMatch
        if pickerWheel.exists {
            print("🎡 Ajustando picker wheel a: '\(name)'")
            pickerWheel.adjust(toPickerWheelValue: name)
            Thread.sleep(forTimeInterval: 0.5)
        } else {
            print("⚠️ Picker wheel no encontrado")
        }
        
        // Paso 5: Buscar botón de eliminar
        print("🔍 Buscando botón de eliminar categoría...")
        let deleteButton = app.buttons["Eliminar categoria seleccionada"]
        
        guard deleteButton.waitForExistence(timeout: 2) else {
            print("❌ Botón de eliminar categoría no encontrado")
            app.debugPrintButtons()
            return false
        }
        
        guard deleteButton.isEnabled else {
            print("❌ Botón de eliminar está deshabilitado")
            return false
        }
        
        print("🗑️ Eliminando categoría...")
        deleteButton.tap()
        Thread.sleep(forTimeInterval: 1)
        
        // Verificar que volvimos
        let success = app.habitListView.waitForExistence(timeout: 2) || (app.addButton?.exists ?? false)
        
        if success {
            print("✅ Categoría eliminada exitosamente")
        } else {
            print("❌ No se pudo confirmar eliminación")
        }
        
        return success
    }
    
    // MARK: - Workflows Premium
    
    /// Crea un hábito con frecuencia expandida
    @discardableResult
    func createHabitWithExpandedFrequency(title: String, frequency: String) -> Bool {
        guard let addButton = app.addButton else { return false }
        
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            let titleField = app.habitTitleField
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText(title)
            }
            
            let frequencyButton = app.findElement(withKeywords: ["frecuencia", "frequency"], in: app.buttons)
            if let freqBtn = frequencyButton, freqBtn.waitForExistence(timeout: 3) {
                freqBtn.tap()
                
                let option = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", frequency)).firstMatch
                if option.exists {
                    option.tap()
                }
            }
            
            guard let saveButton = app.saveButton else { return false }
            guard saveButton.waitForExistence(timeout: 2) else { return false }
            
            saveButton.tap()
            return app.habitListView.waitForExistence(timeout: 2)
        }
        
        return false
    }
    
    /// Pausa un día para el primer hábito
    @discardableResult
    func pauseFirstHabit() -> Bool {
        let firstHabit = app.firstHabit
        
        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()
            
            let pauseButton = app.findElement(withKeywords: ["pausar", "pause"], in: app.buttons)
            if let pause = pauseButton, pause.waitForExistence(timeout: 3) {
                pause.tap()
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Helpers
    
    /// Espera a que un elemento sea interactuable (hittable)
    private func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Espera a que aparezca el teclado
    private func waitForKeyboard(timeout: TimeInterval) -> Bool {
        let keyboard = app.keyboards.firstMatch
        return keyboard.waitForExistence(timeout: timeout)
    }
    
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
