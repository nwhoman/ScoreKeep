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
    @EnvironmentObject var nav: NavigationStateManager
    @Query(sort: \Game.name) private var games: [Game]
    @Query(sort: \Coach.lastName) var coaches: [Coach]
    //@State private var path = [Team]()
    @State private var showAddGameScreen = false
    //@State var startGame: Game = Game(name: "", date: Date(), location: "")
    //@Binding var path: NavigationPath
    @State var JSONString: String = ""
    @State var showJSON: Bool = false
    
    var body: some View {
        //NavigationStack {
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
        Button {
            for each in games {
                JSONString += displayJSON(game: each) + "\n"
            }
            showJSON.toggle()
        } label: {
            Text("JSON")
        }
            .navigationTitle("ScoreKeep Games")
            .navigationDestination(for: Game.self) { game in
                let newGameViewModel = GameViewModel(game: game, totalInnings: 3)
                GameLineupsView(gameViewModel: newGameViewModel)
                //GameLineupsView(path: $path, game: game)
            }
            .toolbar{
                
                ToolbarItem(placement: .topBarLeading){
                    //EditButton()
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button("Add Game", systemImage: "plus"){
                        showAddGameScreen.toggle()
                    }
                }
            }
            .navigationDestination(isPresented: $showAddGameScreen){
                StartGameView()
                //StartGameView(path: $path)
            }
        //}
            .sheet(isPresented: $showJSON) {
                ScrollView {
                    Text(JSONString)
                }
            }
    }
    
    func deleteGame(at offsets: IndexSet){
        for offset in offsets {
            let game = games[offset]
            modelContext.delete(game)
        }
    }
}

#Preview {
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
        
    return NavigationStack {
        GamesView().modelContainer(preview.modelContainer)
    }
}

func displayJSON(game: Game) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted]
    if let jsonData = try? encoder.encode(game),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
        return jsonString
    }
    return "failed to encode game"
}
