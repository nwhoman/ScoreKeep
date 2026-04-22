//
//  ScoreKeepObjects.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/26/24.
//

import Foundation
import Observation
import SpriteKit
import SwiftData
import SwiftUI

@Model
class Team: Hashable, Codable {
    enum CodingKeys: CodingKey {
        case id, name, ageGroup, lineup, coaches, players, homeGames, visitingGames
    }
    
    var id: UUID
    var name: String
    var ageGroup: String
    var lineup: [PlayerPos] = []
    @Relationship(deleteRule: .cascade, inverse: \Coach.team) var coaches: [Coach]?
    @Relationship(deleteRule: .cascade, inverse: \Player.team) var players: [Player]?
    @Relationship(deleteRule: .cascade, inverse: \Game.homeTeam) var homeGames: [Game]?
    @Relationship(deleteRule: .cascade, inverse: \Game.visitingTeam) var visitingGames: [Game]?

    init(name: String = "", ageGroup: String = "") {
        self.id = UUID()
        self.name = name
        self.ageGroup = ageGroup
        self.coaches = coaches
        self.players = players
        self.homeGames = homeGames
        //self.visitingGames = visitingGames
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(UUID.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.ageGroup = try values.decode(String.self, forKey: .ageGroup)
        self.lineup = try values.decode([PlayerPos].self, forKey: .lineup)
        
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(ageGroup, forKey: .ageGroup)
        try container.encode(lineup, forKey: .lineup)
    }
    
    
}

@Model
class Coach: Codable {
    enum CodingKeys: CodingKey {
        case id, firstName, lastName, yearsCoaching, team
    }
    var id: UUID
    var firstName: String
    var lastName: String
    var yearsCoaching: Int
    var team: Team? = nil
    
    init(firstName: String = "", lastName: String = "", yearsCoaching: Int = 0, team: Team? = nil) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.yearsCoaching = yearsCoaching
        self.team = team
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(UUID.self, forKey: .id)
        self.firstName = try values.decode(String.self, forKey: .firstName)
        self.lastName = try values.decode(String.self, forKey: .lastName)
        self.yearsCoaching = try values.decode(Int.self, forKey: .yearsCoaching)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(yearsCoaching, forKey: .yearsCoaching)
    }

}

@Model
class Player: Codable {
    enum CodingKeys: CodingKey {
        case id, firstName, lastName, age, number, team, position
    }
    
    var id: UUID
    var firstName: String
    var lastName: String
    var age: Int
    var number: String = ""
    var team: Team? = nil
    var position: String = ""
    @Relationship(deleteRule: .cascade, inverse: \OffensivePlateAppearance.batter) var plateAppearances: [OffensivePlateAppearance]?
    @Relationship(deleteRule: .cascade, inverse: \DefensivePlateAppearance.pitcher) var battersFaced: [DefensivePlateAppearance]?
    

    init(firstName: String, lastName: String, age: Int = 0, number: String, team: Team? = nil) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.number = number
        self.team = team
        self.position = position
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(UUID.self, forKey: .id)
        self.firstName = try values.decode(String.self, forKey: .firstName)
        self.lastName = try values.decode(String.self, forKey: .lastName)
        self.age = try values.decode(Int.self, forKey: .age)
        self.number = try values.decode(String.self, forKey: .number)
        //self.team = try values.decodeIfPresent(Team.self, forKey: .team, configuration: )
        self.position = try values.decode(String.self, forKey: .position)
        //self.plateAppearances = try values.decode([OffensivePlateAppearance].self, forKey: .plateAppearances)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(age, forKey: .age)
        try container.encode(number, forKey: .number)
        //try container.encodeIfPresent(team, forKey: .team)
        try container.encode(position, forKey: .position)
        //try container.encode(plateAppearances, forKey: .plateAppearances)
    }
    
}

@Model
class Game: Codable {
    enum CodingKeys: CodingKey {
        case id, name, homeTeam, homeLineup, homeFullLineup, visitingTeam, visitingLineup, visitingFullLineup, date, location, isComplete, isStarted, viewModel
    }
    var id: UUID
    var name: String
    var homeTeam: Team? = nil
    var homeLineup: [PlayerPos] = []
    var homeFullLineup: [[PlayerPos]] = []
    var visitingTeam: Team? = nil
    var visitingLineup: [PlayerPos] = []
    var visitingFullLineup: [[PlayerPos]] = []
    var date: Date  //includes time
    var location: String
    var isComplete: Bool = false
    var isStarted: Bool = false
    @Relationship(deleteRule: .cascade, inverse: \Inning.game) var innings: [Inning] = []
    //@Relationship(deleteRule: .cascade, inverse: \Inning.game) var homeInnings: [Inning] = []
    
