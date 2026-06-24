//
//  FieldViewFunctions.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/13/26.
//

import Foundation
import RegexBuilder
import SpriteKit
import SwiftData
import SwiftUI

var baseNode = "Pitch"
var pitchNodes = ["Strike", "Ball", "In-Play"]
var strikeNodes = ["Looking", "Swinging", "Foul"]
var inplayNodes = ["EHit", "Hit", "GO", "FO", "HBP", "SAC"]
var hitNodes = ["1B", "2B", "3B", "HR"]
var baseRunnningOptionNodes = ["E", "SB", "XB", "WP", "PB", "TO"]
var afterHitBaseRunningOptionNodes = ["E", "XB", "TO"]
var strikeoutNodes = ["WP", "PB", "EHit", "TO"]
var sacNodes = ["B", "FO", "EHit"]



func toggleNodes(nodes: [String], bool: Bool, in scene: SKScene) {
    for each in nodes {
        scene.enumerateChildNodes(withName: each) { node, _ in
            node.isHidden = bool
        }
    }
    
}
func placeField(scene: SKScene) {
    var field = SKSpriteNode()
    
    field = SKSpriteNode(imageNamed: "field")
    
    
    field.position = CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.65)
    
    field.scale(to: CGSize(width: scene.frame.width, height: scene.frame.height*0.5))
    scene.addChild(field)
}

func outPoint(p1: CGPoint, p2: CGPoint, scaleFactor: Double) -> CGPoint {
    let x = p1.x
    let y = p1.y
    let x1 = p2.x
    let y1 = p2.y
    let lineSlope = (y1-y) / (x1-x)
    let a = (x1-x) * scaleFactor + x
    let b = (y1-y) * scaleFactor + y
    
    return CGPoint(x: CGFloat(a), y: CGFloat(b))
}

func outLine(p1: CGPoint, p2: CGPoint, plateAppearance: OffensivePlateAppearance, scene: SKScene) -> SKShapeNode {
    let x = p1.x  //firstbase
    let y = p1.y
    let x1 = p2.x  //secondbase
    let y1 = p2.y
    let lineSlope = (y1-y) / (x1-x)
    let a1 = x1 + 1
    let b1 = -1/lineSlope * 1 + y1
    let a2 = x1 - 1
    let b2 = -1/lineSlope * -1 + y1
    
    let c = CGPoint(x: CGFloat(a1), y: CGFloat(b1))
    let d = CGPoint(x: CGFloat(a2), y: CGFloat(b2))

    let pathNode = SKShapeNode()
    let path = CGMutablePath()
    path.move(to: c)
    path.addLine(to: d)
    pathNode.path = path
    pathNode.strokeColor = .red
    pathNode.lineWidth = 3
    //scene.addChild(pathNode)
    
    
    return pathNode
}

func placeBaseRunners(basepathNode: SKShapeNode, baseOccupied: Int, plateAppearance: OffensivePlateAppearance, scene: SKScene) {
    var homePlate: CGPoint { CGPoint(x: scene.frame.midX, y: scene.frame.midY*0.92) }
    var firstBase: CGPoint { CGPoint(x: scene.frame.maxX*0.83, y: scene.frame.maxY*0.635) }
    var secondBase: CGPoint { CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.8) }
    var thirdBase: CGPoint { CGPoint(x: scene.frame.maxX*0.17, y: scene.frame.maxY*0.635) }
    
