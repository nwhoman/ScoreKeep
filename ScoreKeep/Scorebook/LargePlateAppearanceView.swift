//
//  LargePlateAppearanceView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/21/25.
//

import SwiftUI

struct LargePlateAppearanceView: View {
    @Environment(\.modelContext) var modelContext
    //@ObservedObject var gameViewModel: GameViewModel
    @State var gameViewModel: GameViewModel
    var player: OffensivePlateAppearance
    //var pitcher: DefensivePlateAppearance
    @State var playerStats: PlayerStats = PlayerStats()
    @State var pitcherStats: PitcherStats = PitcherStats()
    
    @Binding var largeView: Bool
    var scale: CGFloat = 1
    
    var body: some View {

        GeometryReader { geo in
            
            VStack(alignment: .leading) {
                ZStack {
                    FieldViewScene(gameVM: gameViewModel, plateAppearance: player, scale: scale, largeView: largeView)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .padding(.top, 25)
                    
                    VStack {
                        ScoreView(gameViewModel: gameViewModel, geo: geo)
                            .padding(.trailing)
                        HStack(alignment: .top) {
                            let innings = gameViewModel.halfInning == 0 ? gameViewModel.visitorInnings : gameViewModel.homeInnings
                            let playerStats = gameViewModel.getPlayerStats(plateAppearances: gameViewModel.getPlayerPA(innings: innings, player: gameViewModel.batter!.batter))
                            let pitcherStats = gameViewModel.getPitcherStats(plateAppearances: gameViewModel.getPitcherPA(innings: innings, pitcher: gameViewModel.batter!.pitcher))
                            VStack(alignment: .leading) {
                                Text("#\(gameViewModel.batter!.batter.number) - \(gameViewModel.batter!.batter.lastName), \(gameViewModel.batter!.batter.firstName)")
                                Text("\(playerStats.hits)/\(playerStats.atBats) \(playerStats.doubles > 0 ? String(playerStats.doubles) + " 2B" : "")")
                                Text("\(playerStats.triples > 0 ? String(playerStats.triples) + " 3B" : "")")
                                Text("\(playerStats.homeRuns > 0 ? String(playerStats.homeRuns) + " HR" : "")")
                                Text("\(playerStats.runs > 0 ? String(playerStats.runs) + " runs" : "")")
                                Text("\(playerStats.rbi > 0 ? String(playerStats.rbi) + " rbi" : "")")
                                Text("\(playerStats.k > 0 ? String(playerStats.k) + " k" : "")")
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                
                                Text("#\(gameViewModel.batter!.pitcher.number) - \(gameViewModel.batter!.pitcher.lastName), \(gameViewModel.batter!.pitcher.firstName)")
                                Text("\(pitcherStats.inningsPitched, specifier: "%.2f")-\(gameViewModel.outs)/3")
                                HStack {
                                    Text("B: \(pitcherStats.balls)") //gameViewModel.pitches[gameViewModel.halfInning]?["balls"]! ?? 0)
                                    Text("S: \(pitcherStats.strikes)") //gameViewModel.pitches[gameViewModel.halfInning]?["strikes"]! ?? 0
                                }
                                Text("H: \(pitcherStats.hits)")
                                Text("R: \(pitcherStats.runs)")
                                Text("BB: \(pitcherStats.bb)")
                                Text("K: \(pitcherStats.k)")
                            }
                        }
                        .font(.caption)
                        
                        Spacer()
        
                        
                        
                        HStack {
                            if gameViewModel.batter!.rbi > 0 {
                                VStack(alignment: .center) {
                                    Text("RBI")
                                    //Text("\(player.rbi)")
                                        .padding(.leading,-0)
                                        .font(.system(size: 30).bold())
                                        
                                        .foregroundColor(Color.black)
                    
                                        .padding(.top, -10)
                                }
                                .frame(width: geo.size.width*0.4, height: geo.size.height*0.15)
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height*0.25)
                        //.border(Color.black, width: 1)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height*0.75, alignment: .topLeading)
    
                Spacer()
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                //.border(Color.black, width: 1)
                
        }
        .background(Color.white)
        .scaleEffect(scale)
        .onAppear {
            let innings = gameViewModel.halfInning == 0 ? gameViewModel.visitorInnings : gameViewModel.homeInnings
            self.playerStats = gameViewModel.getPlayerStats(plateAppearances: gameViewModel.getPlayerPA(innings: innings, player: gameViewModel.batter!.batter))
            self.pitcherStats = gameViewModel.getPitcherStats(plateAppearances: gameViewModel.getPitcherPA(innings: innings, pitcher: gameViewModel.batter!.pitcher))
        }
    }
    func getStats(player: OffensivePlateAppearance) -> PlayerStats {
        var stats = PlayerStats()
        let plateAppearances = gameViewModel.getPlayerPA(innings: gameViewModel.innings, player: player.batter)
        stats = gameViewModel.getPlayerStats(plateAppearances: plateAppearances)
        
        return stats
    }
}

//#Preview {
//    @Previewable @State var player: OffensivePlateAppearance
//    var game = Game.defaultGame
//    let preview = Preview()
//    preview.addSampleGames([game])
//    preview.addSampleLineups(game: game)
//    let gameVM = GameViewModel(game: game) 
//    gameVM.setUpGame()
//    gameVM.getBatter()
//    gameVM.getPitcher()
//    let player = OffensivePlateAppearance.defaultPlateAppearance
//    let pitcher = DefensivePlateAppearance.defaultPlateAppearance
//    //var player = game.innings[0].visitorOffense[0]
//    
//     LargePlateAppearanceView(gameViewModel: gameVM, player: $player, largeView: .constant(false))
//        .modelContainer(preview.modelContainer)
//}
