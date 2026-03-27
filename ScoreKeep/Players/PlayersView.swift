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

    let team: Team

    //@Query(sort: [SortDescriptor(\Player.lastName), SortDescriptor(\Player.firstName)]) //var players: [Player]
    @Query(sort: (\Player.number)) var players: [Player]
    @State private var path = [Player]()
    @State private var showAddPlayerScreen = false
    
    init(for team: Team){
        let id = team.id
        self._players = Query(filter: #Predicate {
            $0.team?.id == id
        }, sort: \Player.lastName)
        self.team = team
    }

    var body: some View {
        NavigationStack{
            List {
                ForEach(sortedPlayers(players: players)) { player in
                    NavigationLink(value: player){
                        HStack {
                            Text("# \(player.number)")
                            Text("\(player.firstName)")
                                .font(.system(size: 14))
                            Text("\(player.lastName)")
                                .font(.system(size: 14))
                        }
                    }
                }
                .onDelete(perform: deletePlayer)
            }
            .navigationDestination(for: Player.self) {
                player in
                PlayerDetailView(player: player)
            }
            .toolbar{
                
                ToolbarItem(placement: .topBarLeading){
                    Button("back", systemImage: "arrowshape.turn.up.backward"){
                        dismiss()
                    }
                    
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button("Add Player", systemImage: "plus"){
                        showAddPlayerScreen.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $showAddPlayerScreen) {
            AddPlayerView(team: team)
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
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])

    return NavigationStack {
        PlayersView(for: game.homeTeam!)
            .modelContainer(preview.modelContainer)
    }
}
