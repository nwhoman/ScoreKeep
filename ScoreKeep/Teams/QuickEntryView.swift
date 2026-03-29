//
//  QuickEntryView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/25/26.
//

import SwiftData
import SwiftUI

struct QuickEntryView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var nav: NavigationStateManager
    @Environment(\.dismiss) var dismiss

    //@State var homeTeam: Team = Team(name: "", ageGroup: "")
    //@State var visitingTeam: Team = Team(name: "", ageGroup: "")
    @State var teamName: String = ""
    @State var coachName: String = ""

    @State var players: String = ""
    @State var numbers: String = ""
    @State var playerArray: [String] = []
    @State var numberArray: [String] = []
    @State var playerInfoArray: [Player] = []
    @State var playerInfo: [String: String] = [ "firstName": "", "lastName": "", "number": ""]
    @Binding var newTeam: Team
    
    var body: some View {
            GeometryReader { geo in
                VStack {
                    //ScrollView {
                        TextField(text: $teamName) {
                        Text("Team Name")
                            .foregroundStyle(Color.blue)
                    }
                    .autocorrectionDisabled()
                    .foregroundStyle(Color.blue)
                    .padding(10)
                    .border(Color.gray)
                    .padding(5)
                    TextField(text: $coachName) {
                        Text("Coach Name")
                            .foregroundStyle(Color.blue)
                    }
                    .autocorrectionDisabled()
                    .foregroundStyle(Color.blue)
                    .padding(10)
                    .border(Color.gray)
                    .padding(5)
                    Text("Enter player names here, one per line")
                    Text("First name last name number")
                    TextEditor(text: $players)
                        .autocorrectionDisabled()
                        .border(Color.gray)
                        .padding(5)
                        .onChange(of: players) { _, newValue in
                            playerArray = newValue.components(separatedBy: "\n")
                        }
                        .frame(width: geo.size.width, height: 200)
                    Text("Player count: \(playerArray.count) \n Must be 9 or more")
                    
                        List(playerArray, id: \.self) { line in
                            Text(line)
                        }
                        .listStyle(.plain)
                        .frame(width: geo.size.width, height: 300)
                        .border(Color.gray)
                        
                        
                    }
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) { // Places item in the bottom bar
                            HStack {
                                Spacer()
                                Button {
                                    addTeam()
                                } label: {
                                    Text("Save Team")
                                }
                                .disabled(playerArray.count < 9)
                                
                                
                            }
                        }
                    }
                }
            .navigationTitle(Text("Team Entry"))
        
    }
    func addTeam() {
        newTeam = Team(name: teamName)
        let splitLine = coachName.split(separator: " ") // split refers to the number of parts, not how many spaces
        print("splitCoach: ",splitLine.count)
        if splitLine.count == 2 {                               //first and last
            newTeam.coaches?.append(Coach(firstName: String(splitLine[0]), lastName: String(splitLine[1])))
        } else if splitLine.count == 1 {                        //Last only
            newTeam.coaches?.append(Coach(firstName: " ", lastName: String(splitLine[0])))
        }
        if playerArray.count > 8 {
            for each in playerArray {
                if !each.isEmpty {
                    var firstName = ""
                    var lastName = ""
                    var number = ""
                    let splitLine = each.split(separator: " ")
                    print("splitPlayer: ",splitLine.count)
                    if splitLine.count == 3 {                   //first, last and number
                        firstName = String(splitLine[0])
                        lastName = String(splitLine[1])
                        number = String(splitLine[2])
                    } else if splitLine.count == 2 {            //first or last and number
                        firstName = " "
                        lastName = String(splitLine[0])
                        number = String(splitLine[1])
                    } else {
                        return
                    }
                    playerInfo = ["firstName": firstName, "lastName": lastName, "number": number]
                    
                    let player = Player(firstName: firstName, lastName: lastName, number: number)
                    print("player #- ",player.number)
                    newTeam.players?.append(player)
                }
            }
        }
        modelContext.insert(newTeam)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    @Previewable @State var team = Team(name: "", ageGroup: "")
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    
    return GeometryReader { _ in
        QuickEntryView(newTeam: $team)
            .modelContainer(preview.modelContainer)
    }
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: Team.self, configurations: config)
//        
//        
//        
//        }
//        
//    }  catch {
//        return Text("Failed to create preview: \(error.localizedDescription)")
//    }
    
}
