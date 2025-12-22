//
//  Diary.swift
//  HabitApp
//
//
import Foundation
import SwiftData

/// Modelo intermedio que relaciona CompletionEntry con sus notas de diario
/// Esta clase permite almacenar las notas en SwiftData
@Model
final class DiaryNoteFeature {
    var completionEntryId: UUID
    
    var note: String?
    
    init(completionEntryId: UUID, note: String? = nil) {
        self.completionEntryId = completionEntryId
        self.note = note
    }
}

// Extensión del diario para CompletionEntry
extension CompletionEntry {
    
    private var activeContext: ModelContext? {
        return self.modelContext ?? SwiftDataContext.shared
    }

    /// Método para acceder a la nota
    func getNote() -> String? {
        guard let context = activeContext else { return nil }
        let entryId = self.id
        let descriptor = FetchDescriptor<DiaryNoteFeature>(
            predicate: #Predicate { $0.completionEntryId == entryId }
        )
        return try? context.fetch(descriptor).first?.note
    }
    
    /// Método para establecer la nota
    func setNote(_ newNote: String?) {
        guard let context = activeContext else { return }
        let entryId = self.id
        let descriptor = FetchDescriptor<DiaryNoteFeature>(
            predicate: #Predicate { $0.completionEntryId == entryId }
        )
        
        do {
            let features = try context.fetch(descriptor)
            if let existingFeature = features.first {
                if let newNote = newNote, !newNote.isEmpty {
                    existingFeature.note = newNote
                } else {
                    context.delete(existingFeature)
                }
            } else if let newNote = newNote, !newNote.isEmpty {
                let newFeature = DiaryNoteFeature(completionEntryId: entryId, note: newNote)
                context.insert(newFeature)
            }
        } catch {
            print("Error setting note: \(error)")
        }
    }
    
    var hasNote: Bool {
        guard let note = getNote() else { return false }
        return !note.isEmpty
    }
}

