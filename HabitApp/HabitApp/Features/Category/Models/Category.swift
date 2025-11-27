//
//  Category.swift
//  HabitApp
//
//
import Foundation

struct Category: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    
}


//No se si lo mejor será relacionar los habitos con las categorias o al reves
//Podría ser que la ventana principal muestra directamente las categorias con los habitos dentro (en cuyo caso cada habito solo puede tener una categoria)

