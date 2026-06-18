//
//  BattingBoxScoreView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 5/28/26.
//

import SwiftData
import SwiftUI

struct BattingBoxScoreView: View {
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
                    HStack(alignment: .center) {
                        StatLabelView(geo: geo)
                            .padding(.horizontal)
                    }
                    
                    ForEach(selectTeam(teamID: team.id), id: \.self) { player in
                        HStack {
                            StatLineView(geo: geo, player: player.player, plateAppearances: getPlateAppearances(teamID: team.id, player: player))
                                .padding(.horizontal)
                            
                        }
                    }
                    Divider()
                    HStack {
                        
                        StatLineView(geo: geo, plateAppearances: getTeamStats(teamID: team.id))
                            .padding(.horizontal)
                        Spacer()
                    }
                   
                }
            }
                
            
        }
        .frame(width: geo.size.width, alignment: .leading)

    }
    func selectTeam(teamID: UUID) -> [PlayerPos] {
        return teamID == gameViewModel.visitingTeam.id ? decomposeLineup(lineup: gameViewModel.visitorLineup) : decomposeLineup(lineup: gameViewModel.homeLineup)
    }
    func getPlateAppearances(teamID: UUID, player: PlayerPos) -> [OffensivePlateAppearance] {
        var innings: [Inning] = []

        if teamID == gameViewModel.visitingTeam.id {
            innings = gameViewModel.visitorInnings
        } else {
            innings = gameViewModel.homeInnings
        }

        return getPlayerPA(innings: innings, player: player.player)
    }
    func getTeamStats(teamID: UUID) -> [OffensivePlateAppearance] {
        var players: [PlayerPos] = []
        var innings: [Inning] = []
        var plateAppearances: [OffensivePlateAppearance] = []

        if teamID == gameViewModel.visitingTeam.id {
            players = decomposeLineup(lineup: gameViewModel.visitorLineup)
            innings = gameViewModel.visitorInnings
        } else {
            players = decomposeLineup(lineup: gameViewModel.homeLineup)
            innings = gameViewModel.homeInnings
        }

        for player in players {
            plateAppearances.append(contentsOf: getPlayerPA(innings: innings, player: player.player))
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
        BattingBoxScoreView(gameViewModel: game, team: game.visitingTeam, geo: geo)
            .modelContainer(preview.modelContainer)
    }
}
