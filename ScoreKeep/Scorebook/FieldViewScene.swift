//
//  FieldView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/1/25.
//

import Foundation
import SpriteKit
import SwiftUI

struct FieldViewScene: View {
    @ObservedObject var gameVM: GameViewModel
    var plateAppearance: OffensivePlateAppearance
    let scale: CGFloat
    let largeView: Bool
//    var scene: FieldScene {
//        
//        let scene = FieldScene(size: CGSize(width: 1000, height: 2000), gameVM: gameVM)
//        
//        scene.scaleMode = .aspectFill
//        return scene
//    }
    
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    
                    SpriteView(scene: FieldScene(size: CGSize(width: geo.size.width, height: geo.size.height), gameVM: gameVM, plateAppearance: plateAppearance, largeView: largeView))
                        .frame(width: geo.size.width, height: geo.size.height)
                        .scaledToFill()
                        .background(.white)
                        .ignoresSafeArea(edges: .bottom)
                    
                    
                }
                .scaleEffect(scale)
                
            }
        }
    }
}
func drawFieldPath(xoffset: CGFloat, yoffset: CGFloat) -> CGMutablePath {
    
    let path = CGMutablePath()
        path.move(to: CGPoint(x: xoffset, y: 350+yoffset))
        path.addLine(to: CGPoint(x: 200+xoffset, y: 550+yoffset))
        path.addQuadCurve(to: CGPoint(x: -200+xoffset, y: 550+yoffset), control: CGPoint(x: xoffset, y: 750+yoffset))
    
        path.addLine(to: CGPoint(x: xoffset, y: 350+yoffset))
    
    return path
}
func drawFieldShape(from path: CGPath) -> SKShapeNode {
    let shapeNode = SKShapeNode(path: path)
    shapeNode.strokeColor = .red
    shapeNode.lineWidth = 5
    
    return shapeNode
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
    
    return FieldViewScene(gameVM: gameVM, plateAppearance: gameVM.batter!, scale: 1.0, largeView: true)
}

class FieldScene: SKScene, SKPhysicsContactDelegate {
    @ObservedObject var gameVM: GameViewModel
    var plateAppearance: OffensivePlateAppearance
    var playerNode = SKSpriteNode()
    var shapeNode = SKShapeNode()
    
    var largeView: Bool
    
    init(size: CGSize, gameVM: GameViewModel, plateAppearance: OffensivePlateAppearance, largeView: Bool) {
        // Gets the values from the view
        self.gameVM = gameVM
        self.plateAppearance = plateAppearance
        self.largeView = largeView
        super.init(size: size)
        self.backgroundColor = .white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Catch error
        fatalError()
    }
    var homePlate: CGPoint { CGPoint(x: self.frame.midX, y: self.frame.maxY*0.65-150) }
    var firstBase: CGPoint { CGPoint(x: self.frame.maxX-75, y: self.frame.maxY*0.65-20) }
    var secondBase: CGPoint { CGPoint(x: self.frame.midX, y: self.frame.maxY*0.65+100) }
    var thirdBase: CGPoint { CGPoint(x: self.frame.minX+75, y: self.frame.maxY*0.65-20) }

    override func didMove(to view: SKView) {
        //scene?.backgroundColor = .clear
        
        
        let field = SKSpriteNode(imageNamed: "field")
        field.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.65)
        
