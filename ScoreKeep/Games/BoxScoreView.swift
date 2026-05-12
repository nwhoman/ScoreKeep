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
    var totalPA: [OffensivePlateAppearance] = []
    
    var teams:[Team] {
        [gameViewModel.visitingTeam, gameViewModel.homeTeam]
    }
    let geo: GeometryProxy
    
    
    var body: some View {
        //NavigationStack {
            //GeometryReader { geo in
                VStack(alignment: .leading) {
                    HStack {
                        ScoreView(gameViewModel: gameViewModel)
                            .padding(.horizontal)
                    }
                    ScrollView {
                        
                        ForEach(teams, id: \.self) { team in
                            let index = teams.firstIndex(of: team)!
                            
                            var teamStats: PlayerStats {
                                return gameViewModel.getTeamStats(team: index)
                            }
//                            var pitcher: PlayerPos {
//                                if index == 0 {
//                                    gameViewModel.getCurrentPitcher(i: 1)
//                                } else {
//                                    gameViewModel.getCurrentPitcher(i: 0)
//                                }
//                            }
                            
                            Text("\(team.name)")
                            ScrollView(.horizontal) {
                                VStack(alignment: .leading) {
                                    StatLabelView(geo: geo)
                                        .padding(.horizontal)
                                    ForEach(selectTeam(index: index), id: \.self) { player in
                                        
                                        var plateAppearances: [OffensivePlateAppearance] {
                                            let innings = index == 0 ? gameViewModel.visitorInnings : gameViewModel.homeInnings
                                            let pa = gameViewModel.getPlayerPA(innings: innings, player: player.player)
                                            
                                            return pa
                                        }
                                        
                                        StatLineView(geo: geo, player: player.player, plateAppearances: plateAppearances)
                                            .padding(.horizontal)
                                    }
                                    Divider()
                                    HStack {
                                        
                                        StatLineView(geo: geo, plateAppearances: getTeamStats(index: index))
                                            .padding(.horizontal)
                                        Spacer()
                                    }
                                    .font(.caption2)
                                    Divider()
                                    PitchersBoxScoreView(gameViewModel: gameViewModel, geo: geo, index: index)
                                        .padding(.horizontal)
                                    //Divider()
                                }
                            }
                            
                        }
                    }
                    //.frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
        //}
        
    }
    func selectTeam(index: Int) -> [PlayerPos] {
        return index == 0 ? decomposeLineup(lineup: gameViewModel.visitorLineup) : decomposeLineup(lineup: gameViewModel.homeLineup)
    }
    func getTeamStats(index: Int) -> [OffensivePlateAppearance] {
        let players = index == 0 ? decomposeLineup(lineup: gameViewModel.visitorLineup) : decomposeLineup(lineup: gameViewModel.homeLineup)
        let innings = index == 0 ? gameViewModel.visitorInnings : gameViewModel.homeInnings
        var plateAppearances: [OffensivePlateAppearance] = []
        
        for player in players {
            plateAppearances.append(contentsOf: gameViewModel.getPlayerPA(innings: innings, player: player.player))
        }
        return plateAppearances
    }
}

#Preview {
    var game = GameViewModel.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    //setUpGame(game: game)
    
    return GeometryReader { geo in
        BoxScoreView(gameViewModel: game, geo: geo)
            .modelContainer(preview.modelContainer)
    }
}
struct PitchersBoxScoreView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var gameViewModel: GameViewModel
    @State var geo: GeometryProxy
    var pitcherStats: [PitcherStats] {
        [getPitcherStats(index: 1), getPitcherStats(index: 0)]
    }
    var pitcher: [PlayerPos] {
        [gameViewModel.getCurrentPitcher(i: 1), gameViewModel.getCurrentPitcher(i: 0)]
    }
    let index: Int
    let spacing: CGFloat = CGFloat(PitchingStatLabels.allCases.count)
    
    var body: some View {
        
    
        VStack(alignment: .leading) {
//                var pitcherStats: PitcherStats = getPitcherStats(index: index)
                
            HStack {
                Text("Pitcher")
                    .frame(width: geo.size.width * 0.2, alignment: .init(horizontal: .leading, vertical: .center))
                Spacer()
                ForEach(PitchingStatLabels.allCases, id: \.self) { stat in
                    Text("\(stat.rawValue)")
                        .frame(width: geo.size.width / spacing)
                }
                Spacer()
            }
            .font(.caption2)
            HStack {
                Text("\(pitcher[index].player.lastName), \(pitcher[index].player.firstName.prefix(1))")
                    .frame(width: geo.size.width * 0.2, alignment: .init(horizontal: .leading, vertical: .center))
                Spacer()
                Text("\(pitcherStats[index].inningsPitched, specifier: "%.2f")")
                    .frame(width: geo.size.width / spacing)
                
                ForEach(pitcherStats[index].statSummary, id: \.self) { stat in
                    Text("\(stat)")
                        .frame(width: geo.size.width / spacing)
                }
                Text("\(pitcherStats[index].era, specifier: "%.2f")")
                    .frame(width: geo.size.width / spacing)
                Spacer()
            }
                
        }
        .frame(maxWidth: .infinity)
        .border(Color(.gray).opacity(0.3), width: 0.5)
        .font(.caption2)
        
        
    
    Divider()
        
    }
    func getPitcherStats(index: Int) -> PitcherStats {
        let pitcher = gameViewModel.getCurrentPitcher(i: index)
        let innings = index == 0 ? gameViewModel.visitorInnings : gameViewModel.homeInnings
        return gameViewModel.getPitcherStats(plateAppearances: gameViewModel.getPitcherPA(innings: innings, pitcher: pitcher.player))
    }
}

struct StatLabelView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var geo: GeometryProxy
    let spacing: CGFloat = CGFloat(StatLabels.allCases.count)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Player")
                    .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                HStack {
                    ForEach(StatLabels.allCases, id: \.self) { stat in
                        Text("\(stat.rawValue)")
                            .frame(width: geo.size.width / spacing)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .font(.caption2)
        }
    }
}

struct StatLineView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var geo: GeometryProxy
    let spacing: CGFloat = CGFloat(StatLabels.allCases.count)
    var player: Player? = nil
    var plateAppearances: [OffensivePlateAppearance]
    //var playerStats: PlayerStats = PlayerStats()
    var playerStats: PlayerStats {
        return getPlayerStats(plateAppearances: plateAppearances)
    }
//    init(geo: GeometryProxy, plateAppearances: [OffensivePlateAppearance], player: Player) { //
//        self.geo = geo
//        self.player = player
//        self.plateAppearances = plateAppearances
//        
//    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let player = player {
                    Text("\(player.lastName), \(player.firstName.prefix(1))")
                        .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                        .font(.caption2)
                } else {
                    Text("Totals")
                        .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                }
                
                
                HStack {
                    ForEach(playerStats.statSummary, id: \.self) { stat in
                        Text("\(stat)")
                            .frame(width: geo.size.width / spacing)
                    }
                    Spacer()
                }
                
            }
        }
        .frame(maxWidth: .infinity)
    }
}
