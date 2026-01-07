import SwiftUI
import SwiftData

// Debe heredar de NSObject para que PluginDiscovery pueda instanciarlo dinámicamente.
final class CalendarPlugin: NSObject, ViewPlugin, FeaturePlugin {
    // MARK: - FeaturePlugin
    var id: String { "com.nm.calendar.plugin" }
    var isEnabled: Bool { true }
    var models: [any PersistentModel.Type] { [] }
    func configure() {
        // No-op
    }

    // MARK: - ViewPlugin
    func habitListFooterView() -> AnyView? {
        AnyView(CalendarFooterButton())
    }
}

// MARK: - Footer Button Wrapper

private struct CalendarFooterButton: View {
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("Calendario", systemImage: "calendar")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.thinMaterial, in: Capsule())
        }
        .sheet(isPresented: $isPresented) {
            CalendarView()
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}
