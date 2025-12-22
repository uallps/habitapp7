import SwiftUI
import SwiftData

/// Protocolo base para todas las features (Core o Plugins)
protocol FeaturePlugin {
    /// Identificador único del plugin
    var id: String { get }
    
    /// Si el plugin está habilitado
    var isEnabled: Bool { get }
    
    /// Modelos de SwiftData que este plugin necesita registrar
    var models: [any PersistentModel.Type] { get }
    
    /// Configuración inicial (se llama al arrancar la app)
    func configure()
}

// Implementación por defecto
extension FeaturePlugin {
    var isEnabled: Bool { true }
    var models: [any PersistentModel.Type] { [] }
    func configure() {}
}
