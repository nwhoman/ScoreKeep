//
//  TeamsView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/26/24.
//

import SwiftUI
import SwiftData

struct TeamsView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var nav: NavigationStateManager
    @Query(sort: \Team.name) var teams: [Team]
   // @Query(sort: \Coach.lastName) var coaches: [Coach]
    //@State private var path = [Team]()
    @State private var showAddTeamScreen = false
    //@Binding var path: NavigationPath

    var body: some View {
            List {
                ForEach(teams) { team in
                    Button {
                        nav.push(.team(team: team))
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(team.name)
                                    .font(.headline)
                                Text(team.ageGroup)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
//                    NavigationLink(value: team) {
//                        HStack {
//                            VStack(alignment: .leading) {
//                                Text(team.name)
//                                    .font(.headline)
//                                Text(team.ageGroup)
//                                    .foregroundStyle(.secondary)
//                            }
//                        }
//                    }
                }
                .onDelete(perform: deleteTeam)
            }
            .navigationTitle("ScoreKeep Teams")
//            .navigationDestination(for: Team.self) {
//                team in
//                TeamDetailView(team: team)
//                //TeamDetailView(path: $path, team: team)
//            }
            .toolbar{
                
                ToolbarItem(placement: .topBarLeading){
                    EditButton().font(.system(size: 10))
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button("Add Team", systemImage: "plus"){
                        showAddTeamScreen.toggle()
                    }
                }
            }
            .sheet(isPresented: $showAddTeamScreen) {
                AddTeamView()
            }
            .onAppear {
                print(nav.path)
            }
        }
    func deleteTeam(at offsets: IndexSet){
        for offset in offsets {
            let team = teams[offset]
            modelContext.delete(team)
        }
    }
}

#Preview {
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])

    return NavigationStack {
        TeamsView()
            .modelContainer(preview.modelContainer)
            .environmentObject(NavigationStateManager())
    }
}
