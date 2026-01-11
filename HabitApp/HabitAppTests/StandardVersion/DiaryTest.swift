//
//  DiaryTest.swift
//  HabitAppTests
//

import XCTest
#if canImport(HabitApp_Premium)
@testable import HabitApp_Premium
#elseif canImport(HabitApp_Standard)
@testable import HabitApp_Standard
#elseif canImport(HabitApp_Core)
@testable import HabitApp_Core
#else
@testable import HabitApp
#endif

final class DiaryTest: XCTestCase {
    
    // MARK: - Test de DiaryNoteFeature inicialización
    
    func testDiaryNoteFeatureInitialization() {
        // Arrange
        let entryId = UUID()
        
        // Act
        let diaryNote = DiaryNoteFeature(completionEntryId: entryId, note: "Mi nota del día")
        
        // Assert
        XCTAssertEqual(diaryNote.completionEntryId, entryId)
        XCTAssertEqual(diaryNote.note, "Mi nota del día")
    }
    
    func testDiaryNoteFeatureInitializationWithNilNote() {
        // Arrange
        let entryId = UUID()
        
        // Act
        let diaryNote = DiaryNoteFeature(completionEntryId: entryId)
        
        // Assert
        XCTAssertEqual(diaryNote.completionEntryId, entryId)
        XCTAssertNil(diaryNote.note)
    }
    
    func testDiaryNoteFeatureNoteCanBeModified() {
        // Arrange
        let entryId = UUID()
        let diaryNote = DiaryNoteFeature(completionEntryId: entryId, note: "Original")
        
        // Act
        diaryNote.note = "Modificada"
        
        // Assert
        XCTAssertEqual(diaryNote.note, "Modificada")
    }
    
    func testDiaryNoteFeatureNoteCanBeSetToNil() {
        // Arrange
        let entryId = UUID()
        let diaryNote = DiaryNoteFeature(completionEntryId: entryId, note: "Original")
        
        // Act
        diaryNote.note = nil
        
        // Assert
        XCTAssertNil(diaryNote.note)
    }
    
    // MARK: - Test de valores extremos
    
    func testDiaryNoteWithEmptyString() {
        // Arrange & Act
        let entryId = UUID()
        let diaryNote = DiaryNoteFeature(completionEntryId: entryId, note: "")
        
        // Assert
        XCTAssertEqual(diaryNote.note, "")
    }
    
    func testDiaryNoteWithLongText() {
        // Arrange
        let entryId = UUID()
        let longNote = String(repeating: "A", count: 10000)
        
        // Act
        let diaryNote = DiaryNoteFeature(completionEntryId: entryId, note: longNote)
        
        // Assert
        XCTAssertEqual(diaryNote.note?.count, 10000)
        XCTAssertEqual(diaryNote.note, longNote)
    }
    
    func testDiaryNoteWithSpecialCharacters() {
        // Arrange
        let entryId = UUID()
        let specialNote = "Hoy me sentí genial 😊\nCon energía 💪\n¡Excelente! áéíóú"
        
        // Act
        let diaryNote = DiaryNoteFeature(completionEntryId: entryId, note: specialNote)
        
        // Assert
        XCTAssertEqual(diaryNote.note, specialNote)
        XCTAssertTrue(diaryNote.note?.contains("😊") ?? false)
        XCTAssertTrue(diaryNote.note?.contains("\n") ?? false)
    }
    
    func testDiaryNoteWithMultiline() {
        // Arrange
        let entryId = UUID()
        let multilineNote = """
        Primera línea
        Segunda línea
        Tercera línea
        """
        
        // Act
        let diaryNote = DiaryNoteFeature(completionEntryId: entryId, note: multilineNote)
        
        // Assert
        XCTAssertEqual(diaryNote.note, multilineNote)
        XCTAssertTrue(diaryNote.note?.contains("\n") ?? false)
    }
    
    // MARK: - Test de relación con CompletionEntry
    
    func testMultipleDiaryNotesWithDifferentEntries() {
        // Arrange
        let entry1Id = UUID()
        let entry2Id = UUID()
        
        // Act
        let note1 = DiaryNoteFeature(completionEntryId: entry1Id, note: "Nota 1")
        let note2 = DiaryNoteFeature(completionEntryId: entry2Id, note: "Nota 2")
        
        // Assert
        XCTAssertNotEqual(note1.completionEntryId, note2.completionEntryId)
        XCTAssertNotEqual(note1.note, note2.note)
    }
    
    func testDiaryNoteCompletionEntryIdIsImmutable() {
        // Arrange
        let entryId = UUID()
        let diaryNote = DiaryNoteFeature(completionEntryId: entryId, note: "Nota")
        
        // Act & Assert
        // El completionEntryId es una constante (let), no se puede modificar
        XCTAssertEqual(diaryNote.completionEntryId, entryId)
    }
    
    // MARK: - Test de casos de uso típicos
    
    func testCreateDiaryNoteForTodayCompletion() {
        // Arrange
        let today = Date()
        let entry = CompletionEntry(date: today)
        
        // Act
        let diaryNote = DiaryNoteFeature(
            completionEntryId: entry.id,
            note: "Hoy completé mi hábito con éxito"
        )
        
        // Assert
        XCTAssertEqual(diaryNote.completionEntryId, entry.id)
        XCTAssertNotNil(diaryNote.note)
        XCTAssertTrue(diaryNote.note?.contains("éxito") ?? false)
    }
    
    func testUpdateDiaryNoteMultipleTimes() {
        // Arrange
        let entryId = UUID()
        let diaryNote = DiaryNoteFeature(completionEntryId: entryId, note: "Primer intento")
        
        // Act
        diaryNote.note = "Segundo intento"
        diaryNote.note = "Tercer intento"
        diaryNote.note = "Versión final"
        
        // Assert
        XCTAssertEqual(diaryNote.note, "Versión final")
    }
    
    func testDiaryNoteWithWhitespace() {
        // Arrange
        let entryId = UUID()
        let noteWithSpaces = "   Nota con espacios   "
        
        // Act
        let diaryNote = DiaryNoteFeature(completionEntryId: entryId, note: noteWithSpaces)
        
        // Assert
        XCTAssertEqual(diaryNote.note, noteWithSpaces)
    }
    
    // MARK: - Test de diferentes tipos de contenido
    
    func testDiaryNoteWithNumericContent() {
        // Arrange
        let entryId = UUID()
        let numericNote = "Hice 50 flexiones y corrí 5km en 30 minutos"
        
        // Act
        let diaryNote = DiaryNoteFeature(completionEntryId: entryId, note: numericNote)
        
        // Assert
        XCTAssertEqual(diaryNote.note, numericNote)
        XCTAssertTrue(diaryNote.note?.contains("50") ?? false)
        XCTAssertTrue(diaryNote.note?.contains("5km") ?? false)
    }
    
    func testDiaryNoteWithURL() {
        // Arrange
        let entryId = UUID()
        let noteWithURL = "Completé el curso en https://example.com/curso"
        
        // Act
        let diaryNote = DiaryNoteFeature(completionEntryId: entryId, note: noteWithURL)
        
        // Assert
        XCTAssertEqual(diaryNote.note, noteWithURL)
        XCTAssertTrue(diaryNote.note?.contains("https://") ?? false)
    }
}
