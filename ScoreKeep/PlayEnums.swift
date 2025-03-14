//
//  PlayStructs.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/25/24.
//

import Foundation

let pitches = ["Ball", "Strike", "Foul", "In Play", "HP"]
let hits = ["1B", "2B", "3B", "HR"]

enum pitch: CaseIterable {
     case ball, strike, foul, in_play, hbp
}

enum outcome {
    case single, double, triple, homerun, walk, ks, kl, error, hp, fc, sac
}

/*struct PlayerPos: Identifiable {
    var id: UUID = UUID()
    var orderPos: Int
    var player: Player
    var pos: String
    
    func getPlayer() -> Player {
        return self.player
    }
}*/
