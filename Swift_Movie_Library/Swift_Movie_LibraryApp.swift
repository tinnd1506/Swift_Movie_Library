//
//  Swift_Movie_LibraryApp.swift
//  Swift_Movie_Library
//
//  Created by Nguyễn Tín on 03/02/2025.
//

import SwiftUI

@main
struct Swift_Movie_LibraryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
