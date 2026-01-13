//
//  PremiumUITests.swift
//  HabitAppPremiumUITests
//
//  UI Tests para HabitApp Premium Version
//  Incluye: Core + Standard + Todos los Plugins NM_*
//  (Category, Stats, Diary, Reminders, Streaks, ExpandedFrequency, PauseDay, Type, Calendary, SuggestedHabit)
//

import XCTest

final class PremiumUITests: UITestBase {
    
    override var launchArguments: [String] {
        return ["UI-Testing", "Premium-Version"]
    }
    
    var workflows: UIWorkflows {
        return UIWorkflows(app: app)
    }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Test de Lanzamiento
    
    func testAppLaunches() {
        assertAppIsRunning()
    }
    
    // MARK: - Test de Funcionalidad Básica
    
    func testCreateBasicHabit() {
        let result = workflows.createBasicHabit(title: "Habito Premium")
        XCTAssertTrue(result, "Debe poder crear un habito basico")
    }
    
    func testToggleHabitCompletion() {
        workflows.createBasicHabit(title: "Habito a Completar")
        
        let success = workflows.toggleFirstHabitCompletion()
        XCTAssertTrue(success, "Debe poder marcar habito como completado")
    }
    
    // MARK: - Test de Features Standard DISPONIBLES
    
    func testCategoryFeatureAvailable() {
        XCTAssertNotNil(findCategoryButton(), "Debe existir boton de categorias en Premium")
    }
    
    func testStatsFeatureAvailable() {
        assertFeatureAvailable(keywords: UIPredicates.stats,
                              message: "Estadisticas debe estar disponible en Premium")
    }
    
    func testStreaksFeatureAvailable() {
        assertFeatureAvailable(keywords: UIPredicates.streak,
                              message: "Rachas debe estar disponible en Premium")
    }
    
    func testDiaryFeatureAvailable() {
        workflows.createBasicHabit(title: "Habito con Diario")
        workflows.toggleFirstHabitCompletion()
        
        assertFeatureAvailable(keywords: UIPredicates.diary,
                              message: "Diario debe estar disponible en Premium")
    }
    
    func testRemindersFeatureAvailable() {
        assertFeatureAvailable(keywords: UIPredicates.reminder,
                              message: "Recordatorios debe estar disponible en Premium")
    }
    
    // MARK: - Test de Features Premium DISPONIBLES
    
    func testExpandedFrequencyAvailable() {
        assertFeatureAvailable(keywords: UIPredicates.expandedFrequency,
                              message: "Frecuencia expandida debe estar disponible en Premium")
    }
    
    func testPauseDayAvailable() {
        assertFeatureAvailable(keywords: UIPredicates.pauseDay,
                              message: "Funcion de pausa debe estar disponible en Premium")
    }
    
    func testHabitTypeAvailable() {
        assertFeatureAvailable(keywords: UIPredicates.habitType,
                              message: "Selector de tipo debe estar disponible en Premium")
    }
    
    func testCalendaryAvailable() {
        assertFeatureAvailable(keywords: UIPredicates.calendary,
                              message: "Calendario debe estar disponible en Premium")
    }
    
    func testSuggestedHabitAvailable() {
        assertFeatureAvailable(keywords: UIPredicates.suggestedHabit,
                              message: "Habitos sugeridos debe estar disponible en Premium")
    }
    
    // MARK: - Test de Categorías
    
    func testCreateCategory() {
        let result = workflows.createCategory(name: "Premium")
        XCTAssertTrue(result, "Debe poder crear una categoria")
    }
    
    func testCreateMultipleCategories() {
        let categories = ["VIP", "Elite", "Pro"]
        
        for category in categories {
            let result = workflows.createCategory(name: category)
            XCTAssertTrue(result, "Debe poder crear categoria: \(category)")
        }
    }
    
    func testDeleteCategory() {
        workflows.createCategory(name: "Categoria Premium Temp")
        
        let result = workflows.deleteCategory(name: "Categoria Premium Temp")
        XCTAssertTrue(result, "Debe poder eliminar categoria")
    }
    
    // MARK: - Test de ExpandedFrequency
    
    func testCreateHabitWithDailyFrequency() {
        let result = workflows.createHabitWithExpandedFrequency(title: "Habito Diario", frequency: "diaria")
        XCTAssertTrue(result, "Debe poder crear habito con frecuencia diaria")
    }
    
    func testCreateHabitWithMonthlyFrequency() {
        let result = workflows.createHabitWithExpandedFrequency(title: "Habito Mensual", frequency: "mensual")
        XCTAssertTrue(result, "Debe poder crear habito con frecuencia mensual")
    }
    
    // MARK: - Test de PauseDay
    
    func testPauseHabit() {
        workflows.createBasicHabit(title: "Habito para Pausar")
        
        let result = workflows.pauseFirstHabit()
        XCTAssertTrue(result, "Debe poder pausar un habito")
    }
    
    // MARK: - Test de HabitType
    
