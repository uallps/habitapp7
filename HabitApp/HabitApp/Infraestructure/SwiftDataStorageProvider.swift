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
        return try context.fetch(descriptor)
    }

    func saveHabits(habits: [Habit]) async throws {
        // Cargamos existentes para sincronizar
        let existingHabits = try await self.loadHabits()
        let existingIds = Set(existingHabits.map { $0.id })
        let newIds = Set(habits.map { $0.id })

        // Borrar los que ya no están
        for existingHabit in existingHabits where !newIds.contains(existingHabit.id) {
            context.delete(existingHabit)
        }

        // Insertar los nuevos; los existentes se asume que ya están en el contexto
        for habit in habits {
            if existingIds.contains(habit.id) {
                // Si quieres forzar actualización de propiedades en caso de objetos distintos,
                // busca el existente y copia campos.
                // Aquí asumimos que es la misma instancia o ya está gestionada por el contexto.
            } else {
                context.insert(habit)
            }
        }

        try context.save()
    }
}
