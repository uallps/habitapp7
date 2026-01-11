import SwiftUI
import SwiftData

struct SuggestedHabitSwipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(HuggingFaceConfig.userDefaultsTokenKey) private var apiToken: String = ""

    @StateObject private var viewModel: SuggestedHabitViewModel

    init(context: ModelContext? = SwiftDataContext.shared) {
        _viewModel = StateObject(wrappedValue: SuggestedHabitViewModel(context: context))
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
            .onChange(of: apiToken) { _ in
                Task {
                    await viewModel.retryIfEmpty()
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
}
