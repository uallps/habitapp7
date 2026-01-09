//
//  HabitListViewModelTest.swift
//  HabitAppTests
//

import XCTest
import Combine
@testable import HabitApp

// MARK: - Mock StorageProvider

class MockStorageProvider: StorageProvider {
    var habits: [Habit] = []
    var saveCalledCount = 0
    var loadCalledCount = 0
    var shouldFailOnSave = false
    var shouldFailOnLoad = false
    
    func loadHabits() async throws -> [Habit] {
        loadCalledCount += 1
        
        if shouldFailOnLoad {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Load failed"])
        }
        
        return habits
    }
    
    func saveHabits(habits: [Habit]) async throws {
        saveCalledCount += 1
        
        if shouldFailOnSave {
            throw NSError(domain: "TestError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Save failed"])
        }
        
        self.habits = habits
    }
}

// MARK: - Tests

final class HabitListViewModelTest: XCTestCase {
    
    var viewModel: HabitListViewModel!
    var mockStorage: MockStorageProvider!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockStorage = MockStorageProvider()
        viewModel = HabitListViewModel(storageProvider: mockStorage)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockStorage = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Test de inicialización
    
    func testInitialization_LoadsHabitsFromStorage() async {
        // Arrange
        let habit1 = Habit(title: "Habit 1", frequency: [.monday])
        let habit2 = Habit(title: "Habit 2", frequency: [.tuesday])
        mockStorage.habits = [habit1, habit2]
        
        // Act
        let newViewModel = HabitListViewModel(storageProvider: mockStorage)
        
        // Esperar a que se carguen los hábitos
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
        
        // Assert
        XCTAssertEqual(mockStorage.loadCalledCount, 2) // Una del setUp, otra de esta prueba
        XCTAssertEqual(newViewModel.habits.count, 2)
    }
    
    func testInitialization_StartsWithEmptyCategories() {
        // Assert
        XCTAssertTrue(viewModel.categories.isEmpty)
    }
    
    // MARK: - Test de addCategory
    
    func testAddCategory_AddsToList() {
        // Arrange
        let category = Category(name: "Salud", categoryDescription: "Hábitos saludables")
        
        // Act
        viewModel.addCategory(category)
        
        // Assert
        XCTAssertEqual(viewModel.categories.count, 1)
        XCTAssertEqual(viewModel.categories.first?.name, "Salud")
    }
    
    func testAddCategory_AddMultipleCategories() {
        // Arrange
        let category1 = Category(name: "Salud", categoryDescription: "Desc1")
        let category2 = Category(name: "Trabajo", categoryDescription: "Desc2")
        let category3 = Category(name: "Personal", categoryDescription: "Desc3")
        
        // Act
        viewModel.addCategory(category1)
        viewModel.addCategory(category2)
        viewModel.addCategory(category3)
        
        // Assert
        XCTAssertEqual(viewModel.categories.count, 3)
    }
    
    // MARK: - Test de addHabit
    
    func testAddHabit_AddsToList() {
        // Arrange
        let habit = Habit(title: "Ejercicio", frequency: [.monday, .wednesday])
        
        // Act
        viewModel.addHabit(habit)
        
        // Assert
        XCTAssertEqual(viewModel.habits.count, 1)
        XCTAssertEqual(viewModel.habits.first?.title, "Ejercicio")
    }
    
    func testAddHabit_CallsPersist() async {
        // Arrange
        let habit = Habit(title: "Meditar", frequency: [.monday])
        
        // Act
        viewModel.addHabit(habit)
        
        // Esperar a que se persista
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
        
        // Assert
        XCTAssertGreaterThan(mockStorage.saveCalledCount, 0, "Debe llamar a saveHabits")
        XCTAssertEqual(mockStorage.habits.count, 1)
    }
    
    func testAddHabit_AddMultipleHabits() {
        // Arrange
        let habit1 = Habit(title: "Habit 1", frequency: [.monday])
        let habit2 = Habit(title: "Habit 2", frequency: [.tuesday])
        let habit3 = Habit(title: "Habit 3", frequency: [.wednesday])
        
        // Act
        viewModel.addHabit(habit1)
        viewModel.addHabit(habit2)
        viewModel.addHabit(habit3)
        
        // Assert
        XCTAssertEqual(viewModel.habits.count, 3)
    }
    
    // MARK: - Test de toggleCompletion
    
    func testToggleCompletion_MarksAsCompleted() async {
        // Arrange
        let habit = Habit(title: "Leer", frequency: [.monday])
        viewModel.addHabit(habit)
        
        XCTAssertFalse(habit.isCompletedToday, "Inicialmente no debe estar completado")
        
        // Act
        viewModel.toggleCompletion(habit: habit)
        
        // Esperar a que se persista
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        XCTAssertTrue(viewModel.habits.first!.isCompletedToday, "Debe estar marcado como completado")
        XCTAssertGreaterThan(mockStorage.saveCalledCount, 0)
    }
    
