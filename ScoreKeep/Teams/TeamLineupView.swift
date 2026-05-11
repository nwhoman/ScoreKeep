//
//  TeamLineupView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/22/26.
//

import SwiftUI

struct TeamLineupView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
//    @ObservedObject var gameVM: GameViewModel
//    @State var gameVM: GameViewModel
    @State private var positions: [String] = ["P", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF", "DP", "F", "EP"]
    @Binding var team: Team
    
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
                    GroupBox(label:
                        HStack{
                            Text("Roster")
                            Spacer()
                        }
                    ) {
                        VStack {
                            
                            List {
                                ForEach(unusedPlayers.sorted(by: { Int($0.number)! < Int($1.number)! }), id: \.id) { player in
                                    RosterItemView2(player: player, lineup: $team.lineup, unusedPositions: unusedPositions, position: "")
                                
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
                                ForEach(team.lineup.sorted(by: { $0.batting < $1.batting }), id: \.id) { player in
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
                                            
                                            lineup = popPlayerFromLineup(lineup: lineup, player: player)
                                            
                                            for i in 0..<lineup.count {
                                                lineup[i].batting = i+1
                                            }
                                            modelContext.delete(player)
                                            //try? modelContext.save()
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


struct RosterItemView2: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var player: Player
    @Binding var lineup: [PlayerPos]
    var unusedPositions: [String]
    @State var position: String
    @State var selectFlexPos: Bool = false
    //var lineup: [PlayerPos]
    
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .center) {
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
                    Spacer()
                }
                
            }
            .padding(.horizontal, -5)
            .border(Color(.secondarySystemBackground), width: 1)
            .onChange(of: position) {
                if (position == "") { return }
                
                let order: Int = lineup.count + 1
                let newPlayer: PlayerPos = PlayerPos(player: player, position: position, batting: order)
                modelContext.insert(newPlayer)
                
                if position == "F" {
                    newPlayer.flex = true
                }
                do {
                    try modelContext.save()
                    lineup.append(newPlayer)
                    print("\(player.number) added to lineup at \(position)")
                } catch {
                    print("error inserting PlayerPos \(error)")
                }
                position = ""
                
                
            }
        }
        
    }
}

//#Preview {
//    @Previewable@Binding var team = Team.defaultTeam
//    let preview = Preview()
//    //preview.addSampleGames([game])
//
//     NavigationStack {
//        TeamLineupView(team: team, lineup: team.lineup)
//            .modelContainer(preview.modelContainer)
//    }
//}
