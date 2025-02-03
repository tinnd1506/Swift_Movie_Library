//
//  Persistence.swift
//  MovieLibrary
//
//  Created by Nguyễn Tín on 02/02/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // MARK: - Preview Instance
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create some preview data using your CDMovie entity.
        for i in 0..<5 {
            let previewMovie = CDMovie(context: viewContext)
            previewMovie.id = UUID()
            previewMovie.title = "Preview Movie \(i + 1)"
            previewMovie.releaseYear = Int32(2020 + i)
            previewMovie.rating = Double.random(in: 0...5)
            previewMovie.movieDescription = "This is a description for preview movie \(i + 1)."
            previewMovie.poster = nil  // Optionally, you can add a Base64 encoded string here.
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    // MARK: - Core Data Stack
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MovieLibrary") // Name must match your .xcdatamodeld file.
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
