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
    
    @State private var showDeleteAlert = false
    //@Binding var path: NavigationPath
    @State private var showEditScreen = false
    @State private var showCoachesScreen = false
    @State private var showPlayersScreen = false

    let team: Team
    
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack(alignment: .center) {
                    Spacer()
                    Text("\(team.name.uppercased()) - \(team.ageGroup)")
                        .fontWeight(.black)
                        .padding(15)
                        .foregroundStyle(.white)
                        .background(.black.opacity(0.75))
                        .clipShape(.capsule)
                    Spacer()
                }
                Spacer(minLength: 30)
                Section {
                    if team.coaches!.isEmpty {
                        Text("no coaches").font(.system(size: 20))
                    } else {
                        List {
                            ForEach(team.coaches!, id: \.firstName) { coach in
                                NavigationLink(value: coach){
                                    HStack {
                                        Text("\(coach.firstName)")
                                            .font(.system(size: 14))
                                        Text("\(coach.lastName)")
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                        }
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
                            .font(.system(size: 20))
                        Spacer()
                        Button("Edit Coaches"){
                            showCoachesScreen.toggle()
                        }
                        Spacer()
                    }
                }
                .padding(5)
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
                                            .font(.system(size: 14))
                                        
//                                        Text("\(player.age + 7)")
//                                            .font(.system(size: 14))
                                    }
                                }
                            }
                        }
                        .frame(width: geo.size.width)
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
                            .font(.system(size: 20))
                        Spacer()
                        Button("Edit Players"){
                            showPlayersScreen.toggle()
                        }
                        Spacer()
                    }
                }
                Section {
                    HStack {
                        VStack {
                            HStack {
                                Spacer()
                                Text("Home Games")
                                    .fontWeight(.bold)
                                    .font(.system(size: 20))
                                Spacer()
                            }
                            if ((team.homeGames?.isEmpty) == nil) {
                                Text("no home games").font(.system(size: 20))
                            } else {
                                List {
                                    ForEach(team.homeGames!, id: \.self) { game in
                                        NavigationLink(value: game) {
                                            VStack(alignment: .leading) {
                                                Text("\(game.name) - \(game.location)")
                                                Text("\(game.date.formatted(date: .complete, time: .omitted))")
                                                Text("\(game.date.formatted(date: .omitted, time: .shortened))")
                                            }
                                            .font(.system(size: 8))
                                        }
                                    }
                                }
                            }
                        }
                        VStack {
                            HStack {
                                Spacer()
                                Text("Away Games")
                                    .fontWeight(.bold)
                                    .font(.system(size: 20))
                                Spacer()
                            }
                            if ((team.visitingGames?.isEmpty) == nil) {
                                Text("no away games").font(.system(size: 20))
                            } else {
                                List {
                                    ForEach(team.visitingGames!, id: \.self) { game in
                                        NavigationLink(value: game) {
                                            VStack(alignment: .leading) {
                                                Text("\(game.name) - \(game.location)")
                                                Text("\(game.date.formatted(date: .complete, time: .omitted))")
                                                Text("\(game.date.formatted(date: .omitted, time: .shortened))")
                                            }
                                            .font(.system(size: 8))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .navigationDestination(for: Game.self) { game in
                        //GameLineupsView(game: game)
                    }
                }
                Spacer(minLength: 30)
                Button("Edit"){
                    showEditScreen.toggle()
                }
                .padding(10)
                .foregroundStyle(.blue)
                .clipShape(.capsule)
                .shadow(radius: 5)
                .navigationTitle(team.name)
                .navigationBarTitleDisplayMode(.inline)
                .scrollBounceBehavior(.basedOnSize)
                .alert("Delete Team", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive, action: {})
                    Button("Cancel", role: .cancel){}
                } message: {
                    Text("Are you sure?")
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing){
                        Button("Delete this team", systemImage: "trash") {
                            showDeleteAlert = true
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
        }
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
