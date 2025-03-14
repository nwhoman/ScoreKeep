//
//  GameLineupsView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/5/24.
//

import SwiftData
import SwiftUI

struct GameLineupsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Binding var path: NavigationPath
    let game: Game
    
    @State var homeLineup: [PlayerPos] = []
    @State var homePositions: [Player] = []
    @State var visitorLineup: [PlayerPos] = []
    //@State var visitorPositions: [Player] = []

    /*@State var i: Int = 0
    @State var selected: Player?
    @State var name: String = "NA"
    @State var positions: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]*/
    @State private var selectedTab: String = "Home"


    var body: some View {
        VStack(alignment: .leading) {
            Text(game.name)
            Text("\(game.date.formatted(date: .complete, time: .omitted))")
            Text("\(game.date.formatted(date: .omitted, time: .complete))")
            Text("At: \(game.location)")
           
            
        }
        TabView(selection: $selectedTab) {
            HomeLineupView(path: $path, team: game.homeTeam, battingLineup: game.homeLineup, game: game)
                .tabItem { Text("\(game.homeTeam!.name)") }.tag("Home")
            
            VisitorLineupView(path: $path, team: game.visitingTeam, battingLineup: game.visitorLineup, game: game)
                .tabItem { Text("\(game.visitingTeam!.name)") }.tag("Visitor")
        }
        //.navigationDestination(isPresented: $returnToList) {
            //GamesView(game: Game(name: "", date: Date(), location: ""),path: $path)
        //}
    }
}

//#Preview {
    //GameLineupsView()
//}