    func testCreateBuildTypeHabit() {
        guard let addButton = app.addButton else {
            XCTFail("No se encontro boton de añadir")
            return
        }
        
        guard addButton.waitForExistence(timeout: 3) else {
            XCTFail("Boton de añadir no aparece")
            return
        }
        
        addButton.tap()
        Thread.sleep(forTimeInterval: 1)
        
        // Llenar título
        let titleField = app.habitTitleField
        XCTAssertTrue(titleField.waitForExistence(timeout: 3), "Debe aparecer campo de titulo")
        titleField.tap()
        Thread.sleep(forTimeInterval: 0.5)
        titleField.typeText("Construir Habito Positivo")
        
        // Buscar segmented control para tipo
        let typeSegment = app.segmentedControls.firstMatch
        if typeSegment.waitForExistence(timeout: 2) {
            // Intentar seleccionar Build
            let buildButton = typeSegment.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'build' OR label CONTAINS[c] 'construir'")).firstMatch
            if buildButton.exists {
                buildButton.tap()
                Thread.sleep(forTimeInterval: 0.3)
            }
        }
        
        // Guardar
        guard let saveButton = app.saveButton else {
            XCTFail("No se encontro boton guardar")
            return
        }
        
        saveButton.tap()
        Thread.sleep(forTimeInterval: 1)
        
        XCTAssertTrue(app.habitListView.waitForExistence(timeout: 3),
                     "Debe volver a la lista principal")
    }
    
    func testCreateQuitTypeHabit() {
        guard let addButton = app.addButton else {
            XCTFail("No se encontro boton de añadir")
            return
        }
        
        guard addButton.waitForExistence(timeout: 3) else {
            XCTFail("Boton de añadir no aparece")
            return
        }
        
        addButton.tap()
        Thread.sleep(forTimeInterval: 1)
        
        // Llenar título
        let titleField = app.habitTitleField
        XCTAssertTrue(titleField.waitForExistence(timeout: 3), "Debe aparecer campo de titulo")
        titleField.tap()
        Thread.sleep(forTimeInterval: 0.5)
        titleField.typeText("Dejar Mal Habito")
        
        // Buscar segmented control para tipo
        let typeSegment = app.segmentedControls.firstMatch
        if typeSegment.waitForExistence(timeout: 2) {
            // Intentar seleccionar Quit
            let quitButton = typeSegment.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'quit' OR label CONTAINS[c] 'dejar'")).firstMatch
            if quitButton.exists {
                quitButton.tap()
                Thread.sleep(forTimeInterval: 0.3)
            }
        }
        
        // Guardar
        guard let saveButton = app.saveButton else {
            XCTFail("No se encontro boton guardar")
            return
        }
        
        saveButton.tap()
        Thread.sleep(forTimeInterval: 1)
        
        XCTAssertTrue(app.habitListView.waitForExistence(timeout: 3),
                     "Debe volver a la lista principal")
    }
    
    // MARK: - Test de Flujo Completo Premium
    
    func testCompletePremiumWorkflow() {
        // 1. Crear categoría
        let categoryCreated = workflows.createCategory(name: "Premium VIP")
        XCTAssertTrue(categoryCreated, "Debe crear categoria")
        
        // 2. Crear hábito con frecuencia expandida
        let habitCreated = workflows.createHabitWithExpandedFrequency(title: "Meditar Mensualmente", frequency: "mensual")
        XCTAssertTrue(habitCreated, "Debe crear habito con frecuencia expandida")
        
        // 3. Completar hábito
        let completed = workflows.toggleFirstHabitCompletion()
        XCTAssertTrue(completed, "Debe poder completar habito")
        
        // 4. Pausar hábito
        let paused = workflows.pauseFirstHabit()
        XCTAssertTrue(paused, "Debe poder pausar habito")
    }
    
    func testCategoryAndTypeWorkflow() {
        // Crear categoría
        workflows.createCategory(name: "Salud Premium")
        
        // Crear hábito de tipo Build con categoría
        guard let addButton = app.addButton else {
            XCTFail("No se encontro boton de añadir")
            return
        }
        
        addButton.tap()
        Thread.sleep(forTimeInterval: 1)
        
        // Título
        let titleField = app.habitTitleField
        if titleField.waitForExistence(timeout: 3) {
            titleField.tap()
            Thread.sleep(forTimeInterval: 0.5)
            titleField.typeText("Ejercicio Premium")
        }
        
        // Tipo
        let typeSegment = app.segmentedControls.firstMatch
        if typeSegment.waitForExistence(timeout: 2) {
            let buildButton = typeSegment.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'build'")).firstMatch
            if buildButton.exists {
                buildButton.tap()
            }
        }
        
        // Categoría (si hay picker)
        let categoryPicker = app.pickers["Categoría"]
        if categoryPicker.exists {
            categoryPicker.tap()
            let healthOption = app.buttons["Salud Premium"]
            if healthOption.waitForExistence(timeout: 2) {
                healthOption.tap()
            } else {
                let pickerWheel = app.pickerWheels.firstMatch
                if pickerWheel.exists {
                    pickerWheel.adjust(toPickerWheelValue: "Salud Premium")
                }
            }
        }
        
        // Guardar
        if let saveButton = app.saveButton {
            saveButton.tap()
            Thread.sleep(forTimeInterval: 1)
        }
        
        XCTAssertTrue(app.habitListView.waitForExistence(timeout: 3),
                     "Debe volver a la lista principal")
    }
    
    // MARK: - Test de Performance
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
