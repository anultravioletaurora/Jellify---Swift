//
//  FinTuneApp.swift
//  Shared
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI
import MediaPlayer
import StoreKit

@main
struct JellifyApp: App {
    
    /**
     Shared instance of the PersistenceController for storing to CoreData
     */
    let persistenceController = PersistenceController.shared
    
    let networkingManager = NetworkingManager.shared
    
//    /**
//     Watches the scene phase of the app, so we can perform a save when the user
//     navigates away
//     */
//    @Environment(\.scenePhase)
//    var scenePhase

    var body: some Scene {
        WindowGroup {
                ContentView()
                .environment(\.managedObjectContext, networkingManager.context)
        }
//        .onChange(of: scenePhase) { _ in
//            persistenceController.save()
//        }
    }
}
