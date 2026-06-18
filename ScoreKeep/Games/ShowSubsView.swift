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
    @Binding var gameVM: GameViewModel
    @State var team: Team
       
    @Binding var lineup: [PlayerPos]
    @State var showAlert: Bool = false
    @State var showSubs: Bool = false
    @State var goodAlert: Bool = false
    @State var changedPlayers: [[PlayerPos]] = []
    @Binding var battingOrder: [[PlayerPos]]
    @State var subCard: SubCard = SubCard()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    
                    Spacer()
                    
                    Button("Save Lineup"){
                        if validateSubs(lineup: lineup) {
                            // write lineup to batting order
                            writeLineupToBattingOrder(lineup: lineup, battingOrder: &battingOrder, subCard: subCard, viewModel:  gameVM)
                            updateBaseRunners(subCard: subCard, viewModel: gameVM)
                            
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
                            showAlert = true
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Lineup Check"), message: Text("Please check that all the positions are filled"), dismissButton: .default(Text("OK")))
                    }
                }
                
                .padding(10)
                RosterSubsView(gameVM: gameVM, team: team, showSubs: $showSubs, lineup: $lineup, changedPlayers: $changedPlayers, subCard: $subCard)
                
            }
            .background(Color.clear)
        }
        
        .alert(isPresented: $goodAlert) {
            Alert(title: Text("Lineup Check"), message: Text("Lineup looks good"), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    var game = GameViewModel.defaultGame
    let preview = Preview()
    
    preview.addSampleGames([game])

    return ShowSubsView(gameVM: .constant(game), team: game.homeTeam, lineup: .constant(game.createLineup(players: game.homeTeam.players!)), showAlert: false, showSubs: false, changedPlayers: [], battingOrder: .constant([]))
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
    @Binding var changedPlayers: [[PlayerPos]]
    @Binding var subCard: SubCard
    @State var sub: Sub = Sub()
    
    let teamId: Int? = nil
    
    private var unusedPositions: [String] {
        var possiblePositions = positions
        if !gameVM.isStarted {
            possiblePositions = positions.filter({ pos in !posUsed(position: pos, lineup: lineup)  })
        }
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
                                        .frame(height: 35)
                                        .padding(.horizontal, -5)
                                        .padding(.top, -10)
                                        .padding(.bottom, -10)
                                        .font(.caption)
                                        .onTapGesture {
                                            selectedPlayer = player
                                            sub.id = subCard.list.count + 1
                                            let subEntry = SubEntry(pos: player.position, player: player)
                                            sub.playerOut = subEntry
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
                .frame(height: geo.size.height*0.75)
                .padding(10)
                GroupBox(label: Text("Changes")) {
                    // list of changes
                    ScrollView{
                        ForEach(subCard.list, id:\Sub.id) { sub in
                            HStack {
                                VStack(alignment: .leading){
                                    Text("out: \(sub.playerOut.player?.player.number ?? "no name")-\(sub.playerOut.player?.player.lastName ?? "no name") \(sub.playerOut.pos)")
                                }
                                VStack(alignment: .leading){
                                    Text("in: \(sub.playerIn.player?.player.number ?? "no name")-\(sub.playerIn.player?.player.lastName ?? "no name") \(sub.playerIn.pos)")
                                }
                                Button {
                                    //remove change and revert lineup
                                } label: {
                                    HStack {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .background(Color.clear)
        }
        .navigationDestination(isPresented: $showSubs) {
            SwapPlayerView(lineup: $lineup, selectedPlayer: $selectedPlayer, gameVM: $gameVM, changedPlayers: $changedPlayers, subCard: $subCard, sub: $sub, unusedPlayers: unusedPlayers, positions: unusedPositions, team: teamId )
                
            
        }
    }
}
func createNewLineupSlot(player: Player, selectedPlayer: PlayerPos, lineup: inout [PlayerPos], gameVM: GameViewModel, modelContext: ModelContext) -> PlayerPos {          //team: Int?
    // create PlayerPos for inserted player
    let newPlayerPos = PlayerPos(player: player, position: selectedPlayer.position, batting: selectedPlayer.batting)
    modelContext.insert(newPlayerPos)
    player.fielder?.append(newPlayerPos)
    // insert PlayerPos into lineup
    newPlayerPos.inning = gameVM.inningNumber[gameVM.halfInning] / 10
    lineup = lineup.filter( {$0.batting != selectedPlayer.batting})
    lineup.append(newPlayerPos)
    do {
        try modelContext.save()
    } catch {
        print(error)
    }
    return newPlayerPos
}

func writeLineupToBattingOrder(lineup: [PlayerPos], battingOrder: inout [[PlayerPos]], subCard: SubCard, viewModel: GameViewModel) {
    var pitcher: PlayerPos?
    var newPitcher: PlayerPos?
    print("sub count-\(subCard.list.count)")
    for sub in subCard.list {              // sub: out/in: [ "pos", PlayerPos ]
        var temp:[[PlayerPos]] = []
        let order = sub.playerOut.player?.batting
        print("order: \(order)")
        if let player = sub.playerOut.player, let newPlayer = sub.playerIn.player {
            if sub.playerOut.pos == "P" {
                pitcher = player
                print("0-\(pitcher?.position) \(pitcher?.player.lastName)")
            }
            if sub.playerIn.pos == "P" {
                newPitcher = newPlayer
                print("1-\(newPitcher?.position) \(newPitcher?.player.lastName)")
            }
            for each in battingOrder {
                var slot = each
                print("in order: \(each.last!.batting)")
                if each.last!.batting == order {
                    if let newPlayer = sub.playerIn.player {
                        print("playerIn exists: \(newPlayer.player.lastName)-\(newPlayer.batting)")
                        slot.append(newPlayer)
                    }
                    
                }
                temp.append(slot)
            }
            battingOrder = temp
            
            if player.id != newPlayer.id {
                updateBatterInPlateAppearances(batter: player.player, newBatter: newPlayer, viewModel: viewModel)
                viewModel.batter?.batter = newPlayer.player
            }
        }
    }
    if let pitcher, let newPitcher {
            print("in update")
        updatePitcherInPlateAppearances(pitcher: pitcher.player, newPitcher: newPitcher, innings: viewModel.innings)
        viewModel.batter?.pitcher = newPitcher.player
    }
}

func updateBatterInPlateAppearances(batter: Player, newBatter: PlayerPos, viewModel: GameViewModel) {
    for inning in viewModel.innings {
        for app in inning.plateAppearances {
            
            if !app.active || (app.active && app.outcome["home"] == "") {
                batter.plateAppearances?.removeAll(where: {$0.id == app.id})
                if app.batter.id == batter.id {
                    app.batter = newBatter.player
                    newBatter.player.plateAppearances?.append(app)
                }
            }
            if viewModel.baseRunners.contains(where: {$0.id == app.id}) {
                viewModel.baseRunners = viewModel.baseRunners.filter( { $0.id != app.id })
                viewModel.baseRunners.append(app)
            }
            
        }
    }
}

func updatePitcherInPlateAppearances(pitcher: Player, newPitcher: PlayerPos, innings: [Inning]) {
    for inning in innings {
        for app in inning.plateAppearances {
            
            if !app.active || (app.active && app.outcome["home"] == "") {
                
                if app.pitcher.id == pitcher.id {
                    app.pitcher = newPitcher.player
                    newPitcher.player.pitchingAppearances?.append(app)
                }
            }
        }
        pitcher.pitchingAppearances?.removeAll(where: { !$0.active || ($0.active && $0.outcome["home"] == "") })
    }
}

func updateBaseRunners(subCard: SubCard, viewModel: GameViewModel) {
    for sub in subCard.list {
        if let oldRunner = sub.playerOut.player?.player  {
            for runner in viewModel.baseRunners {
                if oldRunner.number == runner.batter.number {
                    let order = runner.order
                    let inning = runner.inning
                    viewModel.baseRunners.removeAll(where: { $0.batter.number == oldRunner.number })
                    for each in inning.plateAppearances {
                        if each.order == order {
                            viewModel.baseRunners.append(each)
                        }
                    }
                }
            }
        }
    }
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
    @Binding var changedPlayers: [[PlayerPos]]
    @Binding var subCard: SubCard
    @Binding var sub: Sub
    var unusedPlayers: [Player]
    var positions: [String]
    let team: Int?
    
    var body: some View {
        HStack(alignment: .top) {
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
                            let newPlayer = createNewLineupSlot(player: player, selectedPlayer: selectedPlayer, lineup: &lineup, gameVM: gameVM, modelContext: modelContext)
                            
                            selectedPlayer = newPlayer
                            let subEntry = SubEntry(pos: selectedPlayer.position, player: newPlayer)
                            sub.playerIn = subEntry
                        }
                    }
                }
            }
            GroupBox(label:
                HStack {
                    Text("Selected Player")
                    Spacer()
                if !gameVM.isStarted {
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
                    RosterSubsItemView(gameVM: $gameVM, player: $selectedPlayer, lineup: $lineup, changedPlayers: $changedPlayers, subCard: $subCard, sub: $sub, unusedPositions: positions, position: "")
                        .padding(.leading, -15)
                }
            }
        }
        .onDisappear {
            subCard.list.append(sub)
            var order = 1
            lineup = lineup.sorted(by: { $0.batting < $1.batting })
            for i in 0..<lineup.count {
                lineup[i].batting = order
                order += 1
            }
        }
    }
}
#Preview {
    var game = GameViewModel.defaultGame
    let preview = Preview()
    var players: [Player] {
        var temp: [Player] = []
        for i in 0..<4 {
            temp.append(game.homeTeam.players![i])
        }
        return temp
    }
    preview.addSampleGames([game])

    return SwapPlayerView(lineup: .constant(game.createLineup(players: game.homeTeam.players!)), selectedPlayer: .constant(game.homeTeam.lineup[6]), gameVM: .constant(game), changedPlayers: .constant([]), subCard: .constant(SubCard()), sub: .constant(Sub()), unusedPlayers: players, positions: ["P"], team: 0)
            .modelContainer(preview.modelContainer)
    
}

struct RosterSubsItemView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query private var players: [Player]
    @Binding var gameVM: GameViewModel
    
    @Binding var player: PlayerPos
    //var player: PlayerPos
    @Binding var lineup: [PlayerPos]
    @Binding var changedPlayers: [[PlayerPos]]
    @Binding var subCard: SubCard
    @Binding var sub: Sub
    var unusedPositions: [String]
    @State var position: String

    init(gameVM: Binding<GameViewModel>, player: Binding<PlayerPos>, lineup: Binding<[PlayerPos]>, changedPlayers: Binding<[[PlayerPos]]>, subCard: Binding<SubCard>, sub: Binding<Sub>, unusedPositions: [String], position: String) {
        _gameVM = gameVM
        self._player = player
        _lineup = lineup
        _changedPlayers = changedPlayers
        _subCard = subCard
        _sub = sub
        self.unusedPositions = unusedPositions
        self.position = position
        let id = player.player.id
        
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
                var tempArray: [PlayerPos] = [player]
                lineup = lineup.sorted(by: { $0.batting < $1.batting })
                player.position = position
                let newPlayer = createNewLineupSlot(player: player.player, selectedPlayer: player, lineup: &lineup, gameVM: gameVM, modelContext: modelContext)
                tempArray.append(newPlayer)
                changedPlayers.append(tempArray)
                let subEntry = SubEntry(pos: position, player: newPlayer)
                sub.playerIn = subEntry

                player = newPlayer
                
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
