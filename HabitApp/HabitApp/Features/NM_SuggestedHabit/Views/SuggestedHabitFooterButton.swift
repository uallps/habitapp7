import SwiftUI

struct SuggestedHabitFooterButton: View {
    @State private var isPresented = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("Habitos sugeridos", systemImage: "sparkles")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(primaryColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(
                    color: primaryColor.opacity(colorScheme == .dark ? 0.35 : 0.2),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isPresented) {
            SuggestedHabitSwipeView()
        }
    }

    private var primaryColor: Color {
        Color(red: 242 / 255, green: 120 / 255, blue: 13 / 255)
    }
}
