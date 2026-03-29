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
    @EnvironmentObject var nav: NavigationStateManager

    @Bindable var player: Player
    
    var body: some View {
        Form {
            Section {
                Text("id: \(player.id)")
                HStack(content: {
                    Text("First Name:")
                    TextField("Player's First Name:", text: $player.firstName)
                        .autocorrectionDisabled()
                })
                HStack(content: {
                    Text("Last Name:")
                    TextField("Player's Last Name:", text: $player.lastName)
                        .autocorrectionDisabled()
                })
                HStack(content: {
                    Text("Number:")
                    TextField("Player's Number:", text: $player.number)
                })
                
}
//            Picker("Player's Age:", selection: $player.age){
//                ForEach(7..<20){
//                    Text("\($0)")
//                }
//            }
            Section {
                Button("Save Player"){
                    //add coach
                    try? modelContext.save()
                    dismiss()
                }
            }
            Section {
                let data = displayJSON(player: player)
                Text(data)
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
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])

    return NavigationStack {
        PlayerDetailView(player: game.homeTeam!.players![0])
            .modelContainer(preview.modelContainer)
    }
}

func displayJSON(player: Player) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted]
    if let jsonData = try? encoder.encode(player),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
        return jsonString
    }
    return "failed to encode player"
}
