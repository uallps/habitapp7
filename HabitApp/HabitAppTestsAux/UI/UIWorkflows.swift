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
        guard let addButton = app.addButton else { return false }
        
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            let titleField = app.habitTitleField
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText(title)
                
                if let saveButton = app.saveButton {
                    saveButton.tap()
                    sleep(1)
                    return true
                }
            }
        }
        return false
    }
    
    /// Toggle de completitud del primer hábito
    @discardableResult
    func toggleFirstHabitCompletion() -> Bool {
        let firstHabit = app.firstHabit
        
        if firstHabit.waitForExistence(timeout: 3) {
            let completionButton = firstHabit.buttons.firstMatch
            if completionButton.exists {
                completionButton.tap()
                return true
            }
        }
        return false
    }
    
    // MARK: - Workflows de Categorías
    
    /// Crea una categoría completa
    @discardableResult
    func createCategory(name: String) -> Bool {
        guard let categoryButton = findCategoryButton() else { return false }
        
        categoryButton.tap()
        
        let categoryView = app.createCategoryView
        if !categoryView.waitForExistence(timeout: 3) {
            return false
        }
        
        // Asegurar que estamos en modo Crear
        let segmentedControl = app.segmentedControls.firstMatch
        if segmentedControl.exists {
            let createButton = segmentedControl.buttons["Crear"]
            if createButton.exists && !createButton.isSelected {
                createButton.tap()
            }
        }
        
        let nameField = app.categoryNameField
        if nameField.waitForExistence(timeout: 2) {
            nameField.tap()
            sleep(1)
            nameField.typeText(name)
            
            if let saveButton = app.saveButton, saveButton.isEnabled {
                saveButton.tap()
                sleep(1)
                return true
            }
        }
        
        return false
    }
    
    /// Elimina una categoría por nombre
    @discardableResult
    func deleteCategory(name: String) -> Bool {
        guard let categoryButton = findCategoryButton() else { return false }
        
        categoryButton.tap()
        
        let deleteSegment = app.buttons["Eliminar"]
        if !deleteSegment.waitForExistence(timeout: 3) {
            return false
        }
        
        deleteSegment.tap()
        
        let picker = app.pickers.firstMatch
        if picker.waitForExistence(timeout: 2) {
            picker.tap()
            
            let pickerWheel = app.pickerWheels.firstMatch
            if pickerWheel.exists {
                pickerWheel.adjust(toPickerWheelValue: name)
            }
            
            let deleteButton = app.buttons["Eliminar categoria seleccionada"]
            if deleteButton.exists && deleteButton.isEnabled {
                deleteButton.tap()
                sleep(1)
                return true
            }
        }
        
        return false
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
            
            if let saveButton = app.saveButton {
                saveButton.tap()
                sleep(1)
                return true
            }
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
