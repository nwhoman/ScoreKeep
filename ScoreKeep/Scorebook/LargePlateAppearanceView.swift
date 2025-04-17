//
//  LargePlateAppearanceView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/21/25.
//

import SwiftUI

struct LargePlateAppearanceView: View {
    @ObservedObject var gameViewModel: GameViewModel
    var player: OffensivePlateAppearance
    //@Binding var outs: Int
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
        GeometryReader { geo in
            
            VStack(alignment: .leading) {
//                    HStack {
//                        Text("1B")
//                            .font(.system(size: 28))
//                            .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
//                            .padding(.horizontal, -2)
//                        Text("2B")
//                            .font(.system(size: 28))
//                            .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
//                            .padding(.horizontal, -2)
//                        Text("3B")
//                            .font(.system(size: 28))
//                            .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
//                            .padding(.horizontal, -2)
//                        Text("HR")
//                            .font(.system(size: 28))
//                            .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
//                            .padding(.horizontal, -2)
//                    }
//                    .frame(width: geo.size.width, height: geo.size.height*0.1)
                    
                    ZStack {
                        FieldViewScene(gameVM: gameViewModel, plateAppearance: player, scale: scale, largeView: true)
                        //PlateAppearanceView(scale: 1.0, xoffset: 0, yoffset: 0)
                            .frame(width: geo.size.width, height: geo.size.height)
                        
                        VStack {
                            HStack {
                                ScoreView(gameViewModel: gameViewModel)
                            }
                            Spacer()
                            
                            Text("\(gameViewModel.batter!.batter.firstName) \(gameViewModel.batter!.batter.lastName)")
                            HStack {
                                if gameViewModel.batter!.rbi > 0 {
                                    VStack(alignment: .center) {
                                        Text("RBI")
                                        Text("2")
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
}

#Preview {
    var game = Game.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    let gameVM = GameViewModel(game: game) 
    gameVM.setUpGame()
    gameVM.getBatter()
    gameVM.getPitcher()
    //var player = game.innings[0].visitorOffense[0]
    
    return LargePlateAppearanceView(gameViewModel: gameVM, player: gameVM.batter!)
        .modelContainer(preview.modelContainer)
}
