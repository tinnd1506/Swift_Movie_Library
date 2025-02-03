import SwiftUI

struct MovieListView: View {
    // Replace the local MovieStore with the Core Data store from the environment
    @EnvironmentObject var coreDataStore: CoreDataMovieStore
    @State private var searchText: String = ""
    @State private var selectedSortOption: SortOption = .title
    @State private var animateList = false
    
    enum SortOption: String, CaseIterable, Identifiable {
        case title = "Title"
        case rating = "Rating"
        case releaseYear = "Year"
        
        var id: String { self.rawValue }
    }
    
    // Filter and sort movies based on search text and selected option.
    var filteredMovies: [Movie] {
        let filtered = coreDataStore.movies.filter { movie in
            searchText.isEmpty ? true : movie.title.lowercased().contains(searchText.lowercased())
        }
        
        switch selectedSortOption {
        case .title:
            return filtered.sorted { $0.title < $1.title }
        case .rating:
            return filtered.sorted { $0.rating > $1.rating }
        case .releaseYear:
            return filtered.sorted { $0.releaseYear < $1.releaseYear }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar – you can use your custom SearchBar view here
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .transition(.move(edge: .top))
                
                // Sorting Control
                Picker("Sort by", selection: $selectedSortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .animation(.easeInOut, value: selectedSortOption)
                
                // List of Movies
                List {
                    ForEach(filteredMovies) { movie in
                        NavigationLink {
                            MovieDetailView(movie: movie)
                                .environmentObject(coreDataStore)
                        } label: {
                            MovieCardView(movie: movie)
                                .opacity(animateList ? 1 : 0)
                                .offset(x: animateList ? 0 : -50)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .buttonStyle(PlainButtonStyle()) // Prevents double highlighting
                    }
                    .onDelete { indexSet in
                        withAnimation(.easeOut) {
                            indexSet.forEach { index in
                                let movie = filteredMovies[index]
                                coreDataStore.deleteMovie(movie)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("My Movie Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddMovieView()) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    animateList = true
                }
            }
            .onDisappear {
                animateList = false
            }
            .background(
                VisualEffectBlur(blurStyle: .systemMaterial)
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
}
