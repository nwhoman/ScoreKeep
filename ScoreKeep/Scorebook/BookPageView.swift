//
//  BookPageView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/21/25.
//

import SwiftUI

struct BookPageView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nav: NavigationStateManager
    @State var gameViewModel: GameViewModel
    @State var lineup: [[PlayerPos]]
    @State var showLargeView: Bool = false
    @State var showPlayerPA: Bool = false
    @State var largeView: Bool = true
    @State var completeGame: Bool = false
    let geo: GeometryProxy
    
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
            return gameViewModel.visitingTeam
        } else {
            return gameViewModel.homeTeam
        }
    }
    
    var body: some View {
            //GeometryReader { geo in
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
                            BoxScoreView(gameViewModel: gameViewModel, geo: geo)
                        } label: {
                            Text("Box Score")
                        }
                        if !gameViewModel.isComplete {
                            Button {
                                completeGame = true
                            } label: {
                                Text("Complete Game")
                            }
                        } else {
                            Text("Game is complete")
                        }
                        
                        
                    }
                    ScrollView() {
                        HStack(alignment: .top) {
                            BattingLineupView(gameVM: gameViewModel, battingOrder: lineup, geo: geo, team: team, tab: selectedTab)
                            //.padding(.leading)
                                .border(Color.blue)
                            ScrollView(Axis.Set.horizontal) {
                                InningsView(showLargeView: $showLargeView, showPlayerPA: $showPlayerPA, largeView: $largeView, gameViewModel: gameViewModel, team: team, innings: innings, selectedTab: selectedTab, geo: geo)
                                
                            }
                            
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .alert("Complete Game?", isPresented: $completeGame) {
                    Button {
                        
                        gameViewModel.game.isComplete = true
                        gameViewModel.checkGameComplete()
                        try? modelContext.save()
                    } label: {
                        Text("Complete Game")
                    }
            }
            
    //}
        
    }
}

#Preview {
    let gameVM = GameViewModel.defaultGame
    let preview = Preview()
    preview.addSampleGames([gameVM])
    preview.addSampleLineups(game: gameVM)
    //gameVM.setUpGame()
    
    return GeometryReader { geo in
        BookPageView(gameViewModel: gameVM, lineup: gameVM.homeLineup, geo: geo, selectedTab: "Home - \(game.homeTeam!.name)")
            .modelContainer(preview.modelContainer)
    }
}

struct InningsView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var nav: NavigationStateManager

    @Binding var showLargeView: Bool
    @Binding var showPlayerPA: Bool
    @Binding var largeView: Bool
    @State var gameViewModel: GameViewModel
    
    @State var currentPlayer: OffensivePlateAppearance?
    @State var currentPitcher: DefensivePlateAppearance?
    var team: Team
    var innings: [Inning]
    var selectedTab: String?
    let geo: GeometryProxy
    
    var teamBatting: Bool {
        if selectedTab == "Visitor" {
            return true
        } else {
            return false
        }
    }
    var body: some View {
        //GeometryReader { geo in
            HStack {
                ForEach(innings.sorted(by: {$0.number < $1.number}), id: \.self) { inning in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("\(inning.number/10)")//--\(inning.number/10)")
                                .frame(width: 75, height: 50, alignment: .center)
                                .border(Color.blue)
//                            Text("\(gameViewModel.inningNumber[gameViewModel.halfInning])-\(gameViewModel.batterUp[gameViewModel.halfInning])/\(gameViewModel.batterCount[gameViewModel.halfInning])")
//                                .border(Color.blue)
                            ForEach(inning.plateAppearances.sorted(by: {$0.order < $1.order}), id: \.self) { player in
                                SmallPlateAppearanceView(gameViewModel: gameViewModel, player: player, scale: 0.15)
                                    .onTapGesture {
                                        if !gameViewModel.isComplete {
                                            if checkBatter(inning: inning, player: player) {
                                                if player.outcome["home"] == "" {
                                                    gameViewModel.batter = player
                                                    //gameViewModel.currentPlayer = player
                                                    gameViewModel.baseRunners.insert(player, at: 0)
                                                    gameViewModel.incrementBatterUp()
                                                    showLargeView.toggle()
                                                    if !player.active {
                                                        player.active = true
                                                        gameViewModel.balls = 0
                                                        gameViewModel.strikes = 0
                                                    }
                                                } else {
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
                            .frame(width: 75, height: 75, alignment: .topLeading)
                            //.border(Color.black)
                            Spacer()
                        }
                    }
                }
            }
            .sheet(isPresented: $showLargeView, onDismiss: {
                //  update game viewmodel, check outs and switch sides
                gameViewModel.checkInningComplete()
                try? modelContext.save()
                
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
            .frame(maxWidth: .infinity)
        }
        
    
    func checkBatter(inning: Inning, player: OffensivePlateAppearance) -> Bool {
        if (teamBatting && gameViewModel.halfInning == 0 && gameViewModel.inningNumber[gameViewModel.halfInning] == inning.number && gameViewModel.batterUp[gameViewModel.halfInning] == player.order) || (!teamBatting && gameViewModel.halfInning == 1 && gameViewModel.inningNumber[gameViewModel.halfInning] == inning.number && gameViewModel.batterUp[gameViewModel.halfInning] == player.order) {
            return true
        }
        return false
    }
}
