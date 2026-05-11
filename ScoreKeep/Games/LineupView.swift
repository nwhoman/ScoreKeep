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
    @EnvironmentObject var nav: NavigationStateManager
    @State var gameVM: GameViewModel
    @State var game: Game

    @State var selected: Player?
       
    @State var lineup: [PlayerPos]
    @Binding var showAlert: Bool
    @Binding var showTeamAlert: Bool
    @Binding var editPlayers: Bool
    @State var selectedTab: String
    @State var invalidLineup: (Bool, LineupErrors) = (false, .none)
    
    var team: Team {
        if selectedTab == "Home" {
            return game.homeTeam!
        } else {
            return game.visitingTeam!
        }
    }
    
//    var lineup: [PlayerPos] {
//        if selectedTab == "Home" {
//            return gameVM.homeCurrentLineup
//        } else {
//            return gameVM.visitorCurrentLineup
//        }
//    }
     
    
    var body: some View {
       
            VStack(alignment: .leading) {
                HStack {
                    
                    Spacer()
                    
                    Button("Save Lineup"){
                        invalidLineup = validateLineup(lineup: lineup, team: selectedTab.lowercased())
                        if !invalidLineup.0 {
                            
                            for batter in lineup.sorted(by: { $0.batting < $1.batting }) {
                                print("\(batter.batting) \(batter.player.lastName)")
                            }
                            if selectedTab == "Visitor" {
                                gameVM.visitorCurrentLineup = lineup.sorted(by: { $0.batting < $1.batting })
                            } else {
                                gameVM.homeCurrentLineup = lineup.sorted(by: { $0.batting < $1.batting })
                            }
                            team.lineup.removeAll()
                            team.lineup.append(contentsOf: lineup)
//                            for i in 0..<lineup.count {
//                                lineup[i].batting = i+1
//                            }
                            //team.lineup = lineup
//                            if selectedTab == "Home" {
//                                //game.homeTeam!.lineup.removeAll()
//                                gameVM.homeCurrentLineup = lineup.sorted(by: { $0.batting < $1.batting })
//                            } else {
//                                //game.visitingTeam!.lineup.removeAll()
//                                gameVM.visitorCurrentLineup = lineup.sorted(by: { $0.batting < $1.batting })
//                            }
//                            do {
//                                try modelContext.save()
//                            } catch {
//                                print("\(error)")
//                            }
                        }
//                        else {
//                            showAlert = true
//                            showTeamAlert = true
//                        }
                    }
                }
                
                .padding(10)
                
                RosterView(gameVM: gameVM, team: team, selectedTab: $selectedTab, lineup: $lineup, editPlayers: $editPlayers, selectedPlayer: lineup.first ?? PlayerPos.defaultPos)
                
            }
            .background(Color.clear)
            .alert(isPresented: $invalidLineup.0) {
                
                return getAlertForLineup(error: (invalidLineup.1), team: selectedTab.lowercased(), test: $invalidLineup.0)
                
            }
        
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
    @EnvironmentObject var nav: NavigationStateManager
    @State var gameVM: GameViewModel
    @State private var positions: [String] = ["P", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF", "DP", "F", "EP"]
    @State var team: Team
    @Binding var selectedTab: String
    @Binding var lineup: [PlayerPos]
    @Binding var editPlayers: Bool
    @State var showSubs: Bool = false
    @State var selectedPlayer: PlayerPos
    
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
//    var lineup: [PlayerPos] {
//        if selectedTab == "Home" {
//            var temp: [PlayerPos] = []
//            for each in gameVM.homeLineup {
//                temp.append(each.last!)
//            }
//            return temp
//        } else {
//            var temp: [PlayerPos] = []
//            for each in gameVM.visitorLineup {
//                temp.append(each.last!)
//            }
//            return temp
//        }
//    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    GroupBox(label:
                        HStack {
                            Text("Roster")
                            Spacer()
                            Button {
                                nav.push(.teamPlayers(teamID: team.id))
                                //editPlayers.toggle()
                            } label: {
                                Image(systemName: "pencil")
                                    .fontWeight(.bold)
                                    .font(.system(size: 12))
                            }
                        }
                    ) {
                        VStack {
                            
                            List {
                                ForEach(unusedPlayers.sorted(by: { Int($0.number)! < Int($1.number)! }), id: \.id) { player in
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
                                            selectedPlayer = player
                                            showSubs.toggle()
//                                            lineup = popPlayerFromLineup(lineup: lineup, player: player)
//                                            
//                                            for i in 0..<lineup.count {
//                                                lineup[i].batting = i+1
//                                            }
//                                            modelContext.delete(player)
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
        .sheet(isPresented: $showSubs) {
            SwapPlayerView(lineup: $lineup, selectedPlayer: $selectedPlayer, gameVM: $gameVM, unusedPlayers: unusedPlayers, positions: unusedPositions)
              
        }
    }
}

func popPlayerFromLineup(lineup: [PlayerPos], player: PlayerPos) -> [PlayerPos] {
    var temp: [PlayerPos] = lineup
    temp.remove(at: temp.firstIndex(of: player)!)
    
    return temp
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
                    lineup.append(newPlayer)
                    try modelContext.save()
                } catch {
                    print("error inserting PlayerPos \(error)")
                }
                position = ""
            }
        }
    }
}

#Preview {
    var game = Game.defaultGame
    let gameVM = GameViewModel(game: game, totalInnings: 3, inningRunRule: 0)
    let preview = Preview()
    preview.addSampleGames([game])

    return NavigationStack {
         LineupView(gameVM: gameVM, game: game, lineup: gameVM.homeCurrentLineup, showAlert: .constant(false), showTeamAlert: .constant(false), editPlayers: .constant(false), selectedTab: "Home")
            .modelContainer(preview.modelContainer)
    }
}
