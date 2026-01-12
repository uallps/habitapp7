//
//  DiaryViewModelTest.swift
//  HabitAppTests
//

import XCTest
import Combine
#if CORE_VERSION
@testable import HabitApp_Core
#elseif STANDARD_VERSION
@testable import HabitApp_Standard
#elseif PREMIUM_VERSION
@testable import HabitApp_Premium
#elseif canImport(HabitApp_Premium)
@testable import HabitApp_Premium
#elseif canImport(HabitApp_Standard)
@testable import HabitApp_Standard
#elseif canImport(HabitApp_Core)
@testable import HabitApp_Core
#else
@testable import HabitApp
#endif

final class DiaryViewModelTest: XCTestCase {
    
    var viewModel: DiaryViewModel!
    var completionEntry: CompletionEntry!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        completionEntry = CompletionEntry(date: Date())
        viewModel = DiaryViewModel(completionEntry: completionEntry)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        completionEntry = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Test de inicializacion
    
    func testInitialization_WithNoExistingNote() {
        // Arrange & Act
        let entry = CompletionEntry(date: Date())
        let vm = DiaryViewModel(completionEntry: entry)
        
        // Assert
        XCTAssertEqual(vm.noteText, "")
    }
    
    func testInitialization_LoadsExistingNote() {
        // Arrange
        let entry = CompletionEntry(date: Date())
        entry.setNote("Nota existente")
        
        // Act
        let vm = DiaryViewModel(completionEntry: entry)
        
        // Assert
        XCTAssertEqual(vm.noteText, "Nota existente")
    }
    
    // MARK: - Test de noteText property
    