        field.scale(to: CGSize(width: self.frame.width, height: self.frame.height*0.5))
        addChild(field)
        setUpScene()
        resetCount()
    }
    
    
    
    func addGenericNode(center: CGPoint, size: CGFloat, name: String, hidden: Bool) {
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: center.x+size/2, y: center.y+50/2))
        path.addLine(to: CGPoint(x: center.x-size/2, y: center.y+50/2))
        path.addArc(center: CGPoint(x: center.x-size/2, y: center.y), radius: 50/2, startAngle: .pi/2, endAngle: CGFloat.pi*3/2, clockwise: false)
        path.addLine(to: CGPoint(x: center.x+size/2, y: center.y-50/2))
        path.addArc(center: CGPoint(x: center.x+size/2, y: center.y), radius: 50/2, startAngle: .pi*3/2, endAngle: CGFloat.pi/2, clockwise: false)
        
        let node = SKShapeNode(path: path)
        node.fillColor = .gray
        node.strokeColor = .black
        node.lineWidth = 1
        node.name = name
        node.isHidden = hidden
        addChild(node)
        let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
        labelNode.text = name
        labelNode.name = name
        labelNode.fontSize = 30
        labelNode.fontColor = .black
        labelNode.position = CGPoint(x: center.x, y: center.y-50/4)
        labelNode.isHidden = hidden
        addChild(labelNode)
    }
    func addKLabel() {
        let path = CGMutablePath()
        
        path.addArc(center: CGPoint(x: self.frame.width/2, y: self.frame.maxY*0.65), radius: 80, startAngle: 0, endAngle: .pi*2, clockwise: false)
        path.closeSubpath()
        
        let node = SKShapeNode(path: path)
        node.fillColor = .white
        node.strokeColor = .black
        node.lineWidth = 1
        node.name = "K"
        node.isHidden = true
        addChild(node)
        var labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
        labelNode.text = "K"
        labelNode.name = "KS"
        labelNode.fontSize = 70
        labelNode.fontColor = .black
        labelNode.position = CGPoint(x: self.frame.width/2, y: self.frame.maxY*0.65 - 20)
        labelNode.isHidden = true
        addChild(labelNode)
        labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
        labelNode.text = "K"
        labelNode.name = "KL"
        labelNode.fontSize = 70
        labelNode.fontColor = .red
        labelNode.position = CGPoint(x: self.frame.width/2, y: self.frame.maxY*0.65 - 20)
        labelNode.isHidden = true
        addChild(labelNode)
    }
    func addBall() {
        gameVM.pitches.append(.ball)
        
        gameVM.batter!.pitches.append(.ball)
        gameVM.balls += 1
        if gameVM.balls == 4 {
            var node = enumerateChildNodes(withName: gameVM.batter!.batter.number) {
            node, stop in
                self.moveNode(node: node)
            }
            gameVM.balls = 0
        }
        let index = gameVM.batter!.pitches.filter({$0 == .ball}).count
        let path = CGMutablePath()
        //path.move(to: CGPoint(x: self.frame.width*0.05, y: self.frame.height*0.15))
        path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(index)), y: self.frame.height*0.165), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
        path.closeSubpath()
        //let ballNode = SKSpriteNode(imageNamed: "blue-sphere")
        let node = SKShapeNode(path: path)
        node.fillColor = .blue
        node.strokeColor = .black
        node.lineWidth = 1
        node.name = "pitched-ball"
        node.isHidden = false
        
        addChild(node)
        //plateAppearance.baseOccupied += 1
    }
    func addStrike(pos: Int) {
        var swing: Bool = false
        let index = gameVM.batter!.pitches.filter({$0 == .strikeLooking || $0 == .strikeSwinging || $0 == .foul}).count + 1
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(index)), y: self.frame.height*0.215), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.lineWidth = 1
        
        node.isHidden = false
        node.name = "pitched-strike"
        switch pos {
        case 1: //looking
            node.strokeColor = .black
            node.fillColor = .red
            gameVM.strikes += 1
            gameVM.pitches.append(.strikeLooking)
            gameVM.batter!.pitches.append(.strikeLooking)
            swing = false
        
        case 2: //swinging
            node.strokeColor = .black
            node.fillColor = .black
            gameVM.strikes += 1
            gameVM.pitches.append(.strikeSwinging)
            gameVM.batter!.pitches.append(.strikeSwinging)
            swing = true
        default: //foul
            node.strokeColor = .black
            node.fillColor = .yellow
            if gameVM.strikes < 2 {
                gameVM.strikes += 1
            }
            gameVM.pitches.append(.foul)
            gameVM.batter!.pitches.append(.foul)
        }
        addChild(node)
        if gameVM.strikes == 3 {
            
            gameVM.outs += 1
            gameVM.batter!.outs = gameVM.outs
            gameVM.balls = 0
            gameVM.strikes = 0
            addOut()
            
            scene!.enumerateChildNodes(withName: "K") {
                    node, stop in
                node.isHidden = false
            }
            if swing {
                scene!.enumerateChildNodes(withName: "KS") {
                        node, stop in
                    node.isHidden = false
                }
            } else {
                scene!.enumerateChildNodes(withName: "KL") {
                    node, stop in
                    node.isHidden = false
                }
            }
        }
    }
    
    func addOut() {
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(gameVM.outs)), y: self.frame.height*0.115), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.lineWidth = 1
        node.strokeColor = .black
        node.fillColor = .green
        node.isHidden = false
        addChild(node)
        
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
            let touchedNode = self.atPoint(t.location(in: self))
            
            if (touchedNode.name == "\(gameVM.batter!.batter.number)"){
                moveNode(node: touchedNode)
            }
            if touchedNode.name == "Pitch" {
                makePitch()
            }
            if touchedNode.name == "Ball" {
                //touchedNode.isHidden = true
                makePitch()
                addBall()
                
            }
            if touchedNode.name == "Strike" {
                selectStrike()
            }
            if touchedNode.name == "Looking" {
                resetPitch()
                addStrike(pos: 1)
            }
            if touchedNode.name == "Swinging" {
                resetPitch()
                addStrike(pos: 2)
            }
            if touchedNode.name == "Foul" {
                resetPitch()
                addStrike(pos: 3)
            }
            if touchedNode.name == "In-Play" {
                getInPlay()
            }
            if touchedNode.name == "Hit" {
                getBaseHit()
            }
            if touchedNode.name == "1B" || touchedNode.name == "2B" || touchedNode.name == "3B" || touchedNode.name == "HR" {
                getHitType(node: touchedNode)
            }
            if touchedNode.name == "FO" {
                getHitType(node: touchedNode)
            }
            if touchedNode.name == "pitched-strike" || touchedNode.name == "pitched-ball" {
                print("b: \(gameVM.balls) s: \(gameVM.strikes)")
                gameVM.batter!.pitches.popLast()
                let pitch = gameVM.pitches.popLast()
                if pitch == .ball {
                    gameVM.balls -= 1
                } else if pitch != .foul {
                    gameVM.strikes -= 1
                } else {
                    if gameVM.strikes != 2 {
                        gameVM.strikes -= 1
                    }
                }
                resetCount()
                print("b: \(gameVM.balls) s: \(gameVM.strikes)")
            }
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
    func makePitch() {
        var node = enumerateChildNodes(withName: "Strike") {
        node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "Ball") {
        node, stop in
        node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "In-Play") {
        node, stop in
        node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "Pitch") {
        node, stop in
        node.isHidden.toggle()
        }
    }
    func selectStrike() {
        var node = enumerateChildNodes(withName: "Strike") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "Ball") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "In-Play") {
        node, stop in
        node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "Looking") {
        node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "Swinging") {
        node, stop in
        node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "Foul") {
        node, stop in
        node.isHidden.toggle()
        }
    }
    func resetPitch() {
        var node = enumerateChildNodes(withName: "Looking") {
        node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "Swinging") {
        node, stop in
            node.isHidden.toggle()
        }
    
        node = enumerateChildNodes(withName: "Foul") {
        node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "Pitch") {
        node, stop in
        node.isHidden.toggle()
        }
    }
    func getInPlay() {
        var node = enumerateChildNodes(withName: "Strike") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "Ball") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "In-Play") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "Hit") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "GO") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "FO") { node, stop in
            node.isHidden.toggle()
        }
    }
    func getBaseHit() {
        var node = enumerateChildNodes(withName: "Hit") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "GO") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "FO") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "1B") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "2B") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "3B") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "HR") { node, stop in
            node.isHidden.toggle()
        }
    }
    func getHitType(node: SKNode) {
        
        switch node.name! {
        case "1B":
            var unusedNode = enumerateChildNodes(withName: "2B") { unusedNode, stop in
                unusedNode.isHidden.toggle()
            }
            unusedNode = enumerateChildNodes(withName: "3B") { unusedNode, stop in
                unusedNode.isHidden.toggle()
            }
            unusedNode = enumerateChildNodes(withName: "HR") { unusedNode, stop in
                unusedNode.isHidden.toggle()
            }
            moveNode(node: node)
        case "2B":
            var unusedNode = enumerateChildNodes(withName: "1B") { unusedNode, stop in
                unusedNode.isHidden.toggle()
            }
            unusedNode = enumerateChildNodes(withName: "3B") { unusedNode, stop in
                unusedNode.isHidden.toggle()
            }
            unusedNode = enumerateChildNodes(withName: "HR") { unusedNode, stop in
                unusedNode.isHidden.toggle()
            }
            node.run(SKAction.sequence([SKAction.run { self.moveNode(node: node) }, SKAction.wait(forDuration: 0.5), SKAction.run { self.moveNode(node: node) }]))
            
        case "3B":
            var unusedNode = enumerateChildNodes(withName: "1B") { unusedNode, stop in
                unusedNode.isHidden.toggle()
            }
            unusedNode = enumerateChildNodes(withName: "2B") { unusedNode, stop in
                unusedNode.isHidden.toggle()
            }
            unusedNode = enumerateChildNodes(withName: "HR") { unusedNode, stop in
                unusedNode.isHidden.toggle()
            }
            node.run(SKAction.sequence([SKAction.run { self.moveNode(node: node) }, SKAction.wait(forDuration: 0.5), SKAction.run { self.moveNode(node: node) }, SKAction.wait(forDuration: 0.5), SKAction.run { self.moveNode(node: node) }]))
        case "HR":
            var unusedNode = enumerateChildNodes(withName: "1B") { unusedNode, stop in
                unusedNode.isHidden.toggle()
            }
            unusedNode = enumerateChildNodes(withName: "2B") { unusedNode, stop in
                unusedNode.isHidden.toggle()
            }
            unusedNode = enumerateChildNodes(withName: "3B") { unusedNode, stop in
                unusedNode.isHidden.toggle()
            }
            node.run(SKAction.sequence([SKAction.run { self.moveNode(node: node) }, SKAction.wait(forDuration: 0.5), SKAction.run { self.moveNode(node: node) }, SKAction.wait(forDuration: 0.5), SKAction.run { self.moveNode(node: node) }, SKAction.wait(forDuration: 0.5), SKAction.run { self.moveNode(node: node) }]))
            default: break
        }
    }
    func moveNode(node: SKNode) {
        
        for i in gameVM.baseRunners {
            var brNode = enumerateChildNodes(withName: i.batter.number) {
                brNode, stop in
                
                if i.baseOccupied == 3 {
                    i.baseOccupied += 1
                    print("home: \(i.batter.firstName), \(i.batter.number) \(i.baseOccupied)")
                    brNode.run(SKAction.sequence([SKAction.move(to: self.homePlate, duration: 0.5), SKAction.wait(forDuration: 0.5), SKAction.removeFromParent()]))
                    i.run = true
                    self.gameVM.baseRunners.popLast()
                    self.gameVM.incrementScore(team: self.gameVM.halfInning)
                } else if i.baseOccupied == 2 {
                    i.baseOccupied += 1
                    print("third: \(i.batter.firstName), \(i.batter.number) \(i.baseOccupied)")
                    brNode.run(SKAction.move(to: self.thirdBase, duration: 0.5))
                } else if i.baseOccupied == 1 {
                    i.baseOccupied += 1
                    print("second: \(i.batter.firstName), \(i.batter.number) \(i.baseOccupied)")
                    brNode.run(SKAction.move(to: self.secondBase, duration: 0.5))
                } else if i.baseOccupied == 0 {
                    i.baseOccupied += 1
                    print("first: \(self.plateAppearance.batter.firstName), \(self.plateAppearance.batter.number) \(self.plateAppearance.baseOccupied)")
                    brNode.run(SKAction.move(to: self.firstBase, duration: 0.5))
                }
                //self.plateAppearance.baseOccupied = i.baseOccupied
            }
        }
        
    }
    
    func resetCount() {
        var node = enumerateChildNodes(withName: "pitched-strike") {
        node, stop in
            node.removeFromParent()
        }
        node = enumerateChildNodes(withName: "pitched-ball") {
        node, stop in
            node.removeFromParent()
        }
        if plateAppearance.pitches.count > 0 {
            var balls = 1
            var strikes = 1
            var outs = 1
            
            for pitch in plateAppearance.pitches {
                switch pitch {
                case .ball: // blue
                    let path = CGMutablePath()
                    //path.move(to: CGPoint(x: self.frame.width*0.05, y: self.frame.height*0.15))
                    path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(balls)), y: self.frame.height*0.165), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
                    path.closeSubpath()
                    //let ballNode = SKSpriteNode(imageNamed: "blue-sphere")
                    let node = SKShapeNode(path: path)
                    node.fillColor = .blue
                    node.strokeColor = .black
                    node.lineWidth = 1
                    node.isHidden = false
                    addChild(node)
                    balls += 1
                case .strikeLooking: //red
                    let path = CGMutablePath()
                    path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(strikes)), y: self.frame.height*0.215), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
                    path.closeSubpath()
                    let node = SKShapeNode(path: path)
                    node.lineWidth = 1
                
                    node.isHidden = false
                    node.strokeColor = .black
                    node.fillColor = .red
                    addChild(node)
                    strikes += 1
                case .strikeSwinging: //black
                    let path = CGMutablePath()
                    path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(strikes)), y: self.frame.height*0.215), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
                    path.closeSubpath()
                    let node = SKShapeNode(path: path)
                    node.lineWidth = 1
                
                    node.isHidden = false
                    node.strokeColor = .black
                    node.fillColor = .black
                    addChild(node)
                    strikes += 1
                case .foul: // yellow
                    let path = CGMutablePath()
                    path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(strikes)), y: self.frame.height*0.215), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
                    path.closeSubpath()
                    let node = SKShapeNode(path: path)
                    node.lineWidth = 1
                
                    node.isHidden = false
                    node.strokeColor = .black
                    node.fillColor = .yellow
                    addChild(node)
                    strikes += 1
                }
            }
        }
        let strikes = gameVM.pitches.filter { $0 == .strikeLooking || $0 == .strikeSwinging }
        if strikes.last == .strikeLooking {
         // enumerate nodes
        } else {
            // enumerate nodes
        }
        for i in 0..<gameVM.outs {
            let path = CGMutablePath()
            path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(i+1)), y: self.frame.height*0.115), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
            path.closeSubpath()
            let node = SKShapeNode(path: path)
            node.lineWidth = 1
            node.strokeColor = .black
            node.fillColor = .green
            node.isHidden = false
            addChild(node)
        }
    }
    func setUpScene() {
        if largeView {
            for i in gameVM.baseRunners {
                let batterNode = SKLabelNode(fontNamed: "Trebuchet MS")
                batterNode.text = "#\(i.batter.number)"
                batterNode.fontSize = 20
                batterNode.fontColor = SKColor.blue
            
                print("\(i.batter.firstName), \(i.baseOccupied)")
                if i.baseOccupied == 0 {
                    batterNode.position = self.homePlate
                } else if i.baseOccupied == 1 {
                    batterNode.position = self.firstBase
                } else if i.baseOccupied == 2 {
                    batterNode.position = self.secondBase
                } else if i.baseOccupied == 3 {
                    batterNode.position = self.thirdBase
                }
                batterNode.name = i.batter.number
                addChild(batterNode)
            }
            
            let pitcherNode = SKLabelNode(fontNamed: "Trebuchet MS")
            pitcherNode.text = "#\(gameVM.pitcher?.pitcher.number ?? "1")"
            pitcherNode.fontSize = 20
            pitcherNode.fontColor = SKColor.white
            pitcherNode.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.65)
            pitcherNode.name = "pitcher"
            addChild(pitcherNode)
            
            let catcherNode = SKLabelNode(fontNamed: "Trebuchet MS")
            catcherNode.text = "#\(gameVM.defensiveLineup["C"]?.number ?? "2")"
            catcherNode.fontSize = 20
            catcherNode.fontColor = SKColor.red
            catcherNode.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.41)
            catcherNode.name = "catcher"
            addChild(catcherNode)
            
            let firstNode = SKLabelNode(fontNamed: "Trebuchet MS")
            firstNode.text = "#\(gameVM.defensiveLineup["1B"]?.number ?? "3")"
            firstNode.fontSize = 20
            firstNode.fontColor = SKColor.white
            firstNode.position = CGPoint(x: self.frame.maxX-70, y: self.frame.maxY*0.65+20)
            firstNode.name = "first"
            addChild(firstNode)
            
            let secondNode = SKLabelNode(fontNamed: "Trebuchet MS")
            secondNode.text = "#\(gameVM.defensiveLineup["2B"]?.number ?? "4")"
            secondNode.fontSize = 20
            secondNode.fontColor = SKColor.white
            secondNode.position = CGPoint(x: self.frame.midX+70, y: self.frame.maxY*0.65+100)
            secondNode.name = "second"
            addChild(secondNode)
            
            let ssNode = SKLabelNode(fontNamed: "Trebuchet MS")
            ssNode.text = "#\(gameVM.defensiveLineup["SS"]?.number ?? "6")"
            ssNode.fontSize = 20
            ssNode.fontColor = SKColor.white
            ssNode.position = CGPoint(x: self.frame.midX-70, y: self.frame.maxY*0.65+100)
            ssNode.name = "short"
            addChild(ssNode)
            
            let thirdNode = SKLabelNode(fontNamed: "Trebuchet MS")
            thirdNode.text = "#\(gameVM.defensiveLineup["3B"]?.number ?? "5")"
            thirdNode.fontSize = 20
            thirdNode.fontColor = SKColor.white
            thirdNode.position = CGPoint(x: self.frame.minX+70, y: self.frame.maxY*0.65+20)
            thirdNode.name = "thrid"
            addChild(thirdNode)
            
            let leftNode = SKLabelNode(fontNamed: "Trebuchet MS")
            leftNode.text = "#\(gameVM.defensiveLineup["LF"]?.number ?? "7")"
            leftNode.fontSize = 20
            leftNode.fontColor = SKColor.white
            leftNode.position = CGPoint(x: self.frame.midX/3, y: self.frame.maxY*0.65+100)
            leftNode.name = "left"
            addChild(leftNode)
            
            let centerNode = SKLabelNode(fontNamed: "Trebuchet MS")
            centerNode.text = "#\(gameVM.defensiveLineup["CF"]?.number ?? "8")"
            centerNode.fontSize = 20
            centerNode.fontColor = SKColor.white
            centerNode.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.65+170)
            centerNode.name = "right"
            addChild(centerNode)
            
            let rightNode = SKLabelNode(fontNamed: "Trebuchet MS")
            rightNode.text = "#\(gameVM.defensiveLineup["RF"]?.number ?? "9")"
            rightNode.fontSize = 20
            rightNode.fontColor = SKColor.white
            rightNode.position = CGPoint(x: self.frame.midX*5/3, y: self.frame.maxY*0.65+100)
            rightNode.name = "right"
            addChild(rightNode)
            
            let strikesNode = SKLabelNode(fontNamed: "Trebuchet MS")
            strikesNode.text = "S:"
            strikesNode.fontSize = largeView ? 30 : 15
            strikesNode.fontColor = SKColor.red
            strikesNode.position = CGPoint(x: self.frame.width*0.05, y: largeView ? self.frame.height*0.2 : self.frame.height*0.4)
            strikesNode.name = "strike"
            addChild(strikesNode)
            
            let ballsNode = SKLabelNode(fontNamed: "Trebuchet MS")
            ballsNode.text = "B:"
            ballsNode.fontSize = largeView ? 30 : 15
            ballsNode.fontColor = SKColor.blue
            ballsNode.position = CGPoint(x: self.frame.width*0.05, y: largeView ? self.frame.height*0.15 : self.frame.height*0.35)
            ballsNode.name = "ball"
            addChild(ballsNode)
            
            let outsNode = SKLabelNode(fontNamed: "Trebuchet MS")
            outsNode.text = "O:"
            outsNode.fontSize = largeView ? 30 : 15
            outsNode.fontColor = SKColor.green
            outsNode.position = CGPoint(x: self.frame.width*0.05, y: largeView ? self.frame.height*0.1 : self.frame.height*0.3)
            outsNode.name = "out"
            addChild(outsNode)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.25), size: 50, name: "Pitch", hidden: false)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.27), size: 50, name: "Strike", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.2), size: 50, name: "Ball", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.13), size: 50, name: "In-Play", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.27), size: 80, name: "Looking", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.2), size: 80, name: "Swinging", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.13), size: 80, name: "Foul", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.27), size: 50, name: "Hit", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.2), size: 50, name: "GO", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.13), size: 50, name: "FO", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.20, y: self.frame.maxY*0.35), size: 20, name: "1B", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.40, y: self.frame.maxY*0.35), size: 20, name: "2B", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.60, y: self.frame.maxY*0.35), size: 20, name: "3B", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.35), size: 20, name: "HR", hidden: true)
            addKLabel()
        } else {
            let path = CGMutablePath()
            path.move(to: homePlate)
            

                    if plateAppearance.baseOccupied > 0 {
                        print("first: \(plateAppearance.batter.firstName), \(plateAppearance.batter.number) \(plateAppearance.baseOccupied)")
                        path.move(to: firstBase)
                    }
                    if plateAppearance.baseOccupied > 1 {
                        path.move(to: secondBase)
                        print("second: \(plateAppearance.batter.firstName), \(plateAppearance.batter.number) \(plateAppearance.baseOccupied)")
                    }
                    if plateAppearance.baseOccupied > 2 {
                        path.move(to: thirdBase)
                        print("third: \(plateAppearance.batter.firstName), \(plateAppearance.batter.number) \(plateAppearance.baseOccupied)")
                    }
                    if plateAppearance.baseOccupied > 3 {
                        path.move(to: homePlate)
                        path.closeSubpath()
                        print("score: \(plateAppearance.batter.firstName), \(plateAppearance.batter.number) \(plateAppearance.baseOccupied)")
                    }
                    let shapeNode = SKShapeNode(path: path)
                    shapeNode.fillColor = .red
                    shapeNode.strokeColor = .red
                    shapeNode.lineWidth = 25
                    addChild(shapeNode)
                }
        
            
        
        
    }
}
