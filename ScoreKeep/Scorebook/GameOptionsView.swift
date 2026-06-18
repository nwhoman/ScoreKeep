//
//  GameOptionsView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 5/13/26.
//

import SwiftData
import SwiftUI

struct GameOptionsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nav: NavigationStateManager
    
    //    @State var pitcherSubs: Bool = false
    //    @State var batterSubs: Bool = false
    //    @State var baserunnerSubs: Bool = false
    @State var currentState: SubType? = nil
    @State var selectedTab: Int = 0
    @State var selectedPlayer: PlayerPos?
    
    @Binding var gameVM: GameViewModel
    let geo: GeometryProxy
    
    
    var body: some View {
        VStack(alignment: .leading) {
                Section(header: Text("Run Rules:")) {
                    VStack(alignment: .leading) {
                        HStack{
                            Text("Inning Run Rule (0 for no rule):")
                            TextField("Inning Run Rule", value: $gameVM.inningRunRule, format: .number)
                                .padding(.leading, 15)
                                .foregroundStyle(.white)
                                .frame(width: 35)
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        HStack{
                            
                            VStack{
                                Text("Game Run Rule (0 for no rule):")
                                ForEach(Array(gameVM.gameRunRule.keys).sorted(), id: \.self) { key in
                                    HStack{
                                        Text("\(key) innings:")
                                        TextField("Game Run Rule", value: $gameVM.gameRunRule[key], format: .number)
                                            .padding(.leading, 15)
                                            .foregroundStyle(.white)
                                            .frame(width: 35)
                                            .background(.blue)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                    }
                                }
                                
                            }
                        }
                    }
                    Divider()
                }
                .padding(5)
                Section(content: {
                    HStack {
                        Text("Game Length")
                        TextField("Game innings", value: $gameVM.totalInnings, format: .number)
                            .padding(.leading, 15)
                            .foregroundStyle(.white)
                            .frame(width: 35)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }, footer: {
                    Divider()
                })
                .padding(5)
                Section(content: {
                    HStack {
                        Text("Extend Inning")
                        Button { // add plate appearances to inning
                            gameVM.inningNumber[gameVM.halfInning] += 1
                            gameVM.addInning(inning: Inning(number: gameVM.inningNumber[gameVM.halfInning], game: gameVM, half: gameVM.halfInning), lineup: gameVM.halfInning == 0 ? gameVM.visitorCurrentLineup : gameVM.homeCurrentLineup, halfInning: gameVM.halfInning)
                        } label: {
                            Image("green-sphere")
                                .resizable()
                                .frame(width: 30, height: 25)
                        }
                        Spacer()
                        Text("End Inning")
                        Button { // add plate appearances to inning
                            gameVM.outs = 3
                            gameVM.checkInningComplete()
                        } label: {
                            Image("red-sphere")
                                .resizable()
                                .frame(width: 30, height: 25)
                            //Image(systemName: "plus.rectangle")
                        }
                        Spacer()
                    }
                }, footer: {
                    Divider()
                })
                .padding(5)
                Section(content: {
                    HStack {
                        Text("Leave Game")
                        Button { // leave game
                            Task {
                                try? modelContext.save()
                            }
                            nav.path.removeLast()
                        } label: {
                            Image("green-sphere")
                                .resizable()
                                .frame(width: 30, height: 25)
                        }
                        Spacer()
                        Text("Complete Game")
                        Button { // mark game as complete and leave
                            gameVM.isComplete = true
                            gameVM.completeGame()
                            Task {
                                try? modelContext.save()
                            }
                            nav.path.removeLast()
                        } label: {
                            Image("red-sphere")
                                .resizable()
                                .frame(width: 30, height: 25)
                        }
                        Spacer()
                    }
                }, footer: {
                    Divider()
                })
                .padding(5)
                
            Spacer()
        }
    }
}

#Preview {
    let preview = Preview()
    let gameViewModel: GameViewModel = GameViewModel.defaultGame
    preview.addSampleGames([gameViewModel])
    preview.addSampleLineups(game: gameViewModel)
    gameViewModel.setUpGame()
    gameViewModel.visitorCurrentLineup = gameViewModel.visitingTeam.lineup
    gameViewModel.batter = gameViewModel.visitorInnings.first?.plateAppearances[0]
    gameViewModel.baseRunners.insert(gameViewModel.batter!, at: 0)
    gameViewModel.baseRunners.insert(gameViewModel.visitorInnings.first!.plateAppearances[1], at: 1)
    return GeometryReader { geo in
        GameOptionsView(gameVM: .constant(gameViewModel), geo: geo)
            .modelContainer(preview.modelContainer)
    }
}

