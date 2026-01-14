import Combine
import Foundation
import SwiftData

@MainActor
final class SuggestedHabitViewModel: ObservableObject {
    @Published var suggestions: [SuggestedHabitSuggestion] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let context: ModelContext?
    private let modelId: String
    private var hasLoadedInitial = false
    private var lastRequestedId: UUID?
    private let categories = [
        "salud",
        "productividad",
        "actividad fisica",
        "estudio",
        "descanso",
        "social",
        "hogar",
        "bienestar",
        "finanzas",
        "creatividad"
    ]
    private var categoryIndex = 0
    private var recentTitles: [String] = []
    private let maxRecentTitles = 24

    init(context: ModelContext?, modelId: String = HuggingFaceConfig.resolveModelId()) {
        self.context = context
        self.modelId = modelId
    }

    func loadInitialIfNeeded() async {
        guard !hasLoadedInitial else { return }
        hasLoadedInitial = true
        await loadNext()
    }

    func retryIfEmpty() async {
        guard suggestions.isEmpty else { return }
        hasLoadedInitial = false
        errorMessage = nil
        await loadInitialIfNeeded()
    }

    func loadNextIfNeeded(currentId: UUID) async {
        guard let lastId = suggestions.last?.id, lastId == currentId else { return }
        guard canLoadNext(for: lastId) else { return }
        await loadNext()
    }

    private func loadNext() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let client = try HuggingFaceClient(modelId: modelId)
            var batch: [SuggestedHabitSuggestion] = []
            var batchTitles: [String] = []
            var lastModelId = modelId

            for _ in 0..<3 {
                var attempts = 0
                var lastDraft: SuggestedHabitDraft?
                var isDuplicate = false

                while attempts < 3 {
                    let category = nextCategory()
                    let response = try await client.generateHabitSuggestions(
                        count: 1,
                        focus: category,
                        avoidTitles: recentTitles + batchTitles
                    )
                    lastModelId = response.modelId
                    guard let draft = response.drafts.first else {
                        attempts += 1
                        continue
                    }

                    lastDraft = draft
                    let titleKey = normalizeTitle(draft.title)
                    if !recentTitles.contains(titleKey) && !batchTitles.contains(titleKey) {
                        batchTitles.append(titleKey)
                        trackTitle(titleKey)
                        isDuplicate = false
                        break
                    }

                    isDuplicate = true
                    attempts += 1
                }

                guard let draft = lastDraft else {
                    continue
                }

                if isDuplicate {
                    let titleKey = normalizeTitle(draft.title)
                    if !batchTitles.contains(titleKey) {
                        batchTitles.append(titleKey)
                        trackTitle(titleKey)
                    }
                }

                batch.append(
                    SuggestedHabitSuggestion(
                        title: draft.title,
                        details: draft.details,
                        frequency: draft.frequency ?? "Flexible",
                        sourceModel: lastModelId
                    )
                )
            }

            guard !batch.isEmpty else {
                throw HuggingFaceError.decodingFailed
            }

            suggestions.append(contentsOf: batch)

            if let context {
                for item in batch {
                    context.insert(item)
                }
                try? context.save()
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func canLoadNext(for id: UUID) -> Bool {
        if let lastRequestedId, lastRequestedId == id {
            return false
        }
        lastRequestedId = id
        return true
    }

    private func nextCategory() -> String {
        let category = categories[categoryIndex % categories.count]
        categoryIndex += 1
        return category
    }

    private func normalizeTitle(_ title: String) -> String {
        title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func trackTitle(_ title: String) {
        recentTitles.append(title)
        if recentTitles.count > maxRecentTitles {
            recentTitles.removeFirst(recentTitles.count - maxRecentTitles)
        }
    }
}
