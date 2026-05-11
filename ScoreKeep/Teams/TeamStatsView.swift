//
//  TeamStatsView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/10/26.
//

import SwiftData
import SwiftUI

struct TeamStatsView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var nav: NavigationStateManager
    @Query(sort: \Game.date, order: .reverse ) var games: [Game]
    @Query var innings: [Inning]
    var plateAppearances: [OffensivePlateAppearance]?
    @State var geo: GeometryProxy
    
    let team: Team
    
    init(geo: GeometryProxy, for team: Team,) {
        self.geo = geo
        self.team = team
        self._games = Query(filter: #Predicate { $0.homeTeam == team || $0.visitingTeam == team}, sort: \.date, order: .reverse)
        let homeInnings = #Predicate<Inning> { $0.game.homeTeam == team && $0.half == 1 }
        let visitorInnings = #Predicate<Inning> { $0.game.visitingTeam == team && $0.half == 0 }
        let filter = #Predicate<Inning> {
            homeInnings.evaluate($0) || visitorInnings.evaluate($0)
        }
        self._innings = Query(filter: filter)
        var temp: [OffensivePlateAppearance] = []
        for inning in innings {
            temp.append(contentsOf: inning.plateAppearances)
        }
        self.plateAppearances = temp
    }
    
    var body: some View {
        //GeometryReader { geo in
            VStack(alignment: .leading) {
                    Text("\(team.name) Stats")
                    
                ScrollView(.horizontal) {
                    var totalPA: [OffensivePlateAppearance] = []
                    StatLabelView(geo: geo)
                        
                    HStack {
                        VStack(alignment: .leading) {
                            
                            ForEach(team.players!, id: \.id) { player in
                                var pa: [OffensivePlateAppearance] {
                                    totalPA.append(contentsOf: player.plateAppearances ?? [])
                                    return player.plateAppearances ?? []
                                }
                                
                                StatLineView(geo: geo, player: player, plateAppearances: player.plateAppearances ?? [])
                                    
                            }
                        }
                        .font(.caption2)
                        
                    }
                    Divider()
                    StatLineView(geo: geo, plateAppearances: totalPA)
                        
                }
                
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
        //}
    }
}

#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: Game.self, configurations: config)
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])
    //container.mainContext.insert(game)
    
    return GeometryReader { geo in
        NavigationStack {
            TeamStatsView(geo: geo, for: game.homeTeam!)
               .modelContainer(preview.modelContainer)
               .environmentObject(NavigationStateManager())
       }
    }
     
    
}