//    var homePlate: CGPoint { CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.65-150) }
//    var firstBase: CGPoint { CGPoint(x: scene.frame.maxX-75, y: scene.frame.maxY*0.65-50) }
//    var secondBase: CGPoint { CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.65+100) }
//    var thirdBase: CGPoint { CGPoint(x: scene.frame.minX+75, y: scene.frame.maxY*0.65-20) }
    
    var secondBase2: CGPoint { CGPoint(x: (scene.frame.midX + 3), y: (scene.frame.maxY*0.7)) }
    var thirdBase2: CGPoint { CGPoint(x: scene.frame.maxX*0.17 + 3, y: scene.frame.maxY*0.635 - 3) }
    var homePlate2: CGPoint { CGPoint(x: scene.frame.midX - 3, y: scene.frame.midY*0.75) }
    
    let path = CGMutablePath()
    var pathNode = SKShapeNode()
    
    path.move(to: homePlate)
    if baseOccupied == 1 {//|| (plateAppearance.hit == 1 && plateAppearance.outs != 0) {
        path.addLine(to: firstBase)
        basepathNode.path = path
        basepathNode.strokeColor = plateAppearance.re != 1 ? .blue : .red
        basepathNode.lineWidth = 3
        if plateAppearance.outs != 0 {
            path.addLine(to: outPoint(p1: firstBase, p2: secondBase, scaleFactor: 0.8))
            basepathNode.path = path
            basepathNode.strokeColor = plateAppearance.re != 1 ? .blue : .red
            basepathNode.lineWidth = 3
            pathNode = outLine(p1: firstBase, p2: outPoint(p1: firstBase, p2: secondBase, scaleFactor: 0.7), plateAppearance: plateAppearance, scene: scene)
            //add secondary position out label
            
        }
        //addOutcomes(plateAppearance: plateAppearance, scene: scene, base: 1)
        //addHitLoc()
    } else if baseOccupied == 2 {//|| (plateAppearance.hit == 2 && plateAppearance.outs != 0) {
        path.addLine(to: firstBase)
            
        if plateAppearance.outs != 0 {
            
            path.addLine(to: outPoint(p1: firstBase, p2: secondBase, scaleFactor: 0.8)) //(to: thirdBase2)
            
            pathNode = outLine(p1: firstBase, p2: outPoint(p1: firstBase, p2: secondBase, scaleFactor: 0.7), plateAppearance: plateAppearance, scene: scene)
            //addOutX(base: thirdBase2, scene: scene)
        } else {
            path.addLine(to: secondBase)
        }
        //addOutcomes(plateAppearance: plateAppearance, scene: scene, base: 2)

        basepathNode.path = path
        basepathNode.strokeColor = plateAppearance.re != 1 ? .blue : .red
        basepathNode.lineWidth = 3
        //addHitLoc()
    } else if baseOccupied == 3 {//|| (plateAppearance.hit == 3 && plateAppearance.outs != 0) {
        path.addLine(to: firstBase)
        path.addLine(to: secondBase)
        
        if plateAppearance.outs != 0 {
            path.addLine(to: outPoint(p1: secondBase, p2: thirdBase, scaleFactor: 0.8)) //homePlate2)
            
            pathNode = outLine(p1: secondBase, p2: outPoint(p1: secondBase, p2: thirdBase, scaleFactor: 0.7), plateAppearance: plateAppearance, scene: scene)
            //addOutcomes(plateAppearance: plateAppearance, scene: scene, base: 3)
            //addOutX(base: homePlate2, scene: scene)
        } else {
            path.addLine(to: thirdBase)
        }
        basepathNode.path = path
        basepathNode.strokeColor = plateAppearance.re != 1 ? .blue : .red
        basepathNode.lineWidth = 3
        //addHitLoc()
    } else if baseOccupied == 4 {
        path.addLine(to: firstBase)
        path.addLine(to: secondBase)
        path.addLine(to: thirdBase)
        
        if plateAppearance.outs != 0 {
            path.addLine(to: outPoint(p1: thirdBase, p2: homePlate, scaleFactor: 0.8)) //homePlate2)
            
            pathNode = outLine(p1: thirdBase, p2: outPoint(p1: thirdBase, p2: homePlate, scaleFactor: 0.7), plateAppearance: plateAppearance, scene: scene)
            //addOutcomes(plateAppearance: plateAppearance, scene: scene, base: 4)
            //addOutX(base: homePlate2, scene: scene)
        
        } else {
            path.addLine(to: homePlate)
            path.closeSubpath()
            basepathNode.fillColor = plateAppearance.re != 1 ? .blue : .red
            
        }
        basepathNode.path = path
        basepathNode.strokeColor = plateAppearance.re != 1 ? .blue : .red
        basepathNode.lineWidth = 3
        //addHitLoc()
    } else if baseOccupied == 5 || baseOccupied == 0 {
        //placeKLabel(plateAppearance: plateAppearance, scene: scene)
        addOutcomes(plateAppearance: plateAppearance, scene: scene, base: baseOccupied)
    }
    scene.addChild(basepathNode)
    scene.addChild(pathNode)
}
func addBaserunningLabels(plateAppearance: OffensivePlateAppearance, scene: SKScene) {
    var firstBase: CGPoint { CGPoint(x: scene.frame.maxX*0.75, y: scene.frame.maxY*0.68) }
    var secondBase: CGPoint { CGPoint(x: scene.frame.maxX*0.25, y: scene.frame.maxY*0.68) }
    var thirdBase: CGPoint { CGPoint(x: scene.frame.maxX*0.275, y: scene.frame.midY*0.95) }
    let errorRegex = Regex {
        Capture {
            "E"
            One(.digit)
        }
    }
    for outcome in ["first", "second", "third"] {
        let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
        labelNode.fontSize = 6
        labelNode.fontColor = .white
        labelNode.isHidden = false
        labelNode.zPosition = 100
        switch outcome {
        case "first":
            labelNode.position = firstBase
        case "second":
            labelNode.position = secondBase
        case "third":
            labelNode.position = thirdBase
        default:
            break
        }
        //labelNode.setScale(0.35)
        guard let outcomeText = plateAppearance.outcome[outcome] else {
            print("did not get outcome")
            return }
        if outcomeText.contains(/^WP/) {
            labelNode.text = "WP"
            labelNode.name = "WP" + "_" + outcome
            scene.addChild(labelNode)

        } else if outcomeText.contains(/^PB/) {
            labelNode.text = "PB"
            labelNode.name = "PB" + "_" + outcome
            scene.addChild(labelNode)

        } else if outcomeText.contains(/^Stole/) {
            labelNode.text = "SB"
            labelNode.name = "SB" + "_" + outcome
            scene.addChild(labelNode)
        } else if outcomeText.contains(errorRegex) {
            if let match = outcomeText.firstMatch(of: errorRegex) {
                labelNode.text = "\(match.1, default: "EoFCfail")"
                //labelNode.text = "E"
                labelNode.name = "E" + "_" + outcome
                scene.addChild(labelNode)
            }
        }
    }
}

