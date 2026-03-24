//
//  StartGameView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/3/24.
//

import SwiftData
import SwiftUI

struct StartGameView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query(sort: \Team.name) var teams: [Team]
    //@Binding var path: NavigationPath

    @State var homeTeam: Team = Team(name: "", ageGroup: "")
    @State var visitingTeam: Team = Team(name: "", ageGroup: "")
    @State var gameName: String = "Enter name for new Game"
    @State var gameLocation: String = "Enter location for new Game"
    @State var newGame: Game = Game(name: "", date: Date(), location: "")
    @State var gameDate: Date = Date()
    @State var startGame: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Form{
                Spacer(minLength: 50)
                //TextField("Name of Game", text: $newGame.name) 
                DatePicker("Date:", selection: $newGame.date)
                TextField("Game Location", text: $newGame.location)
                Spacer(minLength: 50)
                Text("Home Team: \(homeTeam.name)")
                Picker("pick team", selection: $homeTeam){
                    ForEach(teams, id: \.name){team in
                        Text(team.name)
                            .tag(team as Team)
                    }
                }
                Spacer(minLength: 50)
                Text("Visiting Team: \(visitingTeam.name)")
                Picker("pick team", selection: $visitingTeam){
                    ForEach(teams, id: \.name){team in
                        Text(team.name)
                            .tag(team as Team)
                    }
                }
                //Spacer(minLength: 50)
            }
        }
        Button("Create Game"){
            newGame.homeTeam = homeTeam
            newGame.visitingTeam = visitingTeam
            newGame.name = "\(homeTeam.name) vs. \(visitingTeam.name)"
            modelContext.insert(newGame)
            try? modelContext.save()
            startGame.toggle()
        }
        .navigationDestination(isPresented: $startGame) {
            let newGameViewModel = GameViewModel(game: newGame)
            GameLineupsView(gameViewModel: newGameViewModel)
            //GameLineupsView(path: $path, game: newGame)
        }
        .navigationTitle("Create Game")
        
       
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Team.self, configurations: config)
        //@State var example = NavigationPath()
        let team = Team(name: "B-town", ageGroup: "18U")
        
        return StartGameView(homeTeam: team )
            .modelContainer(container)
    }  catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
   // StartGameView()
}
