//
//  TeamBoxScoreView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 5/28/26.
//

import SwiftData
import SwiftUI

struct TeamBoxScoreView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var gameViewModel: GameViewModel
    var totalPA: [OffensivePlateAppearance] = []
    
    let team:Team
    
    let geo: GeometryProxy
    
    var body: some View {
        VStack {
            BattingBoxScoreView(gameViewModel: gameViewModel, team: team, geo: geo)
            PitchingBoxScoreView(gameViewModel: gameViewModel, team: team, geo: geo)
        }
        .frame(alignment: .top)
    }
}

#Preview {
    var game = GameViewModel.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    //setUpGame(game: game)
    
    return GeometryReader { geo in
        TeamBoxScoreView(gameViewModel: game, team: game.visitingTeam, geo: geo)
            .modelContainer(preview.modelContainer)
    }
}
