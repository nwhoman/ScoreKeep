//
//  BoxScoreView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/4/26.
//

import SwiftUI

struct BoxScoreView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject var gameViewModel: GameViewModel
    
    private var visitingTeam: [PlayerPos] {
        return gameViewModel.game.visitingLineup.sorted { $0.batting < $1.batting }
    }
    
    private var homeTeam: [PlayerPos] {
        return gameViewModel.game.homeLineup.sorted { $0.batting < $1.batting }
    }
    
    private var plateAppearances: [OffensivePlateAppearance] {
        return []
    }
    
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack(alignment: .leading) {
                    HStack {
                        ScoreView(gameViewModel: gameViewModel)
                            .padding(.horizontal)
                    }
                    ScrollView {
                        Text("\(gameViewModel.game.visitingTeam!.name)")
                        ScrollView(.horizontal) {
                            var team: PlayerStats {
                                return gameViewModel.getTeamStats(team: 0)
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
                        
                            ForEach(visitingTeam, id: \.self) { player in
                                var plateAppearances: [OffensivePlateAppearance] {
                                    return gameViewModel.getPlayerPA(innings: gameViewModel.visitorInnings, player: player.player)
                                }
                                var playerStats: PlayerStats {
                                    return gameViewModel.getPlayerStats(plateAppearances: plateAppearances)
                                }
                            
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
                                
                            }
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
                        Text("\(gameViewModel.game.homeTeam!.name)")
                        ScrollView(.horizontal) {
                            var team: PlayerStats {
                                return gameViewModel.getTeamStats(team: 1)
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
                        
                            ForEach(homeTeam, id: \.self) { player in
                                var plateAppearances: [OffensivePlateAppearance] {
                                    return gameViewModel.getPlayerPA(innings: gameViewModel.visitorInnings, player: player.player)
                                }
                                var playerStats: PlayerStats {
                                    return gameViewModel.getPlayerStats(plateAppearances: plateAppearances)
                                }
                                
                                HStack {
                                    Text("\(player.player.lastName), \(player.player.firstName.prefix(1))")
                                        .font(.caption2)
                                        .minimumScaleFactor(0.5)
                                        .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                                        
                                    //Spacer(minLength: 90)
                                    HStack {
                                        ForEach(playerStats.statSummary, id: \.self) { stat in
                                            Text("\(stat)")
                                                .frame(width: geo.size.width / 15)
                                        }
                                    }
                                    .frame(width: geo.size.width * 0.9)
                                }
                            }
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
    
    return BoxScoreView(gameViewModel: GameViewModel(game: game))
        .modelContainer(preview.modelContainer)
    }
