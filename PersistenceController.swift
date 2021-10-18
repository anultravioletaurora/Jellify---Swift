//
//  PersistenceController.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/12/21.
//

import Foundation
import CoreData

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()

    // Storage for Core Data
    let container: NSPersistentContainer
    
    // A test configuration for SwiftUI previews
//    static var preview: PersistenceController = {
//        let controller = PersistenceController(inMemory: true)
//
//        // Create 10 example programming languages.
//        for _ in 0..<10 {
//            let artist = Artist(context: controller.container.viewContext)
//            artist.name = "Example Artist \($0)"
//            artist.id = UUID.init()
//        }
//
//        return controller
//    }

    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    init(inMemory: Bool = false) {
        // If you didn't name your model Main you'll need
        // to change this name below.
        container = NSPersistentContainer(name: "CoreData")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }
}
