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
        let predicates = ["crear", "añadir", "agregar", "add", "new"]
        for predicate in predicates {
            let button = buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", predicate)).firstMatch
            if button.exists {
                return button
            }
        }
        return nil
    }
    
    var saveButton: XCUIElement? {
        if navigationBars.buttons["Guardar"].exists {
            return navigationBars.buttons["Guardar"]
        }
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
}
