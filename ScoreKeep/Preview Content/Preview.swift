//
//  Preview.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/15/25.
//

import Foundation
import SwiftData

struct Preview {
    let modelContainer: ModelContainer
    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            self.modelContainer = try ModelContainer(for: Game.self, configurations: config)
        } catch {
            fatalError("Could not initialize container: \(error)")
        }
    }
    func addSampleGames(_ examples: [Game]) {
        
        Task { @MainActor in
            examples.forEach { example in
                modelContainer.mainContext.insert(example)
                
            }
        }
    }
    func addSampleLineups(game: Game) {
        game.homeTeam!.lineup = game.createLineup(players: game.homeTeam!.players!)
        game.visitingTeam!.lineup = game.createLineup(players: game.visitingTeam!.players!)
    }
}
