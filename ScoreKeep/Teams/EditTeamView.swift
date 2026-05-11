//
//  EditTeamView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/27/24.
//

import SwiftUI
import SwiftData

struct EditTeamView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nav: NavigationStateManager

    @Binding var team: Team
    
    @State private var name: String = ""
    @State private var ageGroup: String = ""

    @State private var showAddCoachScreen: Bool = false
    @State private var showAddPlayerScreen: Bool = false
    
    var body: some View {
        
        NavigationStack {
            Form {
                Section {
                    TextField("Name of Team", text: $team.name)
                    TextField("Age Group", text: $team.ageGroup)
                }

                Section {
                    Text("Coaches:")
                        .fontWeight(.bold)
                        .font(.title)
                    List{
                        ForEach(team.coaches!) { coach in
                            NavigationLink(destination: CoachDetailView(coach: coach)) {
                                HStack {
                                    Text("\(coach.firstName)")
                                        .font(.system(size: 14))
                                    Text("\(coach.lastName)")
                                        .font(.system(size: 14))
                                }
                            }
                        }
                    }
                    
                   if !showAddCoachScreen {
                       Button("Add Coach", systemImage: "plus"){
                           showAddCoachScreen.toggle()
                           try? modelContext.save()
                       }
                    }
                }
                Section {
                    Text("Players:")
                        .fontWeight(.bold)
                        .font(.title)
                    List{
                        ForEach(team.players!) { player in
                            NavigationLink(destination: PlayerDetailView(player: player)) {
                                HStack {
                                    Text("\(player.number) - ")
                                    Text("\(player.firstName)")
                                    Text("\(player.lastName)")
                                    //Text("\(player.age)")
                                        
                                }
                                .font(.system(size: 14))
                            }
                        }
                    }
                    if !showAddPlayerScreen {
                        Button("Add Player", systemImage: "plus"){
                            showAddPlayerScreen.toggle()
                            try? modelContext.save()
                        }
                    }
                    
                }
            }
                
            Spacer(minLength: 100)
                Section {
                    Button("Save Team"){
                        
                        try? modelContext.save()
                        dismiss()
                    }
                }.navigationTitle("Edit Team")
                .sheet(isPresented: $showAddCoachScreen) {
                    AddCoachView(team: team)
                }
                .sheet(isPresented: $showAddPlayerScreen, content: {
                    AddPlayerView(teamId: team.id)
                })
            }
            
            
        }
        
    
}

#Preview {
    @Previewable @State var team = Team(name: "", ageGroup: "")
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])

    return NavigationStack {
        EditTeamView(team: $team)
            .modelContainer(preview.modelContainer)
    }
    
}
