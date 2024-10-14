//
//  PhotoEditorAppApp.swift
//  PhotoEditorApp
//
//  Created by Chandu .. on 10/13/24.
//

import SwiftUI

@main
struct PhotoEditorAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
