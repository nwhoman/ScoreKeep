//
//  SmallPlateAppearanceView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/15/25.
//

import SpriteKit
import SwiftUI

struct SmallPlateAppearanceView: View {
    @Environment(\.modelContext) var modelContext
//    @ObservedObject var gameViewModel: GameViewModel
    @State var gameViewModel: GameViewModel
    @State var player: OffensivePlateAppearance
    let scale: CGFloat
    
    var baseOccupied: Int {
        for i in gameViewModel.baseRunners {
            if i.batter.number == player.batter.number {
                return i.baseOccupied
            }
        }
        return 5
    }
    
    var body: some View {
        GeometryReader { geo in
            
            VStack(alignment: .leading) {
                
                ZStack {
//
                    switch player.baseOccupied {
                
                    case 1:
                        SpriteView(scene: BasePathScene(size: CGSize(width: geo.size.width*0.5, height: geo.size.height*0.5), gameVM: gameViewModel, baseOccupied: 1, plateAppearance: player,))
                            .frame(width: geo.size.width*0.75, height: geo.size.height*1.25)
                            .scaledToFill()
                            .background(.clear)
                            .ignoresSafeArea(edges: .bottom)
                    case 2:
                        SpriteView(scene: BasePathScene(size: CGSize(width: geo.size.width*0.5, height: geo.size.height*0.5), gameVM: gameViewModel, baseOccupied: 2, plateAppearance: player,))
                            .frame(width: geo.size.width*0.75, height: geo.size.height*1.25)
                            .scaledToFill()
                            .background(.clear)
                            .ignoresSafeArea(edges: .bottom)
                    case 3:
                        SpriteView(scene: BasePathScene(size: CGSize(width: geo.size.width*0.5, height: geo.size.height*0.5), gameVM: gameViewModel, baseOccupied: 3, plateAppearance: player,))
                            .frame(width: geo.size.width*0.75, height: geo.size.height*1.25)
                            .scaledToFill()
                            .background(.clear)
                            .ignoresSafeArea(edges: .bottom)
                    case 4:
                        SpriteView(scene: BasePathScene(size: CGSize(width: geo.size.width*0.5, height: geo.size.height*0.5), gameVM: gameViewModel, baseOccupied: 4, plateAppearance: player,))
                            .frame(width: geo.size.width*0.75, height: geo.size.height*1.25)
                            .scaledToFill()
                            .background(.clear)
                            .ignoresSafeArea(edges: .bottom)
                    case 5:
                        SpriteView(scene: BasePathScene(size: CGSize(width: geo.size.width*0.5, height: geo.size.height*0.5), gameVM: gameViewModel, baseOccupied: 5, plateAppearance: player,))
                            .frame(width: geo.size.width*0.75, height: geo.size.height*1.25)
                            .scaledToFill()
                            .background(.clear)
                            .ignoresSafeArea(edges: .bottom)
                    default:
                        SpriteView(scene: BasePathScene(size: CGSize(width: geo.size.width*0.5, height: geo.size.height*0.5), gameVM: gameViewModel, baseOccupied: 0, plateAppearance: player,))
                                .frame(width: geo.size.width*0.75, height: geo.size.height*1.25)
                                .scaledToFill()
                                .background(.clear)
                                .ignoresSafeArea(edges: .bottom)
                    }
                                            
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading) {
                    
                            Text("\(player.outcome["home"] ?? "")")
                                .font(.system(size: 8))
                                .frame(width: 50, height: 1)
                            Text("\(player.outcome["first"] ?? "")")
                                .font(.system(size: 8))
                                .frame(width: 50, height: 1)
                            Text("\(player.outcome["second"] ?? "")")
                                .font(.system(size: 8))
                                .frame(width: 50, height: 1)
                            Text("\(player.outcome["third"] ?? "")")
                                .font(.system(size: 8))
                                .frame(width: 50, height: 1)
                        }
                        .frame(width: 50, height: geo.size.height*0.25, alignment: .topLeading)
                        .padding(0)
                        //.border(Color.black, width: 0.5)
                        HStack {
                            
                        }
                        .frame(width: geo.size.width, height: geo.size.height*0.3)
                        .padding(0)
                        //.border(Color.black, width: 0.5)
                        HStack {
                            RbiView(rbis: player.rbi)
                                .scaleEffect(0.25)
                                .padding(.leading, -15)
                            Spacer()
                            
                        }
                        .frame(width: geo.size.width, height: geo.size.height*0.1)
                        //.border(Color.black, width: 0.5)
                        HStack(alignment: .bottom) {
                            
                            CountView(pitches: player.pitches)
                                .frame(width: geo.size.width*0.4, height: geo.size.height*0.2)
                                
                                .scaleEffect(0.25)
                                .padding(.leading, 2)
                                
                            
                            SacOutView(player: player)
                            

                            
                        }
                        .frame(width: geo.size.width, height: geo.size.height*0.1)
                        //.border(Color.black, width: 0.5)
                        Spacer()
                    }
                    
                }
                .frame(width: 75, height: 75, alignment: .topLeading)
                
                .overlay(player.outcome["home"] == "" ? Rectangle().fill(Color.gray).opacity(0.8) : nil)

            }
        }
    }
    
}
#Preview {
    var gameViewModel = GameViewModel.defaultGame
    let preview = Preview()
    preview.addSampleGames([gameViewModel])
    preview.addSampleLineups(game: gameViewModel)
    
    gameViewModel.setUpGame()
    
    var player: OffensivePlateAppearance = OffensivePlateAppearance.defaultPlateAppearance
    
    return SmallPlateAppearanceView(gameViewModel: gameViewModel, player: player, scale: 0.15)
        .modelContainer(preview.modelContainer)
}

