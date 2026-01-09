//
//  StorageProvider.swift
//  HabitApp
//
//  Created by Aula03 on 3/12/25.
//

@MainActor
protocol StorageProvider {
    func loadHabits() async throws -> [Habit]
    func saveHabits(habits: [Habit]) async throws
}

