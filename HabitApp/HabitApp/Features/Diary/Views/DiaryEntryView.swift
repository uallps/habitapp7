//
//  DiaryEntryView.swift
//  HabitApp
//
//  Created by Francisco Jose Garcia Garcia on 16/11/25.
//
import SwiftUI

struct DiaryEntryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var viewModel: DiaryViewModel
    let habitTitle: String
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text(habitTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                        .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Como te has sentido hoy?")
                            .font(.headline)
                            .foregroundColor(secondaryTextColor)
                        
                        TextEditor(text: $viewModel.noteText)
                            .frame(minHeight: 160)
                            .padding(12)
                            .background(cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(borderColor, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .tint(primaryColor)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        viewModel.saveNote()
                        dismiss()
                    }
                }
            }
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

    private var borderColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.black.opacity(0.08)
    }

    private var secondaryTextColor: Color {
        colorScheme == .dark
            ? Color(red: 199 / 255, green: 186 / 255, blue: 176 / 255)
            : Color(red: 120 / 255, green: 120 / 255, blue: 120 / 255)
    }
}

#Preview {
    DiaryEntryView(
        viewModel: DiaryViewModel(completionEntry: CompletionEntry(date: Date())),
        habitTitle: "Ejemplo de Habito"
    )
}
