import SwiftUI
import SwiftData

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
                            categoryDescription: description
                        )
                        
                        // Persistir en SwiftData usando el contexto global
                        if let context = SwiftDataContext.shared {
                            context.insert(newCategory)
                            try? context.save()
                        }
                        
                        onSave(newCategory)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

