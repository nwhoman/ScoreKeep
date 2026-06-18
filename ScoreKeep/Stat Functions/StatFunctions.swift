//
//  StatFunctions.swift
//  ScoreKeep
//
//  Created by Neal Homan on 6/9/26.
//

import Foundation

func getPlayerPA(innings: [Inning], player: Player) -> [OffensivePlateAppearance] {
    var plateAppearances: [OffensivePlateAppearance] = []
    
    for inning in innings {
        plateAppearances.append(contentsOf: inning.plateAppearances.filter { $0.batter.id == player.id } )
    }
    return plateAppearances
}
func getTeamPA(innings: [Inning], players: [Player]) -> [OffensivePlateAppearance] {
    var plateAppearances: [OffensivePlateAppearance] = []
    
    for player in players {
        plateAppearances.append(contentsOf: getPlayerPA(innings: innings, player: player))
    }
    return plateAppearances
}
func getPlayerStats(plateAppearances: [OffensivePlateAppearance]) -> PlayerStats {
    var playerStats = PlayerStats()
    
    for appearance in plateAppearances {
        if appearance.active {
            
            
            playerStats.plateAppearances += 1
            if appearance.hit != 0 {
                playerStats.hits += 1
                if appearance.hit == 2 {
                    playerStats.doubles += 1
                } else if appearance.hit == 3 {
                    playerStats.triples += 1
                } else if appearance.hit == 4 {
                    playerStats.homeRuns += 1
                }
            }
            playerStats.rbi += appearance.rbi
            if appearance.run {
                playerStats.runs += 1
            }
            playerStats.bb += appearance.bb
            playerStats.k += appearance.k
            
            playerStats.hp += appearance.hp
            playerStats.sac += appearance.sac
            
        }
        
    }
    //var atBats: Int = 0
    
    return playerStats
}

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
    for appearance in plateAppearances {
        if appearance.active {
            if appearance.inning.number < minInning {
                minInning = appearance.inning.number
            } else if appearance.inning.number > maxInning {
                maxInning = appearance.inning.number
            }
            for pitch in appearance.pitches {
                if pitch == .ball {
                    pitcherStats.balls += 1
                } else if pitch != .ball {
                    pitcherStats.strikes += 1
                }
            }
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
        
    return pitcherStats
}

func getPitcherStatsHelper(pitchers: [Player:[OffensivePlateAppearance]]) -> [Player:PitcherStats] {
    
    var returnStats:[Player:PitcherStats] = [:]
    
    for pitcher in pitchers.keys {
        returnStats[pitcher] = getPitcherStats(plateAppearances: pitchers[pitcher]!, outs: 3)
    }
    return returnStats
}

func getFieldingStats(fieldAppearance: [PlayerPos]) -> FielderStats {
    var fieldStats = FielderStats()
    
    for each in fieldAppearance {
        fieldStats.assists += each.assists
        fieldStats.putOuts += each.putOuts
        fieldStats.errors += each.errors
        fieldStats.pb += each.pb
    }
    
    return fieldStats
}
