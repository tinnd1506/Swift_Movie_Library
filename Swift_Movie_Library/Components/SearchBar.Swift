// SearchBar.swift
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.secondaryText)
                    .padding(.leading, 8)
                
                TextField("Search movies...", text: $text)
                    .padding(.horizontal, 8)
                    .autocapitalization(.none)
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.secondaryText)
                            .padding(.trailing, 8)
                    }
                }
            }
            .padding(8)
            .background(Theme.secondaryBackground)
            .cornerRadius(12)
            .animation(.easeInOut(duration: 0.2), value: text)
            
            if isEditing {
                Button("Cancel") {
                    text = ""
                    isEditing = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                 to: nil, from: nil, for: nil)
                }
                .foregroundColor(Theme.primary)
                .transition(.move(edge: .trailing))
            }
        }
        .padding(.horizontal)
        .onTapGesture {
            isEditing = true
        }
    }
}
