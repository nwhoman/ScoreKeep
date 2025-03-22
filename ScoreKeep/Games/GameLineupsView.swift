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
    
    var game: Game
    
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
                    LineupView(game: game, lineup: game.homeTeam!.lineup, selectedTab: selectedTab)
                        .tabItem { Text("\(game.homeTeam!.name)") }.tag("Home")
                    
                    LineupView(game: game, lineup: game.visitingTeam!.lineup, selectedTab: selectedTab)
                        .tabItem { Text("\(game.visitingTeam!.name)") }.tag("Visitor")
                    
                }
                .alert(isPresented: $showAlert) {
                    showHomeAlert ? Alert(title: Text("Home Team Lineup Error"), message: Text("Please check that all the positions are filled"), dismissButton: .default(Text("OK"))) : Alert(title: Text("Visiting Team Lineup Error"), message: Text("Please check that all the positions are filled"), dismissButton: .default(Text("OK")))
                }
            }
            VStack{
                HStack {
                    VStack(alignment: .leading) {
                        Text(game.name)
                        Text("\(game.date.formatted(date: .complete, time: .omitted))")
                        Text("\(game.date.formatted(date: .omitted, time: .complete))")
                        Text("At: \(game.location)")
                    }
                    .font(.system(size: 14))
                    .padding(.leading)
                    Spacer()
                    Button {
                        // Verify both teams' lineups
                        if validateLineup(lineup: game.homeTeam!.lineup) {
                            if validateLineup(lineup: game.visitingTeam!.lineup) {
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
                    NavigationLink(value: selectedTab == "Home" ? game.homeTeam! : game.visitingTeam!) {
                        Text(selectedTab == "Home" ? game.homeTeam!.name : game.visitingTeam!.name)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    Spacer()
                }
                Spacer()
            }
            
        }
        .navigationDestination(for: Team.self) {
            team in
            TeamDetailView(team: team)
        }
        .navigationDestination(isPresented: $startGame) {
            BookView(game: game)
        }
    }
}
func validateLineup(lineup: [PlayerPos]) -> Bool {
    let positions: [String] = ["P", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF"]
    for pos in positions {
        if !lineup.contains(where: { $0.position == pos }) {
            return false
        }
    }
    return true
}

#Preview {
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])
    
    return NavigationStack {
        GameLineupsView(game: game).modelContainer(preview.modelContainer)
    }
}
