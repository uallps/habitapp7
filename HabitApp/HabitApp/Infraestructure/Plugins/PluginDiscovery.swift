import Foundation
import ObjectiveC

class PluginDiscovery {
    static func discoverAndRegisterPlugins() {
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
        
        for i in 0..<Int(actualClassCount) {
            let cls: AnyClass = allClasses[i]
            
            // Comprobar conformidad usando casting de Swift en lugar de runtime de ObjC
            if let _ = cls as? FeaturePlugin.Type {
                // Instanciar y registrar
                if let pluginType = cls as? NSObject.Type {
                    let plugin = pluginType.init()
                    if let featurePlugin = plugin as? FeaturePlugin {
                        PluginRegistry.shared.register(featurePlugin)
                    }
                }
            }
        }
        
        allClasses.deallocate()
    }
}
