//
//  ccmanagerApp.swift
//  ccmanager
//
//  Created by d1demos on 9/6/25.
//

import SwiftUI

@main
struct ccmanagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
