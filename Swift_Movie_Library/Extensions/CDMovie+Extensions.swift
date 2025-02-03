import Foundation
import CoreData

extension CDMovie {
    
    // Convert a Core Data entity to a Swift model
    func toMovie() -> Movie {
        Movie(
            id: self.id ?? UUID(),
            title: self.title ?? "",
            releaseYear: Int(self.releaseYear),
            rating: self.rating,
            description: self.movieDescription ?? "",
            poster: self.poster
        )
    }
    
    // Update the Core Data entity from a Swift model
    func update(from movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.releaseYear = Int32(movie.releaseYear)
        self.rating = movie.rating
        self.movieDescription = movie.description
        self.poster = movie.poster
    }
}
