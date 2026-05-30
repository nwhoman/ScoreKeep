//
//  PlayersView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/30/24.
//

import SwiftUI
import SwiftData

struct PlayersView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var nav: NavigationStateManager
    @Environment(\.dismiss) var dismiss

     //var team: Team?
    var teamId: UUID?

    @Query(sort: (\Player.lastName)) var players: [Player]
    @Query var teams: [Team]
    @State private var showAddPlayerScreen = false
    
    
    init(teamId: UUID?){
        self.teamId = teamId
        if let id = teamId {
            self._players = Query(filter: #Predicate {
                $0.team?.id == id
            }, sort: \Player.lastName)
            self._teams = Query(filter: #Predicate {
                $0.id == id
            })
        }
    }

    var body: some View {
            List {
                ForEach(players) { player in
                    Button {
                        nav.push(.player(player: player))
                    } label: {
                        HStack {
                            Text("# \(player.number)")
                            Text("\(player.firstName)")
                                
                            Text("\(player.lastName)")
                                
                            Spacer()
                            Text("\(player.team?.name ?? "Unknown Team")")
                        }
                        .font(.system(size: 14))
                        .minimumScaleFactor(0.5)
                    }
                    
                }
                .onDelete(perform: deletePlayer)
            }
            
            .toolbar{
                
                ToolbarItem(placement: .topBarTrailing){
                    Button("Add Player", systemImage: "plus"){
                        showAddPlayerScreen.toggle()
                    }
                }
            }
            .sheet(isPresented: $showAddPlayerScreen) {
                if let teamId {
                    AddPlayerView(teamId: teamId)
                } else {
                    AddPlayerView(teamId: nil)
                }
                
            }
    }
    func deletePlayer(at offsets: IndexSet){
        for offset in offsets {
            let player = players[offset]
            do {
                if try checkTeamGames(team: player.team!) {
                    modelContext.delete(player)
                }
            } catch {
                print(error)
            }
            
        }
    }
    func sortedPlayers(players: [Player]) -> [Player]{
        return players.sorted(using: KeyPathComparator(\.number))
    }
}

func checkTeamGames(team: Team) throws -> Bool {
    let container = try ModelContainer(for: GameViewModel.self)
    let context = ModelContext(container)
    let teamId = team.id
    let predicate1 = #Predicate<GameViewModel> { $0.homeTeam.id == teamId || $0.visitingTeam.id == teamId}
    let predicate2 = #Predicate<GameViewModel> { !$0.isComplete }
    let combinedPredicate = #Predicate<GameViewModel> { predicate1.evaluate($0) && predicate2.evaluate($0) }
    let descriptor = FetchDescriptor<GameViewModel>(predicate: combinedPredicate)
    
    let games = try context.fetch(descriptor)
    
    guard games.isEmpty else {
        return false
    }
    return true
    
    
}

#Preview {
    @Previewable @State var team = Team(name: "", ageGroup: "")
    let preview = Preview()
    let game = GameViewModel.defaultGame
    preview.addSampleGames([game])

    return NavigationStack {
        PlayersView(teamId: team.id)
            .modelContainer(preview.modelContainer)
            .environmentObject(NavigationStateManager())
    }
}
