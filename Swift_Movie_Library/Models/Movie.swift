// Models/Movie.swift
import Foundation

struct Movie: Identifiable, Codable {
    let id: UUID
    var title: String
    var releaseYear: Int
    var rating: Double
    var description: String
    var poster: String?  // Base64 string or URL string for the poster
    
    init(id: UUID = UUID(), title: String, releaseYear: Int, rating: Double, description: String, poster: String? = nil) {
        self.id = id
        self.title = title
        self.releaseYear = releaseYear
        self.rating = rating
        self.description = description
        self.poster = poster
    }
}
