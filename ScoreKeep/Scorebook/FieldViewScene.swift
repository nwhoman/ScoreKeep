//
//  FieldView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/1/25.
//

import Foundation
import SpriteKit
import SwiftData
import SwiftUI
import UIKit

struct FieldViewScene: View {
    @Environment(\.modelContext) var modelContext
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
    let player = OffensivePlateAppearance.defaultPlateAppearance
    
    return FieldViewScene(gameVM: gameVM, plateAppearance: player, scale: 1.0, largeView: false)
        .modelContainer(preview.modelContainer)
}

class FieldScene: SKScene, SKPhysicsContactDelegate {
    @Environment(\.modelContext) var modelContext
    @ObservedObject var gameVM: GameViewModel
    var plateAppearance: OffensivePlateAppearance
    var playerNode = SKSpriteNode()
    var shapeNode = SKShapeNode()
    
    var largeView: Bool
    
    let tapToChange = UITapGestureRecognizer()
    let tapOnce = UITapGestureRecognizer()
    let longTap = UILongPressGestureRecognizer()
    var posArray: [Int] = []
    var brToAdvance: BaseRunnerNode?
    
     var setPlay: Bool = false
     var setFlyOut: Bool = false
     var setGroundOut: Bool = false
     var setThrownOut: Bool = false
     var advanceBaseRunner: Bool = false
     var setRBI: Bool = false
     var setError: Bool = false
     var setSac: Bool = false
    
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
    
//    var homePlate: CGPoint { CGPoint(x: self.frame.midX, y: self.frame.midY*0.92) }
//    var firstBase: CGPoint { CGPoint(x: self.frame.maxX*0.83, y: self.frame.maxY*0.635) }
//    var secondBase: CGPoint { CGPoint(x: self.frame.midX, y: self.frame.maxY*0.8) }
//    var thirdBase: CGPoint { CGPoint(x: self.frame.maxX*0.17, y: self.frame.maxY*0.635) }
    
    //    struct PositionDescription {
    //        var number: Int             // ie 1, 2, 3
    //        var name: String            // ie pitcher, catcher, first,
    //        var location: CGPoint
    //        var abbreviation: String    // ie P, C, 1B
    //    }
    
    var positionNames: [PositionDescription] { [
        PositionDescription(number: 1, name: "pitcher", location: CGPoint(x: self.frame.midX, y: self.frame.maxY*0.65), abbreviation: "P"),
        PositionDescription(number: 2, name: "catcher", location: CGPoint(x: self.frame.midX, y: self.frame.maxY*0.41), abbreviation: "C"),
        PositionDescription(number: 3, name: "first", location: CGPoint(x: self.frame.maxX-70, y: self.frame.maxY*0.65+20), abbreviation: "1B"),
        PositionDescription(number: 4, name: "second", location: CGPoint(x: self.frame.midX+70, y: self.frame.maxY*0.65+100), abbreviation: "2B"),
        PositionDescription(number: 5, name: "third", location: CGPoint(x: self.frame.minX+70, y: self.frame.maxY*0.65+20), abbreviation: "3B"),
        PositionDescription(number: 6, name: "short", location: CGPoint(x: self.frame.midX-70, y: self.frame.maxY*0.65+100), abbreviation: "SS"),
        PositionDescription(number: 7, name: "left", location: CGPoint(x: self.frame.midX/3, y: self.frame.maxY*0.65+100), abbreviation: "LF"),
        PositionDescription(number: 8, name: "center", location: CGPoint(x: self.frame.midX, y: self.frame.maxY*0.65+170), abbreviation: "CF"),
        PositionDescription(number: 9, name: "right", location: CGPoint(x: self.frame.midX*5/3, y: self.frame.maxY*0.65+100), abbreviation: "RF")
    ] }
    
    override func didMove(to view: SKView) {
        //scene?.backgroundColor = .clear
        self.physicsWorld.contactDelegate = self
        
        let field = SKSpriteNode(imageNamed: "field")
        field.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.65)
        field.scale(to: CGSize(width: self.frame.width, height: self.frame.height*0.5))
        addChild(field)
        
        setUpScene()
        resetCount(scene: self, plateAppearance: plateAppearance, gameVM: gameVM)
        
