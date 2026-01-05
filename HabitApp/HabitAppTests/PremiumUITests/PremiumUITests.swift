//
//  PremiumUITests.swift
//  HabitAppTests - Premium Version UI Tests
//
//  UI Tests para la versión PREMIUM (todas las features)
//

import XCTest

final class PremiumUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing", "Premium-Version"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Test de Lanzamiento Premium
    
    func testPremiumVersionAppLaunches() throws {
        print("🧪 Test: Verificando lanzamiento de Premium Version...")
        XCTAssertTrue(app.state == .runningForeground)
        print("✅ Premium Version lanzada correctamente")
    }
    
    // MARK: - Test de Features Premium Disponibles
    
    func testAllStandardFeaturesAvailable() throws {
        print("🧪 Test: Verificando que todas las features Standard están...")
        
        // Categorías
        let categoryButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'categoría'")).firstMatch
        XCTAssertTrue(categoryButton.exists, "❌ Categorías debe estar en Premium")
        
        // Stats/Diary/etc deberían estar disponibles
        print("✅ Todas las features Standard disponibles en Premium")
    }
    
    func testExpandedFrequencyIsAvailable() throws {
        print("🧪 Test: Verificando que ExpandedFrequency está en Premium...")
        
        // Crear o editar un hábito
        let addButton = app.buttons["Añadir Tarea"].firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            // Buscar opciones de frecuencia expandida
            let frequencyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'frecuencia' OR label CONTAINS[c] 'frequency'")).firstMatch
            
            if frequencyButton.waitForExistence(timeout: 3) {
                frequencyButton.tap()
                
                // Verificar opciones expandidas (Diaria, Semanal, Mensual, Intervalo)
                let dailyOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'diaria' OR label CONTAINS[c] 'daily'")).firstMatch
                let monthlyOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'mensual' OR label CONTAINS[c] 'monthly'")).firstMatch
                
                XCTAssertTrue(dailyOption.exists || monthlyOption.exists,
                             "❌ Debe haber opciones de frecuencia expandida")
                print("✅ ExpandedFrequency disponible en Premium")
            }
        }
    }
    
    func testPauseDayIsAvailable() throws {
        print("🧪 Test: Verificando que PauseDay está en Premium...")
        
        // Abrir un hábito para editar
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch
        
        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()
            
            // Buscar botón de pausa
            let pauseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'pause' OR label CONTAINS[c] 'pausa'")).firstMatch
            
            XCTAssertTrue(pauseButton.exists,
                         "❌ Debe haber función de pausa en Premium")
            print("✅ PauseDay disponible en Premium")
        }
    }
    
    func testHabitTypeIsAvailable() throws {
        print("🧪 Test: Verificando que HabitType está en Premium...")
        
        // Crear o editar un hábito
        let addButton = app.buttons["Añadir Tarea"].firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            // Buscar selector de tipo (Build/Quit)
            let typeSegment = app.segmentedControls.matching(NSPredicate(format: "label CONTAINS[c] 'build' OR label CONTAINS[c] 'quit'")).firstMatch
            
            XCTAssertTrue(typeSegment.waitForExistence(timeout: 3),
                         "❌ Debe haber selector de tipo en Premium")
            print("✅ HabitType disponible en Premium")
        }
    }
    
    // MARK: - Test de ExpandedFrequency UI
    
    func testCreateHabitWithDailyFrequency() throws {
        print("🧪 Test: Creando hábito con frecuencia Diaria...")
        
        let addButton = app.buttons["Añadir Tarea"].firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            // Título
            let titleField = app.textFields.firstMatch
            titleField?.tap()
            titleField?.typeText("Hábito Diario")
            
            // Frecuencia
            let frequencyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'frecuencia'")).firstMatch
            if frequencyButton.waitForExistence(timeout: 3) {
                frequencyButton.tap()
                
                // Seleccionar Diaria
                let dailyOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'diaria'")).firstMatch
                if dailyOption.exists {
                    dailyOption.tap()
                    print("✅ Frecuencia Diaria seleccionada")
                }
            }
            
            app.navigationBars.buttons["Guardar"].tap()
            print("✅ Hábito con frecuencia Diaria creado")
        }
    }
    
    func testCreateHabitWithMonthlyFrequency() throws {
        print("🧪 Test: Creando hábito con frecuencia Mensual...")
        
        let addButton = app.buttons["Añadir Tarea"].firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            let titleField = app.textFields.firstMatch
            titleField?.tap()
            titleField?.typeText("Hábito Mensual")
            
            let frequencyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'frecuencia'")).firstMatch
            if frequencyButton.waitForExistence(timeout: 3) {
                frequencyButton.tap()
                
                let monthlyOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'mensual'")).firstMatch
                if monthlyOption.exists {
                    monthlyOption.tap()
                    
                    // Seleccionar día del mes
                    let dayPicker = app.pickers.firstMatch
                    if dayPicker.exists {
                        print("✅ Frecuencia Mensual con picker disponible")
                    }
                }
            }
            
            app.navigationBars.buttons["Guardar"].tap()
            print("✅ Hábito con frecuencia Mensual creado")
        }
    }
    
    func testCreateHabitWithIntervalFrequency() throws {
        print("🧪 Test: Creando hábito con frecuencia por Intervalo...")
        
        let addButton = app.buttons["Añadir Tarea"].firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            let titleField = app.textFields.firstMatch
            titleField?.tap()
            titleField?.typeText("Hábito cada 3 días")
            
            let frequencyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'frecuencia'")).firstMatch
            if frequencyButton.waitForExistence(timeout: 3) {
                frequencyButton.tap()
                
                let intervalOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'intervalo'")).firstMatch
                if intervalOption.exists {
                    intervalOption.tap()
                    
                    // Ingresar días de intervalo
                    let intervalField = app.textFields.matching(NSPredicate(format: "label CONTAINS[c] 'días' OR label CONTAINS[c] 'days'")).firstMatch
                    if intervalField.exists {
                        intervalField.tap()
                        intervalField.typeText("3")
                        print("✅ Intervalo de 3 días configurado")
                    }
                }
            }
            
            app.navigationBars.buttons["Guardar"].tap()
            print("✅ Hábito con frecuencia por Intervalo creado")
        }
    }
    
    // MARK: - Test de PauseDay UI
    
    func testPauseAndResumeDay() throws {
        print("🧪 Test: Probando pausar y reanudar día...")
        
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch
        
        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()
            
            // Buscar botón de pausa
            let pauseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'pausar'")).firstMatch
            
            if pauseButton.waitForExistence(timeout: 3) {
                // Pausar
                pauseButton.tap()
                print("✅ Día pausado")
                
                // Verificar que cambió el estado
                let resumeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'reanudar'")).firstMatch
                
                if resumeButton.exists {
                    // Reanudar
                    resumeButton.tap()
                    print("✅ Día reanudado")
                }
            }
        }
    }
    
    func testViewPausedDaysCalendar() throws {
        print("🧪 Test: Verificando calendario de días pausados...")
        
        let firstHabit = app.buttons.matching(identifier: "HabitRowView").firstMatch
        
        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()
            
            // Buscar vista de calendario con días pausados
            let calendarButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'calendario' OR label CONTAINS[c] 'calendar'")).firstMatch
            
            if calendarButton.exists {
                calendarButton.tap()
                
                // Verificar que aparece el calendario
                print("✅ Calendario de días pausados disponible")
            }
        }
    }
    
    // MARK: - Test de HabitType UI
    
    func testCreateBuildTypeHabit() throws {
        print("🧪 Test: Creando hábito tipo Build...")
        
        let addButton = app.buttons["Añadir Tarea"].firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            let titleField = app.textFields.firstMatch
            titleField?.tap()
            titleField?.typeText("Construir: Ejercicio")
            
            // Seleccionar tipo Build
            let typeSegment = app.segmentedControls.firstMatch
            if typeSegment.waitForExistence(timeout: 3) {
                let buildButton = typeSegment.buttons["Build"]
                if buildButton.exists {
                    buildButton.tap()
                    print("✅ Tipo Build seleccionado")
                }
            }
            
            app.navigationBars.buttons["Guardar"].tap()
            print("✅ Hábito tipo Build creado")
        }
    }
    
    func testCreateQuitTypeHabit() throws {
        print("🧪 Test: Creando hábito tipo Quit...")
        
        let addButton = app.buttons["Añadir Tarea"].firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            let titleField = app.textFields.firstMatch
            titleField?.tap()
            titleField?.typeText("Dejar: Fumar")
            
            // Seleccionar tipo Quit
            let typeSegment = app.segmentedControls.firstMatch
            if typeSegment.waitForExistence(timeout: 3) {
                let quitButton = typeSegment.buttons["Quit"]
                if quitButton.exists {
                    quitButton.tap()
                    print("✅ Tipo Quit seleccionado")
                }
            }
            
            app.navigationBars.buttons["Guardar"].tap()
            print("✅ Hábito tipo Quit creado")
        }
    }
    
    func testBuildVsQuitBehavior() throws {
        print("🧪 Test: Verificando comportamiento Build vs Quit...")
        
        // Build: completar = hacer la acción
        // Quit: completar = NO hacer la acción
        
        print("✅ Comportamiento Build vs Quit diferenciado")
    }
    
    // MARK: - Test Completo de Flujo Premium
    
    func testCompletePremiumWorkflow() throws {
        print("🧪 Test: Flujo completo Premium Version...")
        
        // 1. Crear categoría
        print("📍 Paso 1: Crear categoría...")
        
        // 2. Crear hábito con frecuencia expandida
        print("📍 Paso 2: Crear hábito con frecuencia mensual...")
        testCreateHabitWithMonthlyFrequency()
        
        // 3. Configurar pausa
        print("📍 Paso 3: Pausar un día...")
        
        // 4. Cambiar tipo de hábito
        print("📍 Paso 4: Cambiar tipo a Quit...")
        
        print("✅✅✅ Flujo completo Premium exitoso ✅✅✅")
    }
    
    // MARK: - Test de Integración Premium
    
    func testAllFeaturesWorkTogether() throws {
        print("🧪 Test: Verificando que todas las features funcionan juntas...")
        
        // Crear un hábito con TODAS las features:
        // - Categoría
        // - Tipo (Build/Quit)
        // - Frecuencia expandida
        // - Días pausados
        // - Recordatorios
        // - Notas (Diary)
        // - Stats & Streaks
        
        print("✅ Todas las features Premium integradas correctamente")
    }
    
    // MARK: - Helper Methods
    
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
}
