import SwiftUI
import SwiftData

enum CategoryViewMode: String, CaseIterable, Identifiable {
    case create
    case delete

    var id: String { rawValue }

    var title: String {
        switch self {
        case .create:
            return "Crear"
        case .delete:
            return "Eliminar"
        }
    }
}

struct CreateCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var categories: [Category] = []
    @State private var selectedCategoryToDelete: Category?
    @State private var mode: CategoryViewMode = .create
    
    private func reloadCategories() {
        guard let context = SwiftDataContext.shared else { return }
        let descriptor = FetchDescriptor<Category>()
        categories = (try? context.fetch(descriptor)) ?? []
    }

    var onSave: (Category) -> Void
    var onDelete: () -> Void

    init(
        initialMode: CategoryViewMode = .create,
        onSave: @escaping (Category) -> Void,
        onDelete: @escaping () -> Void = {}
    ) {
        self.onSave = onSave
        self.onDelete = onDelete
        _mode = State(initialValue: initialMode)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Modo", selection: $mode) {
                        ForEach(CategoryViewMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(cardBackground)

                if mode == .create {
                    Section(header: Text("Nombre")) {
                        TextField("Nombre de la categoria", text: $name)
                            .autocorrectionDisabled()
                    }
                    .listRowBackground(cardBackground)

                    Section(header: Text("Descripcion")) {
                        TextField("Descripcion (opcional)", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    .listRowBackground(cardBackground)
                }

                if mode == .delete {
                    Section(header: Text("Categorias existentes")) {
                        if categories.isEmpty {
                            Text("No hay categorias creadas")
                                .foregroundStyle(.secondary)
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

                                context.delete(category)
                                try? context.save()

                                selectedCategoryToDelete = nil
                                reloadCategories()
                                
                                onDelete()
                            } label: {
                                Text("Eliminar categoria seleccionada")
                            }
                            .disabled(selectedCategoryToDelete == nil)
                        }
                    }
                    .listRowBackground(cardBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .background(backgroundColor)
            .tint(primaryColor)
            .navigationTitle("Categoria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                if mode == .create {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Guardar") {
                            let newCategory = Category(
                                name: name,
                                categoryDescription: description
                            )
                            
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
            .onAppear {
                if mode == .delete {
                    reloadCategories()
                }
            }
            .onChange(of: mode) { newValue in
                if newValue == .delete {
                    reloadCategories()
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
}