    func testNoteTextCanBeModified() {
        // Arrange
        let expectation = XCTestExpectation(description: "noteText changed")
        
        viewModel.$noteText
            .dropFirst() // Ignorar el valor inicial
            .sink { newValue in
                XCTAssertEqual(newValue, "Nueva nota")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Act
        viewModel.noteText = "Nueva nota"
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNoteTextCanBeSetToEmpty() {
        // Arrange
        viewModel.noteText = "Algun texto"
        
        // Act
        viewModel.noteText = ""
        
        // Assert
        XCTAssertEqual(viewModel.noteText, "")
    }
    
    func testNoteTextPublishes() {
        // Arrange
        var receivedValues: [String] = []
        let expectation = XCTestExpectation(description: "Received updates")
        expectation.expectedFulfillmentCount = 3
        
        viewModel.$noteText
            .dropFirst() // Ignorar el valor inicial
            .sink { value in
                receivedValues.append(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Act
        viewModel.noteText = "Primera"
        viewModel.noteText = "Segunda"
        viewModel.noteText = "Tercera"
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValues, ["Primera", "Segunda", "Tercera"])
    }
    
    // MARK: - Test de saveNote
    
    func testSaveNote_SavesTextToCompletionEntry() {
        // Arrange
        viewModel.noteText = "Mi nota de prueba"
        
        // Act
        viewModel.saveNote()
        
        // Assert
        XCTAssertEqual(completionEntry.getNote(), "Mi nota de prueba")
    }
    
    func testSaveNote_TrimsWhitespace() {
        // Arrange
        viewModel.noteText = "   Nota con espacios   "
        
        // Act
        viewModel.saveNote()
        
        // Assert
        XCTAssertEqual(completionEntry.getNote(), "Nota con espacios")
    }
    
    func testSaveNote_WithEmptyString() {
        // Arrange
        completionEntry.setNote("Nota existente")
        viewModel.noteText = ""
        
        // Act
        viewModel.saveNote()
        
        // Assert
        // Una cadena vacia despues de trim deberia guardarse como cadena vacia
        // (o nil dependiendo de la implementacion)
        let savedNote = completionEntry.getNote()
        XCTAssertTrue(savedNote == nil || savedNote == "")
    }
    
    func testSaveNote_WithWhitespaceOnly() {
        // Arrange
        completionEntry.setNote("Nota existente")
        viewModel.noteText = "     "
        
        // Act
        viewModel.saveNote()
        
        // Assert
        // Espacios en blanco deben eliminarse
        let savedNote = completionEntry.getNote()
        XCTAssertTrue(savedNote == nil || savedNote == "")
    }
    
    func testSaveNote_UpdatesExistingNote() {
        // Arrange
        completionEntry.setNote("Nota original")
        viewModel.noteText = "Nota actualizada"
        
        // Act
        viewModel.saveNote()
        
        // Assert
        XCTAssertEqual(completionEntry.getNote(), "Nota actualizada")
    }
    
    func testSaveNote_MultipleTimesSavesLatestValue() {
        // Arrange & Act
        viewModel.noteText = "Primera"
        viewModel.saveNote()
        
        viewModel.noteText = "Segunda"
        viewModel.saveNote()
        
        viewModel.noteText = "Tercera"
        viewModel.saveNote()
        
        // Assert
        XCTAssertEqual(completionEntry.getNote(), "Tercera")
    }
    
    // MARK: - Test de escenarios con newlines
    
    func testSaveNote_WithNewlines() {
        // Arrange
        viewModel.noteText = "Línea 1\nLínea 2\nLínea 3"
        
        // Act
        viewModel.saveNote()
        
        // Assert
        XCTAssertEqual(completionEntry.getNote(), "Línea 1\nLínea 2\nLínea 3")
    }
    
    func testSaveNote_WithLeadingAndTrailingNewlines() {
        // Arrange
        viewModel.noteText = "\n\nTexto central\n\n"
        
        // Act
        viewModel.saveNote()
        
        // Assert
        // El trim de whitespace y newlines deberia limpiar esto
        XCTAssertEqual(completionEntry.getNote(), "Texto central")
    }
    
    // MARK: - Test de valores extremos
    
    func testSaveNote_WithLongText() {
        // Arrange
        let longText = String(repeating: "A", count: 10000)
        viewModel.noteText = longText
        
        // Act
        viewModel.saveNote()
        
        // Assert
        XCTAssertEqual(completionEntry.getNote()?.count, 10000)
    }
    
    func testSaveNote_WithSpecialCharacters() {
        // Arrange
        viewModel.noteText = "Hoy me sentí genial 😊 con 100% de energía!"
        
        // Act
        viewModel.saveNote()
        
        // Assert
        XCTAssertEqual(completionEntry.getNote(), "Hoy me sentí genial 😊 con 100% de energía!")
    }
    
    // MARK: - Test de integracion con CompletionEntry
    
    func testModifyAndSave_UpdatesEntry() {
        // Arrange
        let entry = CompletionEntry(date: Date())
        let vm = DiaryViewModel(completionEntry: entry)
        
        // Act
        vm.noteText = "Primera nota"
        vm.saveNote()
        
        vm.noteText = "Segunda nota"
        vm.saveNote()
        
        // Assert
        XCTAssertEqual(entry.getNote(), "Segunda nota")
    }
    
    func testReloadViewModel_LoadsPreviouslySavedNote() {
        // Arrange
        let entry = CompletionEntry(date: Date())
        entry.setNote("Nota guardada previamente")
        
        // Act
        let vm = DiaryViewModel(completionEntry: entry)
        
        // Assert
        XCTAssertEqual(vm.noteText, "Nota guardada previamente")
    }
    
    // MARK: - Test de comportamiento observable
    
    func testViewModel_IsObservableObject() {
        // Assert
        XCTAssertTrue(viewModel is ObservableObject)
    }
    
    func testNoteTextChange_TriggersPublisher() {
        // Arrange
        var changeCount = 0
        let expectation = XCTestExpectation(description: "Publisher triggered")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.$noteText
            .dropFirst()
            .sink { _ in
                changeCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Act
        viewModel.noteText = "Cambio 1"
        viewModel.noteText = "Cambio 2"
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(changeCount, 2)
    }
}




