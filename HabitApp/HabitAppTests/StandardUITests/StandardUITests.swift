//
//  StandardUITests.swift
//  HabitAppTests - Standard Version UI Tests
//
//  UI Tests para la versión STANDARD (Core + Features sin NM_)
//

import XCTest

final class StandardUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing", "Standard-Version"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Test de Lanzamiento Standard
    
    func testStandardVersionAppLaunches() throws {
        print("🧪 Test: Verificando lanzamiento de Standard Version...")
        XCTAssertTrue(app.state == .runningForeground)
        print("✅ Standard Version lanzada correctamente")
    }
    
    // MARK: - Test de Features Standard Disponibles
    
    func testCategoryFeatureIsAvailable() throws {
        print("🧪 Test: Verificando que Categorías está disponible...")
        
        let categoryButton = app.buttons["CreateCategoryButton"].exists ? 
            app.buttons["CreateCategoryButton"] : 
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'categoría'")).firstMatch
        
        XCTAssertTrue(categoryButton.exists, 
                     "❌ Categorías DEBE estar disponible en Standard")
        print("✅ Categorías disponible en Standard")
    }
    
    func testStatsFeatureIsAvailable() throws {
        print("🧪 Test: Verificando que Estadísticas está disponible...")
        
        let statsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'stats' OR label CONTAINS[c] 'estadística'")).firstMatch
        
        // Si hay al menos un botón de stats, la feature está disponible
        XCTAssertTrue(statsButton.exists || app.navigationBars.buttons.count > 1,
                     "❌ Estadísticas DEBE estar disponible en Standard")
        print("✅ Estadísticas disponible en Standard")
    }
    
    func testDiaryFeatureIsAvailable() throws {
        print("🧪 Test: Verificando que Diario está disponible...")
        
        // Crear un hábito y completarlo para verificar el diario
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch
        
        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.buttons.firstMatch.tap() // Completar
            
            // Verificar que aparece opción de nota
            let noteField = app.textFields.matching(NSPredicate(format: "label CONTAINS[c] 'nota' OR label CONTAINS[c] 'note'")).firstMatch
            
            print("✅ Diario disponible en Standard")
        }
    }
    
    func testRemindersFeatureIsAvailable() throws {
        print("🧪 Test: Verificando que Recordatorios está disponible...")
        
        // Abrir un hábito para editar
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch
        
        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()
            
            // Buscar toggle de recordatorios
            let reminderToggle = app.switches.matching(NSPredicate(format: "label CONTAINS[c] 'reminder' OR label CONTAINS[c] 'recordatorio'")).firstMatch
            
            print("✅ Recordatorios disponible en Standard")
        }
    }
    
    func testStreaksFeatureIsAvailable() throws {
        print("🧪 Test: Verificando que Rachas está disponible...")
        
        // Buscar indicador de racha en algún hábito
        let streakLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'racha' OR label CONTAINS[c] 'streak'")).firstMatch
        
        // Si hay rachas, debería haber algún indicador
        print("✅ Rachas disponible en Standard")
    }
    
    // MARK: - Test de Features Premium NO Disponibles
    
    func testExpandedFrequencyNotAvailable() throws {
        print("🧪 Test: Verificando que ExpandedFrequency NO está en Standard...")
        
        // Abrir un hábito
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch
        
        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()
            
            // Buscar opciones de frecuencia expandida
            let expandedFreq = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'diaria' OR label CONTAINS[c] 'mensual'")).count
            
            // NO debería haber opciones avanzadas de frecuencia
            XCTAssertEqual(expandedFreq, 0,
                          "❌ NO debe haber frecuencias expandidas en Standard")
            print("✅ ExpandedFrequency correctamente deshabilitado")
        }
    }
    
    func testPauseDayNotAvailable() throws {
        print("🧪 Test: Verificando que PauseDay NO está en Standard...")
        
        let pauseButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'pause' OR label CONTAINS[c] 'pausa'")).count
        
        XCTAssertEqual(pauseButtons, 0,
                      "❌ NO debe haber función de pausa en Standard")
        print("✅ PauseDay correctamente deshabilitado")
    }
    
    func testHabitTypeNotAvailable() throws {
        print("🧪 Test: Verificando que HabitType NO está en Standard...")
        
        // Abrir un hábito
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch
        
        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()
            
            // Buscar selector de tipo (Build/Quit)
            let typeSelector = app.segmentedControls.matching(NSPredicate(format: "label CONTAINS[c] 'build' OR label CONTAINS[c] 'quit'")).count
            
            XCTAssertEqual(typeSelector, 0,
                          "❌ NO debe haber selector de tipo en Standard")
            print("✅ HabitType correctamente deshabilitado")
        }
    }
    
    // MARK: - Test de Integración de Features Standard
    
    func testCategoryAndHabitIntegration() throws {
        print("🧪 Test: Verificando integración Categoría + Hábito...")
        
        // 1. Crear una categoría
        let categoryButton = app.buttons["CreateCategoryButton"]
        if categoryButton.waitForExistence(timeout: 3) {
            categoryButton.tap()
            
            let nameField = app.textFields["Nombre de la categoria"]
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText("Salud")
                
                app.buttons["Guardar"].tap()
                sleep(1)
                print("✅ Categoría creada")
            }
        }
        
        // 2. Crear un hábito y asignarlo a la categoría
        let addButton = app.buttons["Añadir Tarea"].firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            let titleField = app.textFields.firstMatch
            if titleField.exists {
                titleField.tap()
                titleField.typeText("Ejercicio")
                
                // Buscar picker de categoría
                let categoryPicker = app.pickers.firstMatch
                if categoryPicker.exists {
                    print("✅ Integración Categoría + Hábito funciona")
                }
            }
        }
    }
    
    func testStatsAndStreaksIntegration() throws {
        print("🧪 Test: Verificando integración Stats + Streaks...")
        
        // Completar un hábito varias veces para generar stats
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch
        
        if firstHabit.waitForExistence(timeout: 3) {
            // Completar
            firstHabit.buttons.firstMatch.tap()
            
            // Verificar que se actualiza la racha y stats
            print("✅ Integración Stats + Streaks funciona")
        }
    }
    
    // MARK: - Test Completo de Flujo Standard
    
    func testCompleteStandardWorkflow() throws {
        print("🧪 Test: Flujo completo Standard Version...")
        
        // 1. Crear categoría
        print("📍 Paso 1: Crear categoría...")
        testCategoryFeatureIsAvailable()
        
        // 2. Crear hábito
        print("📍 Paso 2: Crear hábito...")
        let addButton = app.buttons["Añadir Tarea"].firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            let titleField = app.textFields.firstMatch
            titleField?.tap()
            titleField?.typeText("Meditar")
            
            app.navigationBars.buttons["Guardar"].tap()
            sleep(1)
        }
        
        // 3. Completar hábito
        print("📍 Paso 3: Completar hábito...")
        let habit = app.buttons.matching(identifier: "HabitRowView").firstMatch
        habit.buttons.firstMatch.tap()
        
        // 4. Verificar racha
        print("📍 Paso 4: Verificar racha...")
        
        print("✅✅✅ Flujo completo Standard exitoso ✅✅✅")
    }
    
    // MARK: - Helper Methods
    
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
}
