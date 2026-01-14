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
    
    func habitMenuButton(in habit: XCUIElement) -> XCUIElement? {
        print("🔍 Iniciando búsqueda exhaustiva del botón de menú...")
        
        // Dar tiempo para que el elemento se renderice
        Thread.sleep(forTimeInterval: 0.3)
        
        // Estrategia 1: Buscar por accessibilityIdentifier en buttons
        let byId = habit.buttons["HabitMenuButton"]
        if byId.exists {
            print("✅ Encontrado botón de menú por ID en buttons")
            return byId
        }
        
        // Estrategia 2: Buscar en otros elementos con el identifier
        let otherById = habit.otherElements["HabitMenuButton"]
        if otherById.exists {
            print("✅ Encontrado botón de menú por ID en otherElements")
            return otherById
        }
        
        // Estrategia 3: Buscar por imagen de ellipsis
        let ellipsisImage = habit.images["ellipsis"]
        if ellipsisImage.exists {
            print("✅ Encontrado botón de menú por imagen ellipsis")
            return ellipsisImage
        }
        
        // Estrategia 4: Buscar en descendientes con el identifier
        let descendantById = habit.descendants(matching: .any)["HabitMenuButton"]
        if descendantById.exists {
            print("✅ Encontrado botón de menú por ID en descendants")
            return descendantById
        }
        
        // Estrategia 5: Recorrer todos los botones buscando ellipsis
        print("🔍 Recorriendo todos los botones del hábito...")
        let allButtons = habit.buttons
        for i in 0..<allButtons.count {
            let button = allButtons.element(boundBy: i)
            if button.exists {
                print("  - Botón [\(i)]: label='\(button.label)', id='\(button.identifier)'")
                if button.label.contains("ellipsis") || button.identifier == "HabitMenuButton" {
                    print("✅ Encontrado botón de menú en índice \(i)")
                    return button
                }
            }
        }
        
        // Estrategia 6: Buscar imágenes con ellipsis
        print("🔍 Recorriendo todas las imágenes del hábito...")
        let allImages = habit.images
        for i in 0..<allImages.count {
            let image = allImages.element(boundBy: i)
            if image.exists {
                print("  - Imagen [\(i)]: label='\(image.label)', id='\(image.identifier)'")
                if image.label.contains("ellipsis") || image.identifier.contains("ellipsis") {
                    print("✅ Encontrado botón de menú como imagen en índice \(i)")
                    return image
                }
            }
        }
        
        // Estrategia 7: Buscar en otros elementos
        print("🔍 Recorriendo otros elementos del hábito...")
        let otherElements = habit.otherElements
        for i in 0..<min(otherElements.count, 20) {
            let element = otherElements.element(boundBy: i)
            if element.exists {
                print("  - Otro elemento [\(i)]: id='\(element.identifier)'")
                if element.identifier == "HabitMenuButton" {
                    print("✅ Encontrado botón de menú en otros elementos índice \(i)")
                    return element
                }
            }
        }
        
        // Estrategia 8: Búsqueda recursiva exhaustiva
        print("🔍 Iniciando búsqueda recursiva del botón de menú...")
        if let foundButton = findMenuButtonRecursively(in: habit, depth: 0) {
            print("✅ Botón de menú encontrado mediante búsqueda recursiva!")
            return foundButton
        }
        
        // Estrategia 9: Coordenadas - último recurso (tap en esquina derecha)
        print("⚠️ No se encontró botón de menú, intentando tap por coordenadas...")
        print("📊 Información del hábito:")
        print("   - Frame: \(habit.frame)")
        print("   - isHittable: \(habit.isHittable)")
        print("   - Botones totales: \(allButtons.count)")
        print("   - Imágenes totales: \(allImages.count)")
        
        // Si no se encuentra, devolver nil para que el test falle con información
        return nil
    }
    
    // Función recursiva para buscar el botón de menú
    private func findMenuButtonRecursively(in element: XCUIElement, depth: Int, maxDepth: Int = 5) -> XCUIElement? {
        guard depth < maxDepth else { return nil }
        
        let indent = String(repeating: "  ", count: depth)
        print("\(indent)📍 Explorando menú nivel \(depth)")
        
        // Buscar buttons con HabitMenuButton
        let buttons = element.buttons
        for i in 0..<buttons.count {
            let button = buttons.element(boundBy: i)
            if button.exists && (button.identifier == "HabitMenuButton" || button.label.contains("ellipsis")) {
                print("\(indent)✅ Encontrado en botones nivel \(depth)")
                return button
            }
        }
        
        // Buscar images con ellipsis
        let images = element.images
        for i in 0..<images.count {
            let image = images.element(boundBy: i)
            if image.exists && (image.label.contains("ellipsis") || image.identifier.contains("ellipsis")) {
                print("\(indent)✅ Encontrado en imágenes nivel \(depth)")
                return image
            }
        }
        
        // Explorar hijos
        let children = element.children(matching: .any)
        for i in 0..<min(children.count, 10) {
            let child = children.element(boundBy: i)
            if child.exists {
                if let found = findMenuButtonRecursively(in: child, depth: depth + 1, maxDepth: maxDepth) {
                    return found
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Text Fields Comunes
    
    var categoryNameField: XCUIElement {
        print("🔍 Iniciando búsqueda exhaustiva del campo de categoría...")
        
        // Estrategia 1: Búsqueda directa por placeholder
        let byPlaceholder = textFields["Nombre de la categoria"]
        if byPlaceholder.exists {
            print("✅ Campo encontrado por placeholder")
            return byPlaceholder
        }
        
        // Estrategia 2: Búsqueda por accessibilityIdentifier
        let byId = textFields["CategoryNameField"]
        if byId.exists {
            print("✅ Campo encontrado por ID")
            return byId
        }
        
        // Estrategia 3: Recorrer todos los text fields
        print("🔍 Recorriendo todos los text fields directos...")
        let allFields = textFields
        for i in 0..<allFields.count {
            let field = allFields.element(boundBy: i)
            if field.exists {
                print("  - TextField [\(i)]: placeholder='\(field.placeholderValue ?? "N/A")', value='\(field.value as? String ?? "")'")
                if field.placeholderValue == "Nombre de la categoria" {
                    print("✅ Campo encontrado en índice \(i)")
                    return field
                }
            }
        }
        
        // Estrategia 4: Búsqueda en profundidad recursiva - EXHAUSTIVA
        print("🔍 Iniciando búsqueda recursiva en profundidad...")
        if let foundField = findTextFieldRecursively(in: self, targetPlaceholder: "Nombre de la categoria", depth: 0) {
            print("✅ Campo encontrado mediante búsqueda recursiva!")
            return foundField
        }
        
        // Estrategia 5: Buscar en todas las celdas
        print("🔍 Buscando en todas las celdas...")
        let allCells = cells
        for i in 0..<allCells.count {
            let cell = allCells.element(boundBy: i)
            if cell.exists {
                print("  - Celda [\(i)]: '\(cell.label)'")
                // Buscar text fields dentro de esta celda
                let fieldsInCell = cell.textFields
                for j in 0..<fieldsInCell.count {
                    let field = fieldsInCell.element(boundBy: j)
                    if field.exists {
                        print("    - TextField en celda: '\(field.placeholderValue ?? "N/A")'")
                        return field
                    }
                }
            }
        }
        
        // Estrategia 6: Buscar celda con "Nombre" y devolverla
        print("🔍 Buscando celda con header 'Nombre'...")
        let nameCell = cells
            .containing(.staticText, identifier: "Nombre")
            .firstMatch
        
        if nameCell.exists {
            print("✅ Celda encontrada, devolviendo celda para tap")
            return nameCell
        }
        
        // Estrategia 7: Si hay algún text field, devolver el primero
        if allFields.count > 0 {
            print("⚠️ Devolviendo primer text field disponible")
            return allFields.element(boundBy: 0)
        }
        
        // Último recurso
        print("❌ No se encontró ningún text field, devolviendo firstMatch")
        return textFields.firstMatch
    }
    
    // Función recursiva para buscar TextFields en profundidad
    private func findTextFieldRecursively(in element: XCUIElement, targetPlaceholder: String, depth: Int, maxDepth: Int = 10) -> XCUIElement? {
        // Límite de profundidad para evitar bucles infinitos
        guard depth < maxDepth else { return nil }
        
        let indent = String(repeating: "  ", count: depth)
        print("\(indent)📍 Explorando nivel \(depth): \(element.elementType) '\(element.identifier)'")
        
        // Buscar text fields directamente en este elemento
        let textFields = element.textFields
        print("\(indent)   TextFields encontrados: \(textFields.count)")
        for i in 0..<textFields.count {
            let field = textFields.element(boundBy: i)
            if field.exists {
                let placeholder = field.placeholderValue ?? ""
                print("\(indent)   - TextField [\(i)]: '\(placeholder)'")
                if placeholder == targetPlaceholder || placeholder.contains("categoria") {
                    return field
                }
            }
        }
        
        // Explorar todos los hijos
        let children = element.children(matching: .any)
        print("\(indent)   Hijos encontrados: \(children.count)")
        for i in 0..<min(children.count, 20) {  // Limitar a 20 hijos por nivel
            let child = children.element(boundBy: i)
            if child.exists {
                if let found = findTextFieldRecursively(in: child, targetPlaceholder: targetPlaceholder, depth: depth + 1, maxDepth: maxDepth) {
                    return found
                }
            }
        }
        
        return nil
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
    
    func debugPrintCells() {
        print("📋 Celdas disponibles:")
        let allCells = cells
        for i in 0..<min(allCells.count, 10) {
            let cell = allCells.element(boundBy: i)
            if cell.exists {
                print("  - [\(i)] identifier: '\(cell.identifier)', label: '\(cell.label)'")
                // Imprimir elementos dentro de la celda
                let textsInCell = cell.staticTexts
                if textsInCell.count > 0 {
                    print("      Textos en celda:")
                    for j in 0..<min(textsInCell.count, 5) {
                        let text = textsInCell.element(boundBy: j)
                        if text.exists {
                            print("        - '\(text.label)' (id: '\(text.identifier)')")
                        }
                    }
                }
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