class BasePathScene: SKScene, SKPhysicsContactDelegate {
    @Environment(\.modelContext) var modelContext
//    @ObservedObject var gameVM: GameViewModel
    @State var gameVM: GameViewModel
    var baseOccupied: Int
    var plateAppearance: OffensivePlateAppearance
    var playerNode = SKSpriteNode()
    var basepathNode = SKShapeNode()
    
    
    init(size: CGSize, gameVM: GameViewModel, baseOccupied: Int, plateAppearance: OffensivePlateAppearance) {
        // Gets the values from the view
        self.gameVM = gameVM
        self.baseOccupied = baseOccupied
        self.plateAppearance = plateAppearance
        
        super.init(size: size)
        self.backgroundColor = .white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Catch error
        fatalError()
    }
    
    var homePlate: CGPoint { CGPoint(x: self.frame.midX, y: self.frame.midY*0.92) }
    var firstBase: CGPoint { CGPoint(x: self.frame.maxX*0.83, y: self.frame.maxY*0.635) }
    var secondBase: CGPoint { CGPoint(x: self.frame.midX, y: self.frame.maxY*0.8) }
    var thirdBase: CGPoint { CGPoint(x: self.frame.maxX*0.17, y: self.frame.maxY*0.635) }
    
    var secondBase2: CGPoint { CGPoint(x: self.frame.midX + 3, y: self.frame.maxY*0.7) }
    var thirdBase2: CGPoint { CGPoint(x: self.frame.maxX*0.17 + 3, y: self.frame.maxY*0.635 - 3) }
    var homePlate2: CGPoint { CGPoint(x: self.frame.midX - 3, y: self.frame.midY*0.75) }

    override func didMove(to view: SKView) {
        
        placeField(scene: self)
        
        placeBaseRunners(basepathNode: self.basepathNode, baseOccupied: baseOccupied, plateAppearance: plateAppearance, scene: self)
//
          
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.11, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "1B", hidden: plateAppearance.hit == 1 ? false : true, color: .black, scene: self)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.11, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "2B", hidden: plateAppearance.hit == 2 ? false : true, color: .black, scene: self)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.11, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "3B", hidden: plateAppearance.hit == 3 ? false : true, color: .black, scene: self)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.11, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "HR", hidden: plateAppearance.hit == 4 ? false : true, color: .black, scene: self)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.11, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "E", hidden: true, color: .red, scene: self)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.8, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "HBP", hidden: plateAppearance.outcome["home"] != "HBP", color: .blue, scene: self)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.8, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "BB", hidden: plateAppearance.bb != 1, color: .blue, scene: self)
    
        addHitLoc(plateAppearance: plateAppearance, scene: self)
    }
//    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self))
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))
            
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
    
    
}
