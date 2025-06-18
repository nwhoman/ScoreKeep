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
    
    var selectedTab: String
    var innings: [Inning] {
        gameViewModel.game.innings.sorted { $0.number < $1.number }
    }
    var team: Team {
        if selectedTab == "Home" {
            return gameViewModel.game.homeTeam!
        } else {
            return gameViewModel.game.visitingTeam!
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    Text("Batting: \(gameViewModel.batterUp[gameViewModel.halfInning])")
                    Text("\(gameViewModel.batterUp[gameViewModel.halfInning])")
                        //Text("\(gameViewModel.i)")
                }
                
                // score by inning + RHE
                HStack {
                    ScoreView(gameViewModel: gameViewModel)
                        .padding()
                    
                }
                ScrollView() {
                    HStack {
                        BattingLineupView(geo: geo, team: team)
                            //.padding(.leading)
                            .border(Color.blue)
                        ScrollView(Axis.Set.horizontal) {
                            InningsView(gameViewModel: gameViewModel, showLargeView: $showLargeView, team: team, innings: innings, selectedTab: selectedTab)
                                
                        }
                        
                        Spacer()
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
                        Text("\(inning.number)\(inning.number/10)")
                        .frame(width: 75, height: 50, alignment: .center)
                        .border(Color.blue)
                        ForEach(teamBatting ? inning.visitorOffense.sorted(by: {$0.order < $1.order}) : inning.homeOffense.sorted(by: {$0.order < $1.order}), id: \.self) { player in
                            GeometryReader { geo in
                                
                                SmallPlateAppearanceView(gameViewModel: gameViewModel, player: player, scale: 0.15)
                                    .onTapGesture {
                                        
                                        
                                        
                                        if player.outcome.isEmpty {
                                            player.active = true
                                            gameViewModel.batter = player
                                            gameViewModel.inningNumber = inning.number
                                            let brNode = BaseRunnerNode(player: player)
                                            gameViewModel.baseRunners.insert(brNode, at: 0)
                                            gameViewModel.balls = 0
                                            gameViewModel.strikes = 0
                                            gameViewModel.batterUp[gameViewModel.halfInning] += 1
                                        } else {
                                            print("\(player.hit), \(player.outcome)")
                                        }
                                        
                                        showLargeView.toggle()
                                        
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
            //gameViewModel.incrementBatterUp()
            //innings[inningNumber-1].visitorOffense[orderNumber].active = true
        })
        {
            LargePlateAppearanceView(gameViewModel: gameViewModel, player: gameViewModel.batter!)
                .presentationBackground(alignment: .top) {
                    LinearGradient(colors: [Color.gray, Color.green], startPoint: .bottomLeading, endPoint: .topTrailing)
              }
            
              .presentationCornerRadius(50)
        }
    }
}