    init(name: String, date: Date = .now, location: String, homeTeam: Team? = nil, visitingTeam: Team? = nil) {
        self.id = UUID()
        self.name = name
        self.homeTeam = homeTeam
        self.visitingTeam = visitingTeam
        self.date = date
        self.location = location
        self.isComplete = isComplete
        self.isStarted = isStarted
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(UUID.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.homeTeam = try values.decode(Team.self, forKey: .homeTeam)
        self.visitingTeam = try values.decode(Team.self, forKey: .visitingTeam)
        self.homeLineup = try values.decode([PlayerPos].self, forKey: .homeLineup)
        self.visitingLineup = try values.decode([PlayerPos].self, forKey: .visitingLineup)
        var lineupContainer = try values.nestedUnkeyedContainer(forKey: .homeFullLineup)
        var lineup: [[PlayerPos]] = []
        while !lineupContainer.isAtEnd {
            let item = try lineupContainer.decode([PlayerPos].self)
            lineup.append(item)
        }
        self.homeFullLineup = lineup
        lineupContainer = try values.nestedUnkeyedContainer(forKey: .visitingFullLineup)
        lineup = []
        while !lineupContainer.isAtEnd {
            let item = try lineupContainer.decode([PlayerPos].self)
            lineup.append(item)
        }
        self.visitingFullLineup = lineup
        self.date = try values.decode(Date.self, forKey: .date)
        self.location = try values.decode(String.self, forKey: .location)
        self.isComplete = try values.decode(Bool.self, forKey: .isComplete)
        self.isStarted = try values.decode(Bool.self, forKey: .isStarted)
    }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(date, forKey: .date)
        try container.encode(homeTeam, forKey: .homeTeam)
        try container.encode(visitingTeam, forKey: .visitingTeam)
        try container.encode(homeLineup, forKey: .homeLineup)
        try container.encode(visitingLineup, forKey: .visitingLineup)
        try container.encode(homeFullLineup, forKey: .homeFullLineup)
        try container.encode(visitingFullLineup, forKey: .visitingFullLineup)
        try container.encode(location, forKey: .location)
        try container.encode(isComplete, forKey: .isComplete)
        try container.encode(isStarted, forKey: .isStarted)        
    }
    
    func getTeamStats(team: Int) -> PlayerStats {
        var innings: [Inning] = []
        if team == 0 {
            innings = self.innings.filter { $0.half == 0 }
        } else {
            innings = self.innings.filter { $0.half == 1 }
        }
        
        var stats = PlayerStats()
        var appearances: [OffensivePlateAppearance] = []
        
        for inning in innings {
            for appearance in inning.plateAppearances {
                if appearance.active {
                    appearances.append(appearance)
                }
            }
        }
        stats = getPlayerStats(plateAppearances: appearances)
        
        return stats
    }
    func getPlayerGameStats(player: Player) -> PlayerStats {
        //var innings: [Inning] = []
    //        if team == 0 {
    //            innings = self.innings.filter { $0.half == 0 }
    //        } else {
    //            innings = self.innings.filter { $0.half == 1 }
    //        }
        
        var stats = PlayerStats()
        var appearances: [OffensivePlateAppearance] = []
        
        for inning in self.innings {
            appearances.append(contentsOf: inning.plateAppearances.filter { $0.batter.id == player.id } )
        }
        stats = getPlayerStats(plateAppearances: appearances)
        return stats
    }
}

@Model
class Inning: Codable {
    enum CodingKeys: CodingKey {
        case id, number, game, half, plateAppearances
    }
    var id: UUID = UUID()
    var number: Int
    var game: Game
    var half: Int
    
    var plateAppearances: [OffensivePlateAppearance] = []
    
   
    init(number: Int, game: Game, half: Int) {
        self.number = number
        self.game = game
        self.half = half
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(UUID.self, forKey: .id)
        self.number = try values.decode(Int.self, forKey: .number)
        self.game = try values.decode(Game.self, forKey: .game)
        self.half = try values.decode(Int.self, forKey: .half)
        self.plateAppearances = try values.decode([OffensivePlateAppearance].self, forKey: .plateAppearances)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(number, forKey: .number)
        try container.encode(game, forKey: .game)
        try container.encode(half, forKey: .half)
        try container.encode(plateAppearances, forKey: .plateAppearances)
    }
}

@Model
class OffensivePlateAppearance: Codable {
    enum CodingKeys: CodingKey {
        case id, order, batter, pitcher, inning, pitches, outs, hit, outcome, baseOccupied, rbi, run, earnedRun, sb, lob, k, bb, hp, sac, re, po, assist, error, wp, active, hitLocX, hitLocY
    }
    
