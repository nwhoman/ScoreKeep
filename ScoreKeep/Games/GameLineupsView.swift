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
    @StateObject var gameViewModel: GameViewModel
    //var game: Game
    
    @State private var selectedTab: String = "Home"
    @State var showAlert = false
    @State var showHomeAlert = false
    @State var showVisitorAlert = false
    @State var startGame: Bool = false

    var body: some View {
        ZStack {
            VStack {
                Spacer(minLength: 70)
                TabView(selection: $selectedTab) {
                    LineupView(gameVM: gameViewModel, game: gameViewModel.game, lineup: gameViewModel.homeCurrentLineup, showAlert: $showAlert, showTeamAlert: $showHomeAlert, selectedTab: selectedTab)
                        .tabItem { Text("\(gameViewModel.game.homeTeam!.name)") }.tag("Home")
                    
                    LineupView(gameVM: gameViewModel, game: gameViewModel.game, lineup: gameViewModel.visitorCurrentLineup, showAlert: $showAlert, showTeamAlert: $showVisitorAlert,selectedTab: selectedTab)
                        .tabItem { Text("\(gameViewModel.game.visitingTeam!.name)") }.tag("Visitor")
                    
                }
                .alert(isPresented: $showAlert) {
                    showHomeAlert ? Alert(title: Text("Home Team Lineup Error"), message: Text("Please check that all the positions are filled"), dismissButton: .default(Text("OK"))) : Alert(title: Text("Visiting Team Lineup Error"), message: Text("Please check that all the positions are filled"), dismissButton: .default(Text("OK")))
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
                        if validateLineup(lineup: gameViewModel.homeCurrentLineup) {
                            if validateLineup(lineup: gameViewModel.visitorCurrentLineup) {
                               // destination Start Game
                                startGame.toggle()
                            } else {
                                showVisitorAlert.toggle()
                                showAlert.toggle()
                            }
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
                    NavigationLink(value: selectedTab == "Home" ? gameViewModel.game.homeTeam! : gameViewModel.game.visitingTeam!) {
                        Text(selectedTab == "Home" ? gameViewModel.game.homeTeam!.name : gameViewModel.game.visitingTeam!.name)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    Spacer()
                }
                .navigationDestination(for: Team.self) {
                    team in
                    TeamDetailView(team: team)
                }
                Spacer()
            }
        
        }
        
        .navigationDestination(isPresented: $startGame) {
            
            BookView(gameViewModel: gameViewModel)
        }
    }
}
func validateLineup(lineup: [PlayerPos]) -> Bool {
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
    print("all good")
    return true
}

func checkFlex(lineup: [PlayerPos]) -> Bool {
    
    if lineup.contains(where: { $0.position == "F" }) && !lineup.contains(where: { $0.position == "DP" }) {
        return false
    }
    return true
}  //|| !lineup.contains(where: { $0.position == "DP" })

#Preview {
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    
    return NavigationStack {
        GameLineupsView(gameViewModel: GameViewModel(game: game, totalInnings: 3))
            .modelContainer(preview.modelContainer)
    }
}
