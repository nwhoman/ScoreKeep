//
//  AddTeamView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/26/24.
//

import SwiftUI
import SwiftData

struct AddTeamView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var ageGroup: String = ""
    
    @State private var newTeam: Team = Team(name: "", ageGroup: "")
    @State private var showAddCoachScreen: Bool = false
    @State private var showAddPlayerScreen: Bool = false
    @State private var showCoachPlayer: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name of Team", text: $name)
                    TextField("Age Group", text: $ageGroup)
                }
                if showCoachPlayer {
                    Section {
                        Text("Coaches:")
                            .fontWeight(.bold)
                            .font(.largeTitle)
                        CoachesView(for: newTeam)
                        
                       if !showAddCoachScreen {
                           Button("Add Coach", systemImage: "plus"){
                               //showAddCoachScreen.toggle()
                               /*let newCoach = Coach(firstName: "", lastName: "", yearsCoaching: 0)
                               newTeam.coaches?.append(newCoach)
                               try? modelContext.save()
                               AddCoachView(coach: newCoach)*/
                           }
                           
                        }
                    }
                    Section {
                        Text("Players:")
                            .fontWeight(.bold)
                            .font(.largeTitle)
                        if !showAddPlayerScreen {
                            Button("Add Player", systemImage: "plus"){
                                showAddPlayerScreen.toggle()
                                //modelContext.insert(newTeam)
                                try? modelContext.save()
                            }
                        }
                        
                    }
                }
                
            }
            /*Section {
                Text("Coaches:")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                if showAddCoachScreen {
                    AddCoachView(team: $newTeam)
                }
                Button("Add Coach", systemImage: "plus"){
                    showAddCoachScreen.toggle()
                }
            }.font(.largeTitle)*/
            
                
            Spacer(minLength: 100)
                Section {
                    HStack {
                        Spacer(minLength: 20)
                        Button("Save Team"){
                            newTeam.name = name
                            newTeam.ageGroup = ageGroup
                            modelContext.insert(newTeam)
                            try? modelContext.save()
                            
                            dismiss()
                            /*if (!showCoachPlayer){
                             showCoachPlayer = true
                             newTeam.name = name
                             newTeam.ageGroup = ageGroup
                             modelContext.insert(newTeam)
                             } else {
                             try? modelContext.save()
                             dismiss()
                             }*/
                        }
                        Spacer(minLength: 20)
                        Button {
                            print("\(undoManager?.undoCount)")
                            undoManager?.undo()
                        } label: {
                            Text("Undo")
                        }
                        .disabled(!(undoManager?.canUndo ?? false))
                        Spacer(minLength: 20)
                    }
                }.navigationTitle("Add Team")
                //.sheet(isPresented: $showAddCoachScreen) {
                    //AddCoachView(team: $newTeam)
                //}
                //.sheet(isPresented: $showAddPlayerScreen) {
                    //AddPlayerView(team: $newTeam)
                //}
            }
            
            
        }    
}

#Preview {
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])

    return NavigationStack {
        AddTeamView()
            .modelContainer(preview.modelContainer)

    }
}