struct QuickSubsItemView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nav: NavigationStateManager
    
    @State var currentState: SubType? = nil
    @State var selectedTab: Int = 0
    @State var selectedPitcher: PlayerPos?
    @State var selectedPlayer: PlayerPos?
    @State var subCard: SubCard = SubCard()
    @State var sub: Sub = Sub()
    @Binding var gameVM: GameViewModel
    let geo: GeometryProxy
    
    var body: some View {
        
    }
}

struct QuickSubsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nav: NavigationStateManager
    
    @State var currentState: SubType? = nil
    @State var selectedTab: Int = 0
    @State var selectedPitcher: PlayerPos?
    @State var selectedPlayer: PlayerPos?
    @State var subCard: SubCard = SubCard()
    @State var sub: Sub = Sub()
    @Binding var gameVM: GameViewModel
    let geo: GeometryProxy
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Section(header: Text("Substitutions")
                .padding(.horizontal, 10)) {
                    ZStack {
                        
                        if currentState != nil {
                            if currentState == .pitcher {
                                
                                if gameVM.halfInning == 0 {
                                    QuickSubsDetailView(subCard: $subCard, sub: $sub, selectedPlayer: $selectedPitcher, currentState: $currentState, lineup: $gameVM.homeCurrentLineup, gameVM: $gameVM, geo: geo, team: 1)
                                } else {
                                    QuickSubsDetailView(subCard: $subCard, sub: $sub, selectedPlayer: $selectedPitcher, currentState: $currentState, lineup: $gameVM.visitorCurrentLineup, gameVM: $gameVM, geo: geo, team: 0)
                                }
                            }
                        
//                            ForEach(SubType.allCases, id: \.self) { subType in
//                                
//                                if currentState == .pitcher {
//                                    
//                                    if gameVM.halfInning == 0 {
//                                        QuickSubsDetailView(subCard: $subCard, sub: $sub, selectedPlayer: $selectedPitcher, currentState: $currentState, lineup: $gameVM.homeCurrentLineup, gameVM: $gameVM, geo: geo, team: 1)
//                                    } else {
//                                        QuickSubsDetailView(subCard: $subCard, sub: $sub, selectedPlayer: $selectedPitcher, currentState: $currentState, lineup: $gameVM.visitorCurrentLineup, gameVM: $gameVM, geo: geo, team: 0)
//                                    }
//                                    
//                                    
//                                } else if currentState == .batter {
//                                    
//                                    if gameVM.halfInning == 0 {
//                                        QuickSubsDetailView(subCard: $subCard, sub: $sub, selectedPlayer: $selectedPlayer, currentState: $currentState, lineup: $gameVM.visitorCurrentLineup, gameVM: $gameVM, geo: geo, team: 0)
//                                    } else {
//                                        QuickSubsDetailView(subCard: $subCard, sub: $sub, selectedPlayer: $selectedPlayer, currentState: $currentState, lineup: $gameVM.homeCurrentLineup, gameVM: $gameVM, geo: geo, team: 1)
//                                    }
//                                } else if currentState == .runner {
//                                    if gameVM.halfInning == 0 {
//                                        QuickSubsDetailView(subCard: $subCard, sub: $sub, selectedPlayer: $selectedPlayer, currentState: $currentState, lineup: $gameVM.visitorCurrentLineup, gameVM: $gameVM, geo: geo, team: 0)
//                                    } else {
//                                        QuickSubsDetailView(subCard: $subCard, sub: $sub, selectedPlayer: $selectedPlayer, currentState: $currentState, lineup: $gameVM.homeCurrentLineup, gameVM: $gameVM, geo: geo, team: 1)
//                                    }
//                                    
//                                }
//                                
//                            }
                            
                            
                        } else {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("pitcher:")
                                    
                                    if selectedPitcher == nil {
                                        
                                        Button { // open sub page for pitcher
                                            currentState = .pitcher
                                                if gameVM.halfInning == 1 {
                                                    selectedPitcher = gameVM.getPlayerPosForPlayer(player: gameVM.batter!.pitcher, lineup: gameVM.visitorCurrentLineup).first!
                                                } else {
                                                    selectedPitcher = gameVM.getPlayerPosForPlayer(player: gameVM.batter!.pitcher, lineup: gameVM.homeCurrentLineup).first!
                                                }
                                                let subEntry = SubEntry(pos: "P", player: selectedPitcher)
                                                sub.playerOut = subEntry
                                            
                                        } label: {
                                            HStack {
                                                Text("#\(String(describing: gameVM.batter?.pitcher.number))")
                                                Text("\(String(describing: gameVM.batter?.pitcher.lastName)), \(String(describing: gameVM.batter?.pitcher.firstName))")
                                                Image("blue-sphere")
                                                    .resizable()
                                                    .frame(width: 30, height: 25)
                                            }
                                        }
                                    } else {
                                        HStack {
                                            Text("#\(selectedPitcher?.player.number ?? "")")
                                            Text("\(selectedPitcher?.player.lastName ?? ""), \(selectedPitcher?.player.firstName ?? "")")
//                                                    Image("blue-sphere")
//                                                        .resizable()
//                                                        .frame(width: 30, height: 25)
                                        }
                                    }
                                    
                                    Spacer()
                                }
//                                ForEach(SubType.allCases, id: \.self) { subType in
//                                    switch subType {
//                                    case .pitcher:
//                                        
//                                        HStack {
//                                            Text("\(subType.description):")
//                                            
//                                            if selectedPitcher == nil {
//                                                
//                                                Button { // open sub page for pitcher
//                                                    if currentState != subType {
//                                                        currentState = subType
//                                                        selectedTab = subType.id
//                                                        if gameVM.halfInning == 1 {
//                                                            selectedPitcher = gameVM.getPlayerPosForPlayer(player: gameVM.batter!.pitcher, lineup: gameVM.visitorCurrentLineup).first!
//                                                        } else {
//                                                            selectedPitcher = gameVM.getPlayerPosForPlayer(player: gameVM.batter!.pitcher, lineup: gameVM.homeCurrentLineup).first!
//                                                        }
//                                                        let subEntry = SubEntry(pos: "P", player: selectedPitcher)
//                                                        sub.playerOut = subEntry
//                                                    } else {
//                                                        currentState = nil
//                                                    }
//                                                } label: {
//                                                    HStack {
//                                                        Text("#\(gameVM.batter!.pitcher.number)")
//                                                        Text("\(gameVM.batter!.pitcher.lastName), \(gameVM.batter!.pitcher.firstName)")
//                                                        Image("blue-sphere")
//                                                            .resizable()
//                                                            .frame(width: 30, height: 25)
//                                                    }
//                                                }
//                                            } else {
//                                                HStack {
//                                                    Text("#\(selectedPitcher?.player.number ?? "")")
//                                                    Text("\(selectedPitcher?.player.lastName ?? ""), \(selectedPitcher?.player.firstName ?? "")")
////                                                    Image("blue-sphere")
////                                                        .resizable()
////                                                        .frame(width: 30, height: 25)
//                                                }
//                                            }
//                                            
//                                            Spacer()
//                                        }
//                                        
//                                    case .batter:
//                                        
//                                        HStack {
//                                            Text("\(subType.description):")
//                                        }
////
////                                            
////                                            Button { // open sub page for pitcher
////                                                if currentState != subType {
////                                                    currentState = subType
////                                                    let batter = gameVM.batter?.batter
////                                                    if gameVM.halfInning == 0 {
////                                                        selectedPlayer = gameVM.getPlayerPosForPlayer(player: batter!, lineup: gameVM.visitorCurrentLineup).first!
////                                                    } else {
////                                                        selectedPlayer = gameVM.getPlayerPosForPlayer(player: batter!, lineup: gameVM.homeCurrentLineup).first!
////                                                    }
////                                                    let subEntry = SubEntry(pos: selectedPlayer?.position ?? "", player: selectedPlayer)
////                                                    sub.playerOut = subEntry
////                                                    
////                                                } else {
////                                                    currentState = nil
////                                                }
////                                            } label: {
////                                                
////                                                HStack {
////                                                    Text("#\(gameVM.batter?.batter.number ?? "")")
////                                                    Text("\(gameVM.batter?.batter.lastName ?? ""), \(gameVM.batter?.batter.firstName ?? "")")
////                                                    Image("blue-sphere")
////                                                        .resizable()
////                                                        .frame(width: 30, height: 25)
////                                                }
////                                            }
////                                            
////                                            
////                                            Spacer()
////                                        }
//                                        
//                                    case .runner:
//                                        HStack {
//                                            Text("\(subType.description):")
//                                        }
//                                        
////                                        HStack(alignment: .top, spacing: 10) {
////                                            Text("\(subType.description):")
////                                            let runners: [OffensivePlateAppearance] = gameVM.baseRunners.filter { each in
////                                                each.baseOccupied != 0
////                                            }
////                                            VStack{
////                                                ForEach(runners, id: \.self) { runner in
////                                                    Button { // open sub page for pitcher
////                                                        if currentState != subType {
////                                                            currentState = subType
////                                                            if gameVM.halfInning == 0 {
////                                                                selectedPlayer = gameVM.getPlayerPosForPlayer(player: runner.batter, lineup: gameVM.visitorCurrentLineup).first!
////                                                            } else {
////                                                                selectedPlayer = gameVM.getPlayerPosForPlayer(player: runner.batter, lineup: gameVM.homeCurrentLineup).first!
////                                                            }
////                                                            let subEntry = SubEntry(pos: selectedPlayer?.position ?? "", player: selectedPlayer)
////                                                            sub.playerOut = subEntry
////                                                        } else {
////                                                            currentState = nil
////                                                        }
////                                                    } label: {
////                                                        
////                                                        HStack {
////                                                            Text("#\(runner.batter.number)")
////                                                            Text("\(runner.batter.lastName), \(runner.batter.firstName)")
////                                                            Image("blue-sphere")
////                                                                .resizable()
////                                                                .frame(width: 30, height: 25)
////                                                        }
////                                                    }
////                                                }
////                                                
////                                                
////                                                
////                                                Spacer()
////                                            }
////                                        }
//                                    }
//                                    VStack {
//                                        
//                                    }
//                                }
                            }
                        }
                    }
                    .padding(25)
                    
                    
                    
                    Divider()
                    
                        .padding(5)
                    
                    
                    
                }
            if currentState == nil {
                Button {
                    var lineup: [PlayerPos] = []
                    var battingOrder: [[PlayerPos]] = []
                    if gameVM.halfInning == 1 {
                        lineup = gameVM.visitorCurrentLineup
                        battingOrder = gameVM.visitorLineup
                    } else {
                        lineup = gameVM.homeCurrentLineup
                        battingOrder = gameVM.homeLineup
                    }
                    if validateSubs(lineup: lineup) {
                        print("validated")
//                        writeLineupToBattingOrder(lineup: lineup, battingOrder: &battingOrder, subCard: subCard, viewModel: gameVM)
                        if gameVM.halfInning == 0 {
                            writeLineupToBattingOrder(lineup: gameVM.homeCurrentLineup, battingOrder: &gameVM.homeLineup, subCard: subCard, viewModel: gameVM)
                        } else {
                            writeLineupToBattingOrder(lineup: gameVM.visitorCurrentLineup, battingOrder: &gameVM.visitorLineup, subCard: subCard, viewModel: gameVM)
                        }
                        do {
                            try modelContext.save()
                        } catch {
                            print("\(error)")
                        }
                        currentState = nil
                    } else {
                        print("not validated")
                    }
                } label: {
                    Text("Save Change")
                }
            }
        }
        
    }
}
#Preview {
    let preview = Preview()
    let gameViewModel: GameViewModel = GameViewModel.defaultGame
    preview.addSampleGames([gameViewModel])
    preview.addSampleLineups(game: gameViewModel)
    gameViewModel.setUpGame()
    gameViewModel.visitorCurrentLineup = gameViewModel.visitingTeam.lineup
    gameViewModel.batter = gameViewModel.visitorInnings.first?.plateAppearances[0]
    gameViewModel.baseRunners.insert(gameViewModel.batter!, at: 0)
    gameViewModel.baseRunners.insert(gameViewModel.visitorInnings.first!.plateAppearances[1], at: 1)
    return GeometryReader { geo in
        QuickSubsView(gameVM: .constant(gameViewModel), geo: geo)
            .modelContainer(preview.modelContainer)
    }
}


