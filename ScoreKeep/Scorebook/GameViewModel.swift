//
//  GameViewModel.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/29/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class GameViewModel: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case date, name, location, isStarted, isComplete, visitors, home, visitorLineup, homeLineup, visitorCurrentLineup, homeCurrentLineup, selectedTab, totalInnings, score, inningNumber, halfInning, outs, balls, strikes, pitches, batterUp, batterCount, batter, pitcherStats, innings, visitingTeam, homeTeam
    }
    var id: UUID = UUID()
    var date: Date = Date.now
    var name: String
    var location: String = ""
    var isStarted: Bool = false
    var isComplete: Bool = false

    var visitors: [Player]
    var home: [Player]
    var visitorReserves: [Player] = []
    var homeReserves: [Player] = []
    var visitorLineup: [[PlayerPos]] = []                // book lineup
    var homeLineup: [[PlayerPos]] = []
    var visitorCurrentLineup: [PlayerPos] = []           // lineup changing lineup
    var homeCurrentLineup: [PlayerPos] = []
    var visitorDecomposedLineup: [PlayerPos] = []
    var homeDecomposedLineup: [PlayerPos] = []
    var selectedTab: String = "Visitor"
    var totalInnings: Int
    var inningRunRule: Int = 0
    var gameRunRule = [
        3: 0,
        4: 0,
        5: 0,
    ]
    var inningRuns: Int = 0
    var score:[String : [Int]] = [:]
    var inningNumber = [10, 10]
    var halfInning = 0 // 1 for home half
    var outs: Int = 0
    var balls: Int = 0
    var strikes: Int = 0
    var pitches = [
        0: [
            "balls": 0,
            "strikes": 0,
        ],
        1: [
            "balls": 0,
            "strikes": 0,
        ]
    ]
    var batterUp = [1, 1]
    var batterCount = [0, 0]
    var batter: OffensivePlateAppearance?
    var baseRunners: [OffensivePlateAppearance] = []
    var pitcherStats: [PitcherStats] = []
    var baserunnerObjectsForBackup: [OffensivePlateAppearance] = []

    
    var visitingTeam: Team
    var homeTeam: Team
    
    @Relationship(deleteRule: .cascade, inverse: \Inning.game) var innings: [Inning] = []
    
    var sortedVisitorLineup: [[PlayerPos]] {
        visitorLineup.sorted(by: { $0.last!.batting < $1.last!.batting })
    }
    
    var sortedHomeLineup: [[PlayerPos]] {
        homeLineup.sorted(by: { $0.last!.batting < $1.last!.batting })
    }
    var visitorInnings: [Inning] {
        return innings.filter( { $0.half == 0 })
    }
    var homeInnings: [Inning] {
        return innings.filter( { $0.half == 1 })
    }
    
    init(name: String, totalInnings: Int, inningRunRule: Int, visitingTeam: Team, homeTeam: Team) {
        self.name = name
        self.totalInnings = totalInnings
        self.inningRunRule = inningRunRule
        
        self.visitingTeam = visitingTeam
        self.homeTeam = homeTeam
        
        self.visitors = visitingTeam.players!
        self.home = homeTeam.players!
        
        self.visitorCurrentLineup = visitingTeam.lineup
        self.homeCurrentLineup = homeTeam.lineup
        
        self.score = setScoreTable()
        self.gameRunRule[self.totalInnings] = 0
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try values.decode(Date.self, forKey: .date)
        self.name = try values.decode(String.self, forKey: .name)
        self.location = try values.decode(String.self, forKey: .location)
        self.isStarted = try values.decode(Bool.self, forKey: .isStarted)
        self.isComplete = try values.decode(Bool.self, forKey: .isComplete)
        self.visitors = try values.decode([Player].self, forKey: .visitors)
        self.home = try values.decode([Player].self, forKey: .home)
        
        var lineupContainer = try values.nestedUnkeyedContainer(forKey: .visitorLineup)
        var lineup: [[PlayerPos]] = []
        while !lineupContainer.isAtEnd {
            let item = try lineupContainer.decode([PlayerPos].self)
            lineup.append(item)
        }
        self.visitorLineup = lineup
        
        lineupContainer = try values.nestedUnkeyedContainer(forKey: .homeLineup)
        lineup = []
        while !lineupContainer.isAtEnd {
            let item = try lineupContainer.decode([PlayerPos].self)
            lineup.append(item)
        }
        self.homeLineup = lineup
        
        self.visitorCurrentLineup = try values.decode([PlayerPos].self, forKey: .visitorCurrentLineup)
        self.homeCurrentLineup = try values.decode([PlayerPos].self, forKey: .homeCurrentLineup)
        self.selectedTab = try values.decode(String.self, forKey: .selectedTab)
        self.totalInnings = try values.decode(Int.self, forKey: .totalInnings)
        self.score = try values.decode([String:[Int]].self, forKey: .score)
        self.inningNumber = try values.decode([Int].self, forKey: .inningNumber)
        self.halfInning = try values.decode(Int.self, forKey: .halfInning)
        self.outs = try values.decode(Int.self, forKey: .outs)
        self.batterUp = try values.decode([Int].self, forKey: .batterUp)
        self.batterCount = try values.decode([Int].self, forKey: .batterCount)
        self.batter = try values.decode(OffensivePlateAppearance.self, forKey: .batter)
        self.pitcherStats = try values.decode([PitcherStats].self, forKey: .pitcherStats)
        self.visitingTeam = try values.decode(Team.self, forKey: .visitingTeam)
        self.homeTeam = try values.decode(Team.self, forKey: .homeTeam)
    }
    
    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(visitors, forKey: .visitors)
        try values.encode(home, forKey: .home)
        try values.encode(visitorLineup, forKey: .visitorLineup)
        try values.encode(homeLineup, forKey: .homeLineup)
        try values.encode(visitorCurrentLineup, forKey: .visitorCurrentLineup)
        try values.encode(homeCurrentLineup, forKey: .homeCurrentLineup)
        try values.encode(selectedTab, forKey: .selectedTab)
        try values.encode(totalInnings, forKey: .totalInnings)
        try values.encode(score, forKey: .score)
        try values.encode(inningNumber, forKey: .inningNumber)
        try values.encode(halfInning, forKey: .halfInning)
        try values.encode(outs, forKey: .outs)
        try values.encode(balls, forKey: .balls)
        try values.encode(strikes, forKey: .strikes)
        try values.encode(pitches, forKey: .pitches)
        try values.encode(batterUp, forKey: .batterUp)
        try values.encode(batterCount, forKey: .batterCount)
        try values.encode(batter, forKey: .batter)
        try values.encode(pitcherStats, forKey: .pitcherStats)
        try values.encode(innings, forKey: .innings)
        try values.encode(visitingTeam, forKey: .visitingTeam)
        try values.encode(homeTeam, forKey: .homeTeam)
}
    
    func popPlayerFromLineup(lineup: [PlayerPos], player: PlayerPos) -> [PlayerPos] {
        var temp: [PlayerPos] = lineup
        temp.remove(at: temp.firstIndex(of: player)!)
        
        return temp
    }
    
    func setUpGame() {
        self.visitorLineup = setInitialLineup(halfInning: 0)
        self.homeLineup = setInitialLineup(halfInning: 1)

        self.batterCount = [visitorCurrentLineup.filter({!$0.flex}).count, homeCurrentLineup.filter({!$0.flex}).count]
        for i in 1...self.totalInnings {
            let vInning = Inning(number: i*10, game: self, half: 0)
            let hInning = Inning(number: i*10, game: self, half: 1)
            modelContext?.insert(vInning)
            modelContext?.insert(hInning)
            do {
                try modelContext?.save()
            } catch {
                print("save inning error \(error), \(error._domain)")
            }
            addInning(inning: vInning, lineup: visitorCurrentLineup, halfInning: 0)
            addInning(inning: hInning, lineup: homeCurrentLineup, halfInning: 1)
        }
    }
    func setScoreTable() -> [String:[Int]]{
        var temp:[Int] = []
        for _ in 0..<totalInnings {
            temp.append(0)
        }
        score["visitor"] = temp
        score["home"] = temp
        return score
    }
    func getCurrentPitcher(i: Int) -> PlayerPos {
        var pitcher: PlayerPos
        if i == 1 {
            if self.visitorCurrentLineup.contains(where: { $0.position == "P" }) {
                pitcher = self.visitorCurrentLineup.filter({$0.position == "P"}).first!
            } else {
                pitcher = self.visitorCurrentLineup.filter({$0.flex}).first!
            }
        } else {
            if self.homeCurrentLineup.contains(where: { $0.position == "P" }) {
                pitcher = self.homeCurrentLineup.filter({$0.position == "P"}).first!
            } else {
                pitcher = self.homeCurrentLineup.filter({$0.flex}).first!
            }
        }
        return pitcher
    }
    
    func getPlayerPosForPlayer(player: Player, lineup: [PlayerPos]) -> [PlayerPos] {
        var playerPos: [PlayerPos] = []
        if lineup.contains(where: { $0.player.id == player.id }) {
            playerPos = lineup.filter({$0.player.id == player.id})
        }
        return playerPos
    }
    
    func addInning(inning: Inning, lineup: [PlayerPos], halfInning: Int) {
        let pitcher = getCurrentPitcher(i: halfInning)
        var temp: [PlayerPos] = []
        var order = 1
        
            if halfInning == 0 {
                temp = visitorCurrentLineup.filter({!$0.flex})
            } else {
                temp = homeCurrentLineup.filter({!$0.flex})
            }
        inning.half = halfInning
        for batter in temp.sorted(by: { $0.batting < $1.batting }) {
            let plateAppearance = OffensivePlateAppearance(order: order, batter: batter.player, pitcher: pitcher.player, inning: inning)
            modelContext?.insert(plateAppearance)
            do {
                try modelContext?.save()
            } catch {
                if halfInning == 0 {
                    print("save VOPA error \(error), \(error._domain)")
                } else {
                    print("save HOPA error \(error), \(error._domain)")
                }
            }
            
            inning.plateAppearances.append(plateAppearance)
            batter.player.plateAppearances?.append(plateAppearance)
            pitcher.player.pitchingAppearances?.append(plateAppearance)
            order += 1
        }
        
        self.innings.append(inning)
    }

    func setInitialLineup(halfInning: Int) -> [[PlayerPos]]{
        var lineup: [[PlayerPos]] = []
        if halfInning == 0 {
            var players: [Player] = self.visitors
            for each in self.visitorCurrentLineup.sorted(by: {$0.batting < $1.batting}) {
                lineup.append([each])
                players.removeAll(where: ({$0.id == each.player.id}))
            }
            self.visitorReserves.append(contentsOf: players)
            return lineup
        } else {
            var players: [Player] = self.home
            for each in self.homeCurrentLineup.sorted(by: {$0.batting < $1.batting}) {
                lineup.append([each])
                players.removeAll(where: ({$0.id == each.player.id}))
            }
            self.homeReserves.append(contentsOf: players)
            return lineup
        }
    }
    func getUnusedPositions(positions: [String], team: Int) -> [String] {
        var possiblePositions = positions
        var lineup: [PlayerPos] = []
        if team == 0 {
            lineup = self.visitorCurrentLineup
        } else {
            lineup = self.homeCurrentLineup
        }
        possiblePositions = positions.filter({ pos in !posUsed(position: pos, lineup: lineup)  })
        return possiblePositions
    }
    func getUnusedPlayers(team: Int) -> [Player] {
        var players: [Player] = []
        var lineup: [PlayerPos] = []
        if team == 0 {
            players = self.visitors
            lineup = self.visitorCurrentLineup
        } else {
            players = self.home
            lineup = self.homeCurrentLineup
        }
        players = players.filter({ pos in !playerUsed(player: pos, lineup: lineup)  })
        return players
    }
    
    
    
    func cleanInning(inning: Inning, halfInning: Int) {
        if halfInning == 0 {
            inning.half = halfInning
        } else {
            
        }
    }
    
    func getBatter() {
        
        if halfInning == 0 {
            let inning = visitorInnings[inningNumber[0]/10-1]
            self.batter = inning.plateAppearances[batterUp[halfInning]]
            inning.plateAppearances[batterUp[halfInning]].active = true
            self.batter!.active = true
            
            baseRunners.insert(self.batter!, at: 0)
        } else {
            let inning = homeInnings[inningNumber[1]/10-1]
            self.batter = inning.plateAppearances[batterUp[halfInning]]
            self.batter!.active = true
            baseRunners.insert(self.batter!, at: 0)
        }
        
    }
    
    func getDefense(defense: [PlayerPos]) -> [String: Player]{
        let positions = ["P", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF"]
        var lineup: [String: Player] = [:]
        for pos in positions {
            for player in defense {
                if player.position == pos {
                    lineup[pos] = player.player
                }
            }
        }
        return lineup
    }
    
    func incrementBatterUp() {
        if batterUp[halfInning] != self.batterCount[halfInning] {
            batterUp[halfInning] += 1
        } else {
            batterUp[halfInning] = 1
        }
    }
    
    func decrementBatterUp() {
        if batterUp[halfInning] != 1 {
            batterUp[halfInning] -= 1
        } else {
            batterUp[halfInning] = self.batterCount[halfInning]
        }
    }
    
    func incrementScore(team: Int) {
        if inningRuns < inningRunRule || inningRunRule == 0 {
            if team == 0 {
                score["visitor"]![inningNumber[0]/10 - 1] += 1
            } else {
                score["home"]![inningNumber[1]/10 - 1] += 1
            }
            inningRuns += 1
        }
    }
    
    func getTotalScore() -> [String: Int] {
        return [
            "visitor": score["visitor"]!.reduce(0, +),
            "home": score["home"]!.reduce(0, +)
        ]
    }
    
    func getTeamHits() -> [String: Int] { // 0 for visitor 1 for home
        var vHits = 0
        var hHits = 0
        for inning in self.visitorInnings {
            vHits += inning.plateAppearances.count(where: {$0.hit > 0})
        }
        for inning in self.homeInnings {
            hHits += inning.plateAppearances.count(where: {$0.hit > 0})
        }
        return [
            "visitor": vHits,
            "home": hHits
        ]
    }
    func getTeamErrors() -> [String: Int] {
        var vErrors = 0
        var hErrors = 0
        
        for inning in self.visitorInnings {
            hErrors += inning.plateAppearances.count(where: {$0.re > 0})
        }
        for inning in self.homeInnings {
            vErrors += inning.plateAppearances.count(where: {$0.re > 0})
        }
        return [
            "visitor": vErrors,
            "home": hErrors
        ]
    }
    
    func getBaserunner(number: String) -> OffensivePlateAppearance {
        for runner in baseRunners {
            if runner.batter.number == number {
                return runner
            }
        }
        return self.baseRunners[0]
    }
    
    
//    func updatePitcherStats() {
//        let innings = self.halfInning == 0 ? self.visitorInnings : self.homeInnings
//        let pa = self.getPitcherPA(innings: innings)
//        self.pitcherStats[self.pitcherStats.count-1] = self.getPitcherStats(plateAppearances: pa, pitcher: self.batter!.pitcher)
//    }
    
    func getTeamStats(team: Int) -> PlayerStats {
        var innings: [Inning] = []
        if team == 0 {
            innings = self.visitorInnings
        } else {
            innings = self.homeInnings
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
    
    func checkGameComplete() {
        let score = self.getTotalScore()
        if self.inningNumber[0]/10 > self.totalInnings { // check complete game
            self.isComplete = checkGameCompleteHelper(score: self.getTotalScore(), runRule: 0)
        }
        for key in self.gameRunRule.keys.sorted() {
            if self.gameRunRule[key] != 0 && self.inningNumber[0]/10 > key {
                if let runRule = self.gameRunRule[key] {
                    self.isComplete = checkGameCompleteHelper(score: self.getTotalScore(), runRule: runRule)
                }
            }
        }
        if self.isComplete {
            self.completeGame()
        }
    }
    func checkGameCompleteHelper(score: [String: Int], runRule: Int) -> Bool {
        if self.halfInning == 1 {
            if self.outs < 3 {
                if score["home"] ?? 0 > score["visitor"] ?? 0 + runRule {
                    print("walk off home wins")
                    return true
                }
            } else {
                if score["home"] ?? 0 + runRule < score["visitor"] ?? 0 {
                    print("visitor wins")
                    return true
                }
            }
        } else {
            if self.outs >= 3 {
                if score["home"] ?? 0 > score["visitor"] ?? 0  + runRule{
                    print("home wins")
                    return true
                }
            }
        }
        return false
    }
    
    func completeGame() {
        self.visitorDecomposedLineup = decomposeLineup(lineup: self.visitorLineup)
        self.homeDecomposedLineup = decomposeLineup(lineup: self.homeLineup)
        self.homeTeam.lineup = self.homeCurrentLineup
        self.visitingTeam.lineup = self.visitorCurrentLineup
//        for inning in innings {
//            for _ in inning.plateAppearances {
//                inning.plateAppearances.removeAll(where: { !$0.active })
//            }
//        }
        for team in [self.visitors, self.home] {
            for player in team {
                player.plateAppearances?.removeAll(where: { !$0.active })
                player.pitchingAppearances?.removeAll(where: { !$0.active })
            }
        }
    }
    
    func checkInningComplete() {
        self.checkGameComplete()
        if self.inningRunRule != 0 && self.inningRuns == self.inningRunRule || self.outs >= 3 {
            self.outs = 0
            self.balls = 0
            self.strikes = 0
            self.inningRuns = 0
            if self.batter?.outcome["home"] == "" { // if 3rd out made on bases while batter is up
                self.decrementBatterUp()
            }
            self.baseRunners.removeAll()
            
            
            if self.halfInning == 0 {
                self.inningNumber[0] = (self.inningNumber[0]/10 + 1) * 10
                self.halfInning = 1
            } else {
                self.halfInning = 0
                self.inningNumber[1] = (self.inningNumber[1]/10 + 1) * 10
            }
            
        } else {
            if !self.isComplete {
                // if dismiss sheet before batter is finished
                if self.batter?.outcome["home"] == "" {
                    self.baseRunners.removeAll { each in
                        each.baseOccupied == 0
                    }
                    self.decrementBatterUp()
                } else {
                    self.balls = 0
                    self.strikes = 0
                }
            }
        }
    }
    func reconcileFieldingAttempts(pa: OffensivePlateAppearance, lineup: [PlayerPos]) {
        for each in pa.assist {
            if let player = getPlayerPosForPositionNumber(positionNumber: Int(each) ?? 0, lineup: lineup) {
                player.assists += 1
            }
        }
        for each in pa.po {
            if let player = getPlayerPosForPositionNumber(positionNumber: Int(each) ?? 0, lineup: lineup) {
                player.putOuts += 1
            }
        }
        for each in pa.error {
            if let player = getPlayerPosForPositionNumber(positionNumber: Int(each) ?? 0, lineup: lineup) {
                player.errors += 1
            }
        }
    }
    
//    func saveViewModelAsJSON() -> String {
//        game.visitingFullLineup = self.visitorLineup
//        game.homeFullLineup = self.homeLineup
//        game.visitingLineup = self.visitorCurrentLineup
//        game.homeLineup = self.homeCurrentLineup
//        game.innings.append(contentsOf: self.visitorInnings)
//        game.innings.append(contentsOf: self.homeInnings)
//        
////        let encoder = JSONEncoder()
////        encoder.outputFormatting = [.prettyPrinted]
////        if let jsonData = try? encoder.encode(self),
////           let jsonString = String(data: jsonData, encoding: .utf8) {
////            game.viewModel.append(jsonData)
////            print("saved view model")
////            return jsonString
////        }
//        
//        return "failed to encode view model"
//    }
    
    
}
