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
    @Query(sort: \OffensivePlateAppearance.batter.lastName) private var plateAppearances: [OffensivePlateAppearance]
    @Bindable var player: Player
    @State private var teamName: String = ""
    @State private var team: Team?
    
    var playerPA: [OffensivePlateAppearance] {
        return plateAppearances.filter({$0.batter.id == player.id})
    }
    
    init(player: Player){
        self.player = player
        self._plateAppearances = Query(filter: #Predicate {
            $0.id == player.id
        })
    }

    var body: some View {
        GeometryReader { geo in
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
                    HStack {
                        Text("Team:")
                        Text("\(player.team?.name ?? "No Team Set")")
                    }
                    if player.team != nil {
                        Button {
                            var team = player.team!
                            team.players?.removeAll(where: { $0.id == player.id })
                        
                            try? modelContext.save()
                            
                        } label: {
                            if player.team != nil {
                                Text("Leave Team")
                            }
                        }
                    } else {
                        TextField("Search Teams", text: $teamName)
                            .padding(.leading)
                            .background(Color.gray.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                        if !teamName.isEmpty {
                            PickerView(searchString: $teamName, selection: $team, player: player)
                            
                        }
                        
                    }
                }
                Section {
                    Button("Save Player"){
                        player.team = team
                        team?.players?.append(player)
                        try? modelContext.save()
                        dismiss()
                    }
                }
                Section {
                    var stats: PlayerStats {
                        return getPlayerStats(plateAppearances: player.plateAppearances ?? [])
                    }
                    ScrollView(Axis.Set.horizontal) {
                        StatLabelView(geo: geo)
                        StatLineView(geo: geo, player: player, plateAppearances: player.plateAppearances ?? [])
                    }
                    
                }
                Section {
                    let data = displayJSON(player: player)
                    Text(data)
                }
                Section {
                    Text("Active PA")
                    ForEach(playerPA, id: \.self) { pa in
                        if pa.active {
                            Text("\(pa.batter.lastName), \(pa.batter.firstName)")
                        }
                    }
                }
                Section {
                    Text("Inactive PA")
                    ForEach(playerPA, id: \.self) { pa in
                        if !pa.active {
                            Text("\(pa.batter.lastName), \(pa.batter.firstName)")
                        }
                    }
                    Button {
                        for each in playerPA {
                            if !each.active {
                                modelContext.delete(each)
                            }
                        }
                    } label: {
                        Text("Delete PA")
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
}

#Preview {
    let preview = Preview()
    let game = GameViewModel.defaultGame
    preview.addSampleGames([game])

    return NavigationStack {
        PlayerDetailView(player: game.homeTeam.players![0])
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
