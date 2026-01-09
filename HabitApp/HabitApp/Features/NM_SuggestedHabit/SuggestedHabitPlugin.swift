import SwiftUI
import SwiftData

class SuggestedHabitPlugin: NSObject, FeaturePlugin, ViewPlugin {
    var id: String { "NM_SuggestedHabit" }
    var models: [any PersistentModel.Type] { [SuggestedHabitSuggestion.self] }

    func habitListFooterView() -> AnyView? {
        AnyView(SuggestedHabitFooterButton())
    }
}
