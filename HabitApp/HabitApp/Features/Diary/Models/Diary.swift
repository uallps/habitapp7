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
    var completionEntry: CompletionEntry?
    
    var note: String?
    
    init(completionEntry: CompletionEntry? = nil, note: String? = nil) {
        self.completionEntry = completionEntry
        self.note = note
    }
}

// Extensión del diario para CompletionEntry
extension CompletionEntry {
    /// Propiedad computada para acceder fácilmente a la nota
    var note: String? {
        get {
            return diaryFeature?.note
        }
        set {
            if let newNote = newValue, !newNote.isEmpty {
                // Si ya existe una feature, actualizar la nota
                if let existingFeature = diaryFeature {
                    existingFeature.note = newNote
                } else {
                    // Crear nueva feature
                    let newFeature = DiaryNoteFeature(completionEntry: self, note: newNote)
                    self.diaryFeature = newFeature
                }
            } else {
                // Eliminar la feature si existe (nota vacía o nil)
                self.diaryFeature = nil
            }
        }
    }
    
    var hasNote: Bool {
        note != nil && !note!.isEmpty
    }
}
