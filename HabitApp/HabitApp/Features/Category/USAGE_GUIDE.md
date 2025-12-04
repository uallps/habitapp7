# Guía de Uso: Sistema de Categorías con SwiftData

## ✅ Respuesta a tu pregunta: **SÍ, es totalmente posible**

El enfoque que propusiste es la solución correcta y estándar para este problema en SwiftData.

## 📋 Qué se ha implementado

### 1. **HabitCategoryFeature** (Modelo intermedio)
```swift
@Model
final class HabitCategoryFeature {
    var habit: Habit?
    var category: Category?
}
```
Esta clase almacena la relación entre un hábito y una categoría en SwiftData.

### 2. **Category** (Ahora es @Model)
Se transformó de `struct` a `class` con `@Model` para poder persistirla en SwiftData.

### 3. **Extension de Habit**
Ahora usa la relación con `HabitCategoryFeature` en lugar de UserDefaults.

## 🔧 Cómo usar

### Asignar una categoría a un hábito

```swift
import SwiftData
import SwiftUI

struct MyView: View {
    @Environment(\.modelContext) private var modelContext
    
    var habit: Habit
    var category: Category
    
    func assignCategory() {
        // Método helper para asignar categoría
        habit.setCategory(category, in: modelContext)
        
        // Guardar cambios
        try? modelContext.save()
    }
}
```

### Acceder a la categoría de un hábito

```swift
// Muy simple - igual que antes
if let categoryName = habit.category?.name {
    Text("Categoría: \(categoryName)")
}
```

### Crear una nueva categoría

```swift
let newCategory = Category(
    name: "Salud",
    categoryDescription: "Hábitos relacionados con la salud"
)
modelContext.insert(newCategory)
try? modelContext.save()
```

### Agrupar hábitos por categoría

```swift
@Query private var habits: [Habit]

var body: some View {
    let grouped = Habit.groupByCategory(habits)
    
    ForEach(grouped.keys.sorted(), id: \.self) { categoryName in
        Section(categoryName) {
            ForEach(grouped[categoryName] ?? []) { habit in
                Text(habit.title)
            }
        }
    }
}
```

## 🔄 Migración desde UserDefaults

Si ya tienes datos en UserDefaults, necesitarás migrarlos:

```swift
func migrateCategories(habits: [Habit], context: ModelContext) {
    for habit in habits {
        // Leer el valor antiguo de UserDefaults si existe
        let categoryKey = "habit_category_\(habit.id.uuidString)"
        if let data = UserDefaults.standard.data(forKey: categoryKey),
           let oldCategoryData = try? JSONDecoder().decode(OldCategoryStruct.self, from: data) {
            
            // Buscar o crear la categoría en SwiftData
            let fetchDescriptor = FetchDescriptor<Category>(
                predicate: #Predicate { $0.name == oldCategoryData.name }
            )
            
            let existingCategory = try? context.fetch(fetchDescriptor).first
            let category = existingCategory ?? Category(
                name: oldCategoryData.name,
                categoryDescription: oldCategoryData.description
            )
            
            if existingCategory == nil {
                context.insert(category)
            }
            
            // Asignar la categoría
            habit.setCategory(category, in: context)
            
            // Limpiar UserDefaults
            UserDefaults.standard.removeObject(forKey: categoryKey)
        }
    }
    
    try? context.save()
}
```

## ⚠️ Consideraciones importantes

### 1. **Schema de SwiftData**
Asegúrate de registrar todos los modelos en tu `ModelContainer`:

```swift
@main
struct HabitAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Habit.self,
            CompletionEntry.self,
            Category.self,
            HabitCategoryFeature.self  // ← Importante incluirlo
        ])
    }
}
```

### 2. **Queries de SwiftData**
Para cargar hábitos con sus categorías de forma eficiente:

```swift
@Query private var habits: [Habit]

// SwiftData carga automáticamente las relaciones cuando las accedes
// No necesitas hacer nada especial
```

### 3. **Eliminar categoría de un hábito**

```swift
habit.setCategory(nil, in: modelContext)
try? modelContext.save()
```

## 🎯 Ventajas de este enfoque

1. **Persistencia real**: Los datos se guardan en la base de datos, no en UserDefaults
2. **Relaciones bidireccionales**: Puedes navegar desde Habit a Category y viceversa
3. **Queries eficientes**: Puedes buscar hábitos por categoría fácilmente
4. **Integridad referencial**: SwiftData maneja automáticamente las eliminaciones
5. **Sintaxis limpia**: La propiedad `habit.category` sigue siendo igual de simple

## 🚀 Ejemplo completo

```swift
import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [Habit]
    @Query private var categories: [Category]
    
    @State private var selectedHabit: Habit?
    @State private var selectedCategory: Category?
    
    var body: some View {
        VStack {
            // Lista de hábitos
            List(habits) { habit in
                HStack {
                    Text(habit.title)
                    Spacer()
                    Text(habit.category?.name ?? "Sin categoría")
                        .foregroundStyle(.secondary)
                }
                .onTapGesture {
                    selectedHabit = habit
                }
            }
            
            // Selector de categoría
            if let habit = selectedHabit {
                Picker("Categoría", selection: $selectedCategory) {
                    Text("Sin categoría").tag(nil as Category?)
                    ForEach(categories) { category in
                        Text(category.name).tag(category as Category?)
                    }
                }
                .onChange(of: selectedCategory) { old, new in
                    habit.setCategory(new, in: modelContext)
                    try? modelContext.save()
                }
            }
        }
    }
}
```

## 💡 Respuesta final

**SÍ, tu enfoque es correcto y funciona perfectamente con SwiftData.**

La clave es:
1. ✅ Crear una clase `@Model` intermedia (HabitCategoryFeature)
2. ✅ Establecer las relaciones bidireccionales
3. ✅ Usar propiedades computadas en la extensión para mantener la API limpia
4. ✅ Proporcionar un método helper (`setCategory`) para gestionar la relación

No necesitas "cargar" manualmente nada - SwiftData gestiona automáticamente las relaciones cuando las accedes a través de `habit.category`.
