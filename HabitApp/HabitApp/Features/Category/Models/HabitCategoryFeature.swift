import Foundation
import SwiftData

@Model
final class HabitCategoryFeature {
    var habitId: UUID

    @Relationship(inverse: \Category.habitAssociations)
    var category: Category?

    init(habitId: UUID, category: Category? = nil) {
        self.habitId = habitId
        self.category = category
    }
}

extension Habit {
    private var activeContext: ModelContext? {
        self.modelContext ?? SwiftDataContext.shared
    }

    func getCategory() -> Category? {
        guard let context = activeContext else { return nil }
        let habitId = id
        let descriptor = FetchDescriptor<HabitCategoryFeature>(
            predicate: #Predicate { $0.habitId == habitId }
        )
        return try? context.fetch(descriptor).first?.category
    }

    func setCategory(_ newCategory: Category?) {
        guard let context = activeContext else { return }
        let habitId = id
        let descriptor = FetchDescriptor<HabitCategoryFeature>(
            predicate: #Predicate { $0.habitId == habitId }
        )

        do {
            let features = try context.fetch(descriptor)
            if let existingFeature = features.first {
                if let newCategory = newCategory {
                    existingFeature.category = newCategory
                } else {
                    context.delete(existingFeature)
                }
            } else if let newCategory = newCategory {
                let newFeature = HabitCategoryFeature(habitId: habitId, category: newCategory)
                context.insert(newFeature)
            }
        } catch {
            print("Error setting category: \(error)")
        }
    }
}