func placeKLabel(plateAppearance: OffensivePlateAppearance, scene: SKScene) {
    let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
    labelNode.text = "K"
    labelNode.name = "K"
    labelNode.fontSize = 20
    labelNode.fontColor = plateAppearance.outcome["home"] == "KS" ? .black : .red
    labelNode.position = CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.5)
    labelNode.setScale(0.5)
    labelNode.isHidden = plateAppearance.outcome["home"] ==  "KS" || plateAppearance.outcome["home"] ==  "KL" ? false : true
    
    labelNode.xScale = plateAppearance.outcome["home"] == "KS" ? 1 : -1
    
    scene.addChild(labelNode)
}

func addOutcomes(plateAppearance: OffensivePlateAppearance, scene: SKScene, base: Int) -> [String] {
    var outcome = ""
    var outcomeArray: [String] = []
//    switch base {
//    case 1: outcome = plateAppearance.outcome["home"] ?? "none1"
//    case 2: outcome = plateAppearance.outcome["first"] ?? "none2"
//    case 3: outcome = plateAppearance.outcome["second"] ?? "none3"
//    case 4: outcome = plateAppearance.outcome["third"] ?? "none4"
//    default: outcome = plateAppearance.outcome["home"] ?? "none5"
//    }
//    
//    if outcome.contains(/[F]\d/) || outcome.starts(with: "U") {
//        addOutcomeNode(center: CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.5), size: 12, name: outcome, hidden: false, color: .red, scene: scene)
//    } else if outcome.starts(with: "G") {
//        addOutcomeNode(center: CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.5), size: 12, name: outcome.replacingOccurrences(of: "G", with: ""), hidden: false, color: .red, scene: scene)
//    } else if outcome.contains(/[B]\d/) {
//        addOutcomeNode(center: CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.5), size: 12, name: outcome, hidden: false, color: .red, scene: scene)
//    } else if outcome.starts(with: "E") || outcome.starts(with: "FC") {
//        addOutcomeNode(center: CGPoint(x: scene.frame.maxX*0.75, y: scene.frame.maxY*0.8), size: 8, name: outcome, hidden: false, color: .red, scene: scene)
//    } else if outcome.contains(/\d-\d-\d/) || outcome.contains(/\d-\d/) {
//        let regex = /(\d-\d)/
//        if let match = outcome.firstMatch(of: regex) {
//            outcome = "\(match.1)"
//        }
//        addOutcomeNode(center: CGPoint(x: scene.frame.maxX*0.75, y: scene.frame.maxY*0.8), size: 8, name: outcome, hidden: false, color: .red, scene: scene)
//    } else if outcome.starts(with: "K") {
//        let regex = /([K ])/
//        if plateAppearance.outs != 0 {
//            
//        }
//    }
    
    //.replacingOccurrences(of: "G", with: "")   if outcome.contains(/\d-\d-\d/)
    var placeHolder = 0.0
    for each in ["home", "first", "second", "third"] {
        outcome = plateAppearance.outcome[each] ?? "none \(each)"
        if outcome.contains(/[F]\d/) || outcome.starts(with: "U") || outcome.starts(with: "K") && each == "home" {
            let newRegex = Regex {
                Capture {
                    "K"
                    Optionally {
                        "S"
                    }
                    Optionally {
                        "L"
                    }
                }
                " "
                Capture {
                    Optionally {
                        "U"
                        One(.digit)
                    }
                    Optionally {
                        OneOrMore {
                            One(.digit)
                            "-"
                        }
                        One(.digit)
                    }
                    Optionally {
                        "WP"
                    }
                    Optionally {
                        "PB"
                    }
                    Optionally {
                        "E"
                        One(.digit)
                    }
                }
            }
            if let match = outcome.firstMatch(of: newRegex) {
                outcome = "\(match.1, default: "Kfail")"
                outcomeArray.append("K \(match.2, default: "Kfail")")
                print("0-\(match.0, default: "Kfail") 1-\(match.1, default: "Kfail") 2-\(match.2, default: "Kfail")")
            }
            
            addOutcomeNode(center: CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.5), size: 12, name: outcome, hidden: false, color: .red, scene: scene)
        } else if outcome.starts(with: "G") {
            //outcomeArray.append(outcome.replacingOccurrences(of: "G", with: ""))
            addOutcomeNode(center: CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.5), size: 12, name: outcome.replacingOccurrences(of: "G", with: ""), hidden: false, color: .red, scene: scene)
        } else if outcome.contains(/[B]\d/) {
            //outcomeArray.append(outcome)
            addOutcomeNode(center: CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.5), size: 12, name: outcome, hidden: false, color: .red, scene: scene)
        } else if outcome.starts(with: "E") || outcome.starts(with: "FC") {
            let newRegex = Regex {
                Capture {
                    Optionally {
                        "E"
                        One(.digit)
                    }
                    Optionally {
                        "FC-"
                        One(.digit)
                    }
                }
            }
            let regex = /(E\d)|(FC-\d)/
            var length = 0.0
            if let match = outcome.firstMatch(of: newRegex) {
                outcome = "\(match.1, default: "EoFCfail")"
                length = Double(outcome.count)
                if each == "home" {
                    outcomeArray.append(outcome)
                }
                
            }
            addOutcomeNode(center: CGPoint(x: scene.frame.maxX - length * 1.5, y: scene.frame.maxY*0.8-7*placeHolder), size: 8, name: outcome, hidden: false, color: .red, scene: scene)
            placeHolder += 1.0
        } else if outcome.contains(/\d-\d-\d/) || outcome.contains(/\d-\d/) {
            let newRegex = Regex {
                Capture {
                    OneOrMore {
                        .digit
                        "-"
                    }
                    One(.digit)
                }
            }
            let regex = /((\d-)+\d)/
            var length = 0.0
            if let match = outcome.firstMatch(of: newRegex) {
                outcome = "\(match.1, default: "Dfaild-d")"
                length = Double(outcome.count)
                outcomeArray.append(outcome)
            }
            addOutcomeNode(center: CGPoint(x: scene.frame.maxX - length * 1.5, y: scene.frame.maxY*0.8-7*placeHolder), size: 8, name: outcome, hidden: false, color: .red, scene: scene)
        } else if outcome.starts(with: "U") && each != "home" {
            let regex = /(U\d)/
            var length = 0.0
            if let match = outcome.firstMatch(of: regex) {
                outcome = "\(match.1, default: "failU")"
                length = Double(outcome.count)
                outcomeArray.append(outcome)
            }
            addOutcomeNode(center: CGPoint(x: scene.frame.maxX - length * 1.5, y: scene.frame.maxY*0.8-7*placeHolder), size: 8, name: outcome, hidden: false, color: .red, scene: scene)
        }
