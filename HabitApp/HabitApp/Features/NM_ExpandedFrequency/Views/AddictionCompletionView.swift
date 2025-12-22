import SwiftUI

struct AddictionCompletionView: View {
    var habit: Habit
    var toggleAction: () -> Void
    
    var body: some View {
        Button(action: toggleAction) {
            HStack {
                // isCompletedToday ahora devuelve true si NO hay entrada (Éxito/Limpio)
                // Si es true (Limpio) -> Check Verde
                // Si es false (Recaída) -> X Roja
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(habit.isCompletedToday ? .green : .red)
                    .font(.title2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
