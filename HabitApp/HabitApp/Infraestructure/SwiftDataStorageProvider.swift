//
//  SwiftDataStorageProvider.swift
//  HabitApp
//
//  Created by Aula03 on 3/12/25.
//

import Foundation
import SwiftData

/// Contexto global de SwiftData para acceder desde extensiones
class SwiftDataContext {
    static var shared: ModelContext?
}

class SwiftDataStorageProvider: StorageProvider {

    private let modelContainer: ModelContainer
    private let context: ModelContext
    private var cachedHabitIds: Set<UUID> = []
    private var hasLoadedHabits = false

    init(schema: Schema) {
        do {
            self.modelContainer = try ModelContainer(for: schema)
            self.context = ModelContext(self.modelContainer)
            SwiftDataContext.shared = self.context
        } catch {
            fatalError("Failed to initialize storage provider: \(error)")
       }
    }

    func loadHabits() async throws -> [Habit] {
        // Con Habit como @Model, ya podemos usar FetchDescriptor<Habit>
        let descriptor = FetchDescriptor<Habit>()
        let habits = try context.fetch(descriptor)
        cachedHabitIds = Set(habits.map(\.id))
        hasLoadedHabits = true
        return habits
    }

    func saveHabits(habits: [Habit]) async throws {
        if !hasLoadedHabits {
            let existingHabits = try context.fetch(FetchDescriptor<Habit>())
            cachedHabitIds = Set(existingHabits.map(\.id))
            hasLoadedHabits = true
        }

        let newIds = Set(habits.map(\.id))
        let idsToDelete = cachedHabitIds.subtracting(newIds)

        if !idsToDelete.isEmpty {
            let idsToDeleteList = Array(idsToDelete)
            let descriptor = FetchDescriptor<Habit>(
                predicate: #Predicate { idsToDeleteList.contains($0.id) }
            )
            let habitsToDelete = try context.fetch(descriptor)
            for habit in habitsToDelete {
                context.delete(habit)
            }
        }

        // Insertar los nuevos; los existentes se asume que ya están en el contexto
        for habit in habits where !cachedHabitIds.contains(habit.id) {
            context.insert(habit)
        }

        try context.save()
        cachedHabitIds = newIds
    }
}
