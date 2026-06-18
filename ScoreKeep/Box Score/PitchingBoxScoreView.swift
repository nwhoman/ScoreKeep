//
//  PitchingBoxScoreView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 5/28/26.
//

import SwiftData
import SwiftUI

struct PitchingBoxScoreView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var gameViewModel: GameViewModel
    var totalPA: [OffensivePlateAppearance] = []
    
    let team:Team
    
    let geo: GeometryProxy
    
    var body: some View {
        
            ScrollView(.horizontal) {
                VStack(alignment: .leading, spacing: 2.0) {
                    PitchersStatLabelView(geo: geo)
                    
                    PitchersBoxScoreView(gameViewModel: gameViewModel, geo: geo, team: team)
                        
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .font(.caption2)
            }
            
        }
    
}

#Preview {
    var game = GameViewModel.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    game.setUpGame()
    
    return GeometryReader { geo in
        PitchingBoxScoreView(gameViewModel: game, team: game.visitingTeam, geo: geo)
            .modelContainer(preview.modelContainer)
    }
}
struct PitchersBoxScoreView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query var plateAppearances: [OffensivePlateAppearance]
    
    @State var gameViewModel: GameViewModel
    let geo: GeometryProxy
    var pitchers: [Player:[OffensivePlateAppearance]] {
        getTeamPitchers()
    }
    
    var pitcherStats: [Player:PitcherStats] {
        getPitcherStatsHelper(pitchers: pitchers)
    }
    
    let team: Team
    let spacing: CGFloat = CGFloat(PitchingStatLabels.allCases.count)
    
    var body: some View {
        
    
        VStack(alignment: .leading, spacing: 1.0) {
//                var pitcherStats: PitcherStats = getPitcherStats(index: index)
                
            
            ForEach(Array(pitcherStats.keys), id: \.self) { key in
                
                PitchersStatLineView(geo: geo, player: key, pitcherStats: pitcherStats[key] ?? PitcherStats())
                Spacer()
            }
        }
        
        
    }
    
    
    func getTeamPitchers() -> [Player: [OffensivePlateAppearance]] {
        var tempPitchers: [Player: [OffensivePlateAppearance]] = [:]
        var innings: [Inning] = []
        if team.id == gameViewModel.visitingTeam.id {
            innings = gameViewModel.homeInnings
        } else {
            innings = gameViewModel.visitorInnings
        }
        for inning in innings {
            for appearance in inning.plateAppearances {
                if !tempPitchers.keys.contains(appearance.pitcher) {
                    tempPitchers[appearance.pitcher] = []
                }
                tempPitchers[appearance.pitcher]?.append(appearance)
            }
        }
        return tempPitchers
    }
}

struct PitchersStatLabelView: View {
    let geo: GeometryProxy
    let spacing: CGFloat = CGFloat(PitchingStatLabels.allCases.count)
    
    var body: some View {
        
        HStack {
            Text("Pitcher")
                .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
            
            ForEach(PitchingStatLabels.allCases, id: \.self) { stat in
                Text("\(stat.rawValue)")
                .frame(width: geo.size.width / spacing)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .font(.caption2)
        
    }
}

struct PitchersStatLineView: View {
    let geo: GeometryProxy
    let spacing: CGFloat = CGFloat(PitchingStatLabels.allCases.count)
    var player: Player
    var plateAppearances: [OffensivePlateAppearance]?
    //var playerStats: PlayerStats = PlayerStats()
    var pitcherStats: PitcherStats?
    
    init(geo: GeometryProxy, player: Player, plateAppearances: [OffensivePlateAppearance]? = nil, pitcherStats: PitcherStats? = nil) {
        self.geo = geo
        self.player = player
        self.plateAppearances = plateAppearances
        if let plateAppearances {
            self.pitcherStats = getPitcherStats(plateAppearances: plateAppearances)
        } else {
            self.pitcherStats = pitcherStats
        }
    }
    
    var body: some View {
        
                
        HStack {
            Text("\(player.lastName), \(player.firstName.prefix(1))")
                .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                .minimumScaleFactor(0.5)
            Text("\(pitcherStats?.inningsPitched ?? 0.00, specifier: "%.2f")")
                
                .frame(width: geo.size.width / spacing)
                
            ForEach(pitcherStats?.statSummary ?? [], id: \.self) { stat in
                Text("\(stat)")
                    .frame(width: geo.size.width / spacing)
            }
            Text("\(pitcherStats?.era ?? 0.00, specifier: "%.2f")")
                .frame(width: geo.size.width / spacing)
                
        }
        .font(.caption2)
        .frame(maxWidth: .infinity)
        Spacer()
        
    }
}
