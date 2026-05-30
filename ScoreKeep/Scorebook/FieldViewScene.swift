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
//    @ObservedObject var gameVM: GameViewModel
    @State var gameVM: GameViewModel
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
    let gameVM = GameViewModel.defaultGame
    let preview = Preview()
    preview.addSampleGames([gameVM])
    preview.addSampleLineups(game: gameVM)
    
    gameVM.setUpGame()
    gameVM.getBatter()
    //gameVM.getPitcher()
    let player = OffensivePlateAppearance.defaultPlateAppearance
    let pitcher = DefensivePlateAppearance.defaultPlateAppearance
    
    return FieldViewScene(gameVM: gameVM, plateAppearance: player, scale: 1.0, largeView: false)
        .modelContainer(preview.modelContainer)
}

class FieldScene: SKScene, SKPhysicsContactDelegate {
    @Environment(\.modelContext) var modelContext
//    @ObservedObject var gameVM: GameViewModel
    @State var gameVM: GameViewModel
    var plateAppearance: OffensivePlateAppearance
    
    var playerNode = SKSpriteNode()
    var shapeNode = SKShapeNode()
    var flyBallNode = SKShapeNode()
    var largeView: Bool
    
    let tapToChange = UITapGestureRecognizer()
    let tapOnce = UITapGestureRecognizer()
    let longTap = UILongPressGestureRecognizer()
    var posArray: [Int] = []
    var brToAdvance: [String: Any] = [:]
    
    var setPlay: Bool = false
    var setFlyOut: Bool = false
    var setGroundOut: Bool = false
    var setThrownOut: Bool = false
    var advanceBaseRunner: Bool = false
    var setRBI: Bool = false
    var setError: Bool = false
    var setErrorField: Bool = false
    var setSac: Bool = false
    var setStrikeout: Bool = false
    var lineup: [PlayerPos] = []
    
    init(size: CGSize, gameVM: GameViewModel, plateAppearance: OffensivePlateAppearance, largeView: Bool) {
        // Gets the values from the view
        self.gameVM = gameVM
        self.plateAppearance = plateAppearance
        self.largeView = largeView
        super.init(size: size)
        self.backgroundColor = .white
        self.lineup = gameVM.halfInning == 0 ? gameVM.homeCurrentLineup : gameVM.visitorCurrentLineup
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Catch error
        fatalError()
    }
//    var homePlate: CGPoint { CGPoint(x: self.frame.midX, y: self.frame.maxY*0.65-150) }
//    var firstBase: CGPoint { CGPoint(x: self.frame.maxX-75, y: self.frame.maxY*0.65-20) }
//    var secondBase: CGPoint { CGPoint(x: self.frame.midX, y: self.frame.maxY*0.65+100) }
//    var thirdBase: CGPoint { CGPoint(x: self.frame.minX+75, y: self.frame.maxY*0.65-20) }
    
    var homePlate: CGPoint { CGPoint(x: self.frame.midX, y: self.frame.maxY*0.45) }
    var firstBase: CGPoint { CGPoint(x: self.frame.midX*1.64, y: self.frame.maxY*0.62) }
    var secondBase: CGPoint { CGPoint(x: self.frame.midX, y: self.frame.maxY*0.78) }
    var thirdBase: CGPoint { CGPoint(x: self.frame.midX*0.36, y: self.frame.maxY*0.62) }
    
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
    
