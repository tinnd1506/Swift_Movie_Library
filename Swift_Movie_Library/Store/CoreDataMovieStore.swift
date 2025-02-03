// Store/CoreDataMovieStore.swift
import SwiftUI
import CoreData

@MainActor
class CoreDataMovieStore: ObservableObject {
    let container: NSPersistentContainer
    @Published var movies: [Movie] = []
    
    init() {
        // Name must match the .xcdatamodeld file (without extension)
        container = NSPersistentContainer(name: "MovieLibrary")
        
        // Configure the persistent store description
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        Task { @MainActor in
            container.loadPersistentStores { description, error in
                if let error = error as NSError? {
                    // Handle the error appropriately
                    print("Core Data store failed to load: \(error.localizedDescription)")
                    print("Error details: \(error.userInfo)")
                    
                    // Attempt to recover by deleting the store
                    self.deleteAndRecreateStore()
                }
            }
            self.fetchMovies()
        }
    }
    
    private func deleteAndRecreateStore() {
        // Get the store URL
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            return
        }
        
        // Remove the store
        do {
            try container.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
            
            // Recreate the store
            try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            
        } catch {
            print("Failed to recreate store: \(error.localizedDescription)")
        }
    }
    
    // Fetch movies from Core Data and convert them to [Movie]
    func fetchMovies() {
        let request: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDMovie.releaseYear, ascending: true)]
        do {
            let cdMovies = try container.viewContext.fetch(request)
            self.movies = cdMovies.map { $0.toMovie() }
        } catch {
            print("Error fetching movies: \(error.localizedDescription)")
            self.movies = []
        }
    }
    
    // Add a new movie
    func addMovie(_ movie: Movie) {
        let cdMovie = CDMovie(context: container.viewContext)
        cdMovie.update(from: movie)
        saveContext()
    }
    
    // Update an existing movie
    func updateMovie(_ movie: Movie) {
        let request: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", movie.id as CVarArg)
        do {
            let results = try container.viewContext.fetch(request)
            if let cdMovie = results.first {
                cdMovie.update(from: movie)
                saveContext()
            }
        } catch {
            print("Error updating movie: \(error.localizedDescription)")
        }
    }
    
    // Delete a movie
    func deleteMovie(_ movie: Movie) {
        let request: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", movie.id as CVarArg)
        do {
            let results = try container.viewContext.fetch(request)
            if let cdMovie = results.first {
                container.viewContext.delete(cdMovie)
                saveContext()
            }
        } catch {
            print("Error deleting movie: \(error.localizedDescription)")
        }
    }
    
    // Save the context and refresh the movies list
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                fetchMovies()  // Refresh the published movies list
            } catch {
                print("Error saving Core Data context: \(error.localizedDescription)")
            }
        }
    }
}
