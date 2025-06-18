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
            if i.player.batter.number == player.batter.number {
                return i.player.baseOccupied
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
                        
                    //}
                    
                    VStack {
                        Text("\(player.outcome)")
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
                            
                        }
                        
                        HStack {
                            
                            CountView(pitches: player.pitches)
                                .frame(width: geo.size.width*0.4, height: geo.size.height*0.2)
                                
                                .scaleEffect(0.25)
                                .padding(.leading, 0)
                                .padding(.top, -15)
                            Text(player.rbi > 0 ? "\( player.rbi)" : "")       // rbi if any
                                .padding(.leading,-5)
                                .font(.system(size: 10).bold())
                                .frame(width: geo.size.width*0.175, height: geo.size.height*0.2)
                                .foregroundColor(Color.black)
                                    
                                .padding(.top, -10)
                            if player.outs > 0 {
                                Text("\(player.outs)")                //Out # if batter out
                                    .font(.system(size: 14).bold())
                                    .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
                                    .foregroundColor(Color.red)
                                        //.background(Color.black)
                                    .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 1)))
                                    .foregroundColor(Color.red)
                                    .padding(.top, -15)
                                    .padding(.leading,-5)
                            }
                            
                        }
                        .frame(width: geo.size.width, height: geo.size.height*0.5)
                        
                    }
                    
                }
                .frame(width: 75, height: 75, alignment: .topLeading)
                
                .overlay(player.outcome.isEmpty ? Rectangle().fill(Color.gray).opacity(0.8) : nil)

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
        if baseOccupied == 1 || (plateAppearance.hit == 1 && plateAppearance.outs != 0) {
            path.addLine(to: firstBase)
            basepathNode.path = path
            basepathNode.strokeColor = .blue
            basepathNode.lineWidth = 3
            //addHitLoc()
        } else if baseOccupied == 2 || (plateAppearance.hit == 2 && plateAppearance.outs != 0) {
            path.addLine(to: firstBase)
            path.addLine(to: secondBase)
            basepathNode.path = path
            basepathNode.strokeColor = .blue
            basepathNode.lineWidth = 3
            //addHitLoc()
        } else if baseOccupied == 3 || (plateAppearance.hit == 3 && plateAppearance.outs != 0) {
            path.addLine(to: firstBase)
            path.addLine(to: secondBase)
            path.addLine(to: thirdBase)
            basepathNode.path = path
            basepathNode.strokeColor = .blue
            basepathNode.lineWidth = 3
            //addHitLoc()
        } else if baseOccupied == 4 {
            path.addLine(to: firstBase)
            path.addLine(to: secondBase)
            path.addLine(to: thirdBase)
            path.addLine(to: homePlate)
            path.closeSubpath()
            basepathNode.fillColor = .blue
            basepathNode.path = path
            basepathNode.strokeColor = .blue
            basepathNode.lineWidth = 3
            //addHitLoc()
        } else if baseOccupied == 5 {
            // show play result
            let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
            labelNode.text = "K"
            labelNode.name = "K"
            labelNode.fontSize = 20
            labelNode.fontColor = plateAppearance.outcome == "KS" ? .black : .red
            labelNode.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.5)
            labelNode.setScale(0.5)
            labelNode.isHidden = plateAppearance.outcome == "KS" || plateAppearance.outcome == "KL" ? false : true
            
            labelNode.xScale = plateAppearance.outcome == "KS" ? 1 : -1
            
            addChild(labelNode)
            if plateAppearance.outcome.starts(with: "F") {
                addOutcomeNode(center: CGPoint(x: self.frame.midX, y: self.frame.maxY*0.5), size: 10, name: plateAppearance.outcome, hidden: false, color: .red)
            }
            if plateAppearance.outcome.starts(with: "G") {
                let outcome = plateAppearance.outcome.replacingOccurrences(of: "G", with: "")
                addOutcomeNode(center: CGPoint(x: self.frame.midX, y: self.frame.maxY*0.5), size: 10, name: outcome, hidden: false, color: .red)
            }
        }
        addChild(basepathNode)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.11, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "1B", hidden: plateAppearance.hit == 1 ? false : true, color: .black)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.11, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "2B", hidden: plateAppearance.hit == 2 ? false : true, color: .black)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.11, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "3B", hidden: plateAppearance.hit == 3 ? false : true, color: .black)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.11, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "HR", hidden: plateAppearance.hit == 4 ? false : true, color: .black)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.11, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "E", hidden: true, color: .red)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.8, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "HBP", hidden: plateAppearance.outcome != "HBP", color: .blue)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.8, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "BB", hidden: plateAppearance.outcome != "BB", color: .blue)
        addGenericNode(center: CGPoint(x: self.frame.maxX*0.8, y: self.frame.maxY*0.37), size: self.frame.maxX*0.1, name: "SAC", hidden: plateAppearance.outcome != "SAC", color: .blue)
        addHitLoc()
    }
    func addHitLoc() {
        let path = CGMutablePath()
        path.move(to: homePlate)
        path.addLine(to: CGPoint(x: self.frame.maxX*(plateAppearance.hitLoc.x) , y: 13.0*(plateAppearance.hitLoc.y)+homePlate.y + 5.0)) //self.frame.maxY*(plateAppearance.hitLoc.y)+homePlate.y))
        print("hitLoc: \(plateAppearance.batter.number) \(CGPoint(x: self.frame.maxX*(plateAppearance.hitLoc.x) , y: self.frame.maxY*(plateAppearance.hitLoc.y)+homePlate.y))")
        let node = SKShapeNode(path: path)
        node.strokeColor = .red
        node.lineWidth = 2
        
        //node.xScale = 0.5
        //node.yScale = 0.5
        if plateAppearance.hitLoc.y != 0 {
            addChild(node)
        }
        
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
    func addGenericNode(center: CGPoint, size: CGFloat, name: String, hidden: Bool, color: UIColor) {
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: center.x+size/2, y: center.y+size/2))
        path.addLine(to: CGPoint(x: center.x-size/2, y: center.y+size/2))
        path.addArc(center: CGPoint(x: center.x-size/2, y: center.y), radius: size/2, startAngle: .pi/2, endAngle: CGFloat.pi*3/2, clockwise: false)
        path.addLine(to: CGPoint(x: center.x+size/2, y: center.y-size/2))
        path.addArc(center: CGPoint(x: center.x+size/2, y: center.y), radius: size/2, startAngle: .pi*3/2, endAngle: CGFloat.pi/2, clockwise: false)
        
        let node = SKShapeNode(path: path)
        node.fillColor = .gray
        node.strokeColor = .black
        node.lineWidth = 1
        node.name = name
        node.isHidden = hidden
        //addChild(node)
        let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
        labelNode.text = name
        labelNode.name = name
        labelNode.fontSize = 6
        labelNode.fontColor = color
        labelNode.position = CGPoint(x: center.x, y: center.y-size/4)
        labelNode.isHidden = hidden
        addChild(labelNode)
    }
    func addOutcomeNode(center: CGPoint, size: CGFloat, name: String, hidden: Bool, color: UIColor) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: center.x+size/2, y: center.y+size/2))
        path.addLine(to: CGPoint(x: center.x-size/2, y: center.y+size/2))
        path.addArc(center: CGPoint(x: center.x-size/2, y: center.y), radius: size/2, startAngle: .pi/2, endAngle: CGFloat.pi*3/2, clockwise: false)
        path.addLine(to: CGPoint(x: center.x+size/2, y: center.y-size/2))
        path.addArc(center: CGPoint(x: center.x+size/2, y: center.y), radius: size/2, startAngle: .pi*3/2, endAngle: CGFloat.pi/2, clockwise: false)
        
        let node = SKShapeNode(path: path)
        node.fillColor = .gray
        node.strokeColor = .black
        node.lineWidth = 1
        node.name = name
        node.isHidden = hidden
        //addChild(node)
        let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
        labelNode.text = name
        labelNode.name = name
        labelNode.fontSize = 12
        labelNode.fontColor = color
        labelNode.position = CGPoint(x: center.x, y: center.y)
        labelNode.isHidden = hidden
        addChild(labelNode)
    }
}
