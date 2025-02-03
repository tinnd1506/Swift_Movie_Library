import SwiftUI

struct MovieDetailView: View {
    var movie: Movie
    @EnvironmentObject var movieStore: CoreDataMovieStore
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteConfirmation = false
    @State private var animate = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Poster Image Section with animation
                Group {
                    if let poster = movie.poster,
                       let imageData = Data(base64Encoded: poster),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                            .overlay(Text("No Image"))
                            .cornerRadius(12)
                    }
                }
                .rotation3DEffect(.degrees(animate ? 0 : 5), axis: (x: 1, y: 0, z: 0))
                .offset(y: animate ? 0 : -50)
                .opacity(animate ? 1 : 0)
                
                // Movie Details Section
                VStack(alignment: .leading, spacing: 10) {
                    Text(movie.title)
                        .font(.largeTitle)
                        .bold()
                        .offset(x: animate ? 0 : -50)
                        .opacity(animate ? 1 : 0)
                    
                    Text("Released in \(movie.releaseYear)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .offset(x: animate ? 0 : -30)
                        .opacity(animate ? 1 : 0)
                    
                    HStack {
                        Text("Rating:")
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(movie.rating) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .scaleEffect(animate ? 1 : 0.1)
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    
                    Text(movie.description)
                        .padding(.top)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 20)
                }
                .padding(.horizontal)
                
                // Action Buttons
                HStack {
                    Button(action: { showDeleteConfirmation = true }) {
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.red)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: EditMovieView(movie: movie).environmentObject(movieStore)) {
                        Label("Edit", systemImage: "pencil")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                }
                .padding(.horizontal)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 30)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(
            VisualEffectBlur(blurStyle: .systemMaterial)
                .edgesIgnoringSafeArea(.all)
        )
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Movie"),
                message: Text("Are you sure you want to delete this movie?"),
                primaryButton: .destructive(Text("Delete")) {
                    withAnimation {
                        movieStore.deleteMovie(movie)
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animate = true
            }
        }
        .onDisappear {
            animate = false
        }
    }
}
