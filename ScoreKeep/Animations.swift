//
//  Animations.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/28/26.
//

import SpriteKit
import UIKit
let generator = UIImpactFeedbackGenerator(style: .heavy)
let vibrate = SKAction.run {
    generator.impactOccurred()
}
let doubleVibrate = SKAction.sequence([vibrate, vibrate])

let scaleNode = SKAction.scale(by: 2.0, duration: 0.3)
let unscaleNode = SKAction.scale(by: 0.5, duration: 0.3)
let colorRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.3)
let colorBlack = SKAction.colorize(with: .black, colorBlendFactor: 1.0, duration: 0.3)
let colorWhite = SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.3)
let hideNode = SKAction.fadeOut(withDuration: 0.15)
let showNode = SKAction.fadeIn(withDuration: 0.15)

let errorAction = SKAction.sequence([SKAction.group([scaleNode, colorRed]), vibrate, SKAction.wait(forDuration: 0.5), SKAction.group([unscaleNode, colorWhite])])
let touchedBRNode = SKAction.sequence([scaleNode, vibrate, SKAction.wait(forDuration: 0.5), unscaleNode])
let touchedFieldNode = SKAction.sequence([SKAction.group([scaleNode, colorBlack]), vibrate, SKAction.wait(forDuration: 0.5), SKAction.group([unscaleNode, colorWhite])])
let rbiAction = SKAction.sequence([hideNode, vibrate, showNode])
let touchPitchNode = SKAction.sequence([scaleNode, vibrate, SKAction.wait(forDuration: 0.5), unscaleNode])
let placeHitLocation = SKAction.sequence([doubleVibrate])
