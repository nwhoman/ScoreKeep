//
//  GameSummaryView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/13/26.
//

import SwiftUI

struct GameSummaryView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject var gameViewModel: GameViewModel
    //@Binding var navPath: NavigationPath

    @State var game: Game
    @State var goHome: Bool = false
    
    var teams:[Team] {
        [game.visitingTeam!, game.homeTeam!]
    }
    var lineups: [[PlayerPos]] {
        [game.visitingLineup, game.homeLineup]
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack(alignment: .leading) {
                    HStack {
                        //ScoreView(gameViewModel: gameViewModel)
                          //  .padding(.horizontal)
                    }
                    ForEach(teams, id: \.id) { team in
                        ScrollView {
                            Text("\(team.name)")
                            ScrollView(.horizontal) {
                                var index = teams.firstIndex(of: team)!
                                var team: PlayerStats {
                                    return game.getTeamStats(team: index)
                                }
                                HStack {
                                    Text("Player")
                                    Spacer(minLength: 90)
                                    HStack {
                                        ForEach(StatLabels.allCases, id: \.self) { stat in
                                            Text("\(stat.rawValue)")
                                                .frame(width: geo.size.width / 15)
                                        }
                                    }
                                    .frame(width: geo.size.width * 0.9)
                                }
                                .font(.caption2)
                                
                                ForEach(lineups[index], id: \.self) { player in
//
                                    var playerStats: PlayerStats {
                                        return game.getPlayerGameStats(player: player.player)
                                    }
//
                                    HStack {
                                        Text("\(player.player.lastName), \(player.player.firstName.prefix(1))")
                                            .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                                            .font(.caption2)
                                        HStack {
                                            ForEach(playerStats.statSummary, id: \.self) { stat in
                                                Text("\(stat)")
                                                    .frame(width: geo.size.width / 15)
                                            }
                                        }
                                        .frame(width: geo.size.width * 0.9)
                                    }
//
                                }
                                Divider()
                                HStack {
                                    Text("Totals")
                                        .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                                        .font(.caption2)
                                    HStack {
                                        ForEach(team.statSummary, id: \.self) { stat in
                                            Text("\(stat)")
                                                .frame(width: geo.size.width / 15)
                                        }
                                    }
                                    .frame(width: geo.size.width * 0.9)
                                }
                            }
                            Divider()
                            Divider()
                            
                        }
                    }
                }
            }.toolbar {
                Button {
                    //navPath = NavigationPath()
                } label: {
                    Image(systemName: "arrow.left")
                }
//                    NavigationLink {
//                        ContentView()
//                    } label: {
//
//                    }
                
            }
            .navigationBarBackButtonHidden(true)
            
            
        }
        
    }
    func selectTeam(index: Int) -> [PlayerPos] {
        return index == 0 ? decomposeLineup(lineup: gameViewModel.visitorLineup) : decomposeLineup(lineup: gameViewModel.homeLineup)
    }
}

#Preview {
    //@Previewable @State var navPath = NavigationPath()

    var game = Game.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    //setUpGame(game: game)
    
    return GameSummaryView(gameViewModel: GameViewModel(game: game), game: game)
        .modelContainer(preview.modelContainer)
    }
