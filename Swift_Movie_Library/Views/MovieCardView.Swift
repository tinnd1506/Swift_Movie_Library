// Views/MovieCardView.swift
import SwiftUI

struct MovieCardView: View {
    var movie: Movie
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Poster Image
            MoviePosterView(poster: movie.poster)
                .frame(width: 100, height: 150)
                .cornerRadius(12)
                .shadow(color: Theme.Card.shadow, radius: 8, x: 0, y: 4)
            
            // Movie Details
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.text)
                    .lineLimit(2)
                
                Text("Released in \(movie.releaseYear)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.secondaryText)
                
                // Rating Stars
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(movie.rating) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 1)
                    }
                    Text(String(format: "%.1f", movie.rating))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.secondaryText)
                }
                
                if !movie.description.isEmpty {
                    Text(movie.description)
                        .font(.system(size: 14))
                        .foregroundColor(Theme.secondaryText)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Removed the custom chevron here since NavigationLink provides one
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.background)
                .shadow(color: Theme.Card.shadow, radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Card.border, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// Helper view for movie posters
struct MoviePosterView: View {
    let poster: String?
    
    var body: some View {
        Group {
            if let poster = poster,
               let imageData = Data(base64Encoded: poster),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Theme.gradientBackground())
                    .overlay(
                        Image(systemName: "film")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    )
            }
        }
    }
}
