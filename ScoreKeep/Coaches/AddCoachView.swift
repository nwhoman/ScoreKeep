//
//  AddCoachView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/27/24.
//

import SwiftUI
import SwiftData

struct AddCoachView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    let team: Team
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var yearsCoaching: Int = 0
    
    var body: some View {
        Form {
            Section {
                TextField("Coach's First Name:", text: $firstName)
                TextField("Coach's Last Name:", text: $lastName)
            }
            Picker("Years Coaching:", selection: $yearsCoaching){
                ForEach(0..<40){
                    Text("\($0)")
                }
            }
            Section {
                Button("Save Coach"){
                    //add coach
                    let newCoach = Coach(firstName: firstName, lastName: lastName, yearsCoaching: yearsCoaching)
                    team.coaches!.append(newCoach)
                    try? modelContext.save()
                    //print("IN button")
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])
    
    return NavigationStack {
        AddCoachView(team: game.homeTeam!)
            .modelContainer(preview.modelContainer)
    }
}