//        } else if outcome.starts(with: "K") {
//            let regex = /([K ])/
//            if plateAppearance.baseOccupied == 0 {
//                addOutcomeNode(center: CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.5), size: 12, name: outcome, hidden: false, color: .red, scene: scene)
//                outcomeArray.append(outcome)
//            } else {
//                addOutcomeNode(center: CGPoint(x: scene.frame.maxX*0.9, y: scene.frame.maxY*0.8-7*placeHolder), size: 8, name: outcome, hidden: false, color: .red, scene: scene)
//                placeHolder += 1.0
//                outcomeArray.append(outcome)
//            }
//        }
    }
    return outcomeArray
}



func addHitLoc(plateAppearance: OffensivePlateAppearance, scene: SKScene) {
    var  homePlate: CGPoint { CGPoint(x: scene.frame.midX, y: scene.frame.midY*0.92) }
    let path = CGMutablePath()
    path.move(to: homePlate)
    path.addLine(to: CGPoint(x: scene.frame.maxX*(plateAppearance.hitLoc.x) , y: 13.0*(plateAppearance.hitLoc.y)+homePlate.y + 5.0)) //self.frame.maxY*(plateAppearance.hitLoc.y)+homePlate.y))
    
    let node = SKShapeNode(path: path)
    node.strokeColor = .red
    node.lineWidth = 2
    
    //node.xScale = 0.5
    //node.yScale = 0.5
    if plateAppearance.hitLoc.y != 0 {
        scene.addChild(node)
    }
    
}

