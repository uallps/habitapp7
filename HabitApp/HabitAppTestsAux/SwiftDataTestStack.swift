//
//  SwiftDataTestStack.swift
//  HabitAppTestsAux
//

import Foundation
import SwiftData
#if CORE_VERSION
@testable import HabitApp_Core
#elseif STANDARD_VERSION
@testable import HabitApp_Standard
#elseif PREMIUM_VERSION
@testable import HabitApp_Premium
#elseif canImport(HabitApp_Premium)
@testable import HabitApp_Premium
#elseif canImport(HabitApp_Standard)
@testable import HabitApp_Standard
#elseif canImport(HabitApp_Core)
@testable import HabitApp_Core
#else
@testable import HabitApp
#endif

@MainActor
enum SwiftDataTestStack {
    private static let configuration = ModelConfiguration(isStoredInMemoryOnly: true)

    static let container: ModelContainer = {
        let schema = Schema(models)
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Failed to create test ModelContainer: \(error)")
        }
    }()

    static func makeContext() -> ModelContext {
        let context = ModelContext(container)
        reset(context)
        SwiftDataContext.sharedContainer = container
        SwiftDataContext.shared = context
        return context
    }

    private static var models: [any PersistentModel.Type] {
        var types: [any PersistentModel.Type] = [
            Habit.self,
            CompletionEntry.self
        ]

        #if CATEGORY_FEATURE
        types.append(Category.self)
        types.append(HabitCategoryFeature.self)
        #endif

        #if DIARY_FEATURE
        types.append(DiaryNoteFeature.self)
        #endif

        #if STREAKS_FEATURE
        types.append(HabitStreakFeature.self)
        #endif

        #if EXPANDED_FREQUENCY_FEATURE
        types.append(ExpandedFrequency.self)
        #endif

        #if PAUSE_DAY_FEATURE
        types.append(HabitPauseDays.self)
        #endif

        #if HABIT_TYPE_FEATURE
        types.append(HabitType.self)
        #endif

        return types
    }

    private static func reset(_ context: ModelContext) {
        deleteAll(Habit.self, in: context)
        deleteAll(CompletionEntry.self, in: context)

        #if CATEGORY_FEATURE
        deleteAll(Category.self, in: context)
        deleteAll(HabitCategoryFeature.self, in: context)
        #endif

        #if DIARY_FEATURE
        deleteAll(DiaryNoteFeature.self, in: context)
        #endif

        #if STREAKS_FEATURE
        deleteAll(HabitStreakFeature.self, in: context)
        #endif

        #if EXPANDED_FREQUENCY_FEATURE
        deleteAll(ExpandedFrequency.self, in: context)
        #endif

        #if PAUSE_DAY_FEATURE
        deleteAll(HabitPauseDays.self, in: context)
        #endif

        #if HABIT_TYPE_FEATURE
        deleteAll(HabitType.self, in: context)
        #endif
    }

    private static func deleteAll<T: PersistentModel>(_ type: T.Type, in context: ModelContext) {
        let descriptor = FetchDescriptor<T>()
        let items = (try? context.fetch(descriptor)) ?? []
        for item in items {
            context.delete(item)
        }
    }
}
