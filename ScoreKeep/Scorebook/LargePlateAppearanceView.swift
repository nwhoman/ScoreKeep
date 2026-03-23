//
//  LargePlateAppearanceView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/21/25.
//

import SwiftUI

struct LargePlateAppearanceView: View {
    @Environment(\.modelContext) var modelContext
    @ObservedObject var gameViewModel: GameViewModel
    var player: OffensivePlateAppearance
    var pitcher: DefensivePlateAppearance
    @Binding var largeView: Bool
    var scale: CGFloat = 1
    //@State var firstBase: OffensivePlateAppearance?
    //@State var secondBase: OffensivePlateAppearance?
    //@State var thirdBase: OffensivePlateAppearance?
    //@State var count = ["balls": 0, "strikes": 0]
    let pitches: [Pitch] = [.ball, .ball, .ball, .strikeSwinging, .foul, .strikeLooking, .ball, .ball]
    
//    var baserunners:[OffensivePlateAppearance?] {
//        return [player, firstBase, secondBase, thirdBase]
//    }
    var body: some View {
        var stats = getStats(player: gameViewModel.batter!)
        var dstats = getPitcherStats(player: gameViewModel.pitcher!)
        GeometryReader { geo in
            
            VStack(alignment: .leading) {
                ZStack {
                    FieldViewScene(gameVM: gameViewModel, plateAppearance: player, batterFaced: pitcher, scale: scale, largeView: largeView)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .padding(.top, 25)
                    
                    VStack {
                        ScoreView(gameViewModel: gameViewModel)
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("#\(gameViewModel.batter!.batter.number) - \(gameViewModel.batter!.batter.lastName), \(gameViewModel.batter!.batter.firstName)")
                                Text("\(stats.hits)/\(stats.atBats) \(stats.doubles > 0 ? String(stats.doubles) + " 2B" : "")")
                                Text("\(stats.triples > 0 ? String(stats.triples) + " 3B" : "")")
                                Text("\(stats.homeRuns > 0 ? String(stats.homeRuns) + " HR" : "")")
                                Text("\(stats.runs > 0 ? String(stats.runs) + " runs" : "")")
                                Text("\(stats.rbi > 0 ? String(stats.rbi) + " rbi" : "")")
                                Text("\(stats.k > 0 ? String(stats.k) + " k" : "")")
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("#\(gameViewModel.pitcher!.pitcher.number) - \(gameViewModel.pitcher!.pitcher.lastName), \(gameViewModel.pitcher!.pitcher.firstName)")
                                Text("\(dstats.inningsPitched) \(dstats.balls + dstats.strikes)")
                                Text("\(dstats.hits) \(dstats.runs) \(dstats.bb) \(dstats.k)")
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
    }
    func getStats(player: OffensivePlateAppearance) -> PlayerStats {
        var stats = PlayerStats()
        let plateAppearances = gameViewModel.getPlayerPA(innings: gameViewModel.game.innings, player: player.batter)
        stats = gameViewModel.getPlayerStats(plateAppearances: plateAppearances)
        
        return stats
    }
    
    func getPitcherStats(player: DefensivePlateAppearance) -> PitcherStats {
        var stats = PitcherStats()
        let plateAppearances = gameViewModel.getPitcherPA(innings: gameViewModel.game.innings, pitcher: player.pitcher)
        stats = gameViewModel.getPitcherStats(plateAppearances: plateAppearances)
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