func addOutX(base: CGPoint, scene: SKScene) {
    let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
    labelNode.text = "X"
    labelNode.name = "X"
    labelNode.fontSize = 15
    labelNode.fontColor = .black
    labelNode.position = base
    labelNode.setScale(0.5)
    
    scene.addChild(labelNode)
}

func addOutcomeNode(center: CGPoint, size: CGFloat, name: String, hidden: Bool, color: UIColor, scene: SKScene) {
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
    if size < 10 {
        //scene.addChild(node)
    }
    let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
    if name == "KL" {
        print("LN-\(name)")
        labelNode.text = "K"
        labelNode.xScale = -1
    } else if name == "KS" {
        labelNode.text = "K"
    } else {
        labelNode.text = name
    }
    
    labelNode.name = name
    labelNode.fontSize = size
    labelNode.fontColor = color
    labelNode.position = CGPoint(x: center.x, y: center.y)
    labelNode.zPosition = 100
    labelNode.isHidden = hidden
    
    scene.addChild(labelNode)
}

func addPlateAppearanceNode(center: CGPoint, size: CGFloat, name: String, hidden: Bool, color: UIColor, scene: SKScene) {
    
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
    scene.addChild(labelNode)
}

func addGenericNode(center: CGPoint, size: CGFloat, name: String, hidden: Bool, scene: SKScene) {
    
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
    scene.addChild(node)
    let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
    labelNode.text = name
    labelNode.name = name
    labelNode.fontSize = 30
    labelNode.fontColor = .black
    labelNode.position = CGPoint(x: center.x, y: center.y-50/4)
    labelNode.isHidden = hidden
    scene.addChild(labelNode)
}

