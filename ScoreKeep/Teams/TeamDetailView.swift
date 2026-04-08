//
//  TeamDetailView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/26/24.
//

import SwiftUI
import SwiftData

struct TeamDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nav: NavigationStateManager
    @Query(sort: \GameViewModel.id) private var viewModels: [GameViewModel]
    
    @State private var showDeleteAlert = false
    //@Binding var path: NavigationPath
    @State private var showEditScreen = false
    @State private var showCoachesScreen = false
    @State private var showPlayersScreen = false
    @State private var showGamesScreen = false
    
    let team: Team
    var completeGames: [Game] {
        (team.homeGames?.filter { game in
            game.isComplete
        })! + (team.visitingGames?.filter { game in
            game.isComplete
        })!
    }
    var teamViewModels: [GameViewModel] {
        return viewModels.filter { completeGames.contains( $0.game)}
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack(alignment: .center) {
                    Spacer()
                    Text(team.ageGroup != "" ? "\(team.name.uppercased()) - \(team.ageGroup)" : "\(team.name.uppercased())")
                        .fontWeight(.black)
                        .padding(15)
                        .foregroundStyle(.white)
                        .background(.black.opacity(0.75))
                        .clipShape(.capsule)
                    Spacer()
                }
                Spacer(minLength: 10)
                Section {
                    if team.coaches!.isEmpty {
                        Text("no coaches").font(.system(size: 20))
                    } else {
                        List {
                            ForEach(team.coaches!, id: \.firstName) { coach in
                                NavigationLink(value: coach){
                                    HStack {
                                        Text("\(coach.firstName)")
                                        Text("\(coach.lastName)")
                                    }
                                    .font(.system(size: 13))
                                }
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height / CGFloat(10/team.coaches!.count))
                        .listStyle(.plain)
                        .navigationDestination(for: Coach.self) {
                            coach in
                            CoachDetailView(coach: coach)
                        }
                    }
                } header: {
                    HStack {
                        Spacer()
                        Text("Coaches")
                            .fontWeight(.bold)
                        Spacer()
                        Button("Edit Coaches"){
                            showCoachesScreen.toggle()
                        }
                        Spacer()
                    }
                }
                .padding(5)
                .font(.system(size: 15))
                Spacer()
                Section {
                    if team.players!.isEmpty {
                        Text("no players").font(.system(size: 20))
                    } else {
                        List {
                            ForEach(team.players!.sorted(by: { $0.number < $1.number } ), id: \.id) { player in
                                NavigationLink(value: player) {
                                    HStack {
                                        Text("# \(player.number) - \(player.firstName) \(player.lastName)")
                                    }
                                }
                            }
                        }
                        .font(.system(size: 13))
                        .listStyle(.plain)
                        .frame(width: geo.size.width, height: geo.size.height / 1.65)
                        .navigationDestination(for: Player.self) {
                            player in
                            PlayerDetailView(player: player)
                        }
                    }
                } header: {
                    HStack {
                        Spacer()
                        Text("Players")
                            .fontWeight(.bold)
                        Spacer()
                        Button("Edit Players"){
                            showPlayersScreen.toggle()
                        }
                        Spacer()
                    }
                    .font(.system(size: 15))
                }
                
                Section {
                    HStack {
                        VStack {
                            HStack {
                                Spacer()
                                
                                Spacer()
                            }
                            
                        }

                    }
                    .navigationDestination(for: GameViewModel.self) { vm in
                        //GameLineupsView(game: game)
                        GameSummaryView(gameViewModel: vm, game: vm.game)
                    }
                }
                .alert("Delete Team", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive, action: {deleteTeam(team: team)})
                    Button("Cancel", role: .cancel){}
                } message: {
                    Text("Are you sure?")
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            showGamesScreen.toggle()
                        } label: {
                            Text("View Games")
                                .fontWeight(.bold)
                                .font(.system(size: 15))
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing){
                        Button {
                            showEditScreen.toggle()
                        } label: {
                            Image(systemName: "pencil")
                                .fontWeight(.bold)
                                .font(.system(size: 12))
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing){
                        Button {
                            showDeleteAlert.toggle()
                        } label: {
                            Image(systemName: "trash")
                                .fontWeight(.bold)
                                .font(.system(size: 12))
                        }
                    }
                }
                
                
            }
            
            .sheet(isPresented: $showEditScreen){
                EditTeamView(team: team)
            }
            .sheet(isPresented: $showCoachesScreen){
                CoachesView(for: team)
            }
            .sheet(isPresented: $showPlayersScreen){
                PlayersView(for: team)
            }
            .sheet(isPresented: $showGamesScreen){
                ScrollView {
                    List {
                        ForEach(teamViewModels, id: \.self) { vm in
                            NavigationLink(value: vm) {
                                VStack(alignment: .leading) {
                                    Text("\(vm.game.name) - \(vm.game.location)")
                                    Text("\(vm.game.date.formatted(date: .complete, time: .omitted))")
                                    Text("\(vm.game.date.formatted(date: .omitted, time: .shortened))")
                                }
                                .font(.system(size: 8))
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large, .fraction(0.25)])
                .padding(20)
            }
        }
    }
    func deleteTeam(team: Team) {
        modelContext.delete(team)
        nav.path.removeLast()
    }
}


#Preview {
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])

    return NavigationStack {
        TeamDetailView(team: game.homeTeam!)
            .modelContainer(preview.modelContainer)
    }
}

func displayJSON(team: Team) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted]
    if let jsonData = try? encoder.encode(team),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
        return jsonString
    }
    return "failed to encode team"
}
//if ((team.homeGames?.isEmpty) == nil) {
//    Text("no games").font(.system(size: 20))
//} else {
    
//}
