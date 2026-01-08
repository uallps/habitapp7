import SwiftUI
import SwiftData
import Combine
struct SuggestedHabitSwipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(HuggingFaceConfig.userDefaultsTokenKey) private var apiToken: String = ""

    @State private var focusText = ""
    @StateObject private var viewModel: SuggestedHabitViewModel

    init() {
        _viewModel = StateObject(wrappedValue: SuggestedHabitViewModel(context: SwiftDataContext.shared))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                header
                tokenSection
                focusSection
                content
                actionBar
            }
            .padding()
            .background(backgroundColor.ignoresSafeArea())
            .navigationTitle("Habitos sugeridos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadCached()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Desliza para ver habitos sugeridos por el modelo.")
                .font(.subheadline)
                .foregroundColor(secondaryTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var tokenSection: some View {
        if apiToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Se necesita un API token de Hugging Face.")
                    .font(.footnote)
                    .foregroundColor(secondaryTextColor)

                SecureField("Hugging Face API token", text: $apiToken)
                    .textFieldStyle(.roundedBorder)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var focusSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tema opcional")
                .font(.footnote)
                .foregroundColor(secondaryTextColor)

            TextField("Ej: salud, estudio, productividad", text: $focusText)
                .textFieldStyle(.roundedBorder)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Generando sugerencias...")
                .frame(maxWidth: .infinity, minHeight: 220)
        } else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, minHeight: 220)
        } else if viewModel.suggestions.isEmpty {
            Text("Sin sugerencias aun. Pulsa Generar para obtener ideas.")
                .font(.footnote)
                .foregroundColor(secondaryTextColor)
                .frame(maxWidth: .infinity, minHeight: 220)
        } else {
            TabView {
                ForEach(viewModel.suggestions) { suggestion in
                    SuggestedHabitCardView(suggestion: suggestion)
                        .padding(.horizontal, 4)
                }
            }
            .frame(height: 260)
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
    }

    private var actionBar: some View {
        Button {
            Task {
                await viewModel.generateSuggestions(focus: focusText)
            }
        } label: {
            Label("Generar", systemImage: "sparkles")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(primaryColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(apiToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
    }

    private var primaryColor: Color {
        Color(red: 242 / 255, green: 120 / 255, blue: 13 / 255)
    }

    private var backgroundColor: Color {
        colorScheme == .dark
            ? Color(red: 25 / 255, green: 18 / 255, blue: 14 / 255)
            : Color(red: 248 / 255, green: 247 / 255, blue: 245 / 255)
    }


    private var secondaryTextColor: Color {
        colorScheme == .dark
            ? Color(red: 199 / 255, green: 186 / 255, blue: 176 / 255)
            : Color(red: 120 / 255, green: 120 / 255, blue: 120 / 255)
    }

    private struct SuggestedHabitCardView: View {
        let suggestion: SuggestedHabitSuggestion
        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(suggestion.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(primaryTextColor)

                Text(suggestion.details)
                    .font(.body)
                    .foregroundColor(primaryTextColor)

                Spacer()

                Text("Model: \(suggestion.sourceModel)")
                    .font(.caption)
                    .foregroundColor(secondaryTextColor)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 220)
            .background(cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.12),
                radius: 10,
                x: 0,
                y: 4
            )
        }

        private var cardBackground: Color {
            colorScheme == .dark
                ? Color(red: 38 / 255, green: 26 / 255, blue: 20 / 255)
                : Color.white
        }

        private var borderColor: Color {
            colorScheme == .dark
                ? Color.white.opacity(0.08)
                : Color.black.opacity(0.08)
        }

        private var primaryTextColor: Color {
            colorScheme == .dark
                ? Color(red: 248 / 255, green: 247 / 255, blue: 245 / 255)
                : Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)
        }

        private var secondaryTextColor: Color {
            colorScheme == .dark
                ? Color(red: 199 / 255, green: 186 / 255, blue: 176 / 255)
                : Color(red: 120 / 255, green: 120 / 255, blue: 120 / 255)
        }
    }
}

@MainActor
final class SuggestedHabitViewModel: ObservableObject {
    @Published var suggestions: [SuggestedHabitSuggestion] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let context: ModelContext?
    private let modelId: String

    init(context: ModelContext?, modelId: String = HuggingFaceConfig.defaultModelId) {
        self.context = context
        self.modelId = modelId
    }

    func loadCached() {
        guard let context else { return }

        let descriptor = FetchDescriptor<SuggestedHabitSuggestion>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        suggestions = (try? context.fetch(descriptor)) ?? []
    }

    func generateSuggestions(focus: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let client = try HuggingFaceClient(modelId: modelId)
            let trimmedFocus = focus.trimmingCharacters(in: .whitespacesAndNewlines)
            let drafts = try await client.generateHabitSuggestions(
                count: 6,
                focus: trimmedFocus.isEmpty ? nil : trimmedFocus
            )

            let newSuggestions = drafts.map {
                SuggestedHabitSuggestion(
                    title: $0.title,
                    details: $0.details,
                    sourceModel: modelId
                )
            }

            if let context {
                let existing = (try? context.fetch(FetchDescriptor<SuggestedHabitSuggestion>())) ?? []
                for item in existing {
                    context.delete(item)
                }
                for item in newSuggestions {
                    context.insert(item)
                }
                try? context.save()
            }

            suggestions = newSuggestions
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}



