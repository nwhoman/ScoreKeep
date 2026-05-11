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
            modelContext.delete(player)
        }
    }
    func sortedPlayers(players: [Player]) -> [Player]{
        return players.sorted(using: KeyPathComparator(\.number))
    }
}

#Preview {
    @Previewable @State var team = Team(name: "", ageGroup: "")
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])

    return NavigationStack {
        PlayersView(teamId: team.id)
            .modelContainer(preview.modelContainer)
            .environmentObject(NavigationStateManager())
    }
}
