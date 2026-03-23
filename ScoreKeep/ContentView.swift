//
//  ContentView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/25/24.
//
import SwiftData
import SwiftUI

struct ContentView: View {
    
    @StateObject var nav = NavigationStateManager()
    
    var body: some View {
        NavigationStack(path: $nav.path) {
            //PlateAppearanceView()
            MainMenuView()
        }
        .environmentObject(nav)
    }
}


#Preview {
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    return ContentView()
        .modelContainer(preview.modelContainer)
}
