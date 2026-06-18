//
//  FieldingBoxScoreView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 5/28/26.
//

import SwiftData
import SwiftUI

struct FieldingBoxScoreView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var gameViewModel: GameViewModel
    var totalPA: [OffensivePlateAppearance] = []
    
    var team: Team
    
    let geo: GeometryProxy
    
    var body: some View {
        VStack {
            Text("\(team.name)")
            ScrollView(.horizontal) {
                VStack(alignment: .leading) {
                    FieldingStatLabelView(geo: geo)
                    ForEach(selectTeam(teamID: team.id), id: \.self) { player in
                        FieldingStatLineView(geo: geo, player: player.player, fieldAppearances: [player])
                            
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)

    }
    func selectTeam(teamID: UUID) -> [PlayerPos] {
        return teamID == gameViewModel.visitingTeam.id ? decomposeLineup(lineup: gameViewModel.visitorLineup) : decomposeLineup(lineup: gameViewModel.homeLineup)
    }

}

#Preview {
    var game = GameViewModel.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    //setUpGame(game: game)
    
    return GeometryReader { geo in
        FieldingBoxScoreView(gameViewModel: game, team: game.visitingTeam, geo: geo)
            .modelContainer(preview.modelContainer)
    }
}
struct FieldingStatLabelView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var geo: GeometryProxy
    let spacing: CGFloat = CGFloat(FieldingStatLabels.allCases.count)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Player")
                    .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                HStack {
                    ForEach(FieldingStatLabels.allCases, id: \.self) { stat in
                        Text("\(stat.rawValue)")
                            .frame(width: 25)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .font(.caption2)
        }
    }
}
struct FieldingStatLineView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var geo: GeometryProxy
    let spacing: CGFloat = CGFloat(FieldingStatLabels.allCases.count)
    var player: Player? = nil
    var fieldAppearances: [PlayerPos]
    //var playerStats: PlayerStats = PlayerStats()
    var playerStats: FielderStats {
        return getFieldingStats(fieldAppearance: fieldAppearances)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let player = player {
                    Text("\(player.lastName), \(player.firstName.prefix(1))")
                        .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                        
                } else {
                    Text("Totals")
                        .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                }
                
                
                HStack {
                    ForEach(playerStats.statSummary, id: \.self) { stat in
                        Text("\(stat)")
                            .frame(width: 25)
                    }
                    Text("\(playerStats.percentage, specifier: "%.2f")")
                        .frame(width: 25)
                    Spacer()
                }
                
            }
            .font(.caption2)
        }
        .frame(maxWidth: .infinity)
    }
}
struct FieldingStatView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    var geo: GeometryProxy
    let spacing: CGFloat = CGFloat(FieldingStatLabels.allCases.count)
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldingStatLabelView(geo: geo)
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
    //setUpGame(game: game)
    
    return GeometryReader { geo in
        FieldingStatView(geo: geo)
            .modelContainer(preview.modelContainer)
    }
}
