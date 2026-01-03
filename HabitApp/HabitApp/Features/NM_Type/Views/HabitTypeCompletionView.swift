import SwiftUI
import SwiftData

struct HabitTypeCompletionView: View {
    @StateObject private var viewModel: HabitCompletionViewModel
    
    init(habit: Habit, context: ModelContext, toggleAction: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: HabitCompletionViewModel(habit: habit, context: context, toggleAction: toggleAction))
    }
    
    var body: some View {
        Group {
            if let type = viewModel.habitType {
                switch type.type {
                case .binary:
                    // Usar botón estándar (o reimplementarlo si se desea control total)
                    Button(action: viewModel.toggleAction) {
                        Image(systemName: viewModel.habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(viewModel.habit.isCompletedToday ? .green : .gray)
                            .font(.title2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                case .count:
                    Button(action: {
                        viewModel.incrementProgress()
                    }) {
                        HStack {
                            Image(systemName: viewModel.habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(viewModel.habit.isCompletedToday ? .green : .gray)
                            
                            Text("\(Int(viewModel.progress)) / \(Int(type.targetValue ?? 0)) \(type.unit ?? "")")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        .padding(6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                case .timer:
                    Button(action: {
                        viewModel.toggleTimer()
                    }) {
                        HStack {
                            Image(systemName: viewModel.isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                                .foregroundColor(viewModel.isTimerRunning ? .orange : .blue)
                            
                            Text(formatTime(viewModel.progress) + " / " + formatTime(type.targetValue ?? 0))
                                .font(.caption)
                                .foregroundColor(.primary)
                                .monospacedDigit()
                        }
                        .padding(6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
