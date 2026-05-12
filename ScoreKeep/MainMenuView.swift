//
//  MainMenuView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/3/24.
//

import SwiftUI

struct MainMenuView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var nav: NavigationStateManager
    
    
    @State private var showAddTeamScreen: Bool = false
    let preview = Preview()
    let game = GameViewModel.defaultGame
    
    var body: some View {
        //NavigationStack { //path: $path.animation(.bouncy)) {
            List {
                Button {
                    nav.push(.players)
                    //PlayersView(team: nil)
                } label: {
                    Image(systemName: "pencil")
                        .fontWeight(.bold)
                        .font(.system(size: 12))
                    Text("Players")
                }
                Button {
                    nav.push(.teams)
                } label: {
                    Image(systemName: "pencil")
                        .fontWeight(.bold)
                        .font(.system(size: 12))
                    Text("Teams")
                }
                Button {
                    nav.push(.games)
                } label: {
                    Image(systemName: "pencil")
                        .fontWeight(.bold)
                        .font(.system(size: 12))
                    Text("Games")
                }
                Button {
                    nav.push(.innings)
                } label: {
                    Image(systemName: "pencil")
                        .fontWeight(.bold)
                        .font(.system(size: 12))
                    Text("Innings")
                }
                
            }
            .navigationTitle("ScoreKeep")
            
            Button {
                
                preview.addSampleLineups(game: game)
                addSampleData([game])
                try? modelContext.save()
            } label: {
                Text("Add Default Data")
            }
        
    }
        
    func addSampleData(_ examples: [GameViewModel]) {
        
        Task {
            examples.forEach { example in
                modelContext.insert(example)
            }
            try? modelContext.save()
        }
    }
}


#Preview {
    let preview = Preview()
    let game = GameViewModel.defaultGame
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    
    return MainMenuView()
        .environmentObject(NavigationStateManager())
        .modelContainer(preview.modelContainer)
}
