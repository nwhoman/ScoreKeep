//
//  BookView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/25/24.
//

import SwiftData
import SwiftUI

struct BookView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var game: Game
    @State private var selectedTab: String = "Visitor"
    
    var body: some View {
        GeometryReader { geo in
            TabView(selection: $selectedTab) {
                BookPageView(game: game, selectedTab: selectedTab)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Visitor - \(game.visitingTeam!.name)")
                    }.tag("Visitor")
                BookPageView(game: game, selectedTab: selectedTab)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Home - \(game.homeTeam!.name)")
                    }.tag("Home")
            }
            
        }
    }
}
#Preview {
    var game = Game.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)

    return NavigationStack {
        BookView(game: game)
            .modelContainer(preview.modelContainer)
    }

   
}
