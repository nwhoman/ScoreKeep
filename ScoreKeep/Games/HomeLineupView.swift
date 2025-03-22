//
//  TeamLineupsView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/9/24.
//

import SwiftData
import SwiftUI

struct LineupView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    //@Binding var path: NavigationPath
    //@State var team: Team?  //Game.(home/visiting)Team
    @State var battingLineup: [PlayerPos] = []
    @State var game: Game

    @State var i: Int = 1
    @State var selected: Player?
    @State var name: String = "NA"
    
    @State private var batting: Bool = true
   
    @State var showAlert: Bool = false
    @State private var lineup: [PlayerPos] = []
    
    var selectedTab: String

    var team: Team {
        if selectedTab == "Home" {
            return game.homeTeam!
        } else {
            return game.visitingTeam!
        }
    }
     
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(team.name)
                Spacer()
                
                Button("Save Game"){
                    try? modelContext.save()
                }
            }
            .padding(10)
            RosterView(team: team)
            
        }
    }
}


func posUsed(position: String, lineup: [PlayerPos]) -> Bool {
    var _used: Bool = false
    if position == "EP" {
        return false
    }
    lineup.forEach { pos in
        print("\(position) == \(pos.position)")
        if (position == pos.position) {
            _used = true
        }
    }
    return _used
}
func playerUsed(player: Player, lineup: [PlayerPos]) -> Bool {
    var _used: Bool = false
    lineup.forEach { pos in
        if (player.id == pos.player.id) {
            _used = true
        }
    }
    return _used
}

struct RosterView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var positions: [String] = ["P", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF", "DP", "F", "EP"]
    @State var team: Team
    @State var lineup: [PlayerPos] = []
    
    private var unusedPositions: [String] {
        var possiblePositions = positions
        possiblePositions = positions.filter({ pos in !posUsed(position: pos, lineup: team.lineup)  })
        return possiblePositions
    }
    private var unusedPlayers: [Player] {
        var players = team.players!
        players = team.players!.filter({ pos in !playerUsed(player: pos, lineup: team.lineup)  })
        return players
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    VStack {
                        Text("Roster")
                        List {
                            ForEach(unusedPlayers, id: \.id) { player in
                                RosterItemView(player: player, lineup: $team.lineup, unusedPositions: unusedPositions)
                            
                            }
                        }
                        
                    }
                    Spacer()
                    VStack {
                        Text("Lineup")
                        List {
                            ForEach(team.lineup, id: \.id) { player in
                                Text("\(player.player.lastName), \(player.player.firstName) - \(player.position)")
                                    
                            
                            }
                        }
                    }
                }
                .padding(10)
            }
        }
    }
}

struct RosterItemView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
//    //@Query(sort: (\PlayerPos.batting)) var players: [Player]
//    
    @State var player: Player
    @Binding var lineup: [PlayerPos]
    var unusedPositions: [String]
    var position: String {
        return player.position
    }

    var body: some View {
        GeometryReader { geo in
            HStack {
                Text("\(player.lastName), \(player.firstName) - #\(player.number)")
                    .font(.caption)
                Spacer()
                Picker("", selection: $player.position){
                    ForEach(unusedPositions, id: \.self){position in
                        Text(position)
                            .tag(position as String)
                    }
                }
                .frame(width: 5, height: geo.size.height)
            }
            .onChange(of: player.position) {
                lineup.append(PlayerPos(player: player, position: $0))
                
                for player in lineup {
                    print("\(player.player.firstName) \(player.player.lastName) now plays \(position)")
                }
            }
        }
    }
}

#Preview {
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])

    return NavigationStack {
        LineupView(game: game, selectedTab: "Home")
            .modelContainer(preview.modelContainer)
    }
}
