//
//  TeamLineupsView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/9/24.
//

import SwiftData
import SwiftUI

struct HomeLineupView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Binding var path: NavigationPath
    @State var team: Team?  //Game.(home/visiting)Team
    @State var battingLineup: [PlayerPos]
    @State var game: Game

    @State var i: Int = 1
    @State var selected: Player?
    @State var name: String = "NA"
    @State var positions: [String] = ["P", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF", "DP", "F"]
    @State private var selectedTab: String = "Home"
    @State private var batting: Bool = true
    @State var position: String = "SS"
    @State var showAlert: Bool = false
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if (selectedTab == "Home"){
                    Text(team!.name)
                } else {
                    Text(team!.name)
                }
                Spacer()
                Picker("", selection: $position){
                    ForEach(positions, id: \.self){position in
                        Text(position)
                            .tag(position as String)
                    }
                }
                Button("Save Game"){
                    try? modelContext.save()
                }
            }
            List{
                ForEach((team!.players)!, id: \.id){player in
                    HStack{
                        Text("\(player.firstName), \(player.number)")
                            .font(.system(size: 10))
                        Spacer()
                        Button("", systemImage: "plus"){
                            if (!inLineup(player: player, position: position, lineup: game.homeLineup)){
                                let lineupSpot: PlayerPos = PlayerPos(batting: game.homeLineup.count + 1, firstName: player.firstName, lastName: player.lastName, number: player.number, position: position, game: game)
                                game.homeLineup.append(lineupSpot)
                                i += 1
                            }
                        }
                    }
                }
            }
            HLineupView(game: $game, lineup: $game.homeLineup)
        }
        .padding(10)
        
    }
}
func inLineup(player: Player, position: String, lineup: [PlayerPos]) -> Bool {
    //let lineupSpot: PlayerPos = PlayerPos(batting: batting, firstName: player.firstName, lastName: player.lastName, number: player.number, position: position, game: game)
    var _in: Bool = false
    
    lineup.forEach { pos in
        if (player.number == pos.number || position == pos.position) {
            _in = true
        }
    }
    
    return _in
    
}

struct HLineupView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    //@Query(sort: (\PlayerPos.batting)) var players: [Player]
    
    @Binding var game: Game
    @Binding var lineup: [PlayerPos]
    
    var body: some View {
        List{
            ForEach(game.homeLineup.sorted( by: { $0.batting < $1.batting } ), id: \.number){player in
                Text("#\(player.batting) - \(player.lastName), \(player.firstName) - # \(player.number) --- \(player.position)")
                    .font(.system(size: 10))
            }.onDelete(perform: { indexSet in
                game.homeLineup.remove(atOffsets: indexSet)
            })
        }
    }
}

//#Preview {
    //TeamLineupsView()
//}
