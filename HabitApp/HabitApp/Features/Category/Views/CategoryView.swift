import SwiftUI
import SwiftData

struct CreateCategoryView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var categories: [Category] = []
    @State private var selectedCategoryToDelete: Category?
    
    private func reloadCategories() {
        guard let context = SwiftDataContext.shared else { return }
        let descriptor = FetchDescriptor<Category>()
        categories = (try? context.fetch(descriptor)) ?? []
    }

    /// Callback para devolver la categoría creada
    var onSave: (Category) -> Void
    
    var onDelete: () -> Void = {}
    
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
                Section(header: Text("Categorías existentes")) {
                    if categories.isEmpty {
                        Text("No hay categorías creadas").foregroundStyle(.secondary)
                    } else {
                        Picker("Selecciona una para eliminar", selection: $selectedCategoryToDelete) {
                            Text("Ninguna").tag(nil as Category?)
                            ForEach(categories, id: \.id) { category in
                                Text(category.name).tag(category as Category?)
                            }
                        }

                        Button(role: .destructive) {
                            guard let category = selectedCategoryToDelete,
                                  let context = SwiftDataContext.shared else { return }

                            // Eliminar la categoría seleccionada
                            context.delete(category)
                            try? context.save()

                            // Limpiar selección y recargar lista
                            selectedCategoryToDelete = nil
                            reloadCategories()
                            
                            onDelete()
                        } label: {
                            Text("Eliminar categoría seleccionada")
                        }
                        .disabled(selectedCategoryToDelete == nil)
                    }
                }
                .onAppear {
                    reloadCategories()
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

