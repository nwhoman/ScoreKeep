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
//    @ObservedObject var gameViewModel: GameViewModel
    @State var gameViewModel: GameViewModel
    @State var player: OffensivePlateAppearance
    let bases: [String] = ["home", "first", "second", "third"]
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack(alignment: .leading) {
                    Spacer().frame(height: 20)
                    Text("Batter: \(player.batter.lastName), \(player.batter.firstName)")
                    Spacer().frame(height: 20)
                    Text("Batting: \(player.order)")
                    Spacer().frame(height: 20)
                    ForEach(bases, id: \.self) { key in
                        Text("At \(key): \(player.outcome["\(key)"] ?? "")")
                    }
                    
                    Spacer().frame(height: 20)
                    Text("Hit type: \(player.hit)")
                    Text("Pitches:")
                    HStack {
                        ForEach(player.pitches, id: \.self) { pitch in
                            
                            Text("\(pitch)")
                        }
                    }
                    Spacer().frame(height: 20)
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
                .frame(height: geometry.size.height)
                .border(Color.black)
                VStack(alignment: .trailing) {
                    Spacer().frame(height: 20)
                    Text("Pitcher: \(player.pitcher.lastName), \(player.pitcher.firstName)")
                    Spacer().frame(height: 20)
                    Text("Batting: \(player.order)")
                    Spacer().frame(height: 20)
                    Text("Pitches:")
                    HStack {
                        ForEach(player.pitches, id: \.self) { pitch in
                            
                            Text("\(pitch)")
                        }
                    }
                    Text("Hit type: \(player.hit)")
                    Text("R: \(player.run)")
                    Text("ER: \(player.earnedRun)")
                    Text("K: \(player.k)")
                    Text("BB: \(player.bb)")
                    Text("HP: \(player.hp)")
                    Text("WP: \(player.wp)")
                    
                    HStack {
                        Text("PO:")
                        ForEach(player.po, id: \.self) { i in
                            
                            Text("\(i)")
                        }
                    }
                    HStack {
                        Text("Assist:")
                        ForEach(player.assist, id: \.self) { i in
                            
                            Text("\(i)")
                        }
                    }
                    HStack {
                        Text("Error:")
                        ForEach(player.error, id: \.self) { i in
                            
                            Text("\(i)")
                        }
                    }
                    if player.active {
                        Text("Active")
                    }
                }
                .frame(height: geometry.size.height)
                .border(Color.black)
            }
            
        }
    }
}

//var run: Bool = false
//var earnedRun: Bool
//var k: Int = 0
//var bb: Int = 0
//var hp: Int = 0
//var sac: Int = 0
//var wp: Int = 0
//var po: [String]
//var assist: [String]
//var error: [String]
//var active: Bool

#Preview {
    var game = Game.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    let gameVM = GameViewModel(game: game, totalInnings: 3, inningRunRule: 0)
    let player = OffensivePlateAppearance.defaultPlateAppearance
    
    return PlateAppearanceView(gameViewModel: gameVM, player: player)
        .modelContainer(preview.modelContainer)
}


