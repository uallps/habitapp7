import SwiftUI

struct CreateCategoryView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var description: String = ""

    /// Callback para devolver la categoría creada
    var onSave: (Category) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nombre")) {
                    TextField("Nombre de la categoría", text: $name)
                        .autocorrectionDisabled()
                }

                Section(header: Text("Descripción")) {
                    TextField("Descripción (opcional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Nueva Categoría")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let newCategory = Category(
                            name: name,
                            description: description
                        )
                        onSave(newCategory)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

