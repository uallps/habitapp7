//
//  CategoryTest.swift
//  HabitAppTests
//

import XCTest
#if canImport(HabitApp_Premium)
@testable import HabitApp_Premium
#elseif canImport(HabitApp_Standard)
@testable import HabitApp_Standard
#elseif canImport(HabitApp_Core)
@testable import HabitApp_Core
#else
@testable import HabitApp
#endif

final class CategoryTest: XCTestCase {
    
    // MARK: - Test de inicialización
    
    func testCategoryInitializationWithDefaults() {
        // Arrange & Act
        let category = Category(name: "Salud", categoryDescription: "Hábitos saludables")
        
        // Assert
        XCTAssertEqual(category.name, "Salud")
        XCTAssertEqual(category.categoryDescription, "Hábitos saludables")
        XCTAssertNotNil(category.id)
        XCTAssertTrue(category.habitAssociations.isEmpty)
    }
    
    func testCategoryInitializationWithCustomId() {
        // Arrange
        let customId = UUID()
        
        // Act
        let category = Category(id: customId, name: "Trabajo", categoryDescription: "Hábitos laborales")
        
        // Assert
        XCTAssertEqual(category.id, customId)
        XCTAssertEqual(category.name, "Trabajo")
        XCTAssertEqual(category.categoryDescription, "Hábitos laborales")
    }
    
    // MARK: - Test de propiedades
    
    func testCategoryPropertiesCanBeModified() {
        // Arrange
        let category = Category(name: "Original", categoryDescription: "Descripción original")
        
        // Act
        category.name = "Modificado"
        category.categoryDescription = "Descripción modificada"
        
        // Assert
        XCTAssertEqual(category.name, "Modificado")
        XCTAssertEqual(category.categoryDescription, "Descripción modificada")
    }
    
    func testCategoryIdIsUnique() {
        // Arrange & Act
        let category1 = Category(name: "Cat1", categoryDescription: "Desc1")
        let category2 = Category(name: "Cat2", categoryDescription: "Desc2")
        
        // Assert
        XCTAssertNotEqual(category1.id, category2.id)
    }
    
    // MARK: - Test de relaciones
    
    func testCategoryHabitAssociationsInitiallyEmpty() {
        // Arrange & Act
        let category = Category(name: "Test", categoryDescription: "Test")
        
        // Assert
        XCTAssertEqual(category.habitAssociations.count, 0)
        XCTAssertTrue(category.habitAssociations.isEmpty)
    }
    
    // MARK: - Test de valores extremos
    
    func testCategoryWithEmptyName() {
        // Arrange & Act
        let category = Category(name: "", categoryDescription: "Descripción")
        
        // Assert
        XCTAssertEqual(category.name, "")
        XCTAssertEqual(category.categoryDescription, "Descripción")
    }
    
    func testCategoryWithEmptyDescription() {
        // Arrange & Act
        let category = Category(name: "Nombre", categoryDescription: "")
        
        // Assert
        XCTAssertEqual(category.name, "Nombre")
        XCTAssertEqual(category.categoryDescription, "")
    }
    
    func testCategoryWithLongName() {
        // Arrange
        let longName = String(repeating: "A", count: 1000)
        
        // Act
        let category = Category(name: longName, categoryDescription: "Desc")
        
        // Assert
        XCTAssertEqual(category.name.count, 1000)
        XCTAssertEqual(category.name, longName)
    }
    
    func testCategoryWithLongDescription() {
        // Arrange
        let longDescription = String(repeating: "B", count: 5000)
        
        // Act
        let category = Category(name: "Name", categoryDescription: longDescription)
        
        // Assert
        XCTAssertEqual(category.categoryDescription.count, 5000)
        XCTAssertEqual(category.categoryDescription, longDescription)
    }
    
    // MARK: - Test de casos especiales
    
    func testCategoryWithSpecialCharacters() {
        // Arrange & Act
        let category = Category(
            name: "Salud 💪 & Bienestar",
            categoryDescription: "Descripción con caracteres especiales: áéíóú ñ @#$%"
        )
        
        // Assert
        XCTAssertEqual(category.name, "Salud 💪 & Bienestar")
        XCTAssertTrue(category.categoryDescription.contains("áéíóú"))
        XCTAssertTrue(category.categoryDescription.contains("@#$%"))
    }
    
    func testMultipleCategoriesWithSameName() {
        // Arrange & Act
        let category1 = Category(name: "Salud", categoryDescription: "Desc1")
        let category2 = Category(name: "Salud", categoryDescription: "Desc2")
        
        // Assert
        XCTAssertNotEqual(category1.id, category2.id, "Deben tener IDs diferentes")
        XCTAssertEqual(category1.name, category2.name, "Pueden tener el mismo nombre")
        XCTAssertNotEqual(category1.categoryDescription, category2.categoryDescription)
    }
    
    // MARK: - Test de comparación
    
    func testCategoryEquality() {
        // Arrange
        let id = UUID()
        let category1 = Category(id: id, name: "Test", categoryDescription: "Desc")
        let category2 = Category(id: id, name: "Different", categoryDescription: "Other")
        
        // Act & Assert
        // Las categorías con el mismo ID deberían considerarse iguales (por referencia)
        XCTAssertEqual(category1.id, category2.id)
    }
}