    var id: UUID
    var order: Int
    var batter: Player
    var pitcher: Player
    var inning: Int
    var pitches: [Pitch]
    var outs: Int
    var hit: Int
    var outcome: [String : String]
    var baseOccupied: Int
    var rbi: Int
    var run: Bool
    var earnedRun: Bool
    var sb: [Int]
    var lob: Int?
    var k: Int = 0
    var bb: Int = 0
    var hp: Int = 0
    var sac: Int = 0
    var re: Int = 0
    var po: [String] = []
    var assist: [String] = []
    var error: [String] = []
    var wp: Int = 0
    var active: Bool
    var hitLoc: CGPoint {
        get {
            CGPoint(x: _hitLocX, y: _hitLocY)
        }
        set {
            self._hitLocX = newValue.x
            self._hitLocY = newValue.y
        }
    }
    
    init(order: Int, batter: Player, pitcher: Player, inning: Int) {
        self.id = UUID()
        self.order = order
        self.batter = batter
        self.pitcher = pitcher
        self.inning = inning
        self.pitches = []
        self.outs = 0
        self.hit = 0
        self.outcome = ["home" : "",
                        "first" : "",
                        "second" : "",
                        "third" : ""]
        self.baseOccupied = 0
        self.rbi = 0
        self.run = false
        self.earnedRun = true
        self.sb = []
        self.lob = 0
        self.active = false
        self.hitLoc = CGPoint(x: 0.0, y: 0.0)
    }
    private var _hitLocX: Double = 0.0
    private var _hitLocY: Double = 0.0
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(UUID.self, forKey: .id)
        self.order = try values.decode(Int.self, forKey: .order)
        self.batter = try values.decode(Player.self, forKey: .batter)
        self.pitcher = try values.decode(Player.self, forKey: .pitcher)
        self.inning = try values.decode(Int.self, forKey: .inning)
        self.pitches = try values.decode([Pitch].self, forKey: .pitches)
        self.outs = try values.decode(Int.self, forKey: .outs)
        self.hit = try values.decode(Int.self, forKey: .hit )
        self.outcome = try values.decode([String : String].self, forKey: .outcome )
        self.baseOccupied = try values.decode(Int.self, forKey: .baseOccupied)
        self.rbi = try values.decode(Int.self, forKey: .rbi)
        self.run = try values.decode(Bool.self, forKey: .run)
        self.earnedRun = try values.decode(Bool.self, forKey: .earnedRun)
        self.sb = try values.decode([Int].self, forKey: .sb)
        self.lob = try values.decodeIfPresent(Int.self, forKey: .lob)
        self.bb = try values.decode(Int.self, forKey: .bb)
        self.hp = try values.decode(Int.self, forKey: .hp)
        self.sac = try values.decode(Int.self, forKey: .sac)
        self.re = try values.decode(Int.self, forKey: .re)
        self.active = try values.decode(Bool.self, forKey: .active)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(order, forKey: .order)
        try container.encode(batter, forKey: .batter)
        try container.encode(inning, forKey: .inning)
        try container.encode(pitches, forKey: .pitches)
        try container.encode(outs, forKey: .outs)
        try container.encode(hit, forKey: .hit )
        try container.encode(outcome, forKey: .outcome )
        try container.encode(baseOccupied, forKey: .baseOccupied)
        try container.encode(rbi, forKey: .rbi)
        try container.encode(run, forKey: .run)
        try container.encode(earnedRun, forKey: .earnedRun)
        try container.encode(sb, forKey: .sb)
        try container.encodeIfPresent(lob, forKey: .lob)
        try container.encode(bb, forKey: .bb)
        try container.encode(hp, forKey: .hp)
        try container.encode(sac, forKey: .sac)
        try container.encode(re, forKey: .re)
        try container.encode(active, forKey: .active)
    }
}

@Model
class DefensivePlateAppearance: Codable {
    enum CodingKeys: CodingKey {
        case id, order, pitcher, inning, pitches, hit, run, earnedRun, k, bb, hp, sac, wp, po, assist, error, active
    }
    
    var id: UUID
    var order: Int
    var pitcher: Player
    var inning: Int
    var pitches: [Pitch] = []
    var hit: Int = 0
    var run: Bool = false
    var earnedRun: Bool
    var k: Int = 0
    var bb: Int = 0
    var hp: Int = 0
    var sac: Int = 0
    var wp: Int = 0
    var po: [String]
    var assist: [String]
    var error: [String]
    var active: Bool

