import Foundation
import ObjectiveC

class PluginDiscovery {
    static func discoverAndRegisterPlugins() {
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
        defer { allClasses.deallocate() }
        
        for i in 0..<Int(actualClassCount) {
            let cls: AnyClass = allClasses[i]
            let className = NSStringFromClass(cls)

            guard className.hasPrefix("HabitApp") else {
                continue
            }
            
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
    }
}
