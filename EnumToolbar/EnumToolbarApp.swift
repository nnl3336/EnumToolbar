//
//  EnumToolbarApp.swift
//  EnumToolbar
//
//  Created by Yuki Sasaki on 2025/09/04.
//

import SwiftUI

@main
struct EnumToolbarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
