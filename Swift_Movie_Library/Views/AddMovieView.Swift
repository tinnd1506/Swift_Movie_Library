// Views/AddMovieView.swift
import SwiftUI

struct AddMovieView: View {
    @EnvironmentObject var coreDataStore: CoreDataMovieStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var releaseYearString: String = ""
    @State private var rating: Double = 0
    @State private var description: String = ""
    // This will store a Base64-encoded image string once an image is picked.
    @State private var poster: String = ""
    
    // For the image picker integration.
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    @State private var selectedImage: Image?
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var releaseYear: Int? {
        return Int(releaseYearString)
    }
    
    private var isValidYear: Bool {
        guard let year = releaseYear else { return false }
        let currentYear = Calendar.current.component(.year, from: Date())
        return year >= 1888 && year <= currentYear + 5 // 1888 is the year of the first film
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Movie Info")) {
                    TextField("Title", text: $title)
                    TextField("Release Year", text: $releaseYearString)
                        .keyboardType(.numberPad)
                    VStack(alignment: .leading) {
                        Text("Rating: \(String(format: "%.1f", rating))")
                        Slider(value: $rating, in: 0...5, step: 0.5)
                    }
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Poster")) {
                    // If an image has been selected, show a preview.
                    if let selectedImage = selectedImage {
                        selectedImage
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
            .navigationTitle("Add Movie")
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
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
        
        // Save the movie
        let newMovie = Movie(
            title: title,
            releaseYear: year,
            rating: rating,
            description: description,
            poster: poster.isEmpty ? nil : poster
        )
        
        coreDataStore.addMovie(newMovie)
        presentationMode.wrappedValue.dismiss()
    }
    
    // When a new image is selected, update the preview and encode the image.
    func loadImage() {
        guard let inputImage = inputImage else { return }
        selectedImage = Image(uiImage: inputImage)
        if let imageData = inputImage.jpegData(compressionQuality: 0.8) {
            poster = imageData.base64EncodedString()
        }
    }
}
