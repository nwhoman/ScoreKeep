//
//  GameLineupsView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/5/24.
//

import SwiftData
import SwiftUI

struct GameLineupsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nav: NavigationStateManager
    @State var gameViewModel: GameViewModel
    
    //var game: Game
    
    @State private var selectedTab: String = "Home"
    @State var showAlert = false
    @State var showHomeAlert = false
    @State var showVisitorAlert = false
    @State var startGame: Bool = false
    @State var editPlayers: Bool = false
    @State var homeCheck: (Bool, LineupErrors) = (false, .none)
    @State var visitorCheck: (Bool, LineupErrors) = (false, .none)
    
    var teamsCheck: Binding<Bool> {
        Binding(
            get: { self.homeCheck.0 || self.visitorCheck.0 },
            set: { newValue in
                self.homeCheck.0 = newValue
                self.visitorCheck.0 = newValue }
        )
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer(minLength: 70)
                TabView(selection: $selectedTab) {
                    LineupView(gameVM: gameViewModel, game: gameViewModel.game, lineup: gameViewModel.homeCurrentLineup, showAlert: $showAlert, showTeamAlert: $showHomeAlert, editPlayers: $editPlayers, selectedTab: selectedTab)
                        .tabItem { Text("\(gameViewModel.game.homeTeam!.name)") }.tag("Home")
                    
                    LineupView(gameVM: gameViewModel, game: gameViewModel.game, lineup: gameViewModel.visitorCurrentLineup, showAlert: $showAlert, showTeamAlert: $showVisitorAlert, editPlayers: $editPlayers, selectedTab: selectedTab)
                        .tabItem { Text("\(gameViewModel.game.visitingTeam!.name)") }.tag("Visitor")
                    
                }
                .alert(isPresented: teamsCheck) {
                    if homeCheck.0 {
                         return getAlertForLineup(error: (homeCheck.1), team: "home", test: $homeCheck.0)
                    } else  {
                        return getAlertForLineup(error: (visitorCheck.1), team: "visitor", test: $visitorCheck.0)
                    }
                }
                
            }
            VStack{
                HStack {
                    VStack(alignment: .leading) {
                        Text(gameViewModel.game.name)
                        Text("\(gameViewModel.game.date.formatted(date: .complete, time: .omitted))")
                        Text("\(gameViewModel.game.date.formatted(date: .omitted, time: .complete))")
                        Text("At: \(gameViewModel.game.location)")
                    }
                    .font(.system(size: 14))
                    .padding(.leading)
                    Spacer()
                    Button {
                        // Verify both teams' lineups
                        homeCheck = validateLineup(lineup: gameViewModel.homeCurrentLineup, team: "home")
                        visitorCheck = validateLineup(lineup: gameViewModel.homeCurrentLineup, team: "visitor")
                        if !homeCheck.0 && !visitorCheck.0 {
                            do {
                                //modelContext.insert(gameViewModel)
                                
                                try modelContext.save()
                            } catch {
                                print("error saving game: \(error)")
                            }
                            nav.push(.bookView(gameViewModel: gameViewModel))
                            //startGame.toggle()
                        
                        } else {
                            showHomeAlert.toggle()
                            showAlert.toggle()
                        }
                
                        
                    } label: {
                        VStack{
                            Image(systemName: "figure.baseball")
                                .font(.system(size: 32))
                                .foregroundStyle(.blue)
                            
                            Text("Start Game")
                                .font(.caption)
                                .padding(.horizontal)
                        }
                        
                        .background {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.lightGray))
                                .stroke(.blue, lineWidth: 2)
                        }
                        .padding(.horizontal)
                    }
                }
                
                HStack {
                    Button {
                        modelContext.delete(gameViewModel)
                        //nav.push(.teams)
//                        nav.pop()
                        nav.push(.team(team: selectedTab == "Home" ? gameViewModel.game.homeTeam! : gameViewModel.game.visitingTeam!))
                    } label: {
                        Text(selectedTab == "Home" ? gameViewModel.game.homeTeam!.name : gameViewModel.game.visitingTeam!.name)
                    }
//                    NavigationLink(value: selectedTab == "Home" ? gameViewModel.game.homeTeam! : gameViewModel.game.visitingTeam!) {
//                        Text(selectedTab == "Home" ? gameViewModel.game.homeTeam!.name : gameViewModel.game.visitingTeam!.name)
//                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    Spacer()
                }
