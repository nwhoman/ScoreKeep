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
    @Environment(\.dismiss) var dismiss

    let team: Team
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var age: Int = 0
    @State private var number: String = ""

    var body: some View {
            Form {
                Section {
                    TextField("Player's Number:", text: $number)
                    TextField("Player's First Name:", text: $firstName)
                    TextField("Player's Last Name:", text: $lastName)
                }
                Picker("Player Age:", selection: $age){
                    ForEach(7..<20){
                        Text("\($0)")
                    }
                }
                Section {
                    Button("Save Player"){
                        //add player
                        let newPlayer = Player(firstName: firstName, lastName: lastName, age: age, number: number)
                        team.players!.append(newPlayer)
                        try? modelContext.save()
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
        AddPlayerView(team: game.homeTeam!)
            .modelContainer(preview.modelContainer)
    }
}

