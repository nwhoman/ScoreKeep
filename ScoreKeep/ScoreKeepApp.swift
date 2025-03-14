//
//  ScoreKeepApp.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/25/24.
//

import SwiftUI
import SwiftData

@main
struct ScoreKeepApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Team.self, Player.self, Coach.self, Game.self])

    }
}
