//
//  StandardUITests.swift
//  HabitAppStandardUITests
//
//  UI Tests para HabitApp Standard Version
//  Incluye: Core + Category + Stats + Diary + Reminders + Streaks
//  Excluye: Plugins NM_* (ExpandedFrequency, PauseDay, Type, Calendary, SuggestedHabit)
//

import XCTest

final class StandardUITests: UITestBase {
    
    override var launchArguments: [String] {
        return ["UI-Testing", "Standard-Version"]
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
    
    // MARK: - Test de Funcionalidad Básica Standard
    
    
    func testCreateBasicHabit() {
        let result = workflows.createBasicHabit(title: "Habito Standard")
        XCTAssertTrue(result, "Debe poder crear un habito basico")
    }
    
    func testToggleHabitCompletion() {
        // Primero crear un hábito
        workflows.createBasicHabit(title: "Habito a Completar")
        
        // Luego marcarlo como completado
        let success = workflows.toggleFirstHabitCompletion()
        XCTAssertTrue(success, "Debe poder marcar habito como completado")
    }
    
    // MARK: - Test de Features Standard DISPONIBLES
    
    func testCategoryFeatureAvailable() {
        XCTAssertNotNil(findCategoryButton(), "Debe existir boton de categorias en Standard")
    }
    
    func testStatsFeatureAvailable() {
        assertFeatureAvailable(keywords: UIPredicates.stats,
                              message: "Estadisticas debe estar disponible en Standard")
    }
    
    func testDiaryFeatureAvailable() {
        // Crear hábito y completarlo para acceder al diario
        workflows.createBasicHabit(title: "Habito con Diario")
        workflows.toggleFirstHabitCompletion()
        
        // Buscar elementos relacionados con diario
        assertFeatureAvailable(keywords: UIPredicates.diary,
                              message: "Diario debe estar disponible en Standard")
    }
    
    // MARK: - Test de Features Premium NO Disponibles
    
    func testExpandedFrequencyNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.expandedFrequency,
                                 message: "No debe haber frecuencia expandida en Standard")
    }
    
    func testPauseDayNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.pauseDay,
                                 message: "No debe haber funcion de pausa en Standard")
    }
    
    func testHabitTypeNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.habitType,
                                 message: "No debe haber selector de tipo en Standard")
    }
    
    func testCalendaryNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.calendary,
                                 message: "No debe haber calendario en Standard")
    }
    
    func testSuggestedHabitNotAvailable() {
        assertFeatureNotAvailable(keywords: UIPredicates.suggestedHabit,
                                 message: "No debe haber habitos sugeridos en Standard")
    }
    
    // MARK: - Test de Categorías
    
    func testCreateCategory() {
        let result = workflows.createCategory(name: "Salud")
        XCTAssertTrue(result, "Debe poder crear una categoria")
    }
    
    func testCreateMultipleCategories() {
        let categories = ["Trabajo", "Personal", "Deporte"]
        
        for category in categories {
            let result = workflows.createCategory(name: category)
            XCTAssertTrue(result, "Debe poder crear categoria: \(category)")
        }
    }
    
    func testDeleteCategory() {
        // Crear y luego eliminar
        workflows.createCategory(name: "Categoria Temporal")
        
        let result = workflows.deleteCategory(name: "Categoria Temporal")
        XCTAssertTrue(result, "Debe poder eliminar categoria")
    }
    
    // MARK: - Test de Flujo Completo: Categoria + Habito
    
    func testCreateCategoryAndAssignToHabit() {
        // 1. Crear categoría
        let categoryCreated = workflows.createCategory(name: "Fitness")
        XCTAssertTrue(categoryCreated, "Debe crear la categoria Fitness")
        
        // 2. Crear hábito
        guard let addButton = app.addButton else {
            XCTFail("No se encontro boton de añadir")
            return
        }
        
        addButton.tap()
        
        // 3. Llenar título
        let titleField = app.habitTitleField
        XCTAssertTrue(titleField.waitForExistence(timeout: 3), "Debe aparecer campo de titulo")
        titleField.tap()
        Thread.sleep(forTimeInterval: 0.5)
        titleField.typeText("Correr 30 min")
        
        // 4. Seleccionar categoría
        let categoryPicker = app.pickers["Categoría"]
        if categoryPicker.exists {
            categoryPicker.tap()
            
            // Buscar la opción "Fitness" en el picker
            let fitnessOption = app.buttons["Fitness"]
            if fitnessOption.waitForExistence(timeout: 2) {
                fitnessOption.tap()
            } else {
                // Si es un picker wheel
                let pickerWheel = app.pickerWheels.firstMatch
                if pickerWheel.exists {
                    pickerWheel.adjust(toPickerWheelValue: "Fitness")
                }
            }
        }
        
        // 5. Guardar
        guard let saveButton = app.saveButton else {
            XCTFail("No se encontro boton guardar")
            return
        }
        
        saveButton.tap()
        Thread.sleep(forTimeInterval: 1)
        
        // 6. Verificar que volvimos a la lista
        XCTAssertTrue(app.habitListView.waitForExistence(timeout: 3),
                     "Debe volver a la lista principal")
        
        // 7. Verificar que el hábito existe
        let habitExists = app.staticTexts["Correr 30 min"].exists
        XCTAssertTrue(habitExists, "El habito debe aparecer en la lista")
    }
    
    // MARK: - Test de Flujo Completo: Completar + Diario
    
    func testCompleteHabitAndWriteDiaryNote() {
        // 1. Crear hábito
        let habitCreated = workflows.createBasicHabit(title: "Meditar")
        XCTAssertTrue(habitCreated, "Debe crear el habito")
        
        // 2. Marcar como completado
        let firstHabit = app.firstHabit
        XCTAssertTrue(firstHabit.waitForExistence(timeout: 3), "Debe existir el primer habito")
        
        let completionButton = firstHabit.buttons.firstMatch
        XCTAssertTrue(completionButton.exists, "Debe existir boton de completitud")
        completionButton.tap()
        Thread.sleep(forTimeInterval: 0.5)
        
        // 3. Buscar campo de diario (puede aparecer automáticamente o necesitar tap en el hábito)
        var diaryField = app.textViews.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'nota' OR placeholderValue CONTAINS[c] 'diario'")).firstMatch
        
        if !diaryField.exists {
            // Intentar hacer tap en el hábito para ver detalles
            firstHabit.tap()
            Thread.sleep(forTimeInterval: 1)
            
            // Buscar campo de diario en la vista de detalles
            diaryField = app.textViews.firstMatch
        }
        
        if diaryField.waitForExistence(timeout: 3) {
            diaryField.tap()
            Thread.sleep(forTimeInterval: 0.5)
            
            let noteText = "Sesión de meditación muy productiva"
            diaryField.typeText(noteText)
            
            // Verificar que el texto se escribió
            let fieldValue = diaryField.value as? String ?? ""
            XCTAssertTrue(fieldValue.contains("productiva"),
                         "La nota del diario debe haberse guardado")
            
            // Cerrar si hay botón de cerrar
            if app.buttons["Listo"].exists {
                app.buttons["Listo"].tap()
            } else if app.buttons["Guardar"].exists {
                app.buttons["Guardar"].tap()
            } else if app.buttons["Cancelar"].exists {
                app.buttons["Cancelar"].tap()
            }
        }
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
