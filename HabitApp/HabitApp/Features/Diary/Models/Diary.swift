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
    @Relationship(inverse: \CompletionEntry.diaryFeature)
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
    /// Getter: Lee desde diaryFeature
    /// Setter: Usa el contexto global de SwiftData para persistir
    var note: String? {
        get {
            return diaryFeature?.note
        }
        set {
            guard let context = SwiftDataContext.shared else {
                print("⚠️ SwiftDataContext no está inicializado")
                return
            }
            
            if let newNote = newValue, !newNote.isEmpty {
                // Si ya existe una feature, actualizar la nota
                if let existingFeature = diaryFeature {
                    existingFeature.note = newNote
                } else {
                    // Crear nueva feature
                    let newFeature = DiaryNoteFeature(completionEntry: self, note: newNote)
                    context.insert(newFeature)
                }
            } else {
                // Eliminar la feature si existe (nota vacía o nil)
                if let existingFeature = diaryFeature {
                    context.delete(existingFeature)
                }
            }
            
            // Guardar cambios
            try? context.save()
        }
    }
    
    var hasNote: Bool {
        note != nil && !note!.isEmpty
    }
}
