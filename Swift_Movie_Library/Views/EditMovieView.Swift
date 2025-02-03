// Views/EditMovieView.swift
import SwiftUI

struct EditMovieView: View {
    @EnvironmentObject var coreDataStore: CoreDataMovieStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var movie: Movie
    @State private var releaseYearString: String
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    @State private var selectedImage: Image?
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(movie: Movie) {
        _movie = State(initialValue: movie)
        _releaseYearString = State(initialValue: String(movie.releaseYear))
    }
    
    private var releaseYear: Int? {
        return Int(releaseYearString)
    }
    
    private var isValidYear: Bool {
        guard let year = releaseYear else { return false }
        let currentYear = Calendar.current.component(.year, from: Date())
        return year >= 1888 && year <= currentYear + 5
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Movie Info")) {
                    TextField("Title", text: $movie.title)
                    TextField("Release Year", text: $releaseYearString)
                        .keyboardType(.numberPad)
                    VStack(alignment: .leading) {
                        Text("Rating: \(String(format: "%.1f", movie.rating))")
                        Slider(value: $movie.rating, in: 0...5, step: 0.5)
                    }
                    TextField("Description", text: $movie.description)
                }
                
                Section(header: Text("Poster")) {
                    // If an image has been selected, show a preview.
                    if let selectedImage = selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                    // Otherwise, if a poster already exists for the movie, decode and show it.
                    else if let poster = movie.poster,
                            let imageData = Data(base64Encoded: poster),
                            let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                    
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Text("Select Poster Image")
                    }
                }
            }
            .navigationTitle("Edit Movie")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        validateAndSave()
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .onChange(of: inputImage) { _ in loadImage() }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func validateAndSave() {
        // Validate title
        if movie.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Please enter a title"
            showingAlert = true
            return
        }
        
        // Validate year format
        if releaseYearString.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            alertMessage = "Release year must contain only numbers"
            showingAlert = true
            return
        }
        
        // Validate year value
        guard let year = releaseYear, isValidYear else {
            alertMessage = "Please enter a valid release year (between 1888 and \(Calendar.current.component(.year, from: Date()) + 5))"
            showingAlert = true
            return
        }
        
        // Update the movie with the validated year
        var updatedMovie = movie
        updatedMovie.releaseYear = year
        
        coreDataStore.updateMovie(updatedMovie)
        presentationMode.wrappedValue.dismiss()
    }
    
    // When a new image is selected, update the preview and encode the image.
    func loadImage() {
        guard let inputImage = inputImage else { return }
        selectedImage = Image(uiImage: inputImage)
        if let imageData = inputImage.jpegData(compressionQuality: 0.8) {
            // Update the movie's poster field with the Base64-encoded image.
            movie.poster = imageData.base64EncodedString()
        }
    }
}