struct QuickSubsDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nav: NavigationStateManager
    
    @State private var positions: [String] = ["P", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF", "DP", "F", "EP"]
    @State var changedPlayers:[[PlayerPos]] = []
    @Binding var subCard: SubCard
    @Binding var sub: Sub
    @Binding var selectedPlayer: PlayerPos?
    @Binding var currentState: SubType?
    @Binding var lineup: [PlayerPos]
    
    @Binding var gameVM: GameViewModel

    let geo: GeometryProxy
    let team: Int
    
    private var unusedPositions: [String] {
        var possiblePositions = positions
        possiblePositions = positions.filter({ pos in !posUsed(position: pos, lineup: lineup)  })
        return possiblePositions
    }
    private var unusedPlayers: [Player] {
        var players: [Player] = []
        if team == 0 {
            players = (gameVM.visitingTeam.players!.filter({ pos in !playerUsed(player: pos, lineup: lineup)  }))
        } else {
            players = gameVM.homeTeam.players!.filter({ pos in !playerUsed(player: pos, lineup: lineup)  })
        }
        return players
    }
    
    var body: some View {
        VStack {
            
            Button {
//                if validateSubs(lineup: lineup) {
//                    print("validated")
//                    if team == 0 {
//                        writeLineupToBattingOrder(lineup: lineup, battingOrder: &gameVM.visitorLineup, subCard: subCard, viewModel: gameVM)
//                    } else {
//                        writeLineupToBattingOrder(lineup: lineup, battingOrder: &gameVM.homeLineup, subCard: subCard, viewModel: gameVM)
//                    }
//                    do {
//                        try modelContext.save()
//                    } catch {
//                        print("\(error)")
//                    }
                    currentState = nil
//                } else {
//                    print("not validated")
//                }
            } label: {
                Text("Back")
            }
            if let player = Binding($selectedPlayer) {
                SwapPlayerView(lineup: $lineup, selectedPlayer: player, gameVM: $gameVM, changedPlayers: $changedPlayers, subCard: $subCard, sub: $sub, unusedPlayers: unusedPlayers, positions: unusedPositions, team: team)
            }
        }
        
    }
    
    
}
//#Preview {
//    @Previewable @State var player: [PlayerPos] = [PlayerPos.defaultPos]
//    let preview = Preview()
//    let gameViewModel: GameViewModel = GameViewModel.defaultGame
//    
//    preview.addSampleGames([gameViewModel])
//    preview.addSampleLineups(game: gameViewModel)
//    gameViewModel.setUpGame()
//    return GeometryReader { geo in
//        QuickSubsView(currentState: .constant(SubType.pitcher), id: gameViewModel.id, unusedPlayers: gameViewModel.visitorReserves, playerToSub: _player, geo: geo)
//    }
//}
func insertBaserunnerNode() {
    
}

