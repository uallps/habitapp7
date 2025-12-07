//
//  TaskAppApp.swift
//  TaskApp
//
//  Created by Francisco José García García on 15/10/25.
//

import SwiftUI
import UserNotifications
import SwiftData

@main
struct HabitApp: App {
    @StateObject private var appConfig = AppConfig()
    
    // Storage provider obtenido desde AppConfig (LPS-friendly)
    private var storageProvider: StorageProvider {
        appConfig.storageProvider
    }
    
    var body: some Scene {
        WindowGroup {
            HabitListView(storageProvider: storageProvider)
                .environmentObject(appConfig)
        }
    }
}

