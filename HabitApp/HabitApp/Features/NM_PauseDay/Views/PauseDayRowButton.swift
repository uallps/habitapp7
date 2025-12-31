import SwiftUI
import SwiftData

struct PauseDayRowButton: View {
    let habit: Habit

    @State private var showSheet = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: {
            showSheet = true
        }) {
            Image(systemName: "pause.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(primaryColor)
                .padding(6)
                .background(surfaceColor)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Dias de pausa")
        .sheet(isPresented: $showSheet) {
            PauseDaySheetView(
                habitID: habit.id,
                context: habit.modelContext ?? SwiftDataContext.shared,
                primaryColor: primaryColor,
                backgroundColor: backgroundColor,
                cardBackground: cardBackground
            )
        }
    }

    private var primaryColor: Color {
        Color(red: 242 / 255, green: 120 / 255, blue: 13 / 255)
    }

    private var backgroundColor: Color {
        colorScheme == .dark
            ? Color(red: 25 / 255, green: 18 / 255, blue: 14 / 255)
            : Color(red: 248 / 255, green: 247 / 255, blue: 245 / 255)
    }

    private var cardBackground: Color {
        colorScheme == .dark
            ? Color(red: 38 / 255, green: 26 / 255, blue: 20 / 255)
            : Color.white
    }

    private var surfaceColor: Color {
        colorScheme == .dark
            ? Color(red: 66 / 255, green: 48 / 255, blue: 38 / 255)
            : Color.white
    }
}

private struct PauseDaySheetView: View {
    let habitID: UUID
    let context: ModelContext?
    let primaryColor: Color
    let backgroundColor: Color
    let cardBackground: Color

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            if let context = context {
                Form {
                    PauseDaySelectionView(habitID: habitID, context: context)
                        .listRowBackground(cardBackground)
                }
                .scrollContentBackground(.hidden)
                .background(backgroundColor)
                .tint(primaryColor)
                .navigationTitle("Dias en pausa")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cerrar") {
                            dismiss()
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Text("No hay contexto disponible.")
                        .foregroundStyle(.secondary)
                    Button("Cerrar") {
                        dismiss()
                    }
                    .tint(primaryColor)
                }
                .padding()
            }
        }
    }
}
