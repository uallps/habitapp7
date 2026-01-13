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
import CoreGraphics

/// Workflows comunes para tests UI
class UIWorkflows {
    
    let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // MARK: - Workflows de Hábitos
    
    /// Crea un hábito básico con título
    @discardableResult
    func createBasicHabit(title: String, activateAllFrequencyDays: Bool = false) -> Bool {
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
        Thread.sleep(forTimeInterval: 0.05)
        
        print("🔘 Haciendo tap en botón añadir...")
        addButton.tap()
        
        // Esperar a que aparezca la vista de modificación
        Thread.sleep(forTimeInterval: 0.05)
        
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
        Thread.sleep(forTimeInterval: 0.05)
        
        // Verificar que el teclado apareció
        var keyboardVisible = waitForKeyboard(timeout: 1)
        if !keyboardVisible {
            print("⚠️ Teclado no visible, reintentando...")
            titleField.tap()
            Thread.sleep(forTimeInterval: 0.05)
            keyboardVisible = waitForKeyboard(timeout: 1)
        }
        
        guard keyboardVisible else {
            print("❌ El teclado no apareció")
            return false
        }
        
        print("⌨️ Escribiendo: '\(title)'")
        titleField.typeText(title)
        Thread.sleep(forTimeInterval: 0.05)

        if activateAllFrequencyDays {
            dismissKeyboardIfNeeded()
            if !activateFrequencyDays([
                "Lunes",
                "Martes",
                "Mi\u{00E9}rcoles",
                "Jueves",
                "Viernes",
                "S\u{00E1}bado",
                "Domingo"
            ]) {
                return false
            }
        }
        
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
        Thread.sleep(forTimeInterval: 0.05)
        
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
        
        let circlePredicate = NSPredicate(format: "label CONTAINS[c] 'circle'")
        let completionButton = firstHabit.buttons.matching(circlePredicate).firstMatch
        if completionButton.exists {
            guard waitForElementToBeHittable(completionButton, timeout: 1) else { return false }
            completionButton.tap()
            return true
        }

        let leftTap = firstHabit.coordinate(withNormalizedOffset: CGVector(dx: 0.08, dy: 0.5))
        leftTap.tap()
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
        
        Thread.sleep(forTimeInterval: 0.05)
        print("🔘 Haciendo tap en botón de categoría...")
        categoryButton.tap()
        
        // Esperar a que aparezca la vista
        Thread.sleep(forTimeInterval: 0.05)
        
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
                    Thread.sleep(forTimeInterval: 0.05)
                } else {
                    print("✅ Ya está en modo Crear")
                }
            }
        }
        
        // Paso 4: Buscar campo de nombre
        print("🔍 Buscando campo de nombre...")
        var nameField = app.categoryNameField
        if !nameField.exists {
            let tableField = app.tables.textFields.firstMatch
            if tableField.exists {
                nameField = tableField
            }
        }
        
        guard nameField.waitForExistence(timeout: 3) else {
            print("❌ Campo de nombre no encontrado")
            app.debugPrintTextFields()
            return false
        }
        
        print("✅ Campo de nombre encontrado")
        
        if !waitForElementToBeHittable(nameField, timeout: 2) {
            let nameCell = app.cells.containing(.staticText, identifier: "Nombre").firstMatch
            if nameCell.exists {
                nameCell.tap()
            }
        }

        // Hacer tap en el campo
        nameField.tap()
        Thread.sleep(forTimeInterval: 0.05)
        
        // Verificar que el teclado apareció
        var keyboardVisible = waitForKeyboard(timeout: 1)
        if !keyboardVisible {
            print("⚠️ Teclado no visible, reintentando...")
            nameField.tap()

            keyboardVisible = waitForKeyboard(timeout: 1)
        }
        
        guard keyboardVisible else {
            print("❌ El teclado no apareció")
            return false
        }
        
        print("⌨️ Escribiendo nombre: '\(name)'")
        nameField.typeText(name)
        Thread.sleep(forTimeInterval: 0.05)

        if let value = nameField.value as? String,
           !value.lowercased().contains(name.lowercased()) {
            nameField.tap()
            nameField.typeText(name)
            Thread.sleep(forTimeInterval: 0.05)
        }

        
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
        Thread.sleep(forTimeInterval: 0.05)
        
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
        Thread.sleep(forTimeInterval: 0.05)
        
        // Paso 2: Buscar y seleccionar modo Eliminar
        print("🔍 Buscando modo Eliminar...")
        let deleteSegment = app.buttons["Eliminar"]
        
        guard deleteSegment.waitForExistence(timeout: 3) else {
            print("❌ Botón Eliminar no encontrado")
            return false
        }
        
        print("🔘 Seleccionando modo Eliminar...")
        deleteSegment.tap()
        Thread.sleep(forTimeInterval: 0.05)
        
        // Paso 3: Abrir selector (extensible) y elegir categoria
        print("Buscando selector de categorias...")
        guard openDeleteCategoryPicker() else {
            print("Selector de categorias no encontrado")
            return false
        }
        Thread.sleep(forTimeInterval: 0.05)

        guard selectCategoryOption(name) else {
            print("No se pudo seleccionar la categoria: '\(name)'")
            return false
        }
        Thread.sleep(forTimeInterval: 0.05)

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
        Thread.sleep(forTimeInterval: 0.05)
        
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
    func createHabitWithExpandedFrequency(title: String, frequency: String, activateAllFrequencyDays: Bool = false) -> Bool {
        guard let addButton = app.addButton else { return false }

        guard addButton.waitForExistence(timeout: 3) else { return false }
        addButton.tap()

        let titleField = app.habitTitleField
        guard titleField.waitForExistence(timeout: 2) else { return false }
        titleField.tap()
        titleField.typeText(title)
        dismissKeyboardIfNeeded()

        if activateAllFrequencyDays {
            if !activateFrequencyDays([
                "Lunes",
                "Martes",
                "Mi\u{00E9}rcoles",
                "Jueves",
                "Viernes",
                "S\u{00E1}bado",
                "Domingo"
            ]) {
                return false
            }
        }

        guard scrollToExpandedFrequencySection() else { return false }
        if !isExpandedFrequencySelected(frequency) {
            guard openExpandedFrequencyPicker() else { return false }
            _ = selectExpandedFrequencyOption(frequency)
        }
        guard isExpandedFrequencySelected(frequency) else { return false }

        guard let saveButton = app.saveButton else { return false }
        guard saveButton.waitForExistence(timeout: 2) else { return false }

        saveButton.tap()
        return app.habitListView.waitForExistence(timeout: 2)
    }
    
    /// Pausa un día para el primer hábito
    /// Crea un habito con categoria y tipo de completado
    @discardableResult
    func createHabitWithCategoryAndType(title: String, category: String, type: String) -> Bool {
        guard let addButton = app.addButton else { return false }
        guard addButton.waitForExistence(timeout: 3) else { return false }
        addButton.tap()

        let titleField = app.habitTitleField
        guard titleField.waitForExistence(timeout: 2) else { return false }
        titleField.tap()
        titleField.typeText(title)
        dismissKeyboardIfNeeded()

        guard openHabitCategoryPicker() else { return false }
        guard selectCategoryOption(category) else { return false }

        guard scrollToHabitTypeSection() else { return false }
        guard openHabitTypePicker() else { return false }
        guard selectHabitTypeOption(type) else { return false }
        guard isHabitTypeSelected(type) else { return false }

        guard let saveButton = app.saveButton else { return false }
        guard saveButton.waitForExistence(timeout: 2) else { return false }
        saveButton.tap()

        return app.habitListView.waitForExistence(timeout: 2)
    }

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

    private func dismissKeyboardIfNeeded() {
        guard app.keyboards.count > 0 else { return }

        let keyboardButtons = ["Done", "Return", "OK", "Aceptar"]
        for label in keyboardButtons {
            let button = app.keyboards.buttons[label]
            if button.exists {
                button.tap()
                return
            }
        }

        app.tap()
    }

    private func scrollToExpandedFrequencySection() -> Bool {
        let table = app.tables.firstMatch
        let scrollView = app.scrollViews.firstMatch
        let scrollContainer = table.exists ? table : scrollView

        for _ in 0..<6 {
            if app.staticTexts["Frecuencia Extendida (Plugin)"].exists {
                return true
            }
            scrollContainer.swipeUp()
        }

        return app.staticTexts["Frecuencia Extendida (Plugin)"].exists
    }

    private func scrollToHabitTypeSection() -> Bool {
        let table = app.tables.firstMatch
        let scrollView = app.scrollViews.firstMatch
        let scrollContainer = table.exists ? table : scrollView

        for _ in 0..<6 {
            if app.staticTexts["Tipo de Completado (Plugin)"].exists {
                return true
            }
            scrollContainer.swipeUp()
        }

        return app.staticTexts["Tipo de Completado (Plugin)"].exists
    }

    private func openExpandedFrequencyPicker() -> Bool {
        let table = app.tables.firstMatch
        let scrollView = app.scrollViews.firstMatch
        let scrollContainer = table.exists ? table : scrollView

        for _ in 0..<6 {
            let picker = app.pickers["Tipo de Frecuencia"]
            if picker.exists, picker.isHittable {
                picker.tap()
                return true
            }

            let cell = app.cells.containing(.staticText, identifier: "Tipo de Frecuencia").firstMatch
            if cell.exists {
                if cell.isHittable {
                    tapRightSide(of: cell)
                    return true
                }
            }

            let label = app.staticTexts["Tipo de Frecuencia"]
            if label.exists, label.isHittable {
                label.tap()
                return true
            }

            scrollContainer.swipeUp()
        }

        return false
    }

    private func openHabitTypePicker() -> Bool {
        let picker = app.pickers["Tipo"]
        if picker.exists {
            picker.tap()
            return true
        }

        let cell = app.cells.containing(.staticText, identifier: "Tipo").firstMatch
        if cell.exists {
            tapRightSide(of: cell)
            return true
        }

        let label = app.staticTexts["Tipo"]
        if label.exists {
            label.tap()
            return true
        }

        return false
    }

    private func openHabitCategoryPicker() -> Bool {
        let picker = app.pickers.matching(NSPredicate(format: "label CONTAINS[c] 'categor'")).firstMatch
        if picker.exists {
            picker.tap()
            return true
        }

        let cell = app.cells.matching(NSPredicate(format: "label CONTAINS[c] 'categor'")).firstMatch
        if cell.exists {
            tapRightSide(of: cell)
            return true
        }

        let label = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'categor'")).firstMatch
        if label.exists {
            label.tap()
            return true
        }

        return false
    }

    private func openDeleteCategoryPicker() -> Bool {
        let pickerLabel = "Selecciona una para eliminar"
        let table = app.tables.firstMatch
        let scrollView = app.scrollViews.firstMatch
        let scrollContainer = table.exists ? table : scrollView

        for _ in 0..<6 {
            let picker = app.pickers[pickerLabel]
            if picker.exists, picker.isHittable {
                picker.tap()
                return true
            }

            let pickerCell = app.cells.containing(.staticText, identifier: pickerLabel).firstMatch
            if pickerCell.exists, pickerCell.isHittable {
                tapRightSide(of: pickerCell)
                return true
            }

            let noneCell = app.cells.containing(.staticText, identifier: "Ninguna").firstMatch
            if noneCell.exists, noneCell.isHittable {
                tapRightSide(of: noneCell)
                return true
            }

            scrollContainer.swipeUp()
        }

        let anyPicker = app.pickers.firstMatch
        if anyPicker.exists {
            anyPicker.tap()
            return true
        }

        return false
    }

    private func selectExpandedFrequencyOption(_ option: String) -> Bool {
        if isExpandedFrequencySelected(option) {
            return true
        }

        let optionButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", option)).firstMatch
        if optionButton.waitForExistence(timeout: 2) {
            optionButton.tap()
            return true
        }

        let optionCell = app.cells.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", option)).firstMatch
        if optionCell.waitForExistence(timeout: 2) {
            optionCell.tap()
            return true
        }

        let optionText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", option)).firstMatch
        if optionText.waitForExistence(timeout: 2) {
            optionText.tap()
            return true
        }

        let wheel = app.pickerWheels.firstMatch
        if wheel.waitForExistence(timeout: 1) {
            wheel.adjust(toPickerWheelValue: option)
            return true
        }

        return false
    }

    private func selectHabitTypeOption(_ option: String) -> Bool {
        if isHabitTypeSelected(option) {
            return true
        }

        let optionButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", option)).firstMatch
        if optionButton.waitForExistence(timeout: 2) {
            optionButton.tap()
            return true
        }

        let optionCell = app.cells.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", option)).firstMatch
        if optionCell.waitForExistence(timeout: 2) {
            optionCell.tap()
            return true
        }

        let optionText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", option)).firstMatch
        if optionText.waitForExistence(timeout: 2) {
            optionText.tap()
            return true
        }

        let wheel = app.pickerWheels.firstMatch
        if wheel.waitForExistence(timeout: 1) {
            wheel.adjust(toPickerWheelValue: option)
            return true
        }

        return false
    }

    private func selectCategoryOption(_ option: String) -> Bool {
        let optionButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", option)).firstMatch
        if optionButton.waitForExistence(timeout: 2) {
            optionButton.tap()
            return true
        }

        let optionCell = app.cells.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", option)).firstMatch
        if optionCell.waitForExistence(timeout: 2) {
            optionCell.tap()
            return true
        }

        let optionText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", option)).firstMatch
        if optionText.waitForExistence(timeout: 2) {
            optionText.tap()
            return true
        }

        let wheel = app.pickerWheels.firstMatch
        if wheel.waitForExistence(timeout: 1) {
            wheel.adjust(toPickerWheelValue: option)
            return true
        }

        return false
    }

    private func isExpandedFrequencySelected(_ option: String) -> Bool {
        let normalizedOption = option.lowercased()
        let cell = app.cells.containing(.staticText, identifier: "Tipo de Frecuencia").firstMatch
        if cell.exists {
            if let value = cell.value as? String,
               value.lowercased().contains(normalizedOption) {
                return true
            }
            if cell.label.lowercased().contains(normalizedOption) {
                return true
            }

            let match = cell.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", option)).firstMatch
            if match.exists {
                return true
            }
        }

        if let pickerValue = app.pickers["Tipo de Frecuencia"].value as? String,
           pickerValue.lowercased().contains(normalizedOption) {
            return true
        }

        if let wheelValue = app.pickerWheels.firstMatch.value as? String,
           wheelValue.lowercased().contains(normalizedOption) {
            return true
        }

        let inlineMatch = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", option)).firstMatch
        return inlineMatch.exists
    }

    private func isHabitTypeSelected(_ option: String) -> Bool {
        let normalizedOption = option.lowercased()
        let cell = app.cells.containing(.staticText, identifier: "Tipo").firstMatch
        if cell.exists {
            if let value = cell.value as? String,
               value.lowercased().contains(normalizedOption) {
                return true
            }

            let match = cell.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", option)).firstMatch
            if match.exists {
                return true
            }
        }

        if let pickerValue = app.pickers["Tipo"].value as? String,
           pickerValue.lowercased().contains(normalizedOption) {
            return true
        }

        let inlineMatch = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", option)).firstMatch
        return inlineMatch.exists
    }

    private func activateFrequencyDays(_ labels: [String]) -> Bool {
        let table = app.tables.firstMatch
        let scrollView = app.scrollViews.firstMatch
        let scrollContainer = table.exists ? table : scrollView

        for label in labels {
            if !activateFrequencyDay(label, scrollContainer: scrollContainer) {
                return false
            }
        }

        return true
    }

    private func activateFrequencyDay(_ label: String, scrollContainer: XCUIElement) -> Bool {
        for _ in 0..<6 {
            if let toggle = findFrequencyToggle(label: label), toggle.isHittable {
                if ensureToggleOn(toggle) {
                    return true
                }
            }

            if let cell = findFrequencyCell(label: label), cell.isHittable {
                tapRightSide(of: cell)
                Thread.sleep(forTimeInterval: 0.05)
                if let toggle = findFrequencyToggle(label: label), ensureToggleOn(toggle) {
                    return true
                }
            }

            scrollContainer.swipeUp()
        }

        print("No se pudo activar el toggle de frecuencia: \(label)")
        return false
    }

    private func findFrequencyToggle(label: String) -> XCUIElement? {
        let toggle = app.switches[label]
        if toggle.exists {
            return toggle
        }

        let cell = app.cells.containing(.staticText, identifier: label).firstMatch
        if cell.exists, cell.switches.count > 0 {
            return cell.switches.firstMatch
        }

        return nil
    }

    private func findFrequencyCell(label: String) -> XCUIElement? {
        let cell = app.cells.containing(.staticText, identifier: label).firstMatch
        return cell.exists ? cell : nil
    }

    private func ensureToggleOn(_ toggle: XCUIElement) -> Bool {
        if isToggleOn(toggle) {
            return true
        }

        toggle.tap()
        Thread.sleep(forTimeInterval: 0.05)
        return isToggleOn(toggle)
    }

    private func isToggleOn(_ toggle: XCUIElement) -> Bool {
        if let value = toggle.value as? String {
            let normalized = value.lowercased()
            return normalized == "1" || normalized == "on" || normalized == "true"
        }
        if let value = toggle.value as? NSNumber {
            return value.intValue != 0
        }
        return false
    }

    private func tapRightSide(of cell: XCUIElement) {
        let coordinate = cell.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
        coordinate.tap()
    }
}
