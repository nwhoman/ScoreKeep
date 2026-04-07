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
    @State var gameViewModel: GameViewModel
    
    
    var teams:[Team] {
        [gameViewModel.game.visitingTeam!, gameViewModel.game.homeTeam!]
    }
    
    var body: some View {
        //NavigationStack {
            GeometryReader { geo in
                VStack(alignment: .leading) {
                    HStack {
                        ScoreView(gameViewModel: gameViewModel)
                            .padding(.horizontal)
                    }
                    
                    ForEach(teams, id: \.self) { team in
                        ScrollView {
                            Text("\(team.name)")
                            ScrollView(.horizontal) {
                                var index = teams.firstIndex(of: team)!
                                var teamStats: PlayerStats {
                                    return gameViewModel.getTeamStats(team: index)
                                }
                                var pitcher: PlayerPos {
                                    gameViewModel.getCurrentPitcher(i: index)
                                }
                                HStack {
                                    Text("Player")
                                    Spacer(minLength: 50)
                                    HStack {
                                        ForEach(StatLabels.allCases, id: \.self) { stat in
                                            Text("\(stat.rawValue)")
                                                .frame(width: geo.size.width / 15)
                                        }
                                    }
                                    .frame(width: geo.size.width * 1.2)
                                    Spacer()
                                }
                                .font(.caption2)
                                
                                ForEach(selectTeam(index: index), id: \.self) { player in
                                    var plateAppearances: [OffensivePlateAppearance] {
                                        let innings = index == 0 ? gameViewModel.visitorInnings : gameViewModel.homeInnings
                                        return gameViewModel.getPlayerPA(innings: innings, player: player.player)
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
                                            Spacer()
                                        }
                                        .frame(width: geo.size.width * 1.3)
                                    }
                                    
                                }
                                Divider()
                                HStack {
                                    Text("Totals")
                                    Spacer(minLength: 50)
                                    HStack {
                                        ForEach(teamStats.statSummary, id: \.self) { stat in
                                            Text("\(stat)")
                                                .frame(width: geo.size.width / 15)
                                        }
                                    }
                                    .frame(width: geo.size.width * 1.2)
                                    Spacer()
                                }
                                .font(.caption2)
                                Divider()
                                PitchersBoxScoreView(gameViewModel: gameViewModel, geo: geo, index: index)
                                    .padding(0)
                            //Divider()
                        }
                    }
                }
            }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
            
        }
        
    }
    func selectTeam(index: Int) -> [PlayerPos] {
        return index == 0 ? decomposeLineup(lineup: gameViewModel.visitorLineup) : decomposeLineup(lineup: gameViewModel.homeLineup)
    }
    
}

#Preview {
    var game = Game.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    //setUpGame(game: game)
    
    return BoxScoreView(gameViewModel: GameViewModel(game: game, totalInnings: 3, inningRunRule: 0))
        .modelContainer(preview.modelContainer)
    }

struct PitchersBoxScoreView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var gameViewModel: GameViewModel
    @State var geo: GeometryProxy
    var pitcherStats: [PitcherStats] {
        [getPitcherStats(index: 0), getPitcherStats(index: 1)]
    }
    var pitcher: [PlayerPos] {
        [gameViewModel.getCurrentPitcher(i: 0), gameViewModel.getCurrentPitcher(i: 1)]
    }
    let index: Int
    
    var body: some View {
        
    
        VStack(alignment: .leading) {
//                var pitcherStats: PitcherStats = getPitcherStats(index: index)
                
                HStack {
                    Text("Pitcher")
                        .frame(width: geo.size.width / 5, alignment: .leading)
                    Spacer(minLength: 60)
                    ForEach(PitchingStatLabels.allCases, id: \.self) { stat in
                        Text("\(stat.rawValue)")
                            .frame(width: geo.size.width / 14)
                    }
                    Spacer()
                }
                .font(.caption2)
                HStack {
                    Text("\(pitcher[index].player.lastName), \(pitcher[index].player.firstName.prefix(1))")
                        .frame(width: geo.size.width / 5, alignment: .leading)
                    Spacer(minLength: 60)
                    Text("\(pitcherStats[index].inningsPitched, specifier: "%.2f")")
                        .frame(width: geo.size.width / 15)
                    ForEach(pitcherStats[index].statSummary, id: \.self) { stat in
                        Text("\(stat)")
                            .frame(width: geo.size.width / 14)
                    }
                    Text("\(pitcherStats[index].era, specifier: "%.2f")")
                        .frame(width: geo.size.width / 13)
                    Spacer()
                }
                .frame(width: geo.size.width * 1.6)
                .font(.caption2)
            }
        
        
    
    Divider()
        
    }
    func getPitcherStats(index: Int) -> PitcherStats {
        let pitcher = gameViewModel.getCurrentPitcher(i: index)
        let innings = index == 1 ? gameViewModel.visitorInnings : gameViewModel.homeInnings
        return gameViewModel.getPitcherStats(plateAppearances: gameViewModel.getPitcherPA(innings: innings, pitcher: pitcher.player))
    }
}