    init(order: Int, pitcher: Player, inning: Int) {
        self.id = UUID()
        self.order = order
        self.pitcher = pitcher
        self.inning = inning
        self.run = false
        self.earnedRun = false
        self.po = []
        self.assist = []
        self.error = []
        self.active = false
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(UUID.self, forKey: .id)
        self.order = try values.decode(Int.self, forKey: .order)
        self.pitcher = try values.decode(Player.self, forKey: .pitcher)
        self.inning = try values.decode(Int.self, forKey: .inning)
        self.pitches = try values.decode([Pitch].self, forKey: .pitches)
        self.hit = try values.decode(Int.self, forKey: .hit)
        self.run = try values.decode(Bool.self, forKey: .run)
        self.earnedRun = try values.decode(Bool.self, forKey: .earnedRun)
        self.k = try values.decode(Int.self, forKey: .k)
        self.bb = try values.decode(Int.self, forKey: .bb)
        self.hp = try values.decode(Int.self, forKey: .hp)
        self.sac = try values.decode(Int.self, forKey: .sac)
        self.wp = try values.decode(Int.self, forKey: .wp)
        self.po = try values.decode([String].self, forKey: .po)
        self.assist = try values.decode([String].self, forKey: .assist)
        self.error = try values.decode([String].self, forKey: .error)
        self.active = try values.decode(Bool.self, forKey: .active)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(order, forKey: .order)
        try container.encode(pitcher, forKey: .pitcher)
        try container.encode(inning, forKey: .inning)
        try container.encode(pitches, forKey: .pitches)
        try container.encode(hit, forKey: .hit)
        try container.encode(run, forKey: .run)
        try container.encode(earnedRun, forKey: .earnedRun)
        try container.encode(k, forKey: .k)
        try container.encode(bb, forKey: .bb)
        try container.encode(hp, forKey: .hp)
        try container.encode(sac, forKey: .sac)
        try container.encode(wp, forKey: .wp)
        try container.encode(po, forKey: .po)
        try container.encode(assist, forKey: .assist)
        try container.encode(error, forKey: .error)
        try container.encode(active, forKey: .active)
    }
}

@Model
class PlayerPos: Identifiable, Hashable, Codable {
    enum CodingKeys: CodingKey {
        case id, inning, batting, player, position, assists, putOuts, errors
    }
    var id: UUID
    var inning: Int = 1
    var batting: Int
    var player: Player
    var position: String
    var assists: Int = 0
    var putOuts: Int = 0
    var errors: Int = 0
    
    init(player: Player, position: String, batting: Int = 0) {
        self.id = UUID()
        self.batting = batting
        self.player = player
        self.position = position
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(UUID.self, forKey: .id)
        self.inning = try values.decode(Int.self, forKey: .inning)
        self.batting = try values.decode(Int.self, forKey: .batting)
        self.player = try values.decode(Player.self, forKey: .player)
        self.position = try values.decode(String.self, forKey: .position)
        self.assists = try values.decode(Int.self, forKey: .assists)
        self.putOuts = try values.decode(Int.self, forKey: .putOuts)
        self.errors = try values.decode(Int.self, forKey: .errors)
}
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.inning, forKey: .inning)
        try container.encode(self.batting, forKey: .batting)
        try container.encode(self.player, forKey: .player)
        try container.encode(self.position, forKey: .position)
        try container.encode(self.assists, forKey: .assists)
        try container.encode(self.putOuts, forKey: .putOuts)
        try container.encode(self.errors, forKey: .errors)
    }
}

struct PlayerStats: Identifiable, Hashable {
    var id: UUID
    var plateAppearances: Int = 0
    //var atBats: Int = 0
    var hits: Int = 0
    var doubles: Int = 0
    var triples: Int = 0
    var homeRuns: Int = 0
    var runs: Int = 0
    var rbi: Int = 0
    var bb: Int = 0
    var k: Int = 0
    var hp: Int = 0
    var sac: Int = 0
    
    init() {
        self.id = UUID()
        //self.atBats = self.plateAppearances - self.bb - self.hp - self.sac
    }
    var atBats: Int {
        return self.plateAppearances - self.bb - self.hp - self.sac
    }
    var avg: Double {
        return Double(self.hits) / Double(self.atBats)
    }
    var slg: Double {
        let tb = self.doubles * 2 + self.triples * 3 + self.homeRuns * 4 + self.hits - self.doubles + self.triples + self.homeRuns
        return Double(tb) / Double(self.atBats)
    }
    var statSummary: [Int] {
        return [self.plateAppearances, self.atBats, self.hits, self.doubles, self.triples, self.homeRuns, self.runs, self.rbi, self.bb, self.k, self.hp, self.sac]
    }
}

struct PitcherStats: Identifiable, Hashable, Codable {
    enum CodingKeys: CodingKey {
        case inningsPitched, balls, strikes, battersFaced, hits, k, bb, hp, wp, doubles, triples, homeRuns, runs, er, sac
    }
    
