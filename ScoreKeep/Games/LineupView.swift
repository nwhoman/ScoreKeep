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
    
    @State var game: Game

    @State var selected: Player?
       
    @State var lineup: [PlayerPos]
    @Binding var showAlert: Bool
    @Binding var showTeamAlert: Bool
    
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
                    
                    Spacer()
                    
                    Button("Save Lineup"){
                        if validateLineup(lineup: lineup) {
                            
                            for batter in lineup.sorted { $0.batting < $1.batting } {
                                print("\(batter.batting) \(batter.player.lastName)")
                                
                            }
//                             team.lineup = lineup
//                            for i in 0..<lineup.count {
//                                lineup[i].batting = i+1
//                            }
                            //team.lineup = lineup
                            if selectedTab == "Home" {
                                game.homeTeam!.lineup.removeAll()
                                game.homeTeam!.lineup = lineup.sorted { $0.batting < $1.batting }
                            } else {
                                game.visitingTeam!.lineup.removeAll()
                                game.visitingTeam!.lineup = lineup.sorted { $0.batting < $1.batting }
                            }
                            do {
                                try modelContext.save()
                            } catch {
                                print("\(error)")
                            }
                        } else {
                            showAlert = true
                            showTeamAlert = true
                        }
                    }
                }
                
                .padding(10)
                RosterView(team: team, lineup: $lineup)
                
            }
            .background(Color.clear)
            
        
    }
}


func posUsed(position: String, lineup: [PlayerPos]) -> Bool {
    var _used: Bool = false
    if position == "EP" {
        return false
    }
    lineup.forEach { pos in
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
    @Binding var lineup: [PlayerPos]
    
    private var unusedPositions: [String] {
        var possiblePositions = positions
        possiblePositions = positions.filter({ pos in !posUsed(position: pos, lineup: lineup)  })
        return possiblePositions
    }
    private var unusedPlayers: [Player] {
        var players = team.players!
        players = team.players!.filter({ pos in !playerUsed(player: pos, lineup: lineup)  })
        return players
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    GroupBox(label: Text("Roster")) {
                        VStack {
                            
                            List {
                                ForEach(unusedPlayers, id: \.id) { player in
                                    RosterItemView(player: player, lineup: $lineup, unusedPositions: unusedPositions, position: "")
                                
                                }
                            }
                            .padding(.horizontal, -5)
                            .listStyle(.plain)
                        }
                    }
                    .clipShape(.rect(cornerRadius: 20))
                    
                    Spacer()
                    GroupBox(label: Text("Lineup")) {
                        VStack {
                            List {
                                ForEach(lineup.sorted(by: { $0.batting < $1.batting }), id: \.id) { player in
                                    HStack {
                                        Text("\(player.batting))")
                                            .font(.caption)
                                        VStack(alignment: .leading) {
                                            Text("#\(player.player.number)")
                                            Text("\(player.player.lastName), \(player.player.firstName) - \(player.position)")
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                            //Text("#\(player.batting)")
                                            
                                        }
                                        .padding(.horizontal, -5)
                                        .font(.caption)
                                        .onTapGesture {
                                            
                                            lineup.remove(at: lineup.firstIndex(of: player)!)
                                            for i in 0..<lineup.count {
                                                lineup[i].batting = i+1
                                            }
                                            try? modelContext.save()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, -5)
                            .listStyle(.plain)
                        }
                    }
                    .clipShape(.rect(cornerRadius: 20))
                }
                .padding(10)
            }
            .background(Color.clear)
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
    @State var position: String

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text("#\(player.number)")
                    Text("\(player.lastName), \(player.firstName)")
                }
                .font(.caption)
                Spacer()
                VStack {
                    Picker("", selection: $position){
                        ForEach(unusedPositions, id: \.self){ position in
                            Text(position)
                                .tag(position as String)
                        }
                    }
                    .frame(width: 5, height: geo.size.height)
              
                }
                
            }
            .padding(.horizontal, -5)
            .onChange(of: position) {
                if (position == "") { return }
                let order: Int = lineup.count + 1
                lineup.append(PlayerPos(player: player, position: position, batting: order))
                try? modelContext.save()
                position = ""
            }
        }
    }
}

#Preview {
    var game = Game.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])

    return NavigationStack {
        LineupView(game: game, lineup: game.homeTeam!.lineup, showAlert: .constant(false), showTeamAlert: .constant(false), selectedTab: "Home")
            .modelContainer(preview.modelContainer)
    }
}