enum SubType: Int, CaseIterable, Identifiable {
    case pitcher
    case batter
    case runner
    
    var id: Int { self.rawValue }
    
    var description: String {
        switch self {
        case .pitcher: return "Pitcher"
        case .batter: return "Batter"
        case .runner: return "Baserunner"
        }
    }
    var currentState: Bool {
        switch self {
        case .pitcher: return true
        case .batter: return false
        case .runner: return false
        }
    }
    
    func toggleBoolVariable(subType: SubType, pitcherSubs: Binding<Bool>, batterSubs: Binding<Bool>, baserunnerSubs: Binding<Bool>) -> Bool {
        switch subType {
        case .pitcher: return {
            if pitcherSubs.wrappedValue == true {
                return false
            } else {
                return true
            }
        }()
        case .batter: return {
            if batterSubs.wrappedValue == true {
                return false
            } else {
                return true
            }
        }()
        case .runner: return {
            if baserunnerSubs.wrappedValue == true {
                return false
            } else {
                return true
            }
        }()
        }
    }
    func chooseTeamToSub(subType: SubType, gameVm: GameViewModel) -> Int {
        switch subType {
        case .pitcher: return {
            if gameVm.halfInning == 0 {
                return 1
            } else {
                return 0
            }
        }()
        case .batter, .runner : return {
            if gameVm.halfInning == 0 {
                return 0
            } else {
                return 1
            }
        }()
        }
    }
    