func addErrorNode(center: CGPoint, size: CGFloat, name: String, hidden: Bool, scene: SKScene) {
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
    scene.addChild(node)
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
    scene.addChild(labelNode)
}

func addPositionNodes(positionNames: [PositionDescription], lineup: [PlayerPos], scene: SKScene, setPlay: Bool) {
    //    eg:      PositionDescription(number: 1, name: "pitcher", location: CGPoint(x: self.frame.midX, y: self.frame.maxY*0.65), abbreviation: "P"),

    for pos in positionNames {
        let node = SKLabelNode(fontNamed: "Trebuchet MS")
        let player = lineup.first(where: { $0.position.lowercased() == pos.abbreviation.lowercased() })
        node.text = "#\(player?.player.number ?? "\(pos.number)")"
//        node.text = "#\(gameVM.defensiveLineup["\(pos.abbreviation)"]?.number ?? "\(pos.number)")"
        node.fontSize = 20
        node.fontColor = SKColor.white
        node.position = pos.location
        node.name = pos.name
        scene.addChild(node)
        
        let secondNode = SKLabelNode(fontNamed: "Trebuchet MS")
        secondNode.text = "#\(player?.player.number ?? "\(pos.number)")"
        secondNode.fontSize = 20
        secondNode.fontColor = SKColor.systemPink
        secondNode.position = pos.location
        secondNode.name = pos.name + "2"
        secondNode.zPosition = 10
        secondNode.isHidden = true
        scene.addChild(secondNode)
    }
}
func getPlayerPosForPositionNode(node: SKLabelNode, lineup: [PlayerPos]) -> PlayerPos? {
    for player in lineup {
        if player.player.number == node.text {
            return player
        }
    }
    return nil
}

func getPlayerPosForPositionNumber(positionNumber: Int, lineup: [PlayerPos]) -> PlayerPos? {
    for each in Positions.allCases {
        if positionNumber == each.number {
            let player = lineup.first(where: { $0.position == each.abbreviation })
            return player
        }
    }
    return nil
}

func resetPositionNodes(scene: SKScene, positions: [PositionDescription]) {
    for child in scene.children {
        
        if child.name?.contains("2") == true {
            child.isHidden = true
        }
    }
    for child in scene.children {
        for pos in positions {
            if child.name == pos.name {
                child.isHidden = false
            }
        }
        
    }
}
func switchBaserunnerOutcome(baseRunner: OffensivePlateAppearance, outcomeString: String) {
    switch baseRunner.baseOccupied {
    case 1:
        baseRunner.outcome["home"]! += outcomeString + " at 1B"
    case 2:
        baseRunner.outcome["first"]! += outcomeString + " at 2B"
    case 3:
        baseRunner.outcome["second"]! += outcomeString + " at 3B"
    case 4:
        baseRunner.outcome["third"]! += outcomeString + " at Home"
    default:
        break
        
    }
}