        tapToChange.addTarget(self, action: #selector (handleTapToChange))
        view.addGestureRecognizer(tapToChange)
        tapToChange.isEnabled = true
        tapToChange.numberOfTapsRequired = 2
        tapToChange.numberOfTouchesRequired = 1
        
        tapOnce.addTarget(self, action: #selector (handleTapOnce))
        view.addGestureRecognizer(tapOnce)
        tapOnce.isEnabled = true
        tapOnce.numberOfTapsRequired = 1
        tapOnce.numberOfTouchesRequired = 1

        longTap.addTarget(self, action: #selector (handleLongTap))
        view.addGestureRecognizer(longTap)
        longTap.isEnabled = true
        longTap.minimumPressDuration = 0.5
    
    }
    @objc func handleTapOnce() {
        let waitAction = SKAction.wait(forDuration: 1)
        let moveAction = SKAction.run {
            self.moveNode(node: self.gameVM.baseRunners[0], bases: 1)
        }
        let sequenceAction = SKAction.sequence([moveAction, waitAction])
//        if setError {
//            var outcomeString: String = "E"
//            for i in posArray {
//                outcomeString += "\(i)-"
//            }
//            outcomeString.removeLast()
//            plateAppearance.outcome = outcomeString
//            print(outcomeString)
//            
//            run(SKAction.repeat(sequenceAction, count: 1))
//            setError = false
//        }
//        print(posArray)
        
    }
    @objc func handleLongTap() {
        
        
        if setGroundOut {
            var outcomeString: String = "G"
            for i in posArray {
                outcomeString += "\(i)-"
            }
            outcomeString.removeLast()
            plateAppearance.outcome.append(outcomeString)
            print(outcomeString)
            //getGroundOut()
        } else if setThrownOut {
            var outcomeString: String = "E"
            for i in posArray {
                outcomeString += "\(i)-"
            }
            outcomeString.removeLast()
            brToAdvance?.player.outcome.append(outcomeString)
            
            print(outcomeString)
        }
    
    }
    @objc func handleTapToChange() {
        let waitAction = SKAction.wait(forDuration: 1)
        let moveAction = SKAction.run {
            self.moveNode(node: self.gameVM.baseRunners[0], bases: 1)
        }
        let sequenceAction = SKAction.sequence([moveAction, waitAction])
        
        if setPlay {
            //plateAppearance.hitLoc = tapToChange.location(in: view)
            plateAppearance.hitLoc = CGPoint(x: tapToChange.location(in: view).x/self.frame.maxX, y: (homePlate.y - tapToChange.location(in: view).y)/homePlate.y)
            let path = CGMutablePath()
            path.move(to: homePlate)
            path.addLine(to: CGPoint(x: self.frame.minX+(tapToChange.location(in: view).x) , y: self.frame.maxY-(tapToChange.location(in: view).y)))
            let node = SKShapeNode(path: path)
            node.strokeColor = .red
            node.lineWidth = 3
            addChild(node)
            print("set hitloc \(plateAppearance.hitLoc)")
            run(SKAction.repeat(sequenceAction, count: plateAppearance.hit))
            setPlay = false
        }
        
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
    
    func addOutcomeLabel() {
        if plateAppearance.outcome.contains(where: { $0 == "G" }) || plateAppearance.outcome.contains(where: { $0 == "F" }) ||
            plateAppearance.outcome.contains(where: { $0 == "SAC" }) {
            let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
            labelNode.text = plateAppearance.outcome[0]
            labelNode.fontSize = 70
            labelNode.position = CGPoint(x: self.frame.width/2, y: self.frame.maxY*0.65 - 20)
            labelNode.name = "outcome"
            labelNode.fontColor = .black
            labelNode.isHidden = false
            addChild(labelNode)
        }
        print(plateAppearance.outcome)
    }
    
    
    func addBall() {
        gameVM.pitches.append(.ball)
        
        gameVM.batter!.pitches.append(.ball)
        gameVM.balls += 1
        if gameVM.balls == 4 {
            var node = enumerateChildNodes(withName: gameVM.batter!.batter.number) {
            node, stop in
                self.moveNode(node: self.gameVM.baseRunners[0], bases: 1)
            }
            gameVM.balls = 0
            gameVM.strikes = 0
            plateAppearance.bb = 1
            plateAppearance.outcome.append("BB")
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
    func getHBP() {
        gameVM.pitches.append(.ball)
        plateAppearance.outcome.append("HBP")
        plateAppearance.hp = 1
        self.moveNode(node: self.gameVM.baseRunners[0], bases: 1)
        gameVM.balls = 0
        gameVM.strikes = 0
    }
    
    
    
    
    func getGroundOut(baseRunner: BaseRunnerNode) {
        gameVM.outs += 1
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(gameVM.outs)), y: self.frame.height*0.115), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.lineWidth = 1
        node.strokeColor = .black
        node.fillColor = .green
        node.isHidden = false
        addChild(node)
        if setGroundOut {
            if baseRunner.player.baseOccupied == 1 {
                var outcomeString: String = ""
                if plateAppearance.sac != 1 {
                    if posArray.count > 1 {
                        //outcomeString += "G"
                        for i in posArray {
                            outcomeString += "\(i)-"
                        }
                    } else {
                        outcomeString += "U"
                        for i in posArray {
                            outcomeString += "\(i)-"
                        }
                    }
                    if plateAppearance.outcome.contains("FC") {
                        plateAppearance.outcome.popLast()
                        outcomeString = ""
                        for i in posArray {
                            outcomeString += "\(i)-"
                        }
                    }
                    outcomeString.removeLast()
                } else {
                    outcomeString += "SAC B"
                    for i in posArray {
                        outcomeString += "\(i)-"
                    }
                    outcomeString.removeLast()
                }
                baseRunner.player.baseOccupied = 0
                plateAppearance.outcome.append(outcomeString)
            } else {
                var outcomeString: String = ""
                if posArray.count > 1 {
                    for i in posArray {
                        outcomeString += "\(i)-"
                    }
                } else {
                    outcomeString += "U"
                    for i in posArray {
                        outcomeString += "\(i)-"
                    }
                }
            
                outcomeString.removeLast()
                plateAppearance.outcome.append("FC-\(posArray[0])")
                baseRunner.player.outcome.append(outcomeString)
                baseRunner.player.baseOccupied -= 1
            }
        } else if setThrownOut {
            var outcomeString: String = ""
            for i in posArray {
                outcomeString += "\(i)-"
            }
            outcomeString.removeLast()
            baseRunner.player.outcome.append(outcomeString)
        }
    
        gameVM.baseRunners.removeAll { node in
            node.player.batter.number == baseRunner.player.batter.number
        }
        //baseRunner.player.baseOccupied = 5
        baseRunner.player.outs = gameVM.outs
        gameVM.balls = 0
        gameVM.strikes = 0
        baseRunner.node.removeFromParent()
        //setPlay = false
        //setFlyOut = false
        //setGroundOut = false
    }
    func addOutNode(gameVM: GameViewModel, scene: SKScene, plateAppearance: OffensivePlateAppearance) {
        gameVM.outs += 1
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: scene.frame.width*0.075 + (20.0*CGFloat(gameVM.outs)), y: scene.frame.height*0.115), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.lineWidth = 1
        node.strokeColor = .black
        node.fillColor = .green
        node.isHidden = false
        scene.addChild(node)
        plateAppearance.baseOccupied = 5
        gameVM.baseRunners.remove(at: 0)
        
        gameVM.batter!.outs = gameVM.outs
        gameVM.balls = 0
        gameVM.strikes = 0
        setPlay = false
        setFlyOut = false
        setGroundOut = false
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
                addStrike(pos: 1, gameVM: gameVM, scene: self, plateAppearance: plateAppearance)
                if gameVM.strikes == 3 {
                    
                    
                    addOutNode(gameVM: gameVM, scene: self, plateAppearance: plateAppearance)  //green out dot, not out at base X
                    
                    self.enumerateChildNodes(withName: "K") {
                            node, stop in
                        node.isHidden = false
                        
                    }
                    
                    self.enumerateChildNodes(withName: "KL") {
                        node, stop in
                        node.isHidden = false
                    }
                    plateAppearance.outcome.append("KL")
                    addKLabel(scene: self, plateAppearance: plateAppearance)
                }
            }
            if touchedNode.name == "Swinging" {
                resetPitch()
                addStrike(pos: 2, gameVM: gameVM, scene: self, plateAppearance: plateAppearance)
                if gameVM.strikes == 3 {
                    
                    
                    addOutNode(gameVM: gameVM, scene: self, plateAppearance: plateAppearance)  //green out dot, not out at base X
                    
                    self.enumerateChildNodes(withName: "K") {
                            node, stop in
                        node.isHidden = false
                        
                    }
                    self.enumerateChildNodes(withName: "KS") {
                            node, stop in
                        node.isHidden = false
                    }
                    plateAppearance.outcome.append("KS")
                    
                    addKLabel(scene: self, plateAppearance: plateAppearance)
                }
            }
            if touchedNode.name == "Foul" {
                resetPitch()
                addStrike(pos: 3, gameVM: gameVM, scene: self, plateAppearance: plateAppearance)
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
            if touchedNode.name == "HBP" {
                getHBP()
            }
            if touchedNode.name == "FO" {
                setFlyOut.toggle()
            }
            if touchedNode.name == "GO" {
                setGroundOut.toggle()
                moveNode(node: gameVM.baseRunners[0], bases: 1)
            }
            if touchedNode.name == "E" {
                setError.toggle()
                moveNode(node: gameVM.baseRunners[0], bases: 1)
                //getError()
            }
            if touchedNode.name == "SAC" {
                setSac = true
                getSAC()
            }
            if touchedNode.name == "B" {
                plateAppearance.outcome.append(" B")
                setGroundOut.toggle()
                moveNode(node: gameVM.baseRunners[0], bases: 1)
            }
            if touchedNode.name == "RBI" {
                plateAppearance.rbi += 1
        
            }
            if touchedNode.name == "pitched-strike" || touchedNode.name == "pitched-ball" {
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
                resetCount(scene: self, plateAppearance: plateAppearance, gameVM: gameVM)
                print("b: \(gameVM.balls) s: \(gameVM.strikes)")
            }
            if setPlay {
//                for i in positionNames {
//                    if touchedNode.name == i.name {
//                        if plateAppearance.hit == 1 {
//                            plateAppearance.outcome = "Single to \(touchedNode.name ?? "")"
//                        } else if plateAppearance.hit == 2 {
//                            plateAppearance.outcome = "Double to \(touchedNode.name ?? "")"
//                        } else if plateAppearance.hit == 3 {
//                            plateAppearance.outcome = "Triple to \(touchedNode.name ?? "")"
//                        } else if plateAppearance.hit == 4 {
//                            plateAppearance.outcome = "Home Run to \(touchedNode.name ?? "")"
//                        }
//                    }
//                }
            }
            if setFlyOut {
                print("FO, \(touchedNode.name)")
                var node = enumerateChildNodes(withName: "Hit") { node, stop in
                    node.isHidden = true
                }
                node = enumerateChildNodes(withName: "GO") { node, stop in
                    node.isHidden = true
                }
                node = enumerateChildNodes(withName: "HBP") { node, stop in
                    node.isHidden = true
                }
                node = enumerateChildNodes(withName: "SAC") { node, stop in
                    if self.plateAppearance.sac != 1 {
                        node.isHidden = true
                    }
                }
                node = enumerateChildNodes(withName: "E") { node, stop in
                    node.isHidden = true
                }
                node = enumerateChildNodes(withName: "SFO") { node, stop in
                    node.isHidden = false
                }
                node = enumerateChildNodes(withName: "B") { node, stop in
                    node.isHidden = true
                }
                for i in positionNames {
                    if touchedNode.name == i.name {
                        
                        plateAppearance.outcome.append("F\(i.number ?? 0)")
                        
                        addOutNode(gameVM: gameVM, scene: self, plateAppearance: plateAppearance)
                        node = enumerateChildNodes(withName: "SFO") { node, stop in
                            node.isHidden = true
                        }
                        setFlyOut.toggle()
                    }
                }
                print(plateAppearance.outcome)
            }
            if setGroundOut {
                var node = enumerateChildNodes(withName: "Hit" ) { node, stop in
                    node.isHidden = true
                }
                node = enumerateChildNodes(withName: "FO") { node, stop in
                    node.isHidden = true
                }

                node = enumerateChildNodes(withName: "HBP") { node, stop in
                    node.isHidden = true
                }
                node = enumerateChildNodes(withName: "SAC") { node, stop in
                    if self.plateAppearance.sac != 1 {
                        node.isHidden = true
                    }
                }
                node = enumerateChildNodes(withName: "E") { node, stop in
                    node.isHidden = true
                }
                node = enumerateChildNodes(withName: "SGO") { node, stop in
                    node.isHidden = false
                }
                for i in positionNames {
                    if touchedNode.name == i.name {
                        posArray.append(i.number)
                    }
                }
                for i in gameVM.baseRunners {
                    if touchedNode.name == i.node.name {
                        getGroundOut(baseRunner: i)
                    }
                }
                if touchedNode.name == "SGO" {
                    setGroundOut = false
                    node = enumerateChildNodes(withName: "SGO") { node, stop in
                        node.isHidden = true
                    }
                }
            }
            if setThrownOut {
                for i in positionNames {
                    if touchedNode.name == i.name {
                        posArray.append(i.number)
                    }
                }
                for i in gameVM.baseRunners {
                    if touchedNode.name == i.node.name {
                        advanceBR(node: i)
                        getGroundOut(baseRunner: i)
                    }
                }
            }
            if setError {
                
                
                var node = enumerateChildNodes(withName: "Hit") { node, stop in
                    node.isHidden = true
                }
                node = enumerateChildNodes(withName: "GO") { node, stop in
                    node.isHidden = true
                }
                node = enumerateChildNodes(withName: "FO") { node, stop in
                    node.isHidden = true
                }
                node = enumerateChildNodes(withName: "HBP") { node, stop in
                    node.isHidden = true
                }
                node = enumerateChildNodes(withName: "SAC") { node, stop in
                    node.isHidden = true
                }
                
                print("Err, \(touchedNode.name)")
                for i in positionNames {
                    if touchedNode.name == i.name {
                        print("TRUE")
                        plateAppearance.re += 1
                        plateAppearance.outcome.append("E\(i.number ?? 0)")
                        gameVM.balls = 0
                        gameVM.strikes = 0
                        setError.toggle()
                    }
                }
                print(plateAppearance.outcome)
                
            }
            if advanceBaseRunner {
                if touchedNode.name == "SB" {
                    advanceBRMenu()
                    brToAdvance?.player.outcome.append("Stole  \((brToAdvance?.player.baseOccupied ?? 1)+1)")
                    brToAdvance?.player.sb.append((brToAdvance?.player.baseOccupied ?? 1)+1)
                    moveNode(node: brToAdvance ?? gameVM.baseRunners[0], bases: 1)
                    var node = enumerateChildNodes(withName: "Pitch") { node, stop in
                        node.isHidden = false
                    }
                }
                if touchedNode.name == "XB" {
                    advanceBRMenu()
                    brToAdvance?.player.outcome.append("Advanced to \((brToAdvance?.player.baseOccupied ?? 1)+1)")
                    moveNode(node: brToAdvance ?? gameVM.baseRunners[0], bases: 1)
                }
                if touchedNode.name == "WP" {
                    advanceBRMenu()
                    brToAdvance?.player.outcome.append("Wild pitch to  \((brToAdvance?.player.baseOccupied ?? 1)+1)")
                    brToAdvance?.player.sb.append((brToAdvance?.player.baseOccupied ?? 1)+1)
                    moveNode(node: brToAdvance ?? gameVM.baseRunners[0], bases: 1)
                    var node = enumerateChildNodes(withName: "Pitch") { node, stop in
                        node.isHidden = false
                    }
                }
                if touchedNode.name == "PB" {
                    advanceBRMenu()
                    brToAdvance?.player.outcome.append("Passed ball to  \((brToAdvance?.player.baseOccupied ?? 1)+1)")
                    brToAdvance?.player.sb.append((brToAdvance?.player.baseOccupied ?? 1)+1)
                    moveNode(node: brToAdvance ?? gameVM.baseRunners[0], bases: 1)
                    var node = enumerateChildNodes(withName: "Pitch") { node, stop in
                        node.isHidden = false
                    }
                }
                if touchedNode.name == "TO" {
                    advanceBRMenu()
                    brToAdvance?.player.outcome.append("Thrown out at   \((brToAdvance?.player.baseOccupied ?? 1)+1)")
                    setThrownOut.toggle()
                }
            }
            for i in gameVM.baseRunners {
                if touchedNode.name == i.node.name {
                    if i.player.baseOccupied != 0 {
                        print("\(i.player.baseOccupied)")
                        brToAdvance = i
                        advanceBRMenu()
                    }
                    
                }
            }
        }
    }
    
    func advanceBRMenu() {
        advanceBaseRunner.toggle()
        var node = enumerateChildNodes(withName: "SB") { node, stop in
            node.isHidden.toggle()
            
        }
        node = enumerateChildNodes(withName: "XB") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "WP") { node, stop in
            node.isHidden.toggle()
            
        }
        node = enumerateChildNodes(withName: "PB") { node, stop in
        node.isHidden.toggle()
            
        }
        node = enumerateChildNodes(withName: "TO") { node, stop in
        node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "Pitch") { node, stop in
        node.isHidden = true
        }
        node = enumerateChildNodes(withName: "1B") { node, stop in
            node.isHidden = true
        }
        node = enumerateChildNodes(withName: "2B") { node, stop in
            node.isHidden = true
        }
        node = enumerateChildNodes(withName: "3B") { node, stop in
            node.isHidden = true
        }
        node = enumerateChildNodes(withName: "HR") { node, stop in
            node.isHidden = true
        }
        node = enumerateChildNodes(withName: "E") { node, stop in
            node.isHidden = true
        }
    }
    func advanceBR(node: BaseRunnerNode) {
        moveNode(node: node, bases: 1)

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
    func didBegin(_ contact: SKPhysicsContact) {
        // system function is responsible for detecting contacts between nodes in the scene
        //
        // set the values for the first and second bodies in the contact
        guard let firstBody = contact.bodyA.node else {return}
        guard let secondBody = contact.bodyB.node else {return}
        
        // if the contact is between the player node and a point node
        // remove the point node and add 50 points
//        batterNode.physicsBody?.categoryBitMask = 0x1 << 0 current base occupied
//        batterNode.physicsBody?.contactTestBitMask = 0x1 << 1 base at contact
//        batterNode.physicsBody?.collisionBitMask = 0x1 << 0
        
        // home to first
        
        if (firstBody.physicsBody?.categoryBitMask == (1 << 1) && secondBody.physicsBody?.categoryBitMask == (1 << 1)) {
            print("2\(secondBody.name ?? "n")")
            let runner = gameVM.getBaserunner(number: "\(secondBody.name ?? "")")
            
            moveNode(node: runner, bases: 1)
        
        } else if (secondBody.physicsBody?.categoryBitMask == (1 << 1) && firstBody.physicsBody?.categoryBitMask == (1 << 1)) {
            
            let runner = gameVM.getBaserunner(number: firstBody.name!)
            moveNode(node: runner, bases: 1)
            
        // first to second
        } else if (firstBody.physicsBody?.categoryBitMask == (1 << 2) && secondBody.physicsBody?.categoryBitMask == (1 << 2)) {
            let runner = gameVM.getBaserunner(number: secondBody.name!)
            moveNode(node: runner, bases: 1)
            
        } else if (secondBody.physicsBody?.categoryBitMask == (1 << 2) && firstBody.physicsBody?.categoryBitMask == (1 << 2)) {
            let runner = gameVM.getBaserunner(number: firstBody.name!)
            moveNode(node: runner, bases: 1)
        
        // second to third
        } else if (firstBody.physicsBody?.contactTestBitMask == 0x1 << 3 && secondBody.physicsBody?.categoryBitMask == 0x1 << 3) {
            let runner = gameVM.getBaserunner(number: secondBody.name!)
            moveNode(node: runner, bases: 1)
            
        } else if (secondBody.physicsBody?.contactTestBitMask == 0x1 << 3 && firstBody.physicsBody?.categoryBitMask == 0x1 << 3) {
            let runner = gameVM.getBaserunner(number: firstBody.name!)
            moveNode(node: runner, bases: 1)
        
        }
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
        node = enumerateChildNodes(withName: "HBP") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "SAC") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "E") { node, stop in
            node.isHidden.toggle()
        }
    }
    func getError() {
        
        
        
    }
    func getBunt() {
        plateAppearance.outcome.append("B")
        
        var node = enumerateChildNodes(withName: "Hit") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "GO") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "FO") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "HBP") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "E") { node, stop in
            node.isHidden = true
        }
    }
    func getSAC() {
        plateAppearance.outcome.append("SAC")
        plateAppearance.sac = 1
        
        var node = enumerateChildNodes(withName: "Hit") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "GO") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "B") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "HBP") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "E") { node, stop in
            node.isHidden = true
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
        node = enumerateChildNodes(withName: "HBP") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "SAC") { node, stop in
            node.isHidden.toggle()
        }
        node = enumerateChildNodes(withName: "E") { node, stop in
            node.isHidden = true
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
        var bases: Int = 0
//        let waitAction = SKAction.wait(forDuration: 1)
//        let moveAction = SKAction.run {
//            self.moveNode(node: self.gameVM.baseRunners[0], bases: 1)
//        }
//        let sequenceAction = SKAction.sequence([moveAction, waitAction])
        
        
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
            bases = 1
            plateAppearance.outcome.append("1B")
            plateAppearance.hit = 1
            setPlay.toggle()
            
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
            bases = 2
            plateAppearance.outcome.append("2B")
            plateAppearance.hit = 2
            setPlay.toggle()
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
            bases = 3
            plateAppearance.outcome.append("3B")
            plateAppearance.hit = 3
            setPlay.toggle()
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
        
            plateAppearance.hit = 4
            plateAppearance.outcome.append("HR")
            
            setPlay.toggle()
        default: break
        }
        //run(SKAction.repeat(sequenceAction, count: plateAppearance.hit))
    }
    func moveNode(node: BaseRunnerNode, bases: Int) {
        let brNode = node.node
        
            switch node.player.baseOccupied {
            case 0:
                brNode.run(SKAction.sequence([SKAction.move(to: self.firstBase, duration: 0.5), SKAction.wait(forDuration: 0.5)]))
                if !setSac {
                    node.player.baseOccupied += 1
                }
                brNode.physicsBody?.categoryBitMask = (1 << 1)
                
            case 1:
                brNode.run(SKAction.sequence([SKAction.move(to: self.secondBase, duration: 0.5), SKAction.wait(forDuration: 0.5)]))
                node.player.baseOccupied += 1
                brNode.physicsBody?.categoryBitMask = (1 << 2)
                brNode.physicsBody?.contactTestBitMask = (1 << 2)
            case 2:
                brNode.run(SKAction.sequence([ SKAction.move(to: self.thirdBase, duration: 0.5), SKAction.wait(forDuration: 0.5)]))
                node.player.baseOccupied += 1
                brNode.physicsBody?.categoryBitMask = (1 << 3)
                brNode.physicsBody?.contactTestBitMask = (1 << 3)
            case 3:
                brNode.run(SKAction.sequence([SKAction.move(to: self.homePlate, duration: 0.5), SKAction.wait(forDuration: 0.3), SKAction.removeFromParent()]))
                node.player.baseOccupied += 1
                node.player.run = true
                self.gameVM.baseRunners.popLast()
                self.gameVM.incrementScore(team: self.gameVM.halfInning)
                if !setThrownOut {
                    var node = enumerateChildNodes(withName: "RBI") { node, stop in
                    node.isHidden = false
                    }
                
                    setRBI = true
                }
                
            default:
                break
            }
    }
    
