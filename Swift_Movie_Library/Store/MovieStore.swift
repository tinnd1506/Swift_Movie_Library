// MovieStore.swift
import SwiftUI

class MovieStore: ObservableObject {
    @Published var movies: [Movie] = [] {
        didSet {
            saveMovies()  // Save movies whenever the array is updated
        }
    }
    
    private let moviesKey = "movies_key"
    
    init() {
        loadMovies()  // Load movies from UserDefaults when the store is initialized
    }
    
    // Add a new movie to the list
    func addMovie(_ movie: Movie) {
        movies.append(movie)
    }
    
    // Delete a movie from the list
    func deleteMovie(_ movie: Movie) {
        movies.removeAll { $0.id == movie.id }
    }
    
    // Update an existing movie
    func updateMovie(_ movie: Movie) {
        // Find the index of the movie to update
        if let index = movies.firstIndex(where: { $0.id == movie.id }) {
            // Replace the old movie with the updated one
            movies[index] = movie
        }
    }
    
    // MARK: Persistence with UserDefaults
    private func loadMovies() {
        if let data = UserDefaults.standard.data(forKey: moviesKey) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Movie].self, from: data) {
                self.movies = decoded
            }
        }
    }
    
    private func saveMovies() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(movies) {
            UserDefaults.standard.set(encoded, forKey: moviesKey)
        }
    }
}