    var id: UUID = UUID()

    var inningsPitched: Double = 0.0
    var balls: Int = 0
    var strikes: Int = 0
    var battersFaced: Int = 0
    var hits: Int = 0
    var k: Int = 0
    var bb: Int = 0
    var hp: Int = 0
    var wp: Int = 0
    var doubles: Int = 0
    var triples: Int = 0
    var homeRuns: Int = 0
    var runs: Int = 0
    var er: Int = 0
    var sac: Int = 0
    
    var atBats: Int {
        return self.battersFaced - self.bb - self.hp - self.sac
    }
    var era: Double {
        if self.inningsPitched != 0 {
             return Double(self.er) * 7.0 / Double(self.inningsPitched)
        } else {
            return 999.0
        }
        
    }
    var statSummary: [Int] {
        return [self.battersFaced, self.hits, self.doubles, self.triples, self.homeRuns, self.runs, self.er, self.bb, self.k, self.hp, self.wp]
    }
    
    //self.inningsPitched, , self.era self.strikes, self.balls, self.atBats,
}

struct TeamStats: Identifiable, Hashable {
    var id: UUID
    var plateAppearances: Int = 0
    //var atBats: Int = 0
    var hits: Int = 0
    var doubles: Int = 0
    var triples: Int = 0
    var homeRuns: Int = 0
    var runs: Int = 0
    var rbi: Int = 0
    var bb: Int = 0
    var k: Int = 0
    var hp: Int = 0
    var sac: Int = 0
    
    init() {
        self.id = UUID()
        //self.atBats = self.plateAppearances - self.bb - self.hp - self.sac
    }
    var atBats: Int {
        return self.plateAppearances - self.bb - self.hp - self.sac
    }
    var statSummary: [Int] {
        return [self.plateAppearances, self.hits, self.doubles, self.triples, self.homeRuns, self.runs, self.rbi, self.bb, self.k, self.hp, self.sac]
    }
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
            
            if appearance.pitches.count(where: {$0 == .strikeLooking || $0 == .strikeSwinging || $0 == .foul}) >= 3 && appearance.pitches.last == .strikeLooking || appearance.pitches.last == .strikeSwinging {
                playerStats.k += 1
            }
            playerStats.hp += appearance.hp
            playerStats.sac += appearance.sac
            
        }
        
    }
    //var atBats: Int = 0
    
    return playerStats
}


func decomposeLineup(lineup: [[PlayerPos]]) -> [PlayerPos] {
    var tempArray:[PlayerPos] = []
    for orderPosition in lineup {
        for each in orderPosition {
            tempArray.append(each)
        }
    }
    return tempArray
}

enum StatLabels: String, Codable, CaseIterable {
    case PA
    case AB
    case H
    case double = "2B"
    case triple = "3B"
    case HR
    case R
    case RBI
    case BB
    case K
    case HP
    case SAC
}

enum PitchingStatLabels: String, Codable, CaseIterable {
    case IP
    case BF
    case H
    case double = "2B"
    case triple = "3B"
    case HR
    case R
    case ER
    case BB
    case K
    case HP
    case WP
    case ERA
}

