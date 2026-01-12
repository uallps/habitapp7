import SwiftUI

struct SuggestedHabitCardView: View {
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
