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
    @Query(sort: \GameViewModel.date) private var homeViewModels: [GameViewModel]
    @Query(sort: \GameViewModel.date) private var visitorViewModels: [GameViewModel]

    @Query(sort: \Team.name) var teams: [Team]
    @State private var showDeleteAlert = false
    //@Binding var path: NavigationPath
    @State private var showEditScreen = false
    @State private var showCoachesScreen = false
    @State private var showPlayersScreen = false
    @State private var showGamesScreen = false
    @State private var showLineupView = false
    @State private var editPlayers: Bool = false
    
    @State var team: Team
    
    init(team: Team) {
        self.team = team
        let teamId = team.id
        self._homeViewModels = Query(filter: #Predicate { $0.homeTeam.id == teamId }, sort: \.date, order: .reverse)
        self._visitorViewModels = Query(filter: #Predicate { $0.visitingTeam.id == teamId }, sort: \.date, order: .reverse)

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
                ScrollView {
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
                                ForEach(team.players!.sorted(by: { Int($0.number) ?? 0 < Int($1.number) ?? 1 } ), id: \.id) { player in
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
                                nav.push(.teamPlayers(teamID: team.id))
                            }
                            Spacer()
                        }
                        .font(.system(size: 15))
                    }
                    //Spacer()
                    Section {
                        
                        TeamStatsView(geo: geo, for: team)
                            .frame(height: geo.size.height / 2)
                            //.frame(width: geo.size.width, height: geo.size.height / 2)
                    
                    } header: {
                        HStack {
                            Spacer()
                            Text("Stats")
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .font(.system(size: 15))
                    }
                    .navigationDestination(for: GameViewModel.self) { vm in
                        //GameLineupsView(game: game)
                        GameSummaryView(gameViewModel: vm, geo: geo)
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
                        ToolbarItem(placement: .bottomBar) {
                            NavigationLink {
                                TeamLineupView(team: $team, lineup: $team.lineup)
                            } label: {
                                Text("Default Lineup")
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
            }
            .frame(maxWidth: .infinity)

            .sheet(isPresented: $showEditScreen){
                EditTeamView(team: $team)
            }
            .sheet(isPresented: $showCoachesScreen){
                CoachesView(for: team)
            }
            .sheet(isPresented: $showPlayersScreen){
                PlayersView(teamId: team.id)
            }
            .sheet(isPresented: $showGamesScreen){
                TeamGamesView(teamId: team.id)
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
    let game = GameViewModel.defaultGame
    preview.addSampleGames([game])

    return NavigationStack {
        TeamDetailView(team: game.homeTeam) //
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
struct TeamGamesView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nav: NavigationStateManager
    @Query var viewModels: [GameViewModel]
    @Query(sort: \GameViewModel.date) var homeViewModels: [GameViewModel]
    @Query(sort: \GameViewModel.date) var visitorViewModels: [GameViewModel]
    @Query var team: [Team]
    
    @State private var showGamesScreen = false
    
    
    let teamId: UUID
    
    init(teamId: UUID) {
        self.teamId = teamId
        
        self._homeViewModels = Query(filter: #Predicate { $0.homeTeam.id == teamId }, sort: \.date, order: .reverse)
        self._visitorViewModels = Query(filter: #Predicate { $0.visitingTeam.id == teamId }, sort: \.date, order: .reverse)
        self._team = Query(filter: #Predicate { $0.id == teamId })
    }
    
    var body: some View {
        ScrollView {
            Text("Team Games - \(team.first?.name ?? "no team")")
            ForEach(Array([visitorViewModels, homeViewModels].enumerated()), id: \.offset) { index, vm in
                Text(index == 0 ? "Visiting Games" : "Home Games")
                ForEach(vm, id: \.self) { game in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("\(game.name) - \(game.location)")
                            Text("\(game.date.formatted(date: .complete, time: .omitted))")
                            Text("\(game.date.formatted(date: .omitted, time: .shortened))")
                        }
                        .font(.system(size: 12))
                        Text(game.isComplete ? "Completed" : "Incomplete")
                            .font(.system(size: 8))
                    }
                }
            }
        }
        .presentationDetents([.medium, .large, .fraction(0.25)])
        .padding(20)
    }
}