struct BattingLineupView: View {
    
//    @ObservedObject var gameVM: GameViewModel
    @State var gameVM: GameViewModel
    @State var showSubPages: Bool = false
    @State var showAlert: Bool = false
    @State var battingOrder: [[PlayerPos]]
    let geo: GeometryProxy
    let team: Team
    let tab: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(team.name)")
                .padding(.horizontal, 5)
                .padding(.top, 5)
                .frame(width: geo.size.width*0.4, height: 50, alignment: .leading)
                .border(Color.blue)
            ForEach(battingOrder, id: \.self) { orderSlot in
                VStack(spacing: 0) {
                    
                    HStack(alignment: .top, spacing: 0) {
                        Text("\(orderSlot.first!.batting))")
                            .padding(.leading, 2)
                            .padding(.top, 2)
                            .font(.caption)
                            .frame(width: 20, height: 25, alignment: .topLeading)
                            //.border(Color.red)
                        VStack(spacing: 0) {
                            ForEach(orderSlot, id: \.self) { player in
                                HStack {
                                    Text("\(player.player.number) - \(player.player.lastName), \(player.player.firstName.first!)")
                                    Spacer(minLength: 10)
                                    Text("\(player.position)")
                                    Text("\(player.inning)").font(.system(size: 6).italic())
                                }
                                .font(.system(size: 12))
                                .padding(.horizontal, 5)
                                .padding(.top, 2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(width: geo.size.width*0.32, height: 25, alignment: .topLeading)
                                //.border(.green)
                                .onTapGesture {
                                    showSubPages.toggle()
                                }
                                Rectangle()
                                    .fill(.blue.opacity(70))
                                    .frame(height: 1)
                                //Divider().opacity(100)
                            }
                        }
                    }
                }
                .padding(.horizontal, 0)
                .padding(.top, 0)
                .frame(width: geo.size.width*0.4, height: 75, alignment: .topLeading)
                .border(Color.blue)
            }
            .padding(.top, 0)
        }
        .sheet(isPresented: $showSubPages, onDismiss: {
            //  update game viewmodel, check outs and switch sides
            battingOrder = gameVM.selectedTab == "Visitor" ? gameVM.visitorLineup : gameVM.homeLineup
                                
            
        })
        {
            ShowSubsView(gameVM: gameVM, team: team, lineup: gameVM.selectedTab == "Visitor" ? gameVM.visitorCurrentLineup : gameVM.homeCurrentLineup)
          
        }
            
    }
        
            
    
        
}
#Preview {
    var game = Game.defaultGame
    
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    //setUpGame(game: game)
    let gameVM = GameViewModel(game: game, totalInnings: 3, inningRunRule: 0)
    var lineup = gameVM.setInitialLineup(halfInning: 0)
        
    return GeometryReader { geo in
        BattingLineupView(gameVM: gameVM, battingOrder: lineup, geo: geo, team: gameVM.game.homeTeam!, tab: "Home")
            .modelContainer(preview.modelContainer)
    }
    
}
struct ScoreView: View {
//    @ObservedObject var gameViewModel: GameViewModel
    @State var gameViewModel: GameViewModel
    //let innings: [Any] = setUpInnings()//[1, 2, 3, 4, 5, 6, 7, "R", "H", "E"]
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .trailing) {
                //Spacer()
                Text(" ")
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 45.0, height: 15.0)
                    .padding(.bottom, -5)
                Text("Visitor:")
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 45.0, height: 15.0)
                    .padding(.bottom, -5)
                Text("Home: ")
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 45.0, height: 15.0)
                    .padding(.bottom, -5)
            }
            .padding(.bottom, 10)
            .frame(width: 70, height: 55)
            .border(Color.gray, width: 0.5)
            VStack(alignment: .leading) {
                HStack {
                    let innings: [Any] = setUpInnings()
                    ForEach(0..<innings.count, id: \.self) {inning in
                        Text("\(innings[inning])")
                            .font(.system(size: 12, weight: .bold))
                            .frame(width: 15.0, height: 15.0)
                    }
                }
                .padding(.bottom, -5)
                HStack {
                    
                    ForEach(gameViewModel.score["visitor"]!, id: \.self) {inning in
                        Text("\(inning)")
                            .font(.system(size: 12, weight: .bold))
                            .frame(width: 15.0, height: 15.0)
                    }
                    Text("\(gameViewModel.getTotalScore(team: "visitor"))")
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 15.0, height: 15.0)
                    Text("\(gameViewModel.getTeamHits()["visitor"] ?? 1)") // change to hits
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 15.0, height: 15.0)
                    Text("\(gameViewModel.getTotalScore(team: "visitor"))") // change to errors
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 15.0, height: 15.0)
                }.padding(.bottom, -5)
                HStack {
                    
                    ForEach(gameViewModel.score["home"]!, id: \.self) {inning in
                        Text("\(inning)")
                            .font(.system(size: 12, weight: .bold))
                            .frame(width: 15.0, height: 15.0)
                    }
                    Text("\(gameViewModel.getTotalScore(team: "home"))")
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 15.0, height: 15.0)
                    Text("\(gameViewModel.getTeamHits()["home"] ?? 0)") // change to hits
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 15.0, height: 15.0)
                    Text("\(gameViewModel.getTotalScore(team: "home"))") // change to errors
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 15.0, height: 15.0)
                }.padding(.bottom, -5)
            }
            .padding(.bottom, 10)
            .frame(width: 220, height: 55)
            .border(Color.gray, width: 0.5)
        }
        .frame(width: 400, height: 75, alignment: .leading)
    }
    func setUpInnings() -> [Any] {
        var temp:[Any] = []
        let labels = ["R", "H", "E"]
        for i in 1...gameViewModel.totalInnings {
            temp.append(i)
        }
        temp.append(contentsOf: labels)
        return temp
    }
}

struct RbiView: View {
    var rbis: Int
    var body: some View {
        HStack {
            Spacer()
            ForEach(0..<rbis, id: \.self) {_ in
                ZStack {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .foregroundStyle(.black)
                        .scaledToFill()
                    
                }
                    .frame(width: 15.0, height: 17.0)
                    .padding(-3)
            }
        }
        .frame(width: 60, height: 17)
    }
}
//#Preview {
//
//    RbiView(rbis: 1)
//}

