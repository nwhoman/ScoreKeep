//
//  BookPageView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/21/25.
//

import SwiftUI

struct BookPageView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    //@ObservedObject var gameViewModel: GameViewModel
    @EnvironmentObject var nav: NavigationStateManager
    @State var gameViewModel: GameViewModel
    //@Binding var game: Game
    //@Binding var orderNumber: Int
    //@Binding var inningNumber: Int
    @State var lineup: [[PlayerPos]]
    @State var showLargeView: Bool = false
    @State var showPlayerPA: Bool = false
    @State var largeView: Bool = true
    
    var selectedTab: String
    var innings: [Inning] {
        if gameViewModel.selectedTab == "Visitor" {
            
            return gameViewModel.visitorInnings.sorted { $0.number < $1.number }

        } else {
            return gameViewModel.homeInnings.sorted { $0.number < $1.number }
        }
    }
    
    var team: Team {
        if gameViewModel.selectedTab == "Visitor" {
            return gameViewModel.game.visitingTeam!
        } else {
            return gameViewModel.game.homeTeam!
        }
    }
    
    var body: some View {
        //NavigationStack {
            GeometryReader { geo in
                VStack {
//                    HStack {
//                        Text("Batting: \(gameViewModel.batterUp[gameViewModel.halfInning])")
//                        Text("\(gameViewModel.inningNumber)")
//                        //Text("\(gameViewModel.i)")
//                    }
                    
                    // score by inning + RHE
                    HStack {
                        ScoreView(gameViewModel: gameViewModel)
                            .padding(.horizontal)
                        
                    }
                    HStack {
                        NavigationLink {
                            BoxScoreView(gameViewModel: gameViewModel)
                        } label: {
                            Text("Box Score")
                        }
                        
                    }
                    ScrollView() {
                        HStack(alignment: .top) {
                            BattingLineupView(gameVM: gameViewModel, battingOrder: lineup, geo: geo, team: team, tab: selectedTab)
                            //.padding(.leading)
                                .border(Color.blue)
                            ScrollView(Axis.Set.horizontal) {
                                InningsView(showLargeView: $showLargeView, showPlayerPA: $showPlayerPA, largeView: $largeView, gameViewModel: gameViewModel, team: team, innings: innings, selectedTab: selectedTab)
                                
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        //}
        
    }
}

#Preview {
    var game = Game.defaultGame
    let gameVM = GameViewModel(game: game, totalInnings: 3, inningRunRule: 0)
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    //gameVM.setUpGame()
    
    return BookPageView(gameViewModel: gameVM, lineup: gameVM.homeLineup, selectedTab: "Home - \(game.homeTeam!.name)")
        .modelContainer(preview.modelContainer)
}

struct InningsView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var nav: NavigationStateManager

    //@ObservedObject var gameViewModel: GameViewModel
    @Binding var showLargeView: Bool
    @Binding var showPlayerPA: Bool
    @Binding var largeView: Bool
    @State var gameViewModel: GameViewModel
    //@Binding var orderNumber: Int
    //@Binding var inningNumber: Int
    @State var currentPlayer: OffensivePlateAppearance?
    @State var currentPitcher: DefensivePlateAppearance?
    var team: Team
    var innings: [Inning]
    var selectedTab: String?
    
    var teamBatting: Bool {
        if selectedTab == "Visitor" {
            return true
        } else {
            return false
        }
    }
    var body: some View {
        HStack {
            ForEach(innings.sorted(by: {$0.number < $1.number}), id: \.self) { inning in
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("\(inning.number/10)")//--\(inning.number/10)")
                        .frame(width: 75, height: 50, alignment: .center)
                        .border(Color.blue)
                        Text("\(gameViewModel.inningNumber[gameViewModel.halfInning])-\(gameViewModel.batterUp[gameViewModel.halfInning])/\(gameViewModel.batterCount[gameViewModel.halfInning])")
                        ForEach(inning.plateAppearances.sorted(by: {$0.order < $1.order}), id: \.self) { player in
                            GeometryReader { geo in
                                
                                SmallPlateAppearanceView(gameViewModel: gameViewModel, player: player, scale: 0.15)
                                    .onTapGesture {
                                        if !gameViewModel.game.isComplete {
                                            if (teamBatting && gameViewModel.halfInning == 0 && gameViewModel.inningNumber[gameViewModel.halfInning] == inning.number && gameViewModel.batterUp[gameViewModel.halfInning] == player.order) || (!teamBatting && gameViewModel.halfInning == 1 && gameViewModel.inningNumber[gameViewModel.halfInning] == inning.number && gameViewModel.batterUp[gameViewModel.halfInning] == player.order) {
                                                if player.outcome["home"] == "" {
                                                    player.active = true
                                                    gameViewModel.batter = player
                                                    //gameViewModel.updatePitcherStats()
                                                    currentPlayer = player
                                                    //currentPitcher?.active = true
                                                    //gameViewModel.inningNumber = inning.number
                                                    
                                                    gameViewModel.baseRunners.insert(player, at: 0)
                                                    gameViewModel.balls = 0
                                                    gameViewModel.strikes = 0
                                                    gameViewModel.incrementBatterUp()
                                                    showLargeView.toggle()
                                                    
                                                } else {
                                                    //print("\(player.hit), \(player.outcome)")
                                                    showLargeView.toggle()
                                                }
                                            } else {
                                                if player.active {
                                                    gameViewModel.batter = player
                                                    showPlayerPA.toggle()
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                    }
                            }
                        }
                        .frame(width: 75, height: 75, alignment: .topLeading)
                        //.border(Color.black)
                    }
                }
            }
        }
        .sheet(isPresented: $showLargeView, onDismiss: {
            //  update game viewmodel, check outs and switch sides
            //gameViewModel.updatePitcherStats()
            gameViewModel.checkGameComplete()
            if gameViewModel.checkInningComplete() { // change of sides, reset all game inning variables
                gameViewModel.outs = 0
                gameViewModel.balls = 0
                gameViewModel.strikes = 0
                
                gameViewModel.baseRunners.removeAll()
                
                gameViewModel.inningRuns = 0
                if gameViewModel.halfInning == 0 {
                    gameViewModel.inningNumber[0] += 10
                    gameViewModel.halfInning = 1
                } else {
                    gameViewModel.halfInning = 0
                    gameViewModel.inningNumber[1] += 10
                }
                
                try? modelContext.save()
            } else {
                if !gameViewModel.game.isComplete {
                    // if dismiss sheet before batter is finished
                    if gameViewModel.batter?.outcome["home"] == "" {
                        gameViewModel.baseRunners.remove(at: 0)
                        gameViewModel.decrementBatterUp()
                    } else {
                        gameViewModel.balls = 0
                        gameViewModel.strikes = 0
                        //print("\(gameViewModel.undoPlay.count)")
                        
                    }
                    try? modelContext.save()
                }
                
                // check for walk-off win
            }
            
            if !largeView {
                largeView.toggle()
            }
        })
        {
            LargePlateAppearanceView(gameViewModel: gameViewModel, player: gameViewModel.batter!, largeView: $largeView)
                .presentationBackground(alignment: .top) {
                    LinearGradient(colors: [Color.gray, Color.green], startPoint: .bottomLeading, endPoint: .topTrailing)
                }
                .presentationCornerRadius(50)
        }
        .sheet(isPresented: $showPlayerPA, onDismiss: {
            return 
        }) {
            PlateAppearanceView(gameViewModel: gameViewModel, player: gameViewModel.batter!)
        }

        
    }
}
