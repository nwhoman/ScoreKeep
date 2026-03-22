//
//  PlateAppearance.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/25/24.
//

import Foundation
import SwiftUI

struct PlateAppearanceView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var gameViewModel: GameViewModel
    @State var player: OffensivePlateAppearance
    let bases: [String] = ["home", "first", "second", "third"]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Spacer().frame(width: geometry.size.width, height: 20)
                Text("Batter: \(player.batter.lastName), \(player.batter.firstName)")
                Spacer().frame(width: geometry.size.width, height: 20)
                Text("Batting: \(player.order)")
                Spacer().frame(width: geometry.size.width, height: 20)
                ForEach(bases, id: \.self) { key in
                    Text("At \(key): \(player.outcome["\(key)"] ?? "")")
                }
                
                Spacer().frame(width: geometry.size.width, height: 20)
                Text("Hit type: \(player.hit)")
                Text("Pitches:")
                HStack {
                    ForEach(player.pitches, id: \.self) { pitch in
                    
                        Text("\(pitch)")
                    }
                }
                Spacer().frame(width: geometry.size.width, height: 20)
                Text("Out made: \(player.outs)")
                Text("Base occupied: \(player.baseOccupied)")
                Text("Scored run: \(player.run)")
                Text("RBIs: \(player.rbi)")
                
                HStack {
                    Text("Stolen bases: ")
                    ForEach(player.sb, id: \.self) { sb in
                        switch sb {
                        case 2:
                            Text("second")
                        case 3:
                            Text("third")
                        case 4:
                            Text("home")
                        default:
                            EmptyView()
                        }
                        
                    }
                }
                Text("Walked: \(player.bb == 0 ? "No" : "Yes")")
                Text("Hit by Pitch: \(player.hp == 0 ? "No" : "Yes")")
                Text("Sac: \(player.sac == 0 ? "No" : "Yes")")
                Text("Reached on Error: \(player.re == 0 ? "No" : "Yes")")
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            
        }
    }
}
//var batter: Player
//var inning: Int
//var outcome: [String : String]
//var earnedRun: Bool
//var lob: Int?
//var re: Int = 0
//var active: Bool
//var hitLoc: CGPoint {
//    get {
//        CGPoint(x: _hitLocX, y: _hitLocY)
//    }
//    set {
//        self._hitLocX = newValue.x
//        self._hitLocY = newValue.y
//    }
//}

#Preview {
    var game = Game.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    let gameVM = GameViewModel(game: game)
    let player = OffensivePlateAppearance.defaultPlateAppearance
        
    return PlateAppearanceView(gameViewModel: gameVM, player: player)
        .modelContainer(preview.modelContainer)
}


