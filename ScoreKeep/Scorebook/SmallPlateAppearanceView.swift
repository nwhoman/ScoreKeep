//
//  SmallPlateAppearanceView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/15/25.
//

import SpriteKit
import SwiftUI

struct SmallPlateAppearanceView: View {
    @ObservedObject var gameViewModel: GameViewModel
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
//                    FieldViewScene(gameVM: gameViewModel, plateAppearance: player, scale: 1.0, largeView: false)
//                        .frame(width: geo.size.width*0.75, height: geo.size.height*1.25)
                    //PlateAppearanceView(scale: scale, xoffset: -150, yoffset: -70)
                        //
//                    ZStack {
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
                    default:
                        SpriteView(scene: BasePathScene(size: CGSize(width: geo.size.width*0.5, height: geo.size.height*0.5), gameVM: gameViewModel, baseOccupied: 0, plateAppearance: player,))
                                .frame(width: geo.size.width*0.75, height: geo.size.height*1.25)
                                .scaledToFill()
                                .background(.clear)
                                .ignoresSafeArea(edges: .bottom)
                    }
                    //}
                    
                    VStack {
                        Text("\(player.order) \(player.batter.number) \(player.baseOccupied)")
                            .font(.system(size: 8))
//                            .frame(width: geo.size.width, height: geo.size.height*0.2)
//                        HStack {
//                            Text("")
//                                .font(.system(size: 8))
//                                .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
//                                .padding(.horizontal, -2)
//                            Text("2B")
//                                .font(.system(size: 8))
//                                .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
//                                .padding(.horizontal, -2)
//                            Text("")
//                                .font(.system(size: 8))
//                                .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
//                                .padding(.horizontal, -2)
//                            Text("")
//                                    .font(.system(size: 8))
//                                    .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
//                                    .padding(.horizontal, -2)
//                            }
//                            .frame(width: geo.size.width, height: geo.size.height*0.2)
                        Spacer()
                        Spacer()
                        Spacer()
                        
                        HStack {
                            
                            CountView(pitches: player.pitches)
                                .frame(width: geo.size.width*0.4, height: geo.size.height*0.2)
                                
                                .scaleEffect(0.25)
                                .padding(.leading, 0)
                                .padding(.top, -15)
                            Text(player.rbi > 0 ? "\( player.rbi)" : "")                // rbi if any
                                .padding(.leading,-5)
                                .font(.system(size: 10).bold())
                                .frame(width: geo.size.width*0.175, height: geo.size.height*0.2)
                                .foregroundColor(Color.black)
                                    
                                .padding(.top, -10)
                            Text("\(player.baseOccupied)")                //Out # if batter out
                                .font(.system(size: 14).bold())
                                .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
                                .foregroundColor(Color.red)
                                    //.background(Color.black)
                                .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 1)))
                                .foregroundColor(Color.red)
                                .padding(.top, -15)
                                .padding(.leading,-5)
                        }
                        .frame(width: geo.size.width, height: geo.size.height*0.5)
                        
                    }
                    
                }
                .frame(width: 75, height: 75, alignment: .topLeading)
                
                .overlay(!player.active ? Rectangle().fill(Color.gray).opacity(0.8) : nil)

            }
        }
    }

}
#Preview {
    var game = Game.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    var gameViewModel = GameViewModel(game: game)
    gameViewModel.setUpGame()
    
    return SmallPlateAppearanceView(gameViewModel: gameViewModel, player: game.innings.first!.homeOffense.first!, scale: 0.15)
        .modelContainer(preview.modelContainer)
}

class BasePathScene: SKScene, SKPhysicsContactDelegate {
    @ObservedObject var gameVM: GameViewModel
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
    
    override func didMove(to view: SKView) {
        //scene?.backgroundColor = .clear
        var field = SKSpriteNode()
        
        field = SKSpriteNode(imageNamed: "field")
        
        
        field.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.65)
        
        field.scale(to: CGSize(width: self.frame.width, height: self.frame.height*0.5))
        addChild(field)
        
        let path = CGMutablePath()
        path.move(to: homePlate)
        if baseOccupied == 1 {
            path.addLine(to: firstBase)
            basepathNode.path = path
            basepathNode.strokeColor = .red
            basepathNode.lineWidth = 2
        } else if baseOccupied == 2 {
            path.addLine(to: firstBase)
            path.addLine(to: secondBase)
            basepathNode.path = path
            basepathNode.strokeColor = .red
            basepathNode.lineWidth = 3
        } else if baseOccupied == 3 {
            path.addLine(to: firstBase)
            path.addLine(to: secondBase)
            path.addLine(to: thirdBase)
            basepathNode.path = path
            basepathNode.strokeColor = .red
            basepathNode.lineWidth = 2
        } else if baseOccupied == 4 {
            path.addLine(to: firstBase)
            path.addLine(to: secondBase)
            path.addLine(to: thirdBase)
            path.addLine(to: homePlate)
            path.closeSubpath()
            basepathNode.fillColor = .blue
            basepathNode.path = path
            basepathNode.strokeColor = .red
            basepathNode.lineWidth = 1
        }
        
        
        
        addChild(basepathNode)
        
    }
    
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