func placeBaseRunnerNodes(gameVM: GameViewModel, scene: SKScene) {
    
    for player in gameVM.baseRunners {
        
        let node = createBaseRunnerNode(player: player, scene: scene)
        
        scene.addChild(node)
    }
}
struct PhysicsCategories {
    static let none: UInt32 = 0
    static let home: UInt32 = 1 << 0
    static let first: UInt32 = 1 << 1
    static let second: UInt32 = 1 << 2
    static let third: UInt32 = 1 << 3
}
func createBaseRunnerNode(player: OffensivePlateAppearance, scene: SKScene) -> SKLabelNode {
    var homePlate: CGPoint { CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.45) }
    var firstBase: CGPoint { CGPoint(x: scene.frame.midX*1.64, y: scene.frame.maxY*0.62) }
    var secondBase: CGPoint { CGPoint(x: scene.frame.midX, y: scene.frame.maxY*0.78) }
    var thirdBase: CGPoint { CGPoint(x: scene.frame.midX*0.36, y: scene.frame.maxY*0.62) }
    var node = SKLabelNode(fontNamed: "Trebuchet MS")
    node.fontColor = .blue


    node.physicsBody = SKPhysicsBody(circleOfRadius: 10)
    node.physicsBody?.affectedByGravity = false

    node.text = "#\(player.batter.number)"
    node.name = "\(player.batter.number)"
    node.fontSize = 20
    node.fontColor = SKColor.blue
    node.physicsBody?.isDynamic = true
    node.physicsBody?.restitution = 0.0
    

    node.userData = ["player": player]
    switch player.baseOccupied {
    case 0:
        node.physicsBody?.categoryBitMask = PhysicsCategories.none
        node.physicsBody?.contactTestBitMask = PhysicsCategories.none
        node.physicsBody?.collisionBitMask = PhysicsCategories.none
        node.position = homePlate
        node.zPosition = 500
    case 1:
        node.physicsBody?.categoryBitMask = PhysicsCategories.first
        node.physicsBody?.contactTestBitMask = PhysicsCategories.home
        node.physicsBody?.collisionBitMask = PhysicsCategories.none
        node.position = firstBase
        node.zPosition = 100
    case 2:

        node.physicsBody?.categoryBitMask = PhysicsCategories.second
        node.physicsBody?.contactTestBitMask = 0b111
        node.physicsBody?.collisionBitMask = PhysicsCategories.none
        node.position = secondBase
        node.zPosition = 100
    case 3:

        node.physicsBody?.categoryBitMask = PhysicsCategories.third
        node.physicsBody?.contactTestBitMask = 0b111
        node.physicsBody?.collisionBitMask = PhysicsCategories.none
        node.position = thirdBase
        node.zPosition = 100
    
        default :
        break
    }
    
    return node
    
}

