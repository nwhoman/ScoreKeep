//
//  PitcherFunctions.swift
//  ScoreKeep
//
//  Created by Neal Homan on 5/30/26.
//

import Foundation


func getPitcherPA(innings: [Inning], pitcher: Player) -> [OffensivePlateAppearance] {
    var plateAppearances: [OffensivePlateAppearance] = []
    
    for inning in innings {
        plateAppearances.append(contentsOf: inning.plateAppearances.filter { $0.pitcher.id == pitcher.id } )
    }
    return plateAppearances
}

func getPitcherStats(plateAppearances: [OffensivePlateAppearance], outs: Int = 3) -> PitcherStats {
    var pitcherStats = PitcherStats()
    var minInning = 200
    var maxInning = 10
    print("pa: \(plateAppearances.count)")
    for appearance in plateAppearances {
        if appearance.active {
            if appearance.inning.number < minInning {
                minInning = appearance.inning.number
            } else if appearance.inning.number > maxInning {
                maxInning = appearance.inning.number
            }
            print("min: \(minInning) max: \(maxInning)")
            for pitch in appearance.pitches {
                if pitch == .ball {
                    pitcherStats.balls += 1
                } else if pitch != .ball {
                    pitcherStats.strikes += 1
                }
            }
            print("pitches: \(appearance.pitches.count)")
            pitcherStats.battersFaced += 1
            if appearance.hit != 0 {
                pitcherStats.hits += 1
                if appearance.hit == 2 {
                    pitcherStats.doubles += 1
                } else if appearance.hit == 3 {
                    pitcherStats.triples += 1
                } else if appearance.hit == 4 {
                    pitcherStats.homeRuns += 1
                }
            }
            
            if appearance.run {
                print("add run")
                pitcherStats.runs += 1
                if appearance.earnedRun {
                    pitcherStats.er += 1
                }
            }
            
            pitcherStats.bb += appearance.bb
            pitcherStats.k += appearance.k
            
            pitcherStats.hp += appearance.hp
            pitcherStats.sac += appearance.sac
            pitcherStats.wp += appearance.wp
        }

    }
    pitcherStats.inningsPitched = Double(maxInning/10 - minInning/10) + Double(outs)/3
    if pitcherStats.inningsPitched < 0 {
        pitcherStats.inningsPitched = 0.0
    }
        
    print("IP: \(pitcherStats.inningsPitched) \(outs)")
    return pitcherStats
}

func reconcilePitcherStats(innings: [Inning]?, team: Int?, player: Player?) -> [Player:PitcherStats] {
    
    var returnStats:[Player:PitcherStats] = [:]
    if innings != nil && team != nil {
        var pitchers: [Player:[OffensivePlateAppearance]] {
            getTeamPitchers(innings: innings!, team: team!)
        }
        for pitcher in pitchers.keys {
            returnStats[pitcher] = getPitcherStats(plateAppearances: pitchers[pitcher]!)
        }
    }
    if let player {
        returnStats[player] = getPitcherStats(plateAppearances: player.pitchingAppearances ?? [])
    }
    
    return returnStats
}

func getTeamPitchers(innings: [Inning], team: Int) -> [Player: [OffensivePlateAppearance]] {
    var tempPitchers: [Player: [OffensivePlateAppearance]] = [:]
    var innings: [Inning] = []
    if team == 0 {
        innings = innings.filter { $0.half == 1 }
    } else {
        innings = innings.filter { $0.half == 0 }
    }
    for inning in innings {
        for appearance in inning.plateAppearances {
            if !tempPitchers.keys.contains(appearance.pitcher) {
                tempPitchers[appearance.pitcher] = []
            }
            tempPitchers[appearance.pitcher]?.append(appearance)
        }
    }
    print("\(tempPitchers)")
    return tempPitchers
}
