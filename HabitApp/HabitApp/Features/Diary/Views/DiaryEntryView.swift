//
//  DiaryEntryView.swift
//  HabitApp
//
//  Created by Francisco José García García on 16/11/25.
//
import SwiftUI

struct DiaryEntryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: DiaryViewModel
    let habitTitle: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(habitTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("¿Cómo te has sentido hoy?")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $viewModel.noteText)
                        .frame(minHeight: 150)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    DiaryEntryView(
        viewModel: DiaryViewModel(completionEntry: CompletionEntry(date: Date())),
        habitTitle: "Ejemplo de Hábito"
    )
}