    func testToggleCompletion_UnmarksAsCompleted() async {
        // Arrange
        let habit = Habit(title: "Leer", frequency: [.monday])
        let today = Calendar.current.startOfDay(for: Date())
        habit.completed.append(CompletionEntry(date: today))
        viewModel.addHabit(habit)
        
        XCTAssertTrue(habit.isCompletedToday, "Inicialmente debe estar completado")
        
        // Act
        viewModel.toggleCompletion(habit: habit)
        
        // Esperar a que se persista
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        XCTAssertFalse(viewModel.habits.first!.isCompletedToday, "Debe estar desmarcado")
        XCTAssertGreaterThan(mockStorage.saveCalledCount, 0)
    }
    
    func testToggleCompletion_WithNonExistentHabit() async {
        // Arrange
        let habit = Habit(title: "No existe", frequency: [.monday])
        // No agregamos el hábito a la lista
        
        let initialCount = viewModel.habits.count
        
        // Act
        viewModel.toggleCompletion(habit: habit)
        
        // Esperar
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        XCTAssertEqual(viewModel.habits.count, initialCount, "No debe cambiar la lista")
    }
    
    func testToggleCompletion_OnlyAffectsTodayDate() async {
        // Arrange
        let habit = Habit(title: "Test", frequency: [.monday])
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        habit.completed.append(CompletionEntry(date: yesterday))
        viewModel.addHabit(habit)
        
        XCTAssertEqual(habit.completed.count, 1, "Debe tener una entrada de ayer")
        XCTAssertFalse(habit.isCompletedToday)
        
        // Act
        viewModel.toggleCompletion(habit: habit)
        
        // Esperar
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        let updatedHabit = viewModel.habits.first!
        XCTAssertEqual(updatedHabit.completed.count, 2, "Debe tener dos entradas ahora")
        XCTAssertTrue(updatedHabit.isCompletedToday)
    }
    
    // MARK: - Test de updateHabit
    
    func testUpdateHabit_CallsPersist() async {
        // Arrange
        let habit = Habit(title: "Original", frequency: [.monday])
        viewModel.addHabit(habit)
        
        // Modificar el hábito
        habit.title = "Modificado"
        
        let saveCountBefore = mockStorage.saveCalledCount
        
        // Act
        viewModel.updateHabit(habit)
        
        // Esperar
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        XCTAssertGreaterThan(mockStorage.saveCalledCount, saveCountBefore, "Debe llamar a persist")
        XCTAssertEqual(viewModel.habits.first?.title, "Modificado")
    }
    
    func testUpdateHabit_ModifiesExistingHabit() async {
        // Arrange
        let habit = Habit(title: "Original", priority: .low, frequency: [.monday])
        viewModel.addHabit(habit)
        
        // Modificar propiedades
        habit.title = "Actualizado"
        habit.priority = .high
        habit.frequency = [.monday, .wednesday, .friday]
        
        // Act
        viewModel.updateHabit(habit)
        
        // Esperar
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        let updatedHabit = viewModel.habits.first!
        XCTAssertEqual(updatedHabit.title, "Actualizado")
        XCTAssertEqual(updatedHabit.priority, .high)
        XCTAssertEqual(updatedHabit.frequency.count, 3)
    }
    
    // MARK: - Test de persistencia con errores
    
    func testPersist_HandlesErrors() async {
        // Arrange
        mockStorage.shouldFailOnSave = true
        let habit = Habit(title: "Test", frequency: [.monday])
        
        // Act
        viewModel.addHabit(habit)
        
        // Esperar
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert - No debe crashear, solo imprimir el error
        XCTAssertEqual(viewModel.habits.count, 1, "El hábito debe seguir en la lista local")
    }
    
    func testLoadHabits_HandlesErrors() async {
        // Arrange
        mockStorage.shouldFailOnLoad = true
        
        // Act
        let newViewModel = HabitListViewModel(storageProvider: mockStorage)
        
        // Esperar
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert - No debe crashear
        XCTAssertTrue(newViewModel.habits.isEmpty, "La lista debe estar vacía si falla la carga")
    }
    
    // MARK: - Test de integración
    
    func testCompleteWorkflow_AddToggleUpdate() async {
        // Arrange
        let habit = Habit(title: "Workflow Test", priority: .medium, frequency: [.monday, .wednesday])
        
        // Act 1: Agregar hábito
        viewModel.addHabit(habit)
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        XCTAssertEqual(viewModel.habits.count, 1)
        XCTAssertFalse(viewModel.habits.first!.isCompletedToday)
        
        // Act 2: Marcar como completado
        viewModel.toggleCompletion(habit: habit)
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        XCTAssertTrue(viewModel.habits.first!.isCompletedToday)
        
        // Act 3: Actualizar título
        habit.title = "Actualizado en workflow"
        viewModel.updateHabit(habit)
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Assert final
        XCTAssertEqual(viewModel.habits.first?.title, "Actualizado en workflow")
        XCTAssertTrue(viewModel.habits.first!.isCompletedToday)
        XCTAssertGreaterThan(mockStorage.saveCalledCount, 2, "Debe haber múltiples llamadas a persist")
    }
    
    func testPublishedProperties_EmitChanges() {
        // Arrange
        let expectation = XCTestExpectation(description: "Habits published")
        var receivedCount = 0
        
        viewModel.$habits
            .dropFirst() // Ignorar el valor inicial
            .sink { habits in
                receivedCount = habits.count
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Act
        let habit = Habit(title: "Test", frequency: [.monday])
        viewModel.addHabit(habit)
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedCount, 1)
    }
}