struct SacOutView: View {
    var player: OffensivePlateAppearance
//    var out: Int = 1
//    var sac: Int = 1
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                Spacer()
                if player.outs != 0 {
                    Text("\(player.outs)")                //Out # if batter out
                        .font(.system(size: 14).bold())
                        //.frame(width: geo.size.width, height: geo.size.height)

                        .overlay {
                            Circle()
                                .stroke(style: StrokeStyle(lineWidth: 1))
                                .frame(width: 15)
                        }
                            
                            
                        .frame(width: geo.size.width, height: geo.size.height)
                        .foregroundColor(Color.red)
                        //.padding(.leading, -10)
                }
                if player.sac != 0 {
                    Text("SAC")                //Out # if batter out
                        .font(.system(size: 12).bold())
                        .frame(width: geo.size.width, height: geo.size.height)
                        .foregroundColor(Color.blue)
                        .padding(.leading, -20)
                    
                        
                }
                Spacer()
            }
            .frame(width: geo.size.width*0.75, height: 27)
            //.border(Color.black)
        }
    }
}
//#Preview {
//    let player = OffensivePlateAppearance.defaultPlateAppearance
//    
//    SacOutView(player: player)
//}

struct CountView: View {
    var pitches: [Pitch]
    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                Text("S:")
                    .font(.title3)
                Text("B:")
                    .font(.title3)
                //Text("Outs:")
                    //.font(.title3)
            }
            VStack(alignment: .leading) {
                HStack {
                    ForEach(Array(pitches.enumerated()), id: \.offset) { index, pitch in
                        if pitch == .strikeSwinging{
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .foregroundStyle(.black)
                                
                                    .scaledToFill()
                                Text("\(index+1)")
                                    .font(.headline.bold())
                                    .minimumScaleFactor(0.85)
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 15.0, height: 17.0)
                                
                        } else if pitch == .strikeLooking {
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .scaledToFill()
                                Text("\(index+1)")
                                    .font(.headline.bold())
                                    .minimumScaleFactor(0.85)
                                    .foregroundStyle(.white)
                            }
                                .frame(width: 15.0, height: 17.0)
                        }
                        else if pitch == .foul {
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .foregroundStyle(.yellow)
                                    .scaledToFill()
                                Text("\(index+1)")
                                    .font(.headline.bold())
                                    .minimumScaleFactor(0.85)
                                    .foregroundStyle(.black)
                            }
                                .frame(width: 15.0, height: 17.0)
                        }
                    }
                    Spacer()
                }
                .frame(width: 135.0, height: 20.0)
                .padding(.leading, 0)
                HStack{
                    ForEach(Array(pitches.enumerated()), id: \.offset) { index, pitch in
                        if pitch == .ball{
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .foregroundStyle(.blue)
                                    .scaledToFill()
                                Text("\(index+1)")
                                    .font(.headline.bold())
                                    .minimumScaleFactor(0.85)
                                    .foregroundStyle(.white)
                            }
                                .frame(width: 15.0, height: 17.0)
                        }
                    }
                    Spacer()
                }
                .frame(width: 135.0, height: 17.0)
                .padding(.leading, 0)
                
            }
            
        }
        .padding(.top, 10)
        //.border(pitches.count > 1 ? Color.red : Color.clear)
        
    }

}
//#Preview {
//
//    CountView(pitches: [.ball, .strikeSwinging, .ball, .ball, .strikeLooking, .foul, .ball, .foul, .foul, .foul])
//}
//#Preview {
//    let game = Game.defaultGame
//    let gameVM = GameViewModel(game: game)
//    ScoreView(gameViewModel: gameVM)
//}
struct FieldView: View {
    var base: Int
    
    let xoffset: CGFloat
    let yoffset: CGFloat
    
