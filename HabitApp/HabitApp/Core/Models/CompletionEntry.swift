//
//  CompletionEntry.swift
//  HabitApp
//

import Foundation
import SwiftData

@Model
final class CompletionEntry {
    // Identificador único para relacionar con features
    @Attribute(.unique) var id: UUID
    
    // Si necesitas identificar cada entry con UUID, agrégalo aquí.
    // Para tu caso actual, basta con la fecha.
    let date: Date
    
    init(date: Date) {
        self.id = UUID()
        self.date = date
    }
}
