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
                VStack(alignment: .leading) {
                    
                    HStack {
                        PitchersBoxScoreView(gameViewModel: gameViewModel, geo: geo, team: team)
                            .padding(.horizontal)
                        //Divider()
                        Spacer()
                    }
                }
                .border(Color.gray, width: 1)
            }
            
        }
    
}

#Preview {
    var game = GameViewModel.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    //setUpGame(game: game)
    
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
        getPitcherStats()
    }
    
    let team: Team
    let spacing: CGFloat = CGFloat(PitchingStatLabels.allCases.count)
    
    var body: some View {
        
    
        VStack(alignment: .leading, spacing: 2.0) {
//                var pitcherStats: PitcherStats = getPitcherStats(index: index)
                
            HStack {
                Text("Pitcher")
                    .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                    .border(Color.gray, width: 1)

                ForEach(PitchingStatLabels.allCases, id: \.self) { stat in
                    Text("\(stat.rawValue)")
                        .frame(width: geo.size.width / spacing)
                }
                Spacer()
            }
            //.font(.caption2)
            ForEach(Array(pitcherStats.keys), id: \.self) { key in
                
                
                HStack {
                    Text("\(key.lastName), \(key.firstName.prefix(1))")
                        .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                        .minimumScaleFactor(0.5)
                    Text("\(pitcherStats[key]?.inningsPitched ?? 0.00, specifier: "%.2f")")
                        
                        .frame(width: geo.size.width / spacing)
                        
                    ForEach(pitcherStats[key]?.statSummary ?? [0], id: \.self) { stat in
                        Text("\(stat)")
                            .frame(width: geo.size.width / spacing)
                    }
                    Text("\(pitcherStats[key]?.era ?? 0.00, specifier: "%.2f")")
                        .frame(width: geo.size.width / spacing)
                        
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .font(.caption2)
        
    }
    func getPitcherStats() -> [Player:PitcherStats] {
        
        var returnStats:[Player:PitcherStats] = [:]
        
        for pitcher in pitchers.keys {
            returnStats[pitcher] = gameViewModel.getPitcherStats(plateAppearances: pitchers[pitcher]!)
        }
        return returnStats
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
        print("\(tempPitchers)")
        return tempPitchers
    }
}
