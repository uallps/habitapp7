//
//  DiaryViewModel.swift
//  HabitApp
//
//  Created by Francisco José García García on 16/11/25.
//
import Foundation
import Combine

class DiaryViewModel: ObservableObject {
    @Published var noteText: String = ""
    
    private let loadNote: () -> String?
    private let persistNote: (String?) -> Void
    
    init(completionEntry: CompletionEntry) {
        self.loadNote = { completionEntry.getNote() }
        self.persistNote = { completionEntry.setNote($0) }
        self.noteText = loadNote() ?? ""
    }

    init(loadNote: @escaping () -> String?, saveNote: @escaping (String?) -> Void) {
        self.loadNote = loadNote
        self.persistNote = saveNote
        self.noteText = loadNote() ?? ""
    }
    
    func saveNote() {
        persistNote(noteText.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
