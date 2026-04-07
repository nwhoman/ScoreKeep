//
//  ShowSubsView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/19/26.
//
//
//  ShowSubsView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/14/26.
//

import SwiftData
import SwiftUI

struct ShowSubsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
//    @ObservedObject var gameVM: GameViewModel
    @State var gameVM: GameViewModel
    @State var team: Team
       
    @State var lineup: [PlayerPos]
    @State var showAlert: Bool = false
    @State var showSubs: Bool = false
    @State var goodAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    
                    Spacer()
                    
                    Button("Save Lineup"){
                        if validateSubs(lineup: lineup) {
                            team.lineup.removeAll()
                            team.lineup = lineup
                            for i in 0..<lineup.count {
                                lineup[i].batting = i+1
                            }
                            team.lineup = lineup
                            
                            do {
                                try modelContext.save()
                            } catch {
                                print("\(error)")
                            }
                            goodAlert = true
                        } else {
                            for i in 0..<lineup.count {
                                lineup[i].batting = i+1
                            }
                            team.lineup = lineup
                            print("false")
                            showAlert = true
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Lineup Check"), message: Text("Please check that all the positions are filled"), dismissButton: .default(Text("OK")))
                    }
                }
                
                .padding(10)
                RosterSubsView(gameVM: gameVM, team: team, showSubs: $showSubs, lineup: $lineup)
                
            }
            .background(Color.clear)
        }
        
        .alert(isPresented: $goodAlert) {
            Alert(title: Text("Lineup Check"), message: Text("Lineup looks good"), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    var game = Game.defaultGame
    let preview = Preview()
    
    preview.addSampleGames([game])

    return ShowSubsView(gameVM: GameViewModel(game: game, totalInnings: 3, inningRunRule: 0), team: game.homeTeam!, lineup: game.createLineup(players: game.homeTeam!.players!), showAlert: false, showSubs: false)
            .modelContainer(preview.modelContainer)
    
}

func validateSubs(lineup: [PlayerPos]) -> Bool {
    let positions: [String] = ["P", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF"]
    let order = lineup.sorted { $0.batting < $1.batting }
    if order.count < 9 {
        print("<9")
        return false
    }
    if order.contains(where: { $0.position == "F" }) {
        if order.last?.position != "F" {
            print("last not F")
            return false
        } else if !order.contains(where: { $0.position == "DP" }) {
            print("no DP")
            return false
        }
        let newLineup = order.filter { $0.position != "F" && $0.position != "DP" && $0.position != "EP"}
        
        if newLineup.count != 8 {
            print("not 8")
            return false
        }
        for each in positions {
            if newLineup.filter({$0.position == each}).count > 1 {
                print("repeat position, flex")
                return false
            }
        }
        print("all good with F")
        return true
    }
    if order.contains(where: { $0.position == "DP" }) {
        print("contains DP")
        return false
    }
    let newLineup = order.filter { $0.position != "EP"}
    if newLineup.count < 9 {
        print("no flex <9")
        return false
    }
    for each in positions {
        if !newLineup.contains(where: { $0.position == each }) {
            print("missing \(each)")
            return false
        }
    }
    for each in positions {
        if newLineup.filter({$0.position == each}).count > 1 {
            print("repeat position, no flex")
            return false
        }
    }
    print("all good")
    return true
}

struct RosterSubsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
//    @ObservedObject var gameVM: GameViewModel
    @State var gameVM: GameViewModel
    @State private var positions: [String] = ["P", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF", "DP", "F", "EP"]
    @State var team: Team
    @State var selectedPlayer: PlayerPos = PlayerPos.defaultPos
    @Binding var showSubs: Bool
    
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
                                    HStack(alignment: .bottom) {
                                        VStack(alignment: .leading) {
                                            Text("#\(player.number)")
                                            Text("\(player.lastName), \(player.firstName)")
                                        }
                                        .font(.caption)
                                        Spacer()
                                        
                                    }
                                    .padding(.horizontal, -5)
                                
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
        .navigationDestination(isPresented: $showSubs) {
                HStack {
                    GroupBox(label: Text("Available Players")) {
                        VStack {
                            ForEach(unusedPlayers, id: \.id) { player in
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading) {
                                        Text("#\(player.number)")
                                        Text("\(player.lastName), \(player.firstName)")
                                    }
                                    .font(.caption)
                                    Spacer()
                                    
                                    
                                }
                                .padding(.top, 15)
                                .padding(.horizontal, 15)
                                .onTapGesture {
                                    print("home: \(lineup)")
                                    // create PlayerPos for inserted player
                                    var newPlayerPos = PlayerPos(player: player, position: selectedPlayer.position, batting: selectedPlayer.batting)
                                    // insert PlayerPos into lineup
                                    lineup.removeAll { $0.id == selectedPlayer.id }
                                    lineup.append(newPlayerPos)
                                    gameVM.insertSubIntoLineup(newPlayerPos: newPlayerPos, selectedPlayer: selectedPlayer)
                                    
                                    selectedPlayer = newPlayerPos
                                    lineup = lineup.sorted(by: { $0.batting < $1.batting })
                                    
                                    print("newhome: \(lineup)")
                                }
                            }
                            
                            
                            
                        }
                    }
                    GroupBox(label: Text("Selected Player")) {
                        VStack(alignment: .leading) {
                            RosterSubsItemView(player: $selectedPlayer, lineup: $lineup, unusedPositions: positions, position: "")
                                .padding(15)

                        }
                    }
                }
            
        }
    }
}



struct RosterSubsItemView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
     
    @Binding var player: PlayerPos
    @Binding var lineup: [PlayerPos]
    var unusedPositions: [String]
    @State var position: String

    var body: some View {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("#\(player.player.number)")
                    Text("\(player.player.lastName), \(player.player.firstName) - \(player.position)")
                }
                .font(.caption)
                Spacer()
                VStack {
                    Picker(player.position, selection: $position){
                        ForEach(unusedPositions, id: \.self){ position in
                            Text(position)
                                .tag(position as String)
                        }
                    }
                    
              
                }
                
            }
            //.frame(width: 5, height: 200)
            .padding(.horizontal, -5)
            .onChange(of: position) {
                player.position = position
                lineup = lineup.sorted(by: { $0.batting < $1.batting })
            }
        
    }
}

//#Preview {
//    var game = Game.defaultGame
//    let preview = Preview()
//    preview.addSampleGames([game])
//
//     NavigationStack {
//         LineupView(game: game, lineup: game.homeTeam!.lineup, gameVM: <#GameViewModel#>, showAlert: .constant(false), showTeamAlert: .constant(false), selectedTab: "Home")
//            .modelContainer(preview.modelContainer)
//    }
//    
//    
//}
