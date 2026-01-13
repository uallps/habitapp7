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
        let created = workflows.createBasicHabit(
            title: "Habito a Completar",
            activateAllFrequencyDays: true
        )
        XCTAssertTrue(created, "Debe poder crear un habito con frecuencia activa")
        
        let success = workflows.toggleFirstHabitCompletion()
        XCTAssertTrue(success, "Debe poder marcar habito como completado")
    }
    
    // MARK: - Test de Features Standard DISPONIBLES
    
    func testCategoryFeatureAvailable() {
        XCTAssertNotNil(findCategoryButton(), "Debe existir boton de categorias en Premium")
    }
    
    func testStatsFeatureAvailable() {
        let created = workflows.createBasicHabit(
            title: "Habito con Stats",
            activateAllFrequencyDays: true
        )
        XCTAssertTrue(created, "Debe poder crear un habito con frecuencia activa")

        let completed = workflows.toggleFirstHabitCompletion()
        XCTAssertTrue(completed, "Debe poder completar el habito para stats")

        assertFeatureAvailable(keywords: UIPredicates.stats,
                              message: "Estadisticas debe estar disponible en Premium")
    }
    
    func testStreaksFeatureAvailable() {
        let created = workflows.createBasicHabit(
            title: "Habito con Rachas",
            activateAllFrequencyDays: true
        )
        XCTAssertTrue(created, "Debe poder crear un habito con frecuencia activa")

        let completed = workflows.toggleFirstHabitCompletion()
        XCTAssertTrue(completed, "Debe poder completar el habito para rachas")

        assertFeatureAvailable(keywords: UIPredicates.streak,
                              message: "Rachas debe estar disponible en Premium")
    }
    
    func testDiaryFeatureAvailable() {
        workflows.createBasicHabit(title: "Habito con Diario")
        workflows.toggleFirstHabitCompletion()
        
        assertFeatureAvailable(keywords: UIPredicates.diary,
                              message: "Diario debe estar disponible en Premium")
    }
    
    // MARK: - Test de Features Premium DISPONIBLES
    
    func testExpandedFrequencyAvailable() {
        guard let addButton = app.addButton else {
            XCTFail("No se encontro boton de anadir")
            return
        }

        guard addButton.waitForExistence(timeout: 3) else {
            XCTFail("Boton de anadir no aparece")
            return
        }

        addButton.tap()

        XCTAssertTrue(app.habitTitleField.waitForExistence(timeout: 2), "Debe aparecer el formulario")
        let table = app.tables.firstMatch
        let scrollView = app.scrollViews.firstMatch
        let scrollContainer = table.exists ? table : scrollView
        var found = false

        for _ in 0..<6 {
            if app.staticTexts["Frecuencia Extendida (Plugin)"].exists {
                found = true
                break
            }
            scrollContainer.swipeUp()
        }

        XCTAssertTrue(found, "Frecuencia expandida debe estar disponible en Premium")

        if app.buttons["Cancelar"].exists {
            app.buttons["Cancelar"].tap()
        }
    }
    
    func testPauseDayAvailable() {
        assertFeatureAvailable(keywords: UIPredicates.pauseDay,
                              message: "Funcion de pausa debe estar disponible en Premium")
    }
    
    func testHabitTypeAvailable() {
        guard let addButton = app.addButton else {
            XCTFail("No se encontro boton de anadir")
            return
        }

        guard addButton.waitForExistence(timeout: 3) else {
            XCTFail("Boton de anadir no aparece")
            return
        }

        addButton.tap()

        XCTAssertTrue(app.habitTitleField.waitForExistence(timeout: 2), "Debe aparecer el formulario")

        let table = app.tables.firstMatch
        let scrollView = app.scrollViews.firstMatch
        let scrollContainer = table.exists ? table : scrollView
        var found = false

        for _ in 0..<6 {
            if app.staticTexts["Tipo de Completado (Plugin)"].exists {
                found = true
                break
            }
            scrollContainer.swipeUp()
        }

        XCTAssertTrue(found, "Selector de tipo debe estar disponible en Premium")

        if app.buttons["Cancelar"].exists {
            app.buttons["Cancelar"].tap()
        }
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
    
    func testDeleteCategory() {
        workflows.createCategory(name: "Categoria Premium Temp")
        
        let result = workflows.deleteCategory(name: "Categoria Premium Temp")
        XCTAssertTrue(result, "Debe poder eliminar categoria")
    }
    
    // MARK: - Test de ExpandedFrequency
    
    func testCreateHabitWithDailyFrequency() {
        let result = workflows.createHabitWithExpandedFrequency(title: "Habito Diario", frequency: "Diaria")
        XCTAssertTrue(result, "Debe poder crear habito con frecuencia diaria")
    }
    
    func testCreateHabitWithMonthlyFrequency() {
        let result = workflows.createHabitWithExpandedFrequency(title: "Habito Mensual", frequency: "Mensual")
        XCTAssertTrue(result, "Debe poder crear habito con frecuencia mensual")
    }
    
    // MARK: - Test de PauseDay
    
    func testPauseHabit() {
        workflows.createBasicHabit(title: "Habito para Pausar")
        
        let result = workflows.pauseFirstHabit()
        XCTAssertTrue(result, "Debe poder pausar un habito")
    }
    
    // MARK: - Test de HabitType
    
    func testCreateQuitTypeHabit() {
        let result = workflows.createHabitWithExpandedFrequency(title: "Habito Adiccion", frequency: "Adiccion")
        XCTAssertTrue(result, "Debe poder crear habito con frecuencia adiccion")
    }
    
    // MARK: - Test de Flujo Completo Premium
    
    func testCompletePremiumWorkflow() {
        // 1. Crear categoría
        let categoryCreated = workflows.createCategory(name: "Premium VIP")
        XCTAssertTrue(categoryCreated, "Debe crear categoria")
        
        // 2. Crear hábito con frecuencia expandida
        let habitCreated = workflows.createHabitWithExpandedFrequency(
            title: "Meditar Mensualmente",
            frequency: "Mensual",
            activateAllFrequencyDays: true
        )
        XCTAssertTrue(habitCreated, "Debe crear habito con frecuencia expandida")
        
        // 3. Completar hábito
        let completed = workflows.toggleFirstHabitCompletion()
        XCTAssertTrue(completed, "Debe poder completar habito")
        
        // 4. Pausar hábito
        let paused = workflows.pauseFirstHabit()
        XCTAssertTrue(paused, "Debe poder pausar habito")
    }
    
    func testCategoryAndTypeWorkflow() {
        let categoryCreated = workflows.createCategory(name: "Salud Premium")
        XCTAssertTrue(categoryCreated, "Debe crear categoria")

        let habitCreated = workflows.createHabitWithCategoryAndType(
            title: "Ejercicio Premium",
            category: "Salud Premium",
            type: "Binario"
        )
        XCTAssertTrue(habitCreated, "Debe poder crear habito con categoria y tipo")
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
