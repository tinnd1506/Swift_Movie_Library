//
//  ContentView.swift
//  MovieLibrary
//
//  Created by Nguyễn Tín on 02/02/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Update the fetch request to use CDMovie and sort by title (or any attribute you prefer)
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDMovie.title, ascending: true)],
        animation: .default)
    private var movies: FetchedResults<CDMovie>

    var body: some View {
        NavigationView {
            List {
                ForEach(movies) { movie in
                    NavigationLink {
                        // Destination: For demonstration, we show the movie title and release year.
                        VStack(alignment: .leading) {
                            Text(movie.title ?? "Unknown Title")
                                .font(.title)
                            Text("Released: \(movie.releaseYear)")
                                .font(.subheadline)
                        }
                        .padding()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(movie.title ?? "Unknown Title")
                                    .font(.headline)
                                Text("Released: \(movie.releaseYear)")
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteMovies)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("My Movie Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addMovie) {
                        Label("Add Movie", systemImage: "plus")
                    }
                }
            }
            Text("Select a movie")
                .foregroundColor(.secondary)
        }
    }

    // Add a new movie to Core Data with some default values.
    private func addMovie() {
        withAnimation {
            let newMovie = CDMovie(context: viewContext)
            newMovie.id = UUID()
            newMovie.title = "New Movie"
            newMovie.releaseYear = 2025
            newMovie.rating = 0.0
            newMovie.movieDescription = "Description goes here."
            newMovie.poster = nil

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // Delete selected movies from Core Data.
    private func deleteMovies(offsets: IndexSet) {
        withAnimation {
            offsets.map { movies[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let previewDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
