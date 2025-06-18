//
//  PlayStructs.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/25/24.
//

import Foundation

//let pitches = ["Ball", "Strike", "Foul", "In Play", "HP"]
let hits = ["1B", "2B", "3B", "HR"]

enum Pitch: String, Codable, CaseIterable {
    case ball
    case strikeSwinging = "strike swinging"
    case strikeLooking = "strike looking"
    case foul
    //case inPlay = "in play"
    //case hbp
    
}



enum Positions: Codable, CaseIterable {
    case P
    case C
    case First
    case Second
    case Third
    case SS
    case LF
    case CF
    case RF
    case Flex
    case DP
    case EP
}
struct PositionDescription {
    var number: Int             // ie 1, 2, 3
    var name: String            // ie pitcher, catcher, first,
    var location: CGPoint
    var abbreviation: String    // ie P, C, 1B
}

enum PitchOutcome: Codable {
    case pitch(type: pitch_types)
    
    enum pitch_types: Codable {
        case strike(type: strike_type)
        case ball
        case in_play(type: in_play_type)
        case hp
        
        enum strike_type: Codable {
            case swinging
            case looking
            case foul
        }
        enum in_play_type: Codable {
            case ground_ball
            case fly_ball
            case line_out
            case base_hit(type: hits)
            case sac(type: sacs)
            
            enum hits: Int, Codable {
                case single = 1
                case double = 2
                case triple = 3
                case home_run = 4
            }
            
            enum sacs: Codable {
                case fly
                case bunt
            }
        }
    }
}
