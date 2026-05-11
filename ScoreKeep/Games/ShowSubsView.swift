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
    @EnvironmentObject var nav: NavigationStateManager
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
    @EnvironmentObject var nav: NavigationStateManager
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
            SwapPlayerView(lineup: $lineup, selectedPlayer: $selectedPlayer, gameVM: $gameVM, unusedPlayers: unusedPlayers, positions: unusedPositions)
                
            
        }
    }
}
func createNewLineupSlot(player: Player, selectedPlayer: PlayerPos, lineup: inout [PlayerPos], gameVM: GameViewModel) -> PlayerPos {
    // create PlayerPos for inserted player
    var newPlayerPos = PlayerPos(player: player, position: selectedPlayer.position, batting: selectedPlayer.batting)
    // insert PlayerPos into lineup
    newPlayerPos.inning = gameVM.inningNumber[gameVM.halfInning] / 10
    lineup.removeAll { $0.id == selectedPlayer.id }
    lineup.append(newPlayerPos)
    gameVM.insertSubIntoLineup(newPlayerPos: newPlayerPos, selectedPlayer: selectedPlayer)
    lineup = lineup.sorted(by: { $0.batting < $1.batting })

    return newPlayerPos
}

func positionChangeOnly(player: Player, position: String, batting: Int, lineup: inout [PlayerPos], gameVM: GameViewModel, selectedPlayer: PlayerPos) -> PlayerPos {
    // create PlayerPos for inserted player
    var newPlayerPos = PlayerPos(player: player, position: position, batting: batting)
    // insert PlayerPos into lineup
    newPlayerPos.inning = gameVM.inningNumber[gameVM.halfInning] / 10
    lineup.removeAll { $0.player.id == player.id }
    lineup.append(newPlayerPos)
    gameVM.insertSubIntoLineup(newPlayerPos: newPlayerPos, selectedPlayer: selectedPlayer)
    lineup = lineup.sorted(by: { $0.batting < $1.batting })

    return newPlayerPos
}
func deleteOrderSlot(lineup: inout [PlayerPos], player: PlayerPos) {
    lineup = popPlayerFromLineup(lineup: lineup, player: player)
    
    for i in 0..<lineup.count {
        lineup[i].batting = i+1
    }
    
}
struct SwapPlayerView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nav: NavigationStateManager
    @Binding var lineup: [PlayerPos]
    @Binding var selectedPlayer: PlayerPos
    @Binding var gameVM: GameViewModel
    var unusedPlayers: [Player]
    var positions: [String]
    
    var body: some View {
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
                            selectedPlayer = createNewLineupSlot(player: player, selectedPlayer: selectedPlayer, lineup: &lineup, gameVM: gameVM)
                            
                            print("newhome: \(lineup)")
                        }
                    }
                }
            }
            GroupBox(label:
                HStack {
                    Text("Selected Player")
                    Spacer()
                if !gameVM.game.isStarted {
                    Button {
                        deleteOrderSlot(lineup: &lineup, player: selectedPlayer)
                        modelContext.delete(selectedPlayer)
                        //nav.path.removeLast()
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle")
                            .fontWeight(.bold)
                            .font(.system(size: 12))
                    }
                }
            }){
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Batting:")
                            .font(.caption)
                        TextField("batting", value: $selectedPlayer.batting, format: .number)
                            
                    }
                    RosterSubsItemView(gameVM: $gameVM, player: selectedPlayer, lineup: $lineup, unusedPositions: positions, position: "")
                        .padding(.leading, -15)
                }
            }
        }
        .onDisappear {
            print("reorder lineup")
            var order = 1
            lineup = lineup.sorted(by: { $0.batting < $1.batting })
            for i in 0..<lineup.count {
                lineup[i].batting = order
                order += 1
            }
        }
    }
}

struct RosterSubsItemView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query private var players: [Player]
    @Binding var gameVM: GameViewModel
    
    //@Binding var player: PlayerPos
    var player: PlayerPos
    @Binding var lineup: [PlayerPos]
    var unusedPositions: [String]
    @State var position: String

    init(gameVM: Binding<GameViewModel>, player: PlayerPos, lineup: Binding<[PlayerPos]>, unusedPositions: [String], position: String) {
        _gameVM = gameVM
        self.player = player
        _lineup = lineup
        self.unusedPositions = unusedPositions
        self.position = position
        let id = player.player.id
        print("\(id)")
        //_players = Query(filter: #Predicate<Player> {$0.id == id})
        print("\(players.count)")
    }
    
    var body: some View {
        ZStack {
            LineupDetailView(player: player.player)
            
            HStack(alignment: .top) {
                
                
                Spacer()
                VStack {
                    Picker(player.position, selection: $position){
                        ForEach(unusedPositions, id: \.self){ position in
                            Text(position)
                                .tag(position as String)
                        }
                    }
                    
                    
                }
                .frame(width: 15)
            }
        }
            //.frame(width: 5, height: 200)
            .padding(.horizontal, -5)
            .onChange(of: position) {
                player.position = position
                
                //lineup = lineup.sorted(by: { $0.batting < $1.batting })
//                let newPlayer = positionChangeOnly(player: player.player, position: position, batting: player.batting, lineup: &lineup, gameVM: gameVM, selectedPlayer: player)
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

struct LineupDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Bindable var player: Player
    @State private var editPlayer: Bool = false
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("#\(player.number) \(player.lastName), \(player.firstName)")
            if editPlayer {
                GroupBox(label: Text("Edit Player")
                    .fontWeight(.bold)
                    .font(.system(size: 12))) {
                    VStack(alignment: .leading) {
                        
                        Divider()
                            .frame(height: 20)
                        TextField("#\(player.number)", text: $player.number)
                        TextField("\(player.firstName)", text: $player.firstName)
                        TextField("\(player.lastName)", text: $player.lastName)
                        Spacer()
                            .frame(height: 20)
                        Button {
                            editPlayer.toggle()
                        } label: {
                            Image(systemName: "xmark")
                                .fontWeight(.bold)
                                .font(.system(size: 12))
                        }
                    }
                }
            } else {
                VStack(alignment: .leading) {
                    Divider()
                        .frame(height: 20)
                    Button {
                        editPlayer.toggle()
                    } label: {
                        Image(systemName: "pencil")
                            .fontWeight(.bold)
                            .font(.system(size: 12))
                    }
                }
            }
        }
        .font(.caption)
        .frame(width: 140)
    }
}
