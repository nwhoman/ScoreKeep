//
//  ContentView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/25/24.
//
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject var nav = NavigationStateManager()
    
    var body: some View {
        NavigationStack(path: $nav.path) {
            //PlateAppearanceView()
            MainMenuView()
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .home: ContentView()
                case .team(let team): TeamDetailView(team: team)
                case .teams: TeamsView()
                case .games: GamesView()
                case .innings: InningsListView()
                case .players: PlayersView(teamId: nil)
                case .player(let player): PlayerDetailView(player: player)
                case .teamPlayers(let id): PlayersView(teamId: id)
                case .startGame(let gameViewModel): GameLineupsView(gameViewModel: gameViewModel)
                case .bookView(let gameViewModel): BookView(gameViewModel: gameViewModel)
                }
            }
        }
        .environmentObject(nav)
    }
}

#Preview {
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    return ContentView()
        .modelContainer(preview.modelContainer)
}