    var body: some View {
        ZStack{
            drawField(xoffset: xoffset, yoffset: yoffset)
                .fill(Color.green)
            drawInfield(xoffset: xoffset, yoffset: yoffset)
                .fill(Color.brown)
            drawRunnerPath(base: base, xoffset: xoffset, yoffset: yoffset)
                .stroke(Color.black)
                .fill(base != 4 ? Color.clear : Color.red)
            drawFirst(xoffset: xoffset, yoffset: yoffset)
                .fill(Color.white)
            drawSecond(xoffset: xoffset, yoffset: yoffset)
                .fill(Color.white)
            drawThird(xoffset: xoffset, yoffset: yoffset)
                .fill(Color.white)
            drawHome(xoffset: xoffset, yoffset: yoffset)
                .fill(Color.white)
        }
        
    }
    func drawRunnerPath(base: Int, xoffset: CGFloat, yoffset: CGFloat) -> Path {
        return Path() { path in
            if base > 3 {
                path.move(to: CGPoint(x: 200+xoffset, y: 340+yoffset))
                path.addLine(to: CGPoint(x: 250+xoffset, y: 290+yoffset))
                path.addLine(to: CGPoint(x: 200+xoffset, y: 240+yoffset))
                path.addLine(to: CGPoint(x: 150+xoffset, y: 290+yoffset))
                path.addLine(to: CGPoint(x: 200+xoffset, y: 340+yoffset))
            } else if base > 2 {
                path.move(to: CGPoint(x: 200+xoffset, y: 340+yoffset))
                path.addLine(to: CGPoint(x: 250+xoffset, y: 290+yoffset))
                path.addLine(to: CGPoint(x: 200+xoffset, y: 240+yoffset))
                path.addLine(to: CGPoint(x: 150+xoffset, y: 290+yoffset))
            } else if base > 1 {
                path.move(to: CGPoint(x: 200+xoffset, y: 340+yoffset))
                path.addLine(to: CGPoint(x: 250+xoffset, y: 290+yoffset))
                path.addLine(to: CGPoint(x: 200+xoffset, y: 240+yoffset))
            } else if base > 0 {
                path.move(to: CGPoint(x: 200+xoffset, y: 340+yoffset))
                path.addLine(to: CGPoint(x: 250+xoffset, y: 290+yoffset))
            }
        }
    }
    func drawField(xoffset: CGFloat, yoffset: CGFloat) -> Path {
        
        return Path() { path in
            path.move(to: CGPoint(x: 200+xoffset, y: 350+yoffset))
            path.addLine(to: CGPoint(x: 400+xoffset, y: 150+yoffset))
            path.addQuadCurve(to: CGPoint(x: 0+xoffset, y: 150+yoffset), control: CGPoint(x: 200+xoffset, y: -100+yoffset))
            path.addLine(to: CGPoint(x: 200+xoffset, y: 350+yoffset))
        }
    }
    func drawInfield(xoffset: CGFloat, yoffset: CGFloat) -> Path {
        return Path() { path in
            path.move(to: CGPoint(x: 200+xoffset, y: 350+yoffset))
            path.addLine(to: CGPoint(x: 330+xoffset, y: 220+yoffset))
            path.addQuadCurve(to: CGPoint(x: 70+xoffset, y: 220+yoffset), control: CGPoint(x: 200+xoffset, y: 70+yoffset))
            path.addLine(to: CGPoint(x: 200+xoffset, y: 350+yoffset))
        }
    }
    func drawFirst(xoffset: CGFloat, yoffset: CGFloat) -> Path {
        return Path() { path in
            path.move(to: CGPoint(x: 255+xoffset, y: 290+yoffset))
            path.addLine(to: CGPoint(x: 250+xoffset, y: 285+yoffset))
            path.addLine(to: CGPoint(x: 245+xoffset, y: 290+yoffset))
            path.addLine(to: CGPoint(x: 250+xoffset, y: 295+yoffset))
        }
    }
    func drawSecond(xoffset: CGFloat, yoffset: CGFloat) -> Path {
        return Path() { path in
            path.move(to: CGPoint(x: 205+xoffset, y: 240+yoffset))
            path.addLine(to: CGPoint(x: 200+xoffset, y: 235+yoffset))
            path.addLine(to: CGPoint(x: 195+xoffset, y: 240+yoffset))
            path.addLine(to: CGPoint(x: 200+xoffset, y: 245+yoffset))
        }
    }
    func drawThird(xoffset: CGFloat, yoffset: CGFloat) -> Path {
        return Path() { path in
            path.move(to: CGPoint(x: 155+xoffset, y: 290+yoffset))
            path.addLine(to: CGPoint(x: 150+xoffset, y: 285+yoffset))
            path.addLine(to: CGPoint(x: 145+xoffset, y: 290+yoffset))
            path.addLine(to: CGPoint(x: 150+xoffset, y: 295+yoffset))
        }
    }
    func drawHome(xoffset: CGFloat, yoffset: CGFloat) -> Path {
        return Path() { path in
            path.move(to: CGPoint(x: 205+xoffset, y: 340+yoffset))
            path.addLine(to: CGPoint(x: 205+xoffset, y: 335+yoffset))
            path.addLine(to: CGPoint(x: 195+xoffset, y: 335+yoffset))
            path.addLine(to: CGPoint(x: 195+xoffset, y: 340+yoffset))
            path.addLine(to: CGPoint(x: 200+xoffset, y: 345+yoffset))
        }
    }
}


