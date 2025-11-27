//
//  Diary.swift
//  HabitApp
//
//
import Foundation

// Extensión del diario para CompletionEntry
extension CompletionEntry {
    private var noteKey: String {
        "completion_note_\(date.timeIntervalSince1970)"
    }
    
    var note: String? {
        get {
            UserDefaults.standard.string(forKey: noteKey)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: noteKey)
            } else {
                UserDefaults.standard.removeObject(forKey: noteKey)
            }
        }
    }
    
    var hasNote: Bool {
        note != nil && !note!.isEmpty
    }
}
