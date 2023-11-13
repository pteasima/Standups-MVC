//
//  Standups_MVCApp.swift
//  Standups-MVC
//
//  Created by Petr Šíma on 13.10.2023.
//

import SwiftUI
import SwiftData

@main
struct Standups_MVCApp: App {
  var body: some Scene {
    WindowGroup {
      StandupsListView()
        .modelContainer(for: Standup.self, isAutosaveEnabled: true)
    }
  }
}


