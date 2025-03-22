//
//  MainMenuView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/3/24.
//

import SwiftUI

struct MainMenuView: View {
    @Environment(\.modelContext) var modelContext
    //@State var path: NavigationPath = .init()
    @State private var showAddTeamScreen: Bool = false
    
    var body: some View {
        NavigationStack { //path: $path.animation(.bouncy)) {
            List {
                NavigationLink("Teams", value: "Teams")
                NavigationLink("Play Game", value: "Play Game")

            }
            .navigationTitle("ScoreKeep")
            .navigationDestination(for: String.self) {
                name in
                if name == "Teams" {
                    TeamsView()
                    //TeamsView(path: $path)
                } else if name == "Play Game" {
                    GamesView()
                    //StartGameView(path: $path)
                    //GamesView(path: $path)
                }
            }
            Button {
                addSampleData([Game.defaultGame])
                try? modelContext.save()
            } label: {
                Text("Add Default Data")
            }
        }
    }
    func addSampleData(_ examples: [Game]) {
        
        Task {
            examples.forEach { example in
                modelContext.insert(example)
            }
            try? modelContext.save()
        }
    }
}


#Preview {
    
    MainMenuView()
}
