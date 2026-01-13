//
//  UIElements.swift
//  HabitAppTestsAux
//
//  Definiciones de elementos UI comunes
//  IMPORTANTE: Este archivo debe agregarse a los Target Membership de:
//  - HabitAppCoreUITests
//  - HabitAppStandardUITests
//  - HabitAppPremiumUITests
//

import XCTest

/// Extensión para acceder fácilmente a elementos comunes de la UI
extension XCUIApplication {
    
    // MARK: - Vistas Principales
    
    var habitListView: XCUIElement {
        return otherElements["HabitListView"]
    }
    
    var createCategoryView: XCUIElement {
        return sheets.firstMatch.exists ? sheets.firstMatch : otherElements["CreateCategoryView"]
    }
    
    // MARK: - Botones Comunes
    
    var addButton: XCUIElement? {
        // Buscar botón con label "Crear Habito" (exacto)
        let exactMatch = buttons["Crear Habito"]
        if exactMatch.exists {
            return exactMatch
        }
        
        // Buscar por contains en label
        let byLabel = buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Crear Habito'")).firstMatch
        if byLabel.exists {
            return byLabel
        }
        
        // Buscar cualquier botón con plus icon y texto crear
        let withIcon = buttons.containing(NSPredicate(format: "label CONTAINS[c] 'crear'")).firstMatch
        if withIcon.exists {
            return withIcon
        }
        
        return nil
    }
    
    var saveButton: XCUIElement? {
        // Buscar en navigation bar primero (es donde debería estar)
        let navBarButtons = navigationBars.buttons
        for i in 0..<navBarButtons.count {
            let button = navBarButtons.element(boundBy: i)
            if button.label == "Guardar" {
                return button
            }
        }
        
        // Buscar en toolbars
        let toolbarButtons = toolbars.buttons
        for i in 0..<toolbarButtons.count {
            let button = toolbarButtons.element(boundBy: i)
            if button.label == "Guardar" {
                return button
            }
        }
        
        // Último recurso: buscar en todos los botones
        return buttons["Guardar"].exists ? buttons["Guardar"] : nil
    }
    
    // MARK: - Hábitos
    
    var firstHabit: XCUIElement {
        return buttons.matching(identifier: "HabitRowView").firstMatch
    }
    
    var allHabits: XCUIElementQuery {
        return buttons.matching(identifier: "HabitRowView")
    }
    
    // MARK: - Text Fields Comunes
    
    var categoryNameField: XCUIElement {
        return textFields["Nombre de la categoria"]
    }
    
    var habitTitleField: XCUIElement {
        // Buscar por placeholder "Título"
        let byPlaceholder = textFields["Título"]
        if byPlaceholder.exists {
            return byPlaceholder
        }
        
        // Buscar en todos los text fields disponibles
        let allFields = textFields
        if allFields.count > 0 {
            // En HabitModifyView, el primer text field es el de título
            return allFields.element(boundBy: 0)
        }
        
        return textFields.firstMatch
    }
    
    // MARK: - Búsqueda de Elementos por Keyword
    
    func findElement(withKeywords keywords: [String], in query: XCUIElementQuery) -> XCUIElement? {
        for keyword in keywords {
            let element = query.matching(NSPredicate(format: "label CONTAINS[c] %@", keyword)).firstMatch
            if element.exists {
                return element
            }
        }
        return nil
    }
    
    func hasElement(withKeywords keywords: [String], in query: XCUIElementQuery) -> Bool {
        return findElement(withKeywords: keywords, in: query) != nil
    }
    
    func countElements(withKeywords keywords: [String], in query: XCUIElementQuery) -> Int {
        var total = 0
        for keyword in keywords {
            total += query.matching(NSPredicate(format: "label CONTAINS[c] %@", keyword)).count
        }
        return total
    }
    
    // MARK: - Debug Helpers
    
    func debugPrintButtons() {
        print("📋 Botones disponibles:")
        let allButtons = buttons
        for i in 0..<min(allButtons.count, 20) {
            let button = allButtons.element(boundBy: i)
            if button.exists {
                print("  - [\(i)] '\(button.label)' (enabled: \(button.isEnabled))")
            }
        }
    }
    
    func debugPrintTextFields() {
        print("📋 Text fields disponibles:")
        let allFields = textFields
        for i in 0..<allFields.count {
            let field = allFields.element(boundBy: i)
            if field.exists {
                print("  - [\(i)] placeholder: '\(field.placeholderValue ?? "N/A")'")
            }
        }
    }
}

/// Helper struct para predicados comunes
struct UIPredicates {
    static let category = ["categor"]
    static let stats = ["stats", "estad"]
    static let diary = ["nota", "note", "diary", "diario"]
    static let reminder = ["reminder", "recordatorio"]
    static let streak = ["racha", "streak"]
    static let expandedFrequency = ["diaria", "mensual", "daily", "monthly"]
    static let pauseDay = ["pause", "pausa"]
    static let habitType = ["build", "quit", "construir", "dejar"]
    static let frequency = ["frecuencia", "frequency"]
    static let calendary = ["calendar", "calendario"]
    static let suggestedHabit = ["sugerido", "suggested", "sugerir", "suggest"]
}
