
import SwiftUI

@main
struct Swift_Movie_LibraryApp: App {
    @StateObject private var coreDataStore = CoreDataMovieStore()
    
    var body: some Scene {
        WindowGroup {
            MovieListView()  // Update the main view to use coreDataStore
                .environmentObject(coreDataStore)
        }
    }
}
