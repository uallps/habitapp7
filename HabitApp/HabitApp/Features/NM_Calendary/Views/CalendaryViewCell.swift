import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let isInCurrentMonth: Bool
    let isToday: Bool
    let isMarked: Bool
    let isSelected: Bool
    let locale: Locale

    var body: some View {
        let day = Calendar.current.component(.day, from: date)

        ZStack {
            // Fondo marcado (naranja más claro)
            if isMarked {
                Circle()
                    .fill(Color.orange.opacity(0.5)) // color de fondo de los días marcados (más claro)
                    .frame(width: 34, height: 34)
            }

            // Borde hoy
            if isToday {
                Circle()
                    .stroke(Color.accentColor, lineWidth: 1.6)
                    .frame(width: 36, height: 36)
            }

            // Selección explícita
            if isSelected {
                Circle()
                    .stroke(Color.primary.opacity(0.7), lineWidth: 2)
                    .frame(width: 38, height: 38)
            }

            Text("\(day)")
                .font(.body)
                .foregroundStyle(isInCurrentMonth ? .primary : .secondary)
        }
        .frame(height: 42)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        let df = DateFormatter()
        df.locale = locale
        df.dateStyle = .full
        var parts = [df.string(from: date)]
        if isToday { parts.append("Hoy") }
        if isMarked { parts.append("Con hábitos") }
        if isSelected { parts.append("Seleccionado") }
        return parts.joined(separator: ", ")
    }
}
