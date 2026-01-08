import SwiftUI
import SwiftData
import Combine

struct SuggestedHabitSwipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(HuggingFaceConfig.userDefaultsTokenKey) private var apiToken: String = ""

    @StateObject private var viewModel: SuggestedHabitViewModel

    init() {
        _viewModel = StateObject(wrappedValue: SuggestedHabitViewModel(context: SwiftDataContext.shared))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                header
                tokenSection
                content
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
                Task {
                    await viewModel.loadInitialIfNeeded()
                }
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

    @ViewBuilder
    private var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, minHeight: 120)
                }

                ForEach(viewModel.suggestions) { suggestion in
                    SuggestedHabitCardView(suggestion: suggestion)
                        .padding(.horizontal, 4)
                        .onAppear {
                            Task {
                                await viewModel.loadNextIfNeeded(currentId: suggestion.id)
                            }
                        }
                }

                if viewModel.isLoading {
                    ProgressView("Cargando otro habito...")
                        .padding(.vertical, 8)
                } else if viewModel.suggestions.isEmpty {
                    Text("Cargando habitos sugeridos...")
                        .font(.footnote)
                        .foregroundColor(secondaryTextColor)
                        .frame(maxWidth: .infinity, minHeight: 120)
                }
            }
            .padding(.bottom, 8)
        }
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

                Text("Frecuencia: \(suggestion.frequency)")
                    .font(.footnote)
                    .foregroundColor(secondaryTextColor)

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
    private var hasLoadedInitial = false

    init(context: ModelContext?, modelId: String = HuggingFaceConfig.resolveModelId()) {
        self.context = context
        self.modelId = modelId
    }

    func loadInitialIfNeeded() async {
        guard !hasLoadedInitial else { return }
        hasLoadedInitial = true
        await loadNext()
    }

    func loadNextIfNeeded(currentId: UUID) async {
        guard let lastId = suggestions.last?.id, lastId == currentId else { return }
        await loadNext()
    }

    private func loadNext() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let client = try HuggingFaceClient(modelId: modelId)
            let response = try await client.generateHabitSuggestions(count: 1, focus: nil)

            guard let draft = response.drafts.first else {
                throw HuggingFaceError.decodingFailed
            }

            let newSuggestion = SuggestedHabitSuggestion(
                title: draft.title,
                details: draft.details,
                frequency: draft.frequency ?? "Flexible",
                sourceModel: response.modelId
            )

            suggestions.append(newSuggestion)

            if let context {
                context.insert(newSuggestion)
                try? context.save()
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}



