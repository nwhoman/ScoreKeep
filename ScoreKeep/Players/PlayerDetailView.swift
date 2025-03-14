//
//  PlayerDetailView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/3/24.
//

import SwiftUI
import SwiftData

struct PlayerDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @Bindable var player: Player
    
    var body: some View {
        Form {
            Section {
                HStack(content: {
                    Text("First Name:")
                    TextField("Player's First Name:", text: $player.firstName)
                })
                HStack(content: {
                    Text("Last Name:")
                    TextField("Player's Last Name:", text: $player.lastName)
                })
                HStack(content: {
                    Text("Number:")
                    TextField("Player's Number:", text: $player.number)
                })
                
}
            Picker("Player's Age:", selection: $player.age){
                ForEach(7..<20){
                    Text("\($0)")
                }
            }
            Section {
                Button("Save Player"){
                    //add coach
                    try? modelContext.save()
                    dismiss()
                }
            }
        }
        .toolbar{
            ToolbarItem(placement: .topBarLeading){
                //Button("back", systemImage: "arrowshape.turn.up.backward"){
                    //dismiss()
                //}
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Team.self, configurations: config)
        let example = Player(firstName: "example", lastName: "example", age: 5, number: "7")
        
        return PlayerDetailView(player: example)
            .modelContainer(container)
    }  catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
