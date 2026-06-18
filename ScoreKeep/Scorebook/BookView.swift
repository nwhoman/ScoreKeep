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
    //@Query private var games: [Game]
    
    @State private var selectedTab: String = "Visitor"
    @Binding var gameViewModel: GameViewModel

    var body: some View {
        GeometryReader { geo in
            ZStack {
                TabView(selection: $gameViewModel.selectedTab) {
                    
                    BookPageView(gameViewModel: $gameViewModel, lineup: $gameViewModel.visitorLineup, geo: geo, selectedTab: gameViewModel.selectedTab)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Visitor - \(gameViewModel.visitingTeam.name)")
                        }.tag("Visitor")
                        .padding(.leading, 5)
                    BookPageView(gameViewModel: $gameViewModel, lineup: $gameViewModel.homeLineup, geo: geo, selectedTab: gameViewModel.selectedTab)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Home - \(gameViewModel.homeTeam.name)")
                        }.tag("Home")
                        .padding(.leading, 5)
                }
                VStack {
                    HStack {
                        //Space
                        
                    }
                    //Spacer()
                }
                .navigationDestination(isPresented: $gameViewModel.isComplete) {
                    GameSummaryView(gameViewModel: gameViewModel, geo: geo)
                }
            }
            
        }
        .onAppear {
            if !gameViewModel.isStarted {
                gameViewModel.setUpGame()
                gameViewModel.isStarted = true
            }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !gameViewModel.isStarted {
                    Button {
                        gameViewModel.setUpGame()
                        gameViewModel.isStarted = true
                    } label: {
                        Text("Start Game")
                            .font(.headline)
                            .padding(.horizontal)
                    }
                } else {
                    Button {
//                        //gameViewModel.addInning(inning: Inning(number: gameViewModel.inningNumber+1, game: gameViewModel.game, half: gameViewModel.halfInning), lineup: gameViewModel.halfInning == 0 ? gameViewModel.visitorLineup : gameViewModel.homeLineup, halfInning: gameViewModel.halfInning)
                        gameViewModel.inningNumber[gameViewModel.halfInning] += 1
                        gameViewModel.addInning(inning: Inning(number: gameViewModel.inningNumber[gameViewModel.halfInning], game: gameViewModel, half: gameViewModel.halfInning), lineup: gameViewModel.halfInning == 0 ? gameViewModel.visitorCurrentLineup : gameViewModel.homeCurrentLineup, halfInning: gameViewModel.halfInning)
                    } label: {
                        Image(systemName: "plus.rectangle")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    //print("leaving game: " + gameViewModel.saveViewModelAsJSON())
                    Task {
                        
                        try? modelContext.save()
                    }
                    
                    
                    nav.path.removeLast()
                } label: {
                    Image(systemName: "backward.fill")
                }
            }
        }
    }
}

#Preview {
    let preview = Preview()
    let gameViewModel: GameViewModel = GameViewModel.defaultGame
    preview.addSampleGames([gameViewModel])
    preview.addSampleLineups(game: gameViewModel)
    //setUpGame(game: game)
    
    return NavigationStack {
        BookView(gameViewModel: .constant(gameViewModel))
            .modelContainer(preview.modelContainer)
    }
   
}