//    func resetCount() {
//        var node = enumerateChildNodes(withName: "pitched-strike") {
//        node, stop in
//            node.removeFromParent()
//        }
//        node = enumerateChildNodes(withName: "pitched-ball") {
//        node, stop in
//            node.removeFromParent()
//        }
//        if plateAppearance.pitches.count > 0 {
//            var balls = 1
//            var strikes = 1
//            var outs = 1
//            
//            for pitch in plateAppearance.pitches {
//                switch pitch {
//                case .ball: // blue
//                    let path = CGMutablePath()
//                    //path.move(to: CGPoint(x: self.frame.width*0.05, y: self.frame.height*0.15))
//                    path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(balls)), y: self.frame.height*0.165), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
//                    path.closeSubpath()
//                    //let ballNode = SKSpriteNode(imageNamed: "blue-sphere")
//                    let node = SKShapeNode(path: path)
//                    node.fillColor = .blue
//                    node.strokeColor = .black
//                    node.lineWidth = 1
//                    node.isHidden = false
//                    addChild(node)
//                    balls += 1
//                case .strikeLooking: //red
//                    let path = CGMutablePath()
//                    path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(strikes)), y: self.frame.height*0.215), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
//                    path.closeSubpath()
//                    let node = SKShapeNode(path: path)
//                    node.lineWidth = 1
//                
//                    node.isHidden = false
//                    node.strokeColor = .black
//                    node.fillColor = .red
//                    addChild(node)
//                    strikes += 1
//                case .strikeSwinging: //black
//                    let path = CGMutablePath()
//                    path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(strikes)), y: self.frame.height*0.215), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
//                    path.closeSubpath()
//                    let node = SKShapeNode(path: path)
//                    node.lineWidth = 1
//                
//                    node.isHidden = false
//                    node.strokeColor = .black
//                    node.fillColor = .black
//                    addChild(node)
//                    strikes += 1
//                case .foul: // yellow
//                    let path = CGMutablePath()
//                    path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(strikes)), y: self.frame.height*0.215), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
//                    path.closeSubpath()
//                    let node = SKShapeNode(path: path)
//                    node.lineWidth = 1
//                
//                    node.isHidden = false
//                    node.strokeColor = .black
//                    node.fillColor = .yellow
//                    addChild(node)
//                    strikes += 1
//                }
//            }
//            if plateAppearance.outcome.contains(where: { $0 == "KS" }) || plateAppearance.outcome.contains(where: { $0 == "KL" }) {
//                addKLabel()
//            }
//        }
//        let strikes = gameVM.pitches.filter { $0 == .strikeLooking || $0 == .strikeSwinging }
//        if strikes.last == .strikeLooking {
//         // enumerate nodes
//        } else {
//            // enumerate nodes
//        }
//        for i in 0..<gameVM.outs {
//            
//            let path = CGMutablePath()
//            path.addArc(center: CGPoint(x: self.frame.width*0.075 + (20.0*CGFloat(i+1)), y: self.frame.height*0.115), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
//            path.closeSubpath()
//            let node = SKShapeNode(path: path)
//            node.lineWidth = 1
//            node.strokeColor = .black
//            node.fillColor = .green
//            node.isHidden = false
//            addChild(node)
//        }
//        if plateAppearance.outs != 0 {
//            addOutLabel()
//        }
//    }
//    
    func setUpScene() {
        
        if largeView {

            placeBaseRunners(gameVM: gameVM, scene: self)
//
            addPositionNodes(positionNames: positionNames, gameVM: gameVM, scene: self, setPlay: setPlay)

            
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
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.25), size: 50, name: "Pitch", hidden: plateAppearance.outcome == [] ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.27), size: 50, name: "Strike", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.2), size: 50, name: "Ball", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.13), size: 50, name: "In-Play", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.27), size: 80, name: "Looking", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.2), size: 80, name: "Swinging", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.13), size: 80, name: "Foul", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.35), size: 50, name: "Hit", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.28), size: 50, name: "GO", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.28), size: 50, name: "B", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.21), size: 50, name: "FO", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.14), size: 20, name: "HBP", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.07), size: 20, name: "SAC", hidden: plateAppearance.sac == 1 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.15, y: self.frame.maxY*0.35), size: 20, name: "E", hidden: plateAppearance.re == 1 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.20, y: self.frame.maxY*0.35), size: 20, name: "1B", hidden: plateAppearance.hit == 1 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.40, y: self.frame.maxY*0.35), size: 20, name: "2B", hidden: plateAppearance.hit == 2 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.60, y: self.frame.maxY*0.35), size: 20, name: "3B", hidden: plateAppearance.hit == 3 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.35), size: 20, name: "HR", hidden: plateAppearance.hit == 4 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.20, y: self.frame.maxY*0.35), size: 20, name: "BB", hidden: plateAppearance.outcome.contains(where: { $0 == "BB" }) ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.22, y: self.frame.maxY*0.35), size: 120, name: "Hit By Pitch", hidden: plateAppearance.hp == 1 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.60, y: self.frame.maxY*0.07), size: 30, name: "SGO", hidden: setGroundOut ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.40, y: self.frame.maxY*0.07), size: 30, name: "SFO", hidden: setFlyOut ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.10, y: self.frame.maxY*0.35), size: 20, name: "SB", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.30, y: self.frame.maxY*0.35), size: 20, name: "XB", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.50, y: self.frame.maxY*0.35), size: 20, name: "WP", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.70, y: self.frame.maxY*0.35), size: 20, name: "PB", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.90, y: self.frame.maxY*0.35), size: 20, name: "TO", hidden: true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.10, y: self.frame.maxY*0.5), size: 20, name: "RBI", hidden: setRBI ? false : true)
            addOutcomeLabel()
        } else {
            var playerNode = SKSpriteNode()
            var basepathNode = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: homePlate)
            
            resetCount(scene: self, plateAppearance: plateAppearance, gameVM: gameVM)
            addHitLoc(plateAppearance: plateAppearance, scene: self)
            placeBaseRunners(basepathNode: basepathNode, baseOccupied: plateAppearance.baseOccupied, plateAppearance: plateAppearance, scene: self)
            placeKLabel(plateAppearance: plateAppearance, scene: self)
            addOutcomes(plateAppearance: plateAppearance, scene: self)
            for each in plateAppearance.outcome {
                print(each)
            }
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.20, y: self.frame.maxY*0.35), size: 20, name: "1B", hidden: plateAppearance.hit == 1 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.40, y: self.frame.maxY*0.35), size: 20, name: "2B", hidden: plateAppearance.hit == 2 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.60, y: self.frame.maxY*0.35), size: 20, name: "3B", hidden: plateAppearance.hit == 3 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.35), size: 20, name: "HR", hidden: plateAppearance.hit == 4 ? false : true)
            
            
//            if plateAppearance.baseOccupied == 1 || (plateAppearance.hit == 1 && plateAppearance.outs != 0) {
//                path.addLine(to: firstBase)
//                basepathNode.path = path
//                basepathNode.strokeColor = plateAppearance.re != 1 ? .blue : .red
//                basepathNode.lineWidth = 15
//                if plateAppearance.outs != 0 {
//                    path.addLine(to: secondBase)
//                    basepathNode.path = path
//                    basepathNode.strokeColor = plateAppearance.re != 1 ? .blue : .red
//                    basepathNode.lineWidth = 3
//                    //addOut(base: secondBase)
//                }
//                //addHitLoc()
//            }
//            addChild(basepathNode)
            shapeNode.fillColor = .red
            shapeNode.strokeColor = .red
            shapeNode.lineWidth = 30
            
        }
        
    }
    
}
