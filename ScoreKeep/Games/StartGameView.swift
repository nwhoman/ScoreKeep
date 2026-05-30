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
    @EnvironmentObject var nav: NavigationStateManager
    @Environment(\.dismiss) var dismiss
    @Query(sort: \Team.name) var teams: [Team]
    //@Binding var path: NavigationPath

    @State var homeTeam: Team? // = Team(name: "", ageGroup: "")
    @State var visitingTeam: Team? // = Team(name: "", ageGroup: "")
    @State var gameName: String = ""
    @State var gameLocation: String = ""
    @State var gameInnings: Int = 7
    @State var inningRR: Int = 0
    @State var newGame: GameViewModel?// = Game(name: "", date: Date(), location: "")
    @State var gameDate: Date = Date()
    @State var startGame: Bool = false
    @State var showAlert: Bool = false
    @State var homeTeamName: String = ""
    @State var visitorTeamName: String = ""
    @State var inningRRBool: Bool = false
    
    
    var body: some View {
        //NavigationStack {
            VStack(alignment: .leading) {
                Form{
                    Spacer(minLength: 50)
                    //TextField("Name of Game", text: $newGame.name) 
                    DatePicker("Date:", selection: $gameDate)
                    TextField("Game Location", text: $gameLocation)
                    Picker("Number of innings", selection: $gameInnings){
                        ForEach(1...10, id: \.self){num in
                            Text("\(num)")
                        }
                    }
                    Picker("Inning Run Rule", selection: $inningRR){
                        ForEach(0...10, id: \.self){num in
                            Text("\(num)")
                        }
                    }
                    HStack {
                        Toggle("Five run rule", systemImage: "", isOn: $inningRRBool)
                    }
                    Spacer(minLength: 20)
                    Text("Home Team: \(homeTeam?.name ?? "")")
                    TextField("Search Teams", text: $homeTeamName)
                        .padding(.leading)
                        .background(Color.gray.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                    if !homeTeamName.isEmpty {
                        PickerView(searchString: $homeTeamName, selection: $homeTeam, player: nil)
                    }
                    Picker("pick team", selection: $homeTeam){
                        ForEach(teams.sorted {$0.name < $1.name}, id: \.name){team in
                            Text(team.name)
                                .tag(team as Team)
                        }
                    }
                    NavigationLink("Create Quick Entry Team", destination: QuickEntryView(newTeam: $homeTeam))
                    
                    Spacer(minLength: 50)
                    Text("Visiting Team: \(visitingTeam?.name ?? "")")
                    TextField("Search Teams", text: $visitorTeamName)
                        .padding(.leading)
                        .background(Color.gray.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                        
                    if !visitorTeamName.isEmpty {
                        PickerView(searchString: $visitorTeamName, selection: $visitingTeam, player: nil)
                    }
                    Picker("pick team", selection: $visitingTeam){
                        ForEach(teams, id: \.name){team in
                            Text(team.name)
                                .tag(team as Team)
                        }
                    }
                    NavigationLink("Create Quick Entry Team", destination: QuickEntryView(newTeam: $visitingTeam))
                    //Spacer(minLength: 50)
                }
            }
        //}
        Button("Create Game"){
            if homeTeam?.players?.count ?? 0 > 8 && visitingTeam?.players?.count ?? 0 > 8 {
                if newGame == nil {
                    if inningRRBool {
                        inningRR = 5
                    }
                    newGame = GameViewModel(name: "\(visitingTeam?.name ?? "") at \(homeTeam?.name ?? "")", totalInnings: gameInnings, inningRunRule: inningRR, visitingTeam: visitingTeam!, homeTeam: homeTeam!)
                    
                    do {
                        modelContext.insert(newGame!)
                        homeTeam?.homeGames.append(newGame!)
                        visitingTeam?.visitingGames.append(newGame!)
                        try modelContext.save()
                        nav.push(.startGame(gameViewModel: newGame!))
                    } catch {
                        print(error)
                    }
                    
                }
                
            } else {
                showAlert.toggle()
            }
            
        }
        .disabled(homeTeam?.name == "" || visitingTeam?.name == "")
//        .navigationDestination(isPresented: $startGame) {
//            let newGameViewModel = GameViewModel(game: newGame ?? Game.defaultGame, totalInnings: gameInnings, inningRunRule: inningRR)
//            GameLineupsView(gameViewModel: newGameViewModel)
//            //GameLineupsView(path: $path, game: newGame)
//        }
        .navigationTitle("Create Game")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Lineup Check"), message: Text("One or both teams have less than 9 players."), dismissButton: .default(Text("OK")))
        }
       
    }
}

#Preview {
    let preview = Preview()
    let game = GameViewModel.defaultGame
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: GameViewModel.self, configurations: config)
        //@State var example = NavigationPath()
        let team = Team(name: "B-town", ageGroup: "18U")
        
        return StartGameView(homeTeam: team )
            .modelContainer(container)
    }  catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
   // StartGameView()
}

struct PickerView: View {
    @Query var teams: [Team]
    @Binding var selection: Team?
//    @Binding var list: [Team]
    @Binding var searchString: String
    var player: Player?
//
    init(searchString: Binding<String>, selection: Binding<Team?>, player: Player?) {
        self._searchString = searchString
        //self.selection = selection
        let search = searchString.wrappedValue
        _teams = Query(filter: #Predicate<Team> {
            $0.name.localizedStandardContains(search)
        }, sort: [SortDescriptor(\.name)])
        self._selection = selection
        
        self.player = player
        
    }
    var body: some View {
        VStack(alignment: .leading) {
            
                       
                            LazyVStack {
                                ForEach(teams) { team in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            HStack {
                                                Image(systemName: "circle")
                                                Text("\(team.name)")
                                                //  .foregroundStyle(.black)
                                            }
                                            .onTapGesture {
                                                selection = team
                                                player?.team = team
                                                if player != nil {
                                                    team.players?.append(player!)
                                                }
                                                
                                                searchString = ""
                                            }
//                                            Button {
//                                                selection = team
//                                                searchString = ""
//                                                print(teams)
//                                                print(team.name)
//                                                print(selection?.name ?? "no selection")
//                                            } label: {
//                                                
//                                            }
                                            Spacer()
                                        }
                                        .padding(.horizontal, 25)
                                        .padding(.vertical, 5)
                                    }
                                }
                            }
                        
                    
                
            //
            //    func addItem()
        }
//
    }
}
