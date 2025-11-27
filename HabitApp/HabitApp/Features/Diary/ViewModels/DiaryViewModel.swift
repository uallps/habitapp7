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
    
    private var completionEntry: CompletionEntry
    
    init(completionEntry: CompletionEntry) {
        self.completionEntry = completionEntry
        self.noteText = completionEntry.note ?? ""
    }
    
    func saveNote() {
        completionEntry.note = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
