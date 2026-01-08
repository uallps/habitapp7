//
//  JSONStorageProvider.swift
//  HabitApp
//
//  Created by Aula03 on 7/12/25.
//

import Foundation

class JSONStorageProvider: StorageProvider {
    static let shared = JSONStorageProvider()
    
    private let fileURL: URL
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = documentsDirectory.appendingPathComponent("habits.json")
    }
    
    func loadHabits() async throws -> [Habit] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        _ = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Por ahora devolvemos array vac??o ya que Habit con @Model no es Codable
        // En una implementaci??n completa necesitar??as DTOs
        print("?????? JSON Storage no implementado completamente - usando SwiftData")
        return []
    }
    
    func saveHabits(habits: [Habit]) async throws {
        // Por ahora no hace nada ya que Habit con @Model no es Codable
        print("?????? JSON Storage no implementado completamente - usando SwiftData")
    }
}