func resetCount(scene: SKScene, plateAppearance: OffensivePlateAppearance, gameVM: GameViewModel) {
    var node = scene.enumerateChildNodes(withName: "pitched-strike") {
    node, stop in
        node.removeFromParent()
    }
    node = scene.enumerateChildNodes(withName: "pitched-ball") {
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
                path.addArc(center: CGPoint(x: scene.frame.width*0.075 + (20.0*CGFloat(balls)), y: scene.frame.height*0.165), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
                path.closeSubpath()
                //let ballNode = SKSpriteNode(imageNamed: "blue-sphere")
                let node = SKShapeNode(path: path)
                node.fillColor = .blue
                node.strokeColor = .black
                node.lineWidth = 1
                node.isHidden = false
                scene.addChild(node)
                balls += 1
            case .strikeLooking: //red
                let path = CGMutablePath()
                path.addArc(center: CGPoint(x: scene.frame.width*0.075 + (20.0*CGFloat(strikes)), y: scene.frame.height*0.215), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
                path.closeSubpath()
                let node = SKShapeNode(path: path)
                node.lineWidth = 1
            
                node.isHidden = false
                node.strokeColor = .black
                node.fillColor = .red
                scene.addChild(node)
                strikes += 1
            case .strikeSwinging: //black
                let path = CGMutablePath()
                path.addArc(center: CGPoint(x: scene.frame.width*0.075 + (20.0*CGFloat(strikes)), y: scene.frame.height*0.215), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
                path.closeSubpath()
                let node = SKShapeNode(path: path)
                node.lineWidth = 1
            
                node.isHidden = false
                node.strokeColor = .black
                node.fillColor = .black
                scene.addChild(node)
                strikes += 1
            case .foul: // yellow
                let path = CGMutablePath()
                path.addArc(center: CGPoint(x: scene.frame.width*0.075 + (20.0*CGFloat(strikes)), y: scene.frame.height*0.215), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
                path.closeSubpath()
                let node = SKShapeNode(path: path)
                node.lineWidth = 1
            
                node.isHidden = false
                node.strokeColor = .black
                node.fillColor = .yellow
                scene.addChild(node)
                strikes += 1
            case .inPlay:
                print("in play")
            }
        }
        if plateAppearance.outcome["home"] == "KS" || plateAppearance.outcome["home"] == "KL" {
            //addKLabel(scene: scene, plateAppearance: plateAppearance)
        }
    }

    for i in 0..<gameVM.outs {
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: scene.frame.width*0.075 + (20.0*CGFloat(i+1)), y: scene.frame.height*0.115), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.lineWidth = 1
        node.strokeColor = .black
        node.fillColor = .green
        node.isHidden = false
        scene.addChild(node)
    }
    
}

func addKLabel(scene: SKScene, plateAppearance: OffensivePlateAppearance) {
    if plateAppearance.outcome["home"]?.starts(with: "K") ?? false && plateAppearance.baseOccupied == 0 {
        let path = CGMutablePath()
        
        path.addArc(center: CGPoint(x: scene.frame.width/2, y: scene.frame.maxY*0.65), radius: 80, startAngle: 0, endAngle: .pi*2, clockwise: false)
        path.closeSubpath()
        
        let node = SKShapeNode(path: path)
        node.fillColor = .white
        node.strokeColor = .black
        node.lineWidth = 1
        node.name = "K"
        node.isHidden = false
        scene.addChild(node)
        let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
        labelNode.text = "K"
        labelNode.fontSize = 70
        labelNode.position = CGPoint(x: scene.frame.width/2, y: scene.frame.maxY*0.65 - 20)
        if plateAppearance.outcome["home"] == "KS" {
            labelNode.name = "KS"
            labelNode.fontColor = .black
        } else {
            labelNode.name = "KL"
            labelNode.fontColor = .red
            labelNode.xScale = -1
        }
        labelNode.isHidden = false
        scene.addChild(labelNode)
        
    }
}

func addOutLabel(scene: SKScene, plateAppearance: OffensivePlateAppearance) {
    let path = CGMutablePath()
    
    path.addArc(center: CGPoint(x: scene.frame.maxX*0.79, y: scene.frame.maxY*0.165), radius: 40, startAngle: 0, endAngle: .pi*2, clockwise: false)
    path.closeSubpath()
    
    let node = SKShapeNode(path: path)
    node.fillColor = .white
    node.strokeColor = .red
    node.lineWidth = 2
    node.name = "out"
    node.isHidden = false
    scene.addChild(node)
    let labelNode = SKLabelNode(fontNamed: "Trebuchet MS")
    labelNode.text = "\(plateAppearance.outs)"
    labelNode.fontSize = 70
    labelNode.position = CGPoint(x: scene.frame.maxX*0.80, y: scene.frame.maxY*0.13)
    labelNode.name = "out"
    labelNode.fontColor = .red
    scene.addChild(labelNode)
}

func addStrike(pos: Int, gameVM: GameViewModel, scene: SKScene, plateAppearance: OffensivePlateAppearance) {
    var swing: Bool = false
    let index = gameVM.batter!.pitches.filter({$0 == .strikeLooking || $0 == .strikeSwinging || $0 == .foul}).count + 1
    let path = CGMutablePath()
    path.addArc(center: CGPoint(x: scene.frame.width*0.075 + (20.0*CGFloat(index)), y: scene.frame.height*0.215), radius: 10, startAngle: 0, endAngle: .pi*2, clockwise: false)
    path.closeSubpath()
    let node = SKShapeNode(path: path)
    node.lineWidth = 1
    
    node.isHidden = false
    node.name = "pitched-strike"
    gameVM.pitches[gameVM.halfInning]?["strikes"]! += 1
    switch pos {
    case 1: //looking
        node.strokeColor = .black
        node.fillColor = .red
        gameVM.strikes += 1
        gameVM.batter!.pitches.append(.strikeLooking)
        swing = false
        
    case 2: //swinging
        node.strokeColor = .black
        node.fillColor = .black
        gameVM.strikes += 1
        gameVM.batter!.pitches.append(.strikeSwinging)
        swing = true
    default: //foul
        node.strokeColor = .black
        node.fillColor = .yellow
        if gameVM.strikes < 2 {
            gameVM.strikes += 1
        }
        gameVM.batter!.pitches.append(.foul)
    }
    scene.addChild(node)
}

