//
//  BoxScoreView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/4/26.
//

import SwiftData
import SwiftUI

struct BoxScoreView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var gameViewModel: GameViewModel
    
    @State var selectedTab: Int = 0
    var totalPA: [OffensivePlateAppearance] = []
    
    
    let geo: GeometryProxy
    
    
    var body: some View {
        VStack(alignment: .trailing) {
            ScoreView(gameViewModel: gameViewModel, geo: geo)
                //.padding(.trailing)
            HStack {
                Button {
                    
                    selectedTab = 0
                    
                } label: {
                    Text("Batting")
                }
                Button {
                    selectedTab = 1
                } label: {
                    Text("Fielding")
                }
            }
            //ScrollView {
                ForEach([gameViewModel.visitingTeam, gameViewModel.homeTeam], id: \.self) { team in
                    
                    TabView(selection: $selectedTab) {
                        if selectedTab == 0 {
                            
                            TeamBoxScoreView(gameViewModel: gameViewModel, team: team, geo: geo)
                                .toolbar(.hidden, for: .tabBar)
                            
                            
                        } else if selectedTab == 1 {
                            FieldingBoxScoreView(gameViewModel: gameViewModel, team: team, geo: geo)
                                .toolbar(.hidden, for: .tabBar)
                            
                        }
                    }
                    .frame(width: geo.size.width, height: .infinity, alignment: .top)
                }
            
            
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
        BoxScoreView(gameViewModel: game, geo: geo)
            .modelContainer(preview.modelContainer)
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
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let player = player {
                    Text("\(player.lastName), \(player.firstName.prefix(1))")
                        .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                        .minimumScaleFactor(0.5)

                } else {
                    Text("Totals")
                        .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                        .border(Color.gray, width: 1)
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
        .font(.caption2)
        .frame(maxWidth: .infinity)
    }
}

