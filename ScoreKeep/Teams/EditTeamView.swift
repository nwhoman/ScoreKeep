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
    
    @Bindable var team: Team
    
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
                        .font(.largeTitle)
                    List{
                        ForEach(team.coaches!) { coach in
                                HStack {
                                    Text("\(coach.firstName)")
                                        .font(.largeTitle)
                                    Text("\(coach.lastName)")
                                        .font(.largeTitle)
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
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .font(.largeTitle)
                    List{
                        ForEach(team.players!) { player in
                                HStack {
                                    Text("\(player.firstName)")
                                        .font(.largeTitle)
                                    Text("\(player.lastName)")
                                        .font(.largeTitle)
                                    Text("\(player.age)")
                                        .font(.largeTitle)
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
                    AddPlayerView(team: team)
                })
            }
            
            
        }
        
    
}

#Preview {
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])

    return NavigationStack {
        EditTeamView(team: game.homeTeam!)
            .modelContainer(preview.modelContainer)
    }
    
}
