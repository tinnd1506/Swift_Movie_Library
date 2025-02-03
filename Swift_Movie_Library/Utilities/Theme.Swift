import SwiftUI

struct Theme {
    static let primary = Color("AccentColor")
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let text = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    
    struct Card {
        static let shadow = Color.black.opacity(0.1)
        static let border = Color.gray.opacity(0.2)
    }
    
    static func gradientBackground(_ colors: [Color] = [.blue, .purple]) -> LinearGradient {
        LinearGradient(gradient: Gradient(colors: colors), 
                      startPoint: .topLeading, 
                      endPoint: .bottomTrailing)
    }
} 