    func getPlayerForSub(subType: SubType, gameVm: GameViewModel) -> [PlayerPos] {
        switch subType {
        case .pitcher: return [gameVm.getCurrentPitcher(i: gameVm.halfInning)]
            
        case .batter: return {
            if gameVm.halfInning == 0 {
                return gameVm.getPlayerPosForPlayer(player: gameVm.batter!.batter, lineup: gameVm.visitorCurrentLineup)
            } else {
                return gameVm.getPlayerPosForPlayer(player: gameVm.batter!.batter, lineup: gameVm.homeCurrentLineup)
            }

        }()
        case .runner: return {
            var baseRunners: [PlayerPos] = []
            for each in gameVm.baseRunners {
                if each.baseOccupied != 0 {
                    if gameVm.halfInning == 0 {
                        print("\(gameVm.baseRunners.count)")
                        baseRunners.append(contentsOf: gameVm.visitorCurrentLineup.filter( { $0.player.id == each.batter.id }))
                    } else {
                        baseRunners.append(contentsOf: gameVm.homeCurrentLineup.filter( { $0.player.id == each.batter.id }))
                    }
                }
            }
            return baseRunners
        }()
        }
    }
//    func viewToUse(currentState: Binding<SubType?>, subType: SubType, gameVm: GameViewModel, geo: GeometryProxy) -> some View {
//        var unusedPlayers: [Player] = []
//         @State var playerToSub: [PlayerPos] = []
//        
//        switch subType {
//        case .pitcher: return {
//            if gameVm.halfInning == 0 {
//                playerToSub = [gameVm.getCurrentPitcher(i: 0)]
//                print("Reserves: \(gameVm.visitorReserves), \(gameVm.homeReserves)")
//                    
//                return QuickSubsView(currentState: currentState, id: gameVm.id, unusedPlayers: gameVm.homeReserves, playerToSub: _playerToSub, geo: geo)
//            } else {
//                playerToSub = [gameVm.getCurrentPitcher(i: 1)]
//                return QuickSubsView(currentState: currentState, id: gameVm.id, unusedPlayers: gameVm.visitorReserves, playerToSub: _playerToSub, geo: geo)
//            }
//    
//        }()
//        case .batter: return {
//            if gameVm.halfInning == 0 {
//                playerToSub = gameVm.getPlayerPosForPlayer(player: gameVm.batter?.batter ?? Player.newPlayer, lineup: gameVm.visitorCurrentLineup)
//                return QuickSubsView(currentState: currentState, id: gameVm.id, unusedPlayers: gameVm.visitorReserves, playerToSub: _playerToSub, geo: geo)
//            } else {
//                playerToSub = gameVm.getPlayerPosForPlayer(player: gameVm.batter?.batter ?? Player.newPlayer, lineup: gameVm.homeCurrentLineup)
//                return QuickSubsView(currentState: currentState, id: gameVm.id, unusedPlayers: gameVm.homeReserves, playerToSub: _playerToSub, geo: geo)
//            }
//            
//        }()
//        case .runner: return {
//            if gameVm.halfInning == 0 {
//                unusedPlayers.append(contentsOf: gameVm.visitorReserves)
//                for each in gameVm.baseRunners {
//                    playerToSub.append(contentsOf: gameVm.getPlayerPosForPlayer(player: each.batter, lineup: gameVm.visitorCurrentLineup))
//                }
//            } else {
//                unusedPlayers.append(contentsOf: gameVm.homeReserves)
//                for each in gameVm.baseRunners {
//                    playerToSub.append(contentsOf: gameVm.getPlayerPosForPlayer(player: each.batter, lineup: gameVm.visitorCurrentLineup))
//                }
//            }
//            return QuickSubsView(currentState: currentState, id: gameVm.id, unusedPlayers: unusedPlayers, playerToSub: _playerToSub, geo: geo)
//        }()
//        }
//    }
}