        //let addOutAction = SKAction.run{self.gameVM.getPlayerStats(plateAppearances: self.gameVM.getPlayerPA(innings: <#T##[Inning]#>, player: <#T##Player#>))}
    }
    @objc func handleTapOnce() {
//        let waitAction = SKAction.wait(forDuration: 1)
//        let moveAction = SKAction.run {
//            self.moveNode(node: self.gameVM.baseRunners[0], bases: 1)
//        }
//        let sequenceAction = SKAction.sequence([moveAction, waitAction])
        
    }
    @objc func handleLongTap() {
        
        
//        if setGroundOut {
//            var outcomeString: String = "G"
//            for i in posArray {
//                outcomeString += "\(i)-"
//            }
//            outcomeString.removeLast()
//            //plateAppearance.outcome.append(outcomeString)
//            //getGroundOut()
//        } else if setThrownOut {
//            var outcomeString: String = "E"
//            for i in posArray {
//                outcomeString += "\(i)-"
//            }
//            outcomeString.removeLast()
//            //brToAdvance?.player.outcome.append(outcomeString)
            
//        }
    
    }
    @objc func handleTapToChange() {
        let waitAction = SKAction.wait(forDuration: 1)
        let node = self.getNodeForBaserunner(player: self.gameVM.batter!)
        let moveAction = SKAction.run {
            self.moveNode(brNode: node, player: self.gameVM.batter!, bases: 1)
            print("\(node.name)-\(node.physicsBody?.categoryBitMask) \(node.physicsBody?.contactTestBitMask)")
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
            node.zPosition = 0
            addChild(node)
            //print("set hitloc \(plateAppearance.hitLoc)")
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
    
    func addErrorNode(center: CGPoint, size: CGFloat, name: String, hidden: Bool) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: center.x+size/2, y: center.y+50/2))
        path.addLine(to: CGPoint(x: center.x-size/2, y: center.y+50/2))
        path.addArc(center: CGPoint(x: center.x-size/2, y: center.y), radius: 50/2, startAngle: .pi/2, endAngle: CGFloat.pi*3/2, clockwise: false)
        path.addLine(to: CGPoint(x: center.x+size/2, y: center.y-50/2))
        path.addArc(center: CGPoint(x: center.x+size/2, y: center.y), radius: 50/2, startAngle: .pi*3/2, endAngle: CGFloat.pi/2, clockwise: false)
        
        let node = SKShapeNode(path: path)
        node.fillColor = .gray
        node.strokeColor = .red
        node.lineWidth = 1
        if name == "E" {
            node.zPosition = 10
        } else {
            node.zPosition = 0
        }
        node.name = name
        node.isHidden = hidden
        addChild(node)
        let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
        
        labelNode.text = "E"
        labelNode.name = name
        labelNode.fontSize = 30
        labelNode.fontColor = .red
        labelNode.position = CGPoint(x: center.x, y: center.y-50/4)
        labelNode.isHidden = hidden
        if name == "E" {
            labelNode.zPosition = 10
        } else {
            labelNode.zPosition = 0
        }
        addChild(labelNode)
    }
    
    func addOutcomeLabel() {
        guard let homeOutcome = plateAppearance.outcome["home"] else { return } //|| homeOutcome.contains("F") 
        if homeOutcome.contains("G") ||
            homeOutcome.contains("SAC") || homeOutcome.contains("E") {
            let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
            labelNode.text = homeOutcome
            labelNode.fontSize = 70
            labelNode.position = CGPoint(x: self.frame.width/2, y: self.frame.maxY*0.65 - 20)
            labelNode.name = "outcome"
            labelNode.fontColor = .black
            labelNode.isHidden = false
            addChild(labelNode)
        }
        //  add other types of outcomes
    }
    
    
    func addBall() {
        gameVM.pitches[gameVM.halfInning]?["balls"]! += 1
        gameVM.batter!.pitches.append(.ball)

        gameVM.balls += 1
        print("B: \(gameVM.balls)")
        if gameVM.balls == 4 {
            let batterNode = getGenericNode(name: gameVM.batter!.batter.number)
            self.moveNode(brNode: batterNode, player: self.gameVM.batter!, bases: 1)
//            var node = enumerateChildNodes(withName: gameVM.batter!.batter.number) {
//            node, stop in
//                self.moveNode(brNode: node, player: self.gameVM.batter!, bases: 1)
//            }
            gameVM.balls = 0
            gameVM.strikes = 0
            plateAppearance.bb = 1
            plateAppearance.outcome["home"] = "BB"
            
            enumerateChildNodes(withName: "Pitch") {
            node, stop in
            node.isHidden = true
            }
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
    
    func getGroundOut(baseRunner: OffensivePlateAppearance) {
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
            if baseRunner.baseOccupied == 1 {
                guard let homeOutcome = plateAppearance.outcome["home"] else { return }
                var outcomeString: String = ""
                if plateAppearance.sac != 1 {
                    if posArray.count > 1 {
                        outcomeString += "G"
                        print("\(posArray)")
                        for i in posArray {
                            outcomeString += "\(i)-"
                            plateAppearance.assist.append("\(i)")
                        }
                        plateAppearance.po.append("\(plateAppearance.assist.popLast()!)")
                        
                    } else {
                        outcomeString += "U"
                        for i in posArray {
                            outcomeString += "\(i)-"
                            plateAppearance.po.append("\(i)")
                        }
                    }
                    if homeOutcome.contains("FC") {
                        //plateAppearance.outcome.popLast()
                        outcomeString = ""
                        for i in posArray {
                            outcomeString += "\(i)-"
                            plateAppearance.assist.append("\(i)")
                        }
                        plateAppearance.po.append("\(plateAppearance.assist.popLast()!)")
                    }
                    outcomeString.removeLast()
                }
                checkRunnerScoring(baseRunner: baseRunner)
                baseRunner.baseOccupied = 0
                plateAppearance.outcome["home"] = outcomeString
            } else if baseRunner.baseOccupied > 1 {
                var outcomeString: String = ""
                if !posArray.isEmpty {
                    if posArray.count > 1 {
                        for i in posArray {
                            outcomeString += "\(i)-"
                            plateAppearance.assist.append("\(i)")
                        }
                        plateAppearance.po.append("\(plateAppearance.assist.popLast()!)")
                    } else {
                        outcomeString += "U"
                        for i in posArray {
                            outcomeString += "\(i)-"
                            plateAppearance.po.append("\(i)")
                        }
                    }
                }
           // print("\(baseRunner.player.batter.number), \(baseRunner.player.baseOccupied)")
                outcomeString.removeLast()
                plateAppearance.outcome["home"] = "FC-\(posArray[0])"
                switchBaserunnerOutcome(baseRunner: baseRunner, outcomeString: outcomeString)
                //baseRunner.player.baseOccupied -= 1
                checkRunnerScoring(baseRunner: baseRunner)
            } else if baseRunner.baseOccupied == 0 {
                var outcomeString: String = "B"
                    for i in posArray {
                        print("\(i)-")
                        outcomeString += "\(i)-"
                        plateAppearance.assist.append("\(i)")
                    }
                    plateAppearance.po.append("\(plateAppearance.assist.popLast()!)")
                outcomeString.removeLast()
                plateAppearance.outcome["home"] = outcomeString
            }
            gameVM.balls = 0
            gameVM.strikes = 0
        } else if setThrownOut {
            var outcomeString: String = ""
            print("\(posArray)")
            for i in posArray {
                outcomeString += "\(i)-"
                plateAppearance.assist.append("\(i)")
            }
            plateAppearance.po.append("\(plateAppearance.assist.popLast()!)")
            outcomeString.removeLast()
            switchBaserunnerOutcome(baseRunner: baseRunner, outcomeString: outcomeString)
            
            resetPositionNodes(scene: self, positions: positionNames)
            posArray.removeAll()
            setThrownOut = false
        } else if setStrikeout {
            var outcomeString: String = "K "
            if posArray.count > 1 {
                for i in posArray {
                    outcomeString += "\(i)-"
                    plateAppearance.assist.append("\(i)")
                }
                plateAppearance.po.append("\(plateAppearance.assist.popLast()!)")
            } else {
                outcomeString += "U"
                for i in posArray {
                    outcomeString += "\(i)-"
                    plateAppearance.po.append("\(i)")
                }
            }
            outcomeString.removeLast()
            plateAppearance.outcome["home"] = outcomeString
            gameVM.balls = 0
            gameVM.strikes = 0
            posArray.removeAll()
            setStrikeout = false
        }
        
        gameVM.baseRunners.removeAll { node in
            node.batter.number == baseRunner.batter.number
        }
        
        baseRunner.outs = gameVM.outs
        
        //baseRunner.node.removeFromParent()
        
    }
    func checkRunnerScoring(baseRunner: OffensivePlateAppearance) {
        if gameVM.baseRunners.contains(where: { $0.baseOccupied == 4 }) && baseRunner.baseOccupied != 4 {
            let scoringRunner: OffensivePlateAppearance? = gameVM.baseRunners.first(where: { $0.baseOccupied == 4 })
            if gameVM.outs < 3 {
                print("scoring runner: \(scoringRunner?.batter.number ?? "nil")")
                scoringRunner!.run = true
                self.gameVM.baseRunners.removeAll(where: { $0 == scoringRunner })
                self.gameVM.incrementScore(team: self.gameVM.halfInning)
                if !setThrownOut {
                    
                    if (!setError || !setErrorField) {
                        enumerateChildNodes(withName: "RBI") { node, stop in
                            node.isHidden = false
                        }
                        
                        setRBI = true
                    }
                }
            } else {
                scoringRunner?.baseOccupied -= 1
            }
        }
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
        gameVM.baseRunners.removeAll(where: { $0 == plateAppearance })
        
        gameVM.batter!.outs = gameVM.outs
        gameVM.balls = 0
        gameVM.strikes = 0
        setPlay = false
        setFlyOut = false
        setGroundOut = false
    }

    func getNodeForBaserunner(player: OffensivePlateAppearance) -> SKNode {
        let nonnode: SKNode = SKNode()
        
        guard let node = self.childNode(withName: player.batter.number) else { return nonnode }
        return node
    
        
    }
    func getGenericNode(name: String) -> SKNode {
        let nonnode: SKNode = SKNode()
        
        guard let node = self.childNode(withName: name) else { return nonnode }
        return node
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
        let touchedNode = self.atPoint(touch.location(in: self))
        for t in touches { self.touchDown(atPoint: t.location(in: self))
            //let touchedNode = self.atPoint(t.location(in: self))
            
            if touchedNode.name == "Pitch" {
                makePitch()
            }
            if touchedNode.name == "Ball" {
                //touchedNode.isHidden = true
                resetPitch()
                addBall()
                
            }
            if touchedNode.name == "Strike" {
                selectStrike()
            }
            if touchedNode.name == "Looking" {
                resetPitch()
                addStrike(pos: 1, gameVM: gameVM, scene: self, plateAppearance: plateAppearance)
                if gameVM.strikes == 3 {
                    for i in gameVM.baseRunners {
                        print("base runner \(i.baseOccupied)")
                    }
                    if gameVM.outs > 1 || !gameVM.baseRunners.contains(where: { $0.baseOccupied == 1 }) {
                        // dropped 3rd strike in play
                        print("dropped 3rd strike in play, \(gameVM.outs) outs")
                            setStrikeout = true
                        
                    } else {
                        // batter out on 3rd strike
                        print("dropped 3rd strike not in play, \(gameVM.outs) outs")
                        getStrikeout(type: "l")
                    }
                    
                }
                
            }
            if touchedNode.name == "Swinging" {
                resetPitch()
                addStrike(pos: 2, gameVM: gameVM, scene: self, plateAppearance: plateAppearance)
                if gameVM.strikes == 3 {
                    for i in gameVM.baseRunners {
                        print("base runner \(i.baseOccupied)")
                    }
                    if gameVM.outs > 1 || !gameVM.baseRunners.contains(where: { $0.baseOccupied == 1 }) {
                        print("dropped 3rd strike in play, \(gameVM.outs) outs")
                        setStrikeout = true
                        
                    } else {
                        print("dropped 3rd strike not in play, \(gameVM.outs) outs")
                        getStrikeout(type: "s")
                    }
                    
                    
                }
            }
            if touchedNode.name == "Foul" {
                resetPitch()
                addStrike(pos: 3, gameVM: gameVM, scene: self, plateAppearance: plateAppearance)
            }
            if touchedNode.name == "In-Play" {
                gameVM.pitches[gameVM.halfInning]?["strikes"]! += 1
                gameVM.batter!.pitches.append(.inPlay)
                getInPlay()
            }
            if touchedNode.name == "Hit" {
                getBaseHit()
            }
            if touchedNode.name == "1B" || touchedNode.name == "2B" || touchedNode.name == "3B" || touchedNode.name == "HR" {
                getHitType(node: touchedNode)
            }
            if touchedNode.name == "HBP" {
                gameVM.pitches[gameVM.halfInning]?["strikes"]! -= 1
                gameVM.batter!.pitches.popLast()
                gameVM.pitches[gameVM.halfInning]?["balls"]! += 1

                gameVM.batter!.pitches.append(.ball)
                getHitType(node: touchedNode)
            }
            if touchedNode.name == "FO" {
                
                setFlyOut = true
            }
            if touchedNode.name == "GO" {
                
                setGroundOut.toggle()
                moveNode(brNode: getNodeForBaserunner(player: gameVM.batter!), player: gameVM.batter!, bases: 1)
            }
            if touchedNode.name == "EHit" {
                
                setError.toggle()
                moveNode(brNode: getNodeForBaserunner(player: gameVM.batter!), player: gameVM.batter!, bases: 1)
                
                getError()
            }
            if touchedNode.name == "SAC" {
                gameVM.pitches[gameVM.halfInning]?["strikes"]! += 1
                plateAppearance.pitches.append(.inPlay)
                setSac = true
                getSAC()
            }
            if touchedNode.name == "B" {
                setGroundOut.toggle()
                guard let outcome = plateAppearance.outcome["home"] else { return }
                plateAppearance.outcome["home"] = "B"
                moveNode(brNode: getNodeForBaserunner(player: gameVM.batter!), player: gameVM.batter!, bases: 1)
                
            }
            if touchedNode.name == "RBI" {
                touchedNode.run(rbiAction)
                plateAppearance.rbi += 1
                
            }
            if touchedNode.name == "pitched-strike" || touchedNode.name == "pitched-ball" {
                
                
                let pitch = gameVM.batter!.pitches.popLast()
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
            }
            if setStrikeout {
                
                for i in positionNames {
                    if touchedNode.name == i.name { // name is 
                        posArray.append(i.number)
                        touchedNode.run(touchedFieldNode)
                    }
                }
                for i in gameVM.baseRunners {
                    if touchedNode.name == i.batter.number {
                        if posArray.isEmpty { //dropped 3rd strike options
                            toggleNodes(nodes: strikeoutNodes, bool: false, in: self)
                            
                            touchedNode.run(touchedBRNode)
                            brToAdvance = ["player": i, "node": touchedNode]
                            
                        } else {
                            getGroundOut(baseRunner: gameVM.batter!)
                            let node = getNodeForBaserunner(player: gameVM.batter!)
                            node.removeFromParent()
                        }
                    }
                    
                    
                }
            }
            if setFlyOut {
                var tempNodes = inplayNodes
                tempNodes.removeAll(where: { $0 == "FO" } )
                if self.plateAppearance.sac == 1 {
                    tempNodes.removeAll(where: { $0 == "SAC" } )
                }
                toggleNodes(nodes: tempNodes, bool: true, in: self)
                var node = enumerateChildNodes(withName: "SFO") { node, stop in
                    node.isHidden = false
                }
                
                for i in positionNames {
                    if touchedNode.name == i.name {
//                        uncomment for hit line addition to fly balls 
//                        let location = touch.location(in: self)
//                        plateAppearance.hitLoc.x = location.x
//                        plateAppearance.hitLoc.y = location.y
//                        let path = CGMutablePath()
//                        path.move(to: homePlate)
//                        path.addLine(to: CGPoint(x: plateAppearance.hitLoc.x, y: plateAppearance.hitLoc.y))
//                        flyBallNode = SKShapeNode(path: path)
//                        flyBallNode.strokeColor = .white
//                        flyBallNode.lineWidth = 3
//                        flyBallNode.lineCap = .round
//                        addChild(flyBallNode)
                        plateAppearance.outcome["home"] = "F\(i.number)"
                        plateAppearance.po.append("\(i.number)")
                        node = enumerateChildNodes(withName: "SFO") { node, stop in
                            node.isHidden = true
                        }
                        setFlyOut = false
                        let addOutAction = SKAction.run{self.addOutNode(gameVM: self.gameVM, scene: self, plateAppearance: self.plateAppearance)}
                        let removeAction = SKAction.removeFromParent()
                        let seq = SKAction.sequence([touchedFieldNode, addOutAction])
                        touchedNode.run(seq)
                    }
                }
            }
            if setGroundOut {
                var tempNodes = inplayNodes
                tempNodes.removeAll(where: { $0 == "GO" } )
                toggleNodes(nodes: tempNodes, bool: true, in: self)
                toggleNodes(nodes: ["SGO"], bool: false, in: self)
                
                for i in positionNames {
                    if touchedNode.name == i.name {
                        posArray.append(i.number)
                        touchedNode.run(touchedFieldNode)
                        
                    }
                }
                for i in gameVM.baseRunners {
                    if touchedNode.name == i.batter.number {
                        if posArray.isEmpty {
                            touchedNode.run(touchedBRNode)
                            moveNode(brNode: touchedNode, player: i, bases: 1)
                            
                        } else {
                            let addOutAction = SKAction.run{self.getGroundOut(baseRunner: i)}
                            let removeAction = SKAction.removeFromParent()
                            let seq = SKAction.sequence([touchedBRNode, addOutAction, removeAction])
                            touchedNode.run(seq)
                            gameVM.baseRunners.removeAll(where: { $0 == i } )
                        }
                        
                    }
                }
                if touchedNode.name == "SGO" {
                    setGroundOut = false
                    toggleNodes(nodes: ["SGO"], bool: true, in: self)
                }
            }
            if setThrownOut {
                for i in positionNames {
                    if touchedNode.name == i.name {
                        posArray.append(i.number)
                        touchedNode.run(touchedFieldNode)
                    }
                }
                for i in gameVM.baseRunners {
                    if touchedNode.name == i.batter.number {
                        print("touched runner: \(i.baseOccupied)")
                        
                        let addOutAction = SKAction.run{self.getGroundOut(baseRunner: i)}
                        let removeAction = SKAction.removeFromParent()
                        let seq = SKAction.sequence([touchedBRNode, addOutAction, removeAction])
                        touchedNode.run(seq)
                        gameVM.baseRunners.removeAll(where: { $0 == i } )
                        advanceBRMenu(hide: false)
                    }
                }
            }
            if setError {
                var tempNodes = inplayNodes
                tempNodes.removeAll(where: { $0 == "E" } )
                toggleNodes(nodes: tempNodes, bool: true, in: self)
                
                for i in positionNames {
                    if touchedNode.name == i.name {
                        touchedNode.run(errorAction)
                        
                        plateAppearance.re += 1
                        plateAppearance.earnedRun = false
                        plateAppearance.outcome["home"] = "E\(i.number)"
                        
                        gameVM.balls = 0
                        gameVM.strikes = 0
                        addOutcomeLabel()
                        //setError = false
                        plateAppearance.error.append("\(i.number)")
                    }
                }
                for i in gameVM.baseRunners {
                    if touchedNode.name == i.batter.number {
                        touchedNode.run(touchedBRNode)
                        if i.baseOccupied != 0 {
                            switch i.baseOccupied {
                            
                            case 1:
                                i.outcome["first"] = (plateAppearance.outcome["home"] ?? "") + " to  2B"
                            case 2:
                                i.outcome["second"] = (plateAppearance.outcome["home"] ?? "") + " to 3B"
                            case 3:
                                i.outcome["third"] = (plateAppearance.outcome["home"] ?? "") + " to Home"
                            case 4:
                                i.outcome["home"]! += ""
                            default:
                                break
                                
                            }
                            moveNode(brNode: touchedNode, player: i, bases: 1)
                        }
                        
                    }
                }
                
            }
            if setErrorField {
                guard let baseRunner: OffensivePlateAppearance = brToAdvance["player"] as? OffensivePlateAppearance else { return }
                var errorPos: String = ""
                print("\(touchedNode.name ?? "james")")
                for i in positionNames {
                    if touchedNode.name == i.name {
                        touchedNode.run(errorAction)
                        
                        errorPos = "\(i.number)"
                        print(" in if: \(errorPos)")
                        if let playerPos = getPlayerPosForPositionNode(node: touchedNode as! SKLabelNode, lineup: lineup) {
                            playerPos.errors += 1
                        }
                        
                        switch baseRunner.baseOccupied {
                        case 1:
                            baseRunner.outcome["home"]! += ""
                        case 2:
                            baseRunner.outcome["first"] = "E\(errorPos) to  2B"
                        case 3:
                            baseRunner.outcome["second"] = "E\(errorPos) to 3B"
                        case 4:
                            baseRunner.outcome["third"] = "E\(errorPos) to Home"
                        default:
                            break
                            
                        }
                        plateAppearance.error.append(errorPos)
                        //setErrorField.toggle()
                    }
                }
            }
            if advanceBaseRunner || setStrikeout {
                guard let baseRunner: OffensivePlateAppearance = brToAdvance["player"] as? OffensivePlateAppearance else { return }
                guard let baseRunnerNode: SKNode = brToAdvance["node"] as? SKNode else { return }
                if touchedNode.name == "SB" {
                    moveNode(brNode: baseRunnerNode, player: baseRunner, bases: 1)
                    switch baseRunner.baseOccupied {
                    case 1:
                        baseRunner.outcome["home"]! += ""
                    case 2:
                        baseRunner.outcome["first"] = "Stole  2B"
                        baseRunner.sb.append(2)
                    case 3:
                        baseRunner.outcome["second"] = "Stole 3B"
                        baseRunner.sb.append(3)
                    case 4:
                        baseRunner.outcome["third"] = "Stole Home"
                        baseRunner.sb.append(4)
                    default:
                        break
                        
                    }
                    advanceBRMenu(hide: true)
                    
                    var node = enumerateChildNodes(withName: "Pitch") { node, stop in
                        node.isHidden = false
                    }
                }
                if touchedNode.name == "XB" {
                    
                    moveNode(brNode: baseRunnerNode, player: baseRunner, bases: 1)
                    switch baseRunner.baseOccupied {
                    case 1:
                        baseRunner.outcome["home"]! += ""
                    case 2:
                        baseRunner.outcome["first"] = "Adv to  2B"
                    case 3:
                        baseRunner.outcome["second"] = "Adv to 3B"
                    case 4:
                        baseRunner.outcome["third"] = "Adv to Home"
                    default:
                        break
                    }
                    advanceBRMenu(hide: true)
                    if plateAppearance.outcome["home"] == "" {
                        var node = enumerateChildNodes(withName: "Pitch") { node, stop in
                            node.isHidden = false
                        }
                    }
                    
                    
                }
                if touchedNode.name == "WP" {
                    
                    moveNode(brNode: baseRunnerNode, player: baseRunner, bases: 1)
                    switch baseRunner.baseOccupied {
                    case 1:
                        if setStrikeout {
                            baseRunner.outcome["home"]! += "K WP"
                        } else {
                            baseRunner.outcome["home"]! += ""
                        }
                    case 2:
                        baseRunner.outcome["first"] = "WP to  2B"
                    case 3:
                        baseRunner.outcome["second"] = "WP to 3B"
                    case 4:
                        baseRunner.outcome["third"] = "WP to Home"
                    default:
                        break
                    }
                    plateAppearance.wp += 1
                    advanceBRMenu(hide: true)
                                //moveNode(node: brToAdvance ?? gameVM.baseRunners[0], bases: 1)
                    var node = enumerateChildNodes(withName: "Pitch") { node, stop in
                        node.isHidden = false
                    }
                }
                if touchedNode.name == "PB" {
                    
                    moveNode(brNode: baseRunnerNode, player: baseRunner, bases: 1)
                    baseRunner.earnedRun = false
                    switch baseRunner.baseOccupied {
                    case 1:
                        if setStrikeout {
                            baseRunner.outcome["home"]! += "K PB"
                        } else {
                            baseRunner.outcome["home"]! += ""
                        }
                    case 2:
                        baseRunner.outcome["first"] = "PB to  2B"
                    case 3:
                        baseRunner.outcome["second"] = "PB to 3B"
                    case 4:
                        baseRunner.outcome["third"] = "PB to Home"
                    default:
                        break
                        
                    }
                    advanceBRMenu(hide: true)
                    //                    moveNode(node: brToAdvance ?? gameVM.baseRunners[0], bases: 1)
                    var node: Void = enumerateChildNodes(withName: "Pitch") { node, stop in
                        node.isHidden = false
                    }
                }
                if touchedNode.name == "E" {
                    
                    if setStrikeout {
                        setError = true
                    } else {
                        setErrorField = true
                        for i in gameVM.baseRunners {
                            if baseRunner.batter.number == i.batter.number {
                                moveNode(brNode: baseRunnerNode, player: baseRunner, bases: 1)
                            }
                            
                        }
                        baseRunner.earnedRun = false
                        
                        
                        advanceBRMenu(hide: true)
                        if gameVM.batter!.outcome["home"] == "" {
                            var node: Void = enumerateChildNodes(withName: "Pitch") { node, stop in
                                node.isHidden = false
                            }
                        }
                    }
                }
                if touchedNode.name == "TO" {
                    
                    print("TO: \(baseRunner.baseOccupied)")
                    switch baseRunner.baseOccupied {
                    case 1:
                        baseRunner.outcome["first"] = "Thrown out "
                    case 2:
                        baseRunner.outcome["second"] = "Thrown out "
                    case 3:
                        baseRunner.outcome["third"] = "Thrown out "
                    case 4:
                        baseRunner.outcome["third"] = "Thrown out "
                    default:
                        break
                        
                    }
                    posArray.removeAll()
                    advanceBRMenu(hide: true)
                    //moveNode(node: brToAdvance ?? gameVM.baseRunners[0], bases: 1)
                    
                    var node: Void = enumerateChildNodes(withName: "Pitch") { node, stop in
                        node.isHidden = false
                    }
                    setThrownOut = true
                    for i in gameVM.baseRunners {
                        if baseRunner.batter.number == i.batter.number {
                            
                            moveNode(brNode: baseRunnerNode, player: i, bases: 1)
                        }
                    }
                }
            }
            if !setGroundOut && !setStrikeout && !setError {
                
                for i in gameVM.baseRunners {
                    if touchedNode.name == i.batter.number {
                        touchedNode.run(touchedBRNode)
                        if i.baseOccupied != 0 {
                            print("\(i.batter.number)-\(i.baseOccupied)")
                            brToAdvance = ["player": i, "node": touchedNode]
                            advanceBRMenu(hide: false)
                        }
                        
                    }
                }
            }
            //toggleNodes(nodes: sacNodes, bool: true, in: self)
        }
    }
    func getStrikeout(type: String) {
        if type == "l" {
            addOutNode(gameVM: gameVM, scene: self, plateAppearance: plateAppearance)  //green out dot, not out at base X
            self.enumerateChildNodes(withName: "K") {
                node, stop in
                node.isHidden = false
            }
            self.enumerateChildNodes(withName: "KL") {
                node, stop in
                node.isHidden = false
            }
            plateAppearance.outcome["home"] = "KL"
            plateAppearance.k = 1
            addKLabel(scene: self, plateAppearance: plateAppearance)
        } else {
            addOutNode(gameVM: gameVM, scene: self, plateAppearance: plateAppearance)  //green out dot, not out at base X
            self.enumerateChildNodes(withName: "K") {
                node, stop in
                node.isHidden = false
            }
            self.enumerateChildNodes(withName: "KS") {
                node, stop in
                node.isHidden = false
            }
            plateAppearance.outcome["home"] = "KS"
            plateAppearance.k = 1
            addKLabel(scene: self, plateAppearance: plateAppearance)
        }
    }
    
    func advanceBRMenu(hide: Bool) {
        advanceBaseRunner.toggle()
        print("\(advanceBaseRunner)")
        
        toggleNodes(nodes: baseRunnningOptionNodes, bool: hide, in: self)
        var tempNodes = hitNodes + ["Pitch"] + sacNodes
        toggleNodes(nodes: hitNodes, bool: true, in: self)

    }
    func advanceBR(player: OffensivePlateAppearance) {
        var node = enumerateChildNodes(withName: "\(player.batter.number)") { node, stop in
            self.moveNode(brNode: node, player: player, bases: 1)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
       // updateLine(to: location)
        
    }
    func updateLine(to controlPoint: CGPoint) {
        let path = CGMutablePath()
                path.move(to: homePlate)
                // Use a quadratic curve where the touch controls the bend
        path.addQuadCurve(to: CGPoint(x: plateAppearance.hitLoc.x, y: plateAppearance.hitLoc.y), control: controlPoint)
                flyBallNode.path = path
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
        print("FB: \(String(describing: firstBody.name)) cat: \(String(describing: firstBody.physicsBody?.categoryBitMask)) con: \(String(describing: firstBody.physicsBody?.contactTestBitMask))")
        print("SB: \(String(describing: secondBody.name)) cat: \(String(describing: secondBody.physicsBody?.categoryBitMask)) con: \(String(describing: secondBody.physicsBody?.contactTestBitMask))")

        // home to first
//        if (firstBody.physicsBody?.categoryBitMask == (1 << 0) && secondBody.physicsBody?.categoryBitMask == (1 << 1)) {
//            let batter = gameVM.getBaserunner(number: "\(firstBody.name ?? "")")
//            var outcome = batter.outcome["home"]
//            if setError {
//                outcome = "E"
//            }
//            let runner = gameVM.getBaserunner(number: "\(secondBody.name ?? "")")//at first
//            runner.outcome["first"] = (outcome ?? "") + " to 2B"
//            print("H-1: \(String(describing: firstBody.name)) \(String(describing: firstBody.physicsBody?.categoryBitMask))- \(String(describing: secondBody.physicsBody?.categoryBitMask))")
//            print("H-1: \(String(describing: firstBody.name)) \(String(describing: firstBody.physicsBody?.contactTestBitMask))- \(String(describing: secondBody.physicsBody?.contactTestBitMask))")
//            
//            moveNode(brNode: secondBody, player: runner, bases: 1)
//        
//        } else if (secondBody.physicsBody?.categoryBitMask == (1 << 0) && firstBody.physicsBody?.categoryBitMask == (1 << 1)) {
//            let batter = gameVM.getBaserunner(number: "\(secondBody.name ?? "")")
//            var outcome = batter.outcome["home"]
//            if setError {
//                outcome = "E"
//            }
//            let runner = gameVM.getBaserunner(number: firstBody.name!)
//            runner.outcome["first"] = (outcome ?? "") + " to 2B"
//            print("H-1: \(String(describing: firstBody.physicsBody?.categoryBitMask))- \(String(describing: secondBody.physicsBody?.categoryBitMask))")
//            print("H-1: \(String(describing: firstBody.physicsBody?.contactTestBitMask))- \(String(describing: secondBody.physicsBody?.contactTestBitMask))")
//            moveNode(brNode: firstBody, player: runner, bases: 1)
        // first to second
         if (firstBody.physicsBody?.categoryBitMask == (1 << 1) || firstBody.physicsBody?.categoryBitMask == (1 << 0) && secondBody.physicsBody?.categoryBitMask == (1 << 2)) {
            let batter = gameVM.getBaserunner(number: "\(firstBody.name ?? "")")
            let runner = gameVM.getBaserunner(number: "\(secondBody.name ?? "")")
            
            applyOutcomeToLeadRunner(player: batter, leadRunner: runner)
            print("1-2a: \(String(describing: firstBody.physicsBody?.categoryBitMask))- \(String(describing: secondBody.physicsBody?.categoryBitMask))")
            print("1-2a: \(String(describing: firstBody.physicsBody?.contactTestBitMask))- \(String(describing: secondBody.physicsBody?.contactTestBitMask))")
            moveNode(brNode: secondBody, player: runner, bases: 1)
            
        } else if (secondBody.physicsBody?.categoryBitMask == (1 << 1) && firstBody.physicsBody?.categoryBitMask == (1 << 2)) {
            let batter = gameVM.getBaserunner(number: "\(secondBody.name ?? "")")
            let runner = gameVM.getBaserunner(number: "\(firstBody.name ?? "")")
            applyOutcomeToLeadRunner(player: batter, leadRunner: runner)
            print("1-2b: \(String(describing: firstBody.physicsBody?.categoryBitMask))- \(String(describing: secondBody.physicsBody?.categoryBitMask))")
            print("1-2b: \(String(describing: firstBody.physicsBody?.contactTestBitMask))- \(String(describing: secondBody.physicsBody?.contactTestBitMask))")
            moveNode(brNode: firstBody, player: runner, bases: 1)
            
        // second to third
        } else if (firstBody.physicsBody?.categoryBitMask == 1 << 2 || firstBody.physicsBody?.categoryBitMask == (1 << 1) || firstBody.physicsBody?.categoryBitMask == (1 << 0) && secondBody.physicsBody?.categoryBitMask == 1 << 3) {
            let batter = gameVM.getBaserunner(number: "\(firstBody.name ?? "")")
            let runner = gameVM.getBaserunner(number: "\(secondBody.name ?? "")")
            applyOutcomeToLeadRunner(player: batter, leadRunner: runner)
            print("2-3a: \(String(describing: firstBody.physicsBody?.categoryBitMask))- \(String(describing: secondBody.physicsBody?.categoryBitMask))")
            print("2-3a: \(String(describing: firstBody.physicsBody?.contactTestBitMask))- \(String(describing: secondBody.physicsBody?.contactTestBitMask))")

            moveNode(brNode: secondBody, player: runner, bases: 1)
            
        } else if (secondBody.physicsBody?.categoryBitMask == 1 << 2 && firstBody.physicsBody?.categoryBitMask == 1 << 3) {
            let batter = gameVM.getBaserunner(number: "\(secondBody.name ?? "")")
            let runner = gameVM.getBaserunner(number: "\(firstBody.name ?? "")")
            applyOutcomeToLeadRunner(player: batter, leadRunner: runner)
            print("2-3b: \(String(describing: firstBody.physicsBody?.categoryBitMask))- \(String(describing: secondBody.physicsBody?.categoryBitMask))")
            print("2-3b: \(String(describing: firstBody.physicsBody?.contactTestBitMask))- \(String(describing: secondBody.physicsBody?.contactTestBitMask))")
            moveNode(brNode: firstBody, player: runner, bases: 1)
        }
    }
    func checkTrailingRunnerOutcome(player: OffensivePlateAppearance) -> String { // playerTwo is the lead runner
        if player.outcome["third"] != "" { // third to home
            return player.outcome["third"] ?? ""
        } else if player.outcome["second"] != "" { // second to third
            return player.outcome["second"] ?? ""
        } else if player.outcome["first"] != "" { // first to second 1B for example
            return player.outcome["first"] ?? ""
        } else { // home to first 1B for example
            return player.outcome["home"] ?? ""
        }
    }
    func applyOutcomeToLeadRunner(player: OffensivePlateAppearance, leadRunner: OffensivePlateAppearance) {
        let outcomeToApply = checkTrailingRunnerOutcome(player: player)
        print("outcome to apply: \(outcomeToApply)")
        if leadRunner.outcome["first"] == "" { // third to home
            leadRunner.outcome["first"] = outcomeToApply
        } else if leadRunner.outcome["second"] == "" { // second to third
            leadRunner.outcome["second"] = outcomeToApply
        } else if leadRunner.outcome["third"] == "" { // first to second 1B for example
            leadRunner.outcome["third"] = outcomeToApply
        } else { // home to first 1B for example
            
        }
    }
    func moveNode(brNode: SKNode, player: OffensivePlateAppearance, bases: Int) {
        print("before move:\(player.baseOccupied)")
        print("\(brNode.name)-\(brNode.physicsBody?.categoryBitMask) \(brNode.physicsBody?.contactTestBitMask)")
            switch player.baseOccupied {
            case 0:
                brNode.run(SKAction.sequence([SKAction.move(to: self.firstBase, duration: 0.5), SKAction.wait(forDuration: 0.5)]))
                
                
                if !setSac || setError { // && !setError
                    player.baseOccupied += 1
                }
                brNode.physicsBody?.categoryBitMask = (1 << 1)

            case 1:
                let action = SKAction.run {

                }
                brNode.run(SKAction.sequence([SKAction.move(to: self.secondBase, duration: 0.5), SKAction.wait(forDuration: 0.5), action]))
                player.baseOccupied += 1

                if setThrownOut {
                    //node.player.baseOccupied -= 1
                }
            case 2:
                let action = SKAction.run {

                }
                brNode.run(SKAction.sequence([ SKAction.move(to: self.thirdBase, duration: 0.5), SKAction.wait(forDuration: 0.5), action]))
                player.baseOccupied += 1

            case 3:
                
                if !setGroundOut && !setThrownOut {
                    brNode.run(SKAction.sequence([SKAction.move(to: self.homePlate, duration: 0.5), SKAction.wait(forDuration: 0.3), SKAction.removeFromParent()]))
                    player.baseOccupied += 1
                    player.run = true
                    self.gameVM.baseRunners.removeAll(where: {$0 == player})
                    self.gameVM.incrementScore(team: self.gameVM.halfInning)
                    print("\(setError) \(setErrorField)")
                    if !setError && !setErrorField {
                        var node = enumerateChildNodes(withName: "RBI") { node, stop in
                            node.isHidden = false
                        }
                        
                        setRBI = true
                    } else {
                        player.earnedRun = false
                    }
                    
                } else {  // if setGroundOut == true and setThrownOut == true
                    player.baseOccupied += 1
                    
                    
                    brNode.run(SKAction.sequence([SKAction.move(to: self.homePlate, duration: 0.5), SKAction.wait(forDuration: 0.3)]))
                }
                
            default:
                break
            }
        print("after move:\(player.baseOccupied)")
        print("\(brNode.name)-\(brNode.physicsBody?.categoryBitMask) \(brNode.physicsBody?.contactTestBitMask)")
    }
    
    func makePitch() {
        toggleNodes(nodes: pitchNodes, bool: false, in: self)
        enumerateChildNodes(withName: "Pitch") { node, stop in
            node.isHidden = true
        }
    }
    func selectStrike() {
        toggleNodes(nodes: pitchNodes, bool: true, in: self)
        toggleNodes(nodes: strikeNodes, bool: false, in: self)
    }
    
    func resetPitch() {
        toggleNodes(nodes: strikeNodes, bool: true, in: self)
        toggleNodes(nodes: pitchNodes, bool: true, in: self)
        enumerateChildNodes(withName: "Pitch") { node, stop in
        node.isHidden = false
        }
    }
    func getInPlay() {
        toggleNodes(nodes: pitchNodes, bool: true, in: self)
        toggleNodes(nodes: inplayNodes, bool: false, in: self)

    }
    func getError() {
        
        
        
    }
    func getBunt() {
        plateAppearance.outcome["home"] = "B"
        
//        var node = enumerateChildNodes(withName: "Hit") { node, stop in
//            node.isHidden.toggle()
//        }
//        node = enumerateChildNodes(withName: "GO") { node, stop in
//            node.isHidden.toggle()
//        }
//        node = enumerateChildNodes(withName: "FO") { node, stop in
//            node.isHidden.toggle()
//        }
//        node = enumerateChildNodes(withName: "HBP") { node, stop in
//            node.isHidden.toggle()
//        }
//        node = enumerateChildNodes(withName: "EHit") { node, stop in
//            node.isHidden = true
//        }
    }
    func getSAC() {
        plateAppearance.outcome["home"] = "SAC"
        plateAppearance.sac = 1
        var tempNodes = inplayNodes
        tempNodes.removeAll(where: { $0 == plateAppearance.outcome["home"] } )
        toggleNodes(nodes: tempNodes, bool: true, in: self)
        toggleNodes(nodes: sacNodes, bool: false, in: self)

    }

    func getBaseHit() {
        toggleNodes(nodes: inplayNodes, bool: true, in: self)
        toggleNodes(nodes: hitNodes, bool: false, in: self)
    }
    func getHitType(node: SKNode) {
        
        switch node.name! {
        case "1B":
            plateAppearance.outcome["home"] = "1B"
            plateAppearance.hit = 1
            setPlay.toggle()
        case "2B":
            plateAppearance.outcome["home"] = "2B"
            plateAppearance.hit = 2
            setPlay.toggle()

        case "3B":
            plateAppearance.outcome["home"] = "3B"
            plateAppearance.hit = 3
            setPlay.toggle()

        case "HR":
            plateAppearance.hit = 4
            plateAppearance.outcome["home"] = "HR"
            setPlay.toggle()

        case "HBP":
            plateAppearance.hp = 1
            plateAppearance.outcome["home"] = "HBP"
            
            
            gameVM.balls = 0
            gameVM.strikes = 0

            var node = enumerateChildNodes(withName: "\(self.gameVM.batter!.batter.number)") { node, stop in
                self.moveNode(brNode: node, player: self.gameVM.batter!, bases: 1)
            }
            
        default: break
        }
        var tempNodes = hitNodes
        tempNodes.removeAll(where: { $0 == plateAppearance.outcome["home"] } )
        toggleNodes(nodes: tempNodes, bool: true, in: self)
        
    }
    
    
    
    func setUpScene() {
        
        if largeView {

            placeBaseRunnerNodes(gameVM: gameVM, scene: self)
            

            
            addPositionNodes(positionNames: positionNames, lineup: lineup, scene: self, setPlay: setPlay)

            
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
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.25), size: 50, name: "Pitch", hidden: plateAppearance.outcome["home"] == "" ? false : true)
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
            addErrorNode(center: CGPoint(x: self.frame.maxX*0.15, y: self.frame.maxY*0.45), size: 20, name: "EHit", hidden: true)  // error on batted ball
            addErrorNode(center: CGPoint(x: self.frame.maxX*0.15, y: self.frame.maxY*0.45), size: 20, name: "E", hidden: true)  // error on basepaths play
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.20, y: self.frame.maxY*0.35), size: 20, name: "1B", hidden: plateAppearance.hit == 1 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.40, y: self.frame.maxY*0.35), size: 20, name: "2B", hidden: plateAppearance.hit == 2 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.60, y: self.frame.maxY*0.35), size: 20, name: "3B", hidden: plateAppearance.hit == 3 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.80, y: self.frame.maxY*0.35), size: 20, name: "HR", hidden: plateAppearance.hit == 4 ? false : true)
            addGenericNode(center: CGPoint(x: self.frame.maxX*0.20, y: self.frame.maxY*0.35), size: 20, name: "BB", hidden: plateAppearance.outcome["home"] == "BB" ? false : true)
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
            //addOutcomes(plateAppearance: plateAppearance, scene: self)
            
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
