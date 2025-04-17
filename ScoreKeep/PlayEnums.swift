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

enum Outcome: Codable {
    case in_play(type: in_play_type)
    case walk
    case hp
    case strikeout(type: strikeout_type)
    
    enum in_play_type: Codable {
        case ground_ball
        case fly_ball
        case line_out
        case base_hit(type: hits)
        
        enum hits: Codable {
            case single
            case double
            case triple
            case home_run
        }
        
    }
    
    enum strikeout_type: Codable {
        case swinging
        case looking
    }
}
