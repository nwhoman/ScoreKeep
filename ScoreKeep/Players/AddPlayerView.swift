//
//  AddPlayerView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/30/24.
//

import SwiftUI
import SwiftData

struct AddPlayerView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var nav: NavigationStateManager
    @Environment(\.dismiss) var dismiss

    @Query var teams: [Team]
    
    //@Binding var team: Team?
    @State var player: Player? // = Player(firstName: "", lastName: "", number: "")
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var age: Int = 0
    @State private var number: String = ""
    @State private var showAlert: Bool = false
    
    var teamId: UUID?
    
    init(teamId: UUID?){
        self.teamId = teamId
        if let id = teamId {
            self._teams = Query(filter: #Predicate {
                $0.id == id
            })
        }
    }
    
    var body: some View {
        Form {
            Section {
                if let player = player {
                    Text("\(player.number) \(player.firstName) \(player.lastName)")
                } else {
                    TextField("Player's Number:", text: $number)
                    TextField("Player's First Name:", text: $firstName)
                        .autocorrectionDisabled()
                    TextField("Player's Last Name:", text: $lastName)
                        .autocorrectionDisabled()
                }
            }
//                Picker("Player Age:", selection: $age){
//                    ForEach(7..<20){
//                        Text("\($0)")
//                    }
//                }
            Section {
                
                if !lastName.isEmpty || !firstName.isEmpty {
                    PlayerPickerView(searchLastName: lastName, searchFirstName: firstName, selection: $player)
                }
            }
            Section {
                Button("Save Player"){
                    //add player
                    if firstName.isEmpty {
                        firstName = " "
                    } else if lastName.isEmpty {
                        lastName = " "
                    } else if number.isEmpty {
                        showAlert.toggle()
                    }
                    if !showAlert {
                        guard let boundTeam = teams.first else {
                            let newPlayer = Player(firstName: firstName, lastName: lastName, age: age, number: number)
                            modelContext.insert(newPlayer)
                            try? modelContext.save()
                            return
                        }
                        print("\(boundTeam.name), count \(boundTeam.players?.count ?? 100)")
                        if player != nil {
                            //print("a p: \(player?.lastName ?? "no player") t: \($team??.name ?? "no team")")
                            boundTeam.players?.append(player!)
                        } else {
                            //print("b p: \(player?.lastName ?? "no player") t: \(team?.name ?? "no team")")
                            let newPlayer = Player(firstName: firstName, lastName: lastName, age: age, number: number)
                            modelContext.insert(newPlayer)
                            try? modelContext.save()
                            
                            boundTeam.players?.append(newPlayer)
                            
                        }
                        print("\(boundTeam.name), count \(boundTeam.players?.count ?? 100)")
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Player Entry Error"), message: Text("A Player requires a number"), dismissButton: .default(Text("OK")))
        }
        
    }
}

//#Preview {
//    let preview = Preview()
//    let game = Game.defaultGame
//    preview.addSampleGames([game])
//
//    return NavigationStack {
//        AddPlayerView(team: game.homeTeam!)
//            .modelContainer(preview.modelContainer)
//    }
//}

struct PlayerPickerView: View {
    @Query var players: [Player]
    @Binding var selection: Player?
//    @Binding var list: [Team]
    let searchLastName: String
    let searchFirstName: String
//
    init(searchLastName: String, searchFirstName: String, selection: Binding<Player?>) {
        self.searchLastName = searchLastName
        self.searchFirstName = searchFirstName
        _players = Query(filter: #Predicate<Player> {
            $0.lastName.localizedStandardContains(searchLastName) || $0.firstName.localizedStandardContains(searchFirstName)
        })
        self._selection = selection
    }
    var body: some View {
        VStack(alignment: .leading) {
            
                       
                            LazyVStack {
                                ForEach(players) { player in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Button {
                                                selection = player
                                                //list.items.sort { $0.ordinal < $1.ordinal }
                                                //try? modelContext.save()
                                            } label: {
                                                HStack {
                                                    Image(systemName: "circle")
                                                    Text("\(player.lastName), \(player.firstName)")
                                                    
                                                }
                                            }
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
