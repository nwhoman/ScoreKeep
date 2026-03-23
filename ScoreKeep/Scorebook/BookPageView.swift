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
    @ObservedObject var gameViewModel: GameViewModel
    //@Binding var game: Game
    //@Binding var orderNumber: Int
    //@Binding var inningNumber: Int
    @State var showLargeView: Bool = false
    @State var showPlayerPA: Bool = false
    @State var largeView: Bool = true
    
    var selectedTab: String
    var innings: [Inning] {
        if selectedTab == "Visitor" {
            
            return gameViewModel.visitorInnings.sorted { $0.number < $1.number }

        } else {
            return gameViewModel.homeInnings.sorted { $0.number < $1.number }
        }
    }
    
    var team: Team {
        if selectedTab == "Home" {
            return gameViewModel.game.homeTeam!
        } else {
            return gameViewModel.game.visitingTeam!
        }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack {
                    HStack {
                        Text("Batting: \(gameViewModel.batterUp[gameViewModel.halfInning])")
                        Text("\(gameViewModel.inningNumber)")
                        //Text("\(gameViewModel.i)")
                    }
                    
                    // score by inning + RHE
                    HStack {
                        ScoreView(gameViewModel: gameViewModel)
                            .padding(.horizontal)
                        
                    }
                    HStack {
                        Button {
                            print(gameViewModel.undoPlay.count)
                        } label: {
                            Text("Undo Last Play")
                        }
                        NavigationLink {
                            BoxScoreView(gameViewModel: gameViewModel)
                        } label: {
                            Text("Box Score")
                        }
                        
                    }
                    ScrollView() {
                        HStack(alignment: .top) {
                            BattingLineupView(gameVM: gameViewModel, geo: geo, team: team, tab: selectedTab)
                            //.padding(.leading)
                                .border(Color.blue)
                            ScrollView(Axis.Set.horizontal) {
                                InningsView(gameViewModel: gameViewModel, showLargeView: $showLargeView, showPlayerPA: $showPlayerPA, largeView: $largeView, team: team, innings: innings, selectedTab: selectedTab)
                                
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        
    }
}

#Preview {
    var game = Game.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    //setUpGame(game: game)
    
    return BookPageView(gameViewModel: GameViewModel(game: game), selectedTab: "Home - \(game.homeTeam!.name)")
        .modelContainer(preview.modelContainer)
}

struct InningsView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @Binding var showLargeView: Bool
    @Binding var showPlayerPA: Bool
    @Binding var largeView: Bool

    //@Binding var orderNumber: Int
    //@Binding var inningNumber: Int
    //@State var currentPlayer: OffensivePlateAppearance?
    //@State var outs: Int = 0
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
                        //Text("\(gameViewModel.inningNumber)--\(gameViewModel.batterUp[gameViewModel.halfInning])")
                        ForEach(inning.offense.sorted(by: {$0.order < $1.order}), id: \.self) { player in
                            GeometryReader { geo in
                                
                                SmallPlateAppearanceView(gameViewModel: gameViewModel, player: player, scale: 0.15)
                                    .onTapGesture {
                                        if !gameViewModel.game.isComplete {
                                            
                                            if (teamBatting && gameViewModel.halfInning == 0 && gameViewModel.inningNumber == inning.number && gameViewModel.batterUp[gameViewModel.halfInning] == player.order) || (!teamBatting && gameViewModel.halfInning == 1 && gameViewModel.inningNumber == inning.number && gameViewModel.batterUp[gameViewModel.halfInning] == player.order) {
                                                if player.outcome["home"] == "" {
                                                    player.active = true
                                                    gameViewModel.batter = player
                                                    //gameViewModel.inningNumber = inning.number
                                                    let brNode = BaseRunnerNode(player: player)
                                                    gameViewModel.baseRunners.insert(brNode, at: 0)
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
        .navigationDestination(isPresented: $gameViewModel.game.isComplete) {
            GameSummaryView(gameViewModel: gameViewModel, game: gameViewModel.game)
        }
        .sheet(isPresented: $showLargeView, onDismiss: {
            //  update game viewmodel, check outs and switch sides
            gameViewModel.checkGameComplete()
            if gameViewModel.outs == 3 {
                gameViewModel.outs = 0
                gameViewModel.balls = 0
                gameViewModel.strikes = 0
                
                gameViewModel.baseRunners.removeAll()
                gameViewModel.pitches.removeAll()
                
                if gameViewModel.halfInning == 0 {
                    gameViewModel.halfInning = 1
                } else {
                    gameViewModel.halfInning = 0
                    gameViewModel.inningNumber += 10
                }
                                
            } else { // if dismiss sheet before batter is finished
                if !gameViewModel.game.isComplete {
                    if gameViewModel.batter?.outcome["home"] == "" {
                        gameViewModel.baseRunners.remove(at: 0)
                        gameViewModel.decrementBatterUp()
                    }
                    gameViewModel.undoPlay.append(gameViewModel)
                }
                
                // check for walk-off win
            }
            
            if !largeView {
                largeView.toggle()
            }
        })
        {
            LargePlateAppearanceView(gameViewModel: gameViewModel, player: gameViewModel.batter!, pitcher: gameViewModel.pitcher!, largeView: $largeView)
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
