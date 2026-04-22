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
    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nav: NavigationStateManager
    @Query private var games: [Game]
    
    @State private var selectedTab: String = "Visitor"
    @State var gameViewModel: GameViewModel

    var body: some View {
        GeometryReader { geo in
            ZStack {
                TabView(selection: $gameViewModel.selectedTab) {
                    
                    BookPageView(gameViewModel: gameViewModel, lineup: gameViewModel.visitorLineup, selectedTab: gameViewModel.selectedTab)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Visitor - \(gameViewModel.game.visitingTeam!.name)")
                        }.tag("Visitor")
                    BookPageView(gameViewModel: gameViewModel, lineup: gameViewModel.homeLineup, selectedTab: gameViewModel.selectedTab)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Home - \(gameViewModel.game.homeTeam!.name)")
                        }.tag("Home")
                    
            
                }

                VStack {
                    HStack {
                        //Spacer(
                    
                    }
                    //Spacer()
                }
                .navigationDestination(isPresented: $gameViewModel.game.isComplete) {
                    GameSummaryView(gameViewModel: gameViewModel, game: gameViewModel.game)
                }
            }
        }
        .onAppear {
            if !gameViewModel.game.isStarted {
                gameViewModel.setUpGame()
                gameViewModel.game.isStarted = true
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            if !gameViewModel.game.isStarted {
                Button {
                    gameViewModel.setUpGame()
                    //gameViewModel.game.innings[gameViewModel.inningNumber-1].visitorOffense[gameViewModel.batterUp[gameViewModel.halfInning]].active = true
                    gameViewModel.game.isStarted = true
                } label: {
                    Text("Start Game")
                        .font(.headline)
                        .padding(.horizontal)
                }
            } else {
                Button {
                    //gameViewModel.addInning(inning: Inning(number: gameViewModel.inningNumber+1, game: gameViewModel.game, half: gameViewModel.halfInning), lineup: gameViewModel.halfInning == 0 ? gameViewModel.visitorLineup : gameViewModel.homeLineup, halfInning: gameViewModel.halfInning)
                    gameViewModel.inningNumber[gameViewModel.halfInning] += 1
                    gameViewModel.addInning(inning: Inning(number: gameViewModel.inningNumber[gameViewModel.halfInning], game: gameViewModel.game, half: gameViewModel.halfInning), lineup: gameViewModel.halfInning == 0 ? gameViewModel.game.visitingLineup : gameViewModel.game.homeLineup, halfInning: gameViewModel.halfInning)
                } label: {
                    Image(systemName: "plus.rectangle")
                }
            }
            Button {
                //print("leaving game: " + gameViewModel.saveViewModelAsJSON())
                Task {
                    modelContext.insert(gameViewModel)
                    try? modelContext.save()
                }
    
                
                nav.path.removeLast()
            } label: {
                Image(systemName: "backward.fill")
            }
        }
    }
}
func advanceLineup() {
    //game.innings[inningNumber-1].visitorOffense[orderNumber].active = true
}

#Preview {
    var game = Game.defaultGame
    let preview = Preview()
    let gameViewModel: GameViewModel = .init(game: game, totalInnings: 3, inningRunRule: 0)
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    //setUpGame(game: game)
    
    return NavigationStack {
        BookView(gameViewModel: gameViewModel)
            .modelContainer(preview.modelContainer)
    }
   
}
