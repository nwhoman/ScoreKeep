//
//  GamesView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/10/24.
//

import SwiftData
import SwiftUI

struct GamesView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Game.name) var games: [Game]
    @Query(sort: \Coach.lastName) var coaches: [Coach]
    //@State private var path = [Team]()
    @State private var showAddGameScreen = false
    //@State var startGame: Game = Game(name: "", date: Date(), location: "")
    @Binding var path: NavigationPath
    
    var body: some View {
        List {
            ForEach(games) { startGame in
                NavigationLink(value: startGame) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(startGame.name)
                                .font(.headline)
                            Text("\(startGame.date.formatted(date: .complete, time: .omitted))")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .onDelete(perform: deleteGame)
        }
        .navigationTitle("ScoreKeep Games")
        .navigationDestination(for: Game.self) {
             game in
            GameLineupsView(path: $path, game: game)
        }
        .toolbar{
            
            ToolbarItem(placement: .topBarLeading){
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing){
                Button("Add Game", systemImage: "plus"){
                    showAddGameScreen.toggle()
                }
            }
        }
        .navigationDestination(isPresented: $showAddGameScreen){
            StartGameView(path: $path)
        }
        //.sheet(isPresented: $showAddGameScreen) {
            //StartGameView(path: $path)
        //}
    }
    
    func deleteGame(at offsets: IndexSet){
        for offset in offsets {
            let game = games[offset]
            modelContext.delete(game)
        }
    }
}

/*#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Team.self, configurations: config)
        @State var example = NavigationPath()
        @Binding var game = Game(name: "djkd", date: Date(), location: "DLLLD")
        
        return GamesView(game: game, path: $example)
            .modelContainer(container)
    }  catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}*/