//                .navigationDestination(for: Team.self) {
//                    team in
//                    TeamDetailView(team: team)
//                }
                Spacer()
            }
        
        }
//        .sheet(isPresented: $editPlayers, content: {
//            let homeTeam = $gameViewModel.game.homeTeam
//            if selectedTab == "Home" {
//                AddPlayerView(team: homeTeam)
//            } else {
//                AddPlayerView(team: $gameViewModel.game.visitingTeam)
//            }
//        })
//        .navigationDestination(isPresented: $startGame) {
//            BookView(gameViewModel: gameViewModel)
//        }
    }
}
enum LineupErrors: Error {
    case invalidLineup
    case fNotLast
    case noDPwithF
    case noFwithDP
    case tooFewWithF
    case tooFewWithEP
    case none
    
}

func getAlertForLineup(error: LineupErrors, team: String, test: Binding<Bool>) -> Alert {
    switch error {
    case .invalidLineup:
        return  Alert(title: Text("\(team) Team Lineup Error"), message: Text("Not all the positions are filled, do you want to proceed?"), primaryButton: .default(Text("Proceed")) { test.wrappedValue = true }, secondaryButton: .cancel())
    case .fNotLast:
        return Alert(title: Text("\(team) Team Lineup Error"), message: Text("The Flex is not last in the order"), dismissButton: .default(Text("OK")))
    case .noDPwithF:
        return Alert(title: Text("\(team) Team Lineup Error"), message: Text("There is no DP designated for the Flex"), dismissButton: .default(Text("OK")))
    case .noFwithDP:
        return Alert(title: Text("\(team) Team Lineup Error"), message: Text("There is no F designated for the DP"), dismissButton: .default(Text("OK")))
    case .tooFewWithF:
        return Alert(title: Text("\(team) Team Lineup Error"), message: Text("Not all the positions are filled with a designated Flex"), dismissButton: .default(Text("OK")))
    case .tooFewWithEP:
        return Alert(title: Text("\(team) Team Lineup Error"), message: Text("Not all the positions are filled with designated EP players"), dismissButton: .default(Text("OK")))
    default:
        return Alert(title: Text("No Error"), message: Text("\(team) Lineup Looks Good"), dismissButton: .default(Text("OK")))
    }
    
}

func validateLineup(lineup: [PlayerPos], team: String) -> (Bool, LineupErrors) {
    var positions: [String] = ["P", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF"]
    var errorType: LineupErrors = .none
    var invalidLineup: Bool = false
    let order = lineup.sorted { $0.batting < $1.batting }
    
    // filter all used positions out of lineup
    for each in order {
        positions.removeAll { $0 == each.position }
    }
    
    // add the unfilled position to the Flex player
    if let pos = positions.first {
        for each in order {
            if each.flex {
                if !each.position.contains("/") {
                    each.position += "/" + pos
                }
            }
        }
    }
    if order.contains(where: { $0.flex }) {
        if let lastInOrder = order.last, !lastInOrder.flex {
            print("last not F")
            errorType = .fNotLast
            invalidLineup = true
        } else if !order.contains(where: { $0.position == "DP" }) {
            print("no DP")
            errorType = .noDPwithF
            invalidLineup = true
        }
        
        let newLineup = order.filter { !$0.flex && $0.position != "DP" && $0.position != "EP"}
        
        if newLineup.count != 8 {
            print("not 8")
            errorType = .tooFewWithF
            invalidLineup = true
        }
        print("all good with F")
        //return true
    } else {
        if order.contains(where: { $0.position == "DP" }) {
            print("contains DP")
            errorType = .noFwithDP
            invalidLineup = true
        }
    }
    
    let newLineup = order.filter { $0.position != "EP"}
    if newLineup.count < 9 {
        print("no flex <9")
        errorType = .invalidLineup
        invalidLineup = true
    }
    if !invalidLineup {
        print("all good")
    }
    return (invalidLineup, errorType)
    
}

func checkFlex(lineup: [PlayerPos]) -> Bool {
    
    if lineup.contains(where: { $0.position == "F" }) && !lineup.contains(where: { $0.position == "DP" }) {
        return false
    }
    return true
}  //|| !lineup.contains(where: { $0.position == "DP" })

#Preview {
    @Previewable @State var navPath = NavigationPath()
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    
    
    return NavigationStack {
         GameLineupsView(gameViewModel: GameViewModel(game: game, totalInnings: 3, inningRunRule: 0))
            .modelContainer(preview.modelContainer)
    }
}
