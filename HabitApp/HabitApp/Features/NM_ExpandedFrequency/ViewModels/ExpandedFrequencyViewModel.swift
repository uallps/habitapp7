import Combine
import Foundation
import SwiftData

@MainActor
final class ExpandedFrequencyViewModel: ObservableObject {
    @Published var selectedType: FrequencyType

    private let habitId: UUID
    private let context: ModelContext
    private var expandedFrequency: ExpandedFrequency?

    init(habitId: UUID, context: ModelContext) {
        self.habitId = habitId
        self.context = context
        
        // Cargar datos ANTES de inicializar selectedType
        let descriptor = FetchDescriptor<ExpandedFrequency>(
            predicate: #Predicate { $0.habitID == habitId }
        )
        
        if let existing = try? context.fetch(descriptor).first {
            self.expandedFrequency = existing
            self.selectedType = existing.type
        } else {
            let newFreq = ExpandedFrequency(habitID: habitId, type: .daily)
            context.insert(newFreq)
            self.expandedFrequency = newFreq
            self.selectedType = .daily
        }
    }

    var isDaily: Bool {
        selectedType == .daily
    }

    var isAddiction: Bool {
        selectedType == .addiction
    }

    func saveSelection(_ type: FrequencyType) {
        if let expandedFrequency = expandedFrequency {
            expandedFrequency.type = type
        } else {
            let newFreq = ExpandedFrequency(habitID: habitId, type: type)
            context.insert(newFreq)
            expandedFrequency = newFreq
        }
        syncCache()
    }

    private func syncCache() {
        guard let plugin = PluginRegistry.shared.plugins.first(where: { $0 is ExpandedFrequencyPlugin })
                as? ExpandedFrequencyPlugin else {
            return
        }
        plugin.updateCache(for: habitId, frequency: expandedFrequency)
    }
}
