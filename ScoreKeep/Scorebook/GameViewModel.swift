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
        case game, visitors, home, visitorLineup, homeLineup, visitorCurrentLineup, homeCurrentLineup, selectedTab, totalInnings, score, inningNumber, halfInning, outs, balls, strikes, pitches, batterUp, batterCount, batter, pitcherStats, baserunnerObjectsForBackup, visitorInnings, homeInnings
    }
    var id: UUID = UUID()
    var game: Game
    var visitors: [Player]
    var home: [Player]
    var visitorLineup: [[PlayerPos]] = []                // book lineup
    var homeLineup: [[PlayerPos]] = []
    var visitorCurrentLineup: [PlayerPos] = []           // lineup changing lineup
    var homeCurrentLineup: [PlayerPos] = []
    var selectedTab: String = "Visitor"
    var totalInnings: Int
    var inningRunRule: Int = 0
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
    var visitorInnings: [Inning] = []
    var homeInnings: [Inning] = []
    
    var sortedVisitorLineup: [[PlayerPos]] {
        visitorLineup.sorted(by: { $0.last!.batting < $1.last!.batting })
    }
    
    var sortedHomeLineup: [[PlayerPos]] {
        homeLineup.sorted(by: { $0.last!.batting < $1.last!.batting })
    }
    
    
    init(game: Game, totalInnings: Int, inningRunRule: Int) {
        self.game = game
        self.visitors = game.visitingTeam!.players!
        self.home = game.homeTeam!.players!
        
        self.visitorCurrentLineup = game.visitingTeam?.lineup ?? []
        self.homeCurrentLineup = game.homeTeam?.lineup ?? []
        self.totalInnings = totalInnings
        self.inningRunRule = inningRunRule
        self.score = setScoreTable()
        print("V: \(self.visitorCurrentLineup.count) H: \(self.homeCurrentLineup.count) on game init")
    }
    
    init(gameViewModel: GameViewModel) {
        self.game = gameViewModel.game
        self.visitors = gameViewModel.game.visitingTeam!.players!
        self.home = gameViewModel.game.homeTeam!.players!
        
        self.visitorCurrentLineup = gameViewModel.game.visitingTeam?.lineup ?? []
        self.homeCurrentLineup = gameViewModel.game.homeTeam?.lineup ?? []
        self.totalInnings = gameViewModel.totalInnings
        print("V: \(self.visitorCurrentLineup.count) H: \(self.homeCurrentLineup.count) on GVM init")
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.game = try values.decode(Game.self, forKey: .game)
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
        self.baserunnerObjectsForBackup = try values.decode([OffensivePlateAppearance].self, forKey: .baserunnerObjectsForBackup)
        self.visitorInnings = try values.decode([Inning].self, forKey: .visitorInnings)
        self.homeInnings = try values.decode([Inning].self, forKey: .homeInnings)

    }
    
    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(game, forKey: .game)
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
        try values.encode(baserunnerObjectsForBackup, forKey: .baserunnerObjectsForBackup)
        try values.encode(visitorInnings, forKey: .visitorInnings)
        try values.encode(homeInnings, forKey: .homeInnings)
}
    
    func popPlayerFromLineup(lineup: [PlayerPos], player: PlayerPos) -> [PlayerPos] {
        var temp: [PlayerPos] = lineup
        temp.remove(at: temp.firstIndex(of: player)!)
        
        return temp
    }
    
    func setUpGame() {
        self.visitorLineup = setInitialLineup(halfInning: 0)
        self.homeLineup = setInitialLineup(halfInning: 1)
        self.batterCount = [visitorCurrentLineup.filter({$0.position != "F"}).count, homeCurrentLineup.filter({$0.position != "F"}).count]
        for i in 1...self.totalInnings {
            let vInning = Inning(number: i*10, game: game, half: 0)
            let hInning = Inning(number: i*10, game: game, half: 1)
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
//        self.pitcherStats.append(PitcherStats(pitcherID: getCurrentPitcher(i: 0)))
//        self.pitcherStats.append(PitcherStats(pitcherID: getCurrentPitcher(i: 1)))
        print("start game: \(self.batterCount[0]) \(self.batterCount[1])")
        print("start game: \(self.visitorInnings.count) \(self.homeInnings.count)")
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
        var pitcher: PlayerPos!
        if i == 0 {
            if self.visitorCurrentLineup.filter({$0.position == "P"}).first != nil {
                pitcher = self.visitorCurrentLineup.filter({$0.position == "P"}).first
            } else {
                pitcher = self.visitorCurrentLineup.filter({$0.position == "F"}).first
            }
        } else {
            if self.homeCurrentLineup.filter({$0.position == "P"}).first != nil {
                pitcher = self.homeCurrentLineup.filter({$0.position == "P"}).first
            } else {
                pitcher = self.homeCurrentLineup.filter({$0.position == "F"}).first
            }
        }
        return pitcher
    }
    func addInning(inning: Inning, lineup: [PlayerPos], halfInning: Int) {
        var visitorPitcher = getCurrentPitcher(i: 0)
        var homePitcher = getCurrentPitcher(i: 1)
        
        var order = 1
        
            if halfInning == 0 {
                inning.half = halfInning
                for batter in self.visitorCurrentLineup.sorted(by: { $0.batting < $1.batting }) {
                    let plateAppearance = OffensivePlateAppearance(order: order, batter: batter.player, pitcher: homePitcher.player, inning: inning.number)
                    modelContext?.insert(plateAppearance)
                    do {
                        try modelContext?.save()
                    } catch {
                        print("save VOPA error \(error), \(error._domain)")
                    }
                    
                    inning.plateAppearances.append(plateAppearance)
                    order += 1
                }
                print("save VOPA count \(inning.half), \(inning.plateAppearances)")
                self.visitorInnings.append(inning)
                
            } else {
                inning.half = halfInning
                for batter in self.homeCurrentLineup.sorted(by: { $0.batting < $1.batting }) {
                    let plateAppearance = OffensivePlateAppearance(order: order, batter: batter.player, pitcher: visitorPitcher.player, inning: inning.number)
                    modelContext?.insert(plateAppearance)
                    do {
                        try modelContext?.save()
                    } catch {
                        print("save HOPA error \(error), \(error._domain)")
                    }
                    inning.plateAppearances.append(plateAppearance
                    )
                    order += 1
                }
                print("save HOPA count \(inning.half), \(inning.plateAppearances)")
                self.homeInnings.append(inning)
            }
    }

    func setInitialLineup(halfInning: Int) -> [[PlayerPos]]{
        var lineup: [[PlayerPos]] = []
        if halfInning == 0 {
            
            for each in self.visitorCurrentLineup.sorted(by: {$0.batting < $1.batting}) {
                lineup.append([each])
            }
            return lineup
        } else {
            for each in self.homeCurrentLineup.sorted(by: {$0.batting < $1.batting}) {
                lineup.append([each])
            }
            return lineup
        }
    }
    
    func insertSubIntoLineup(newPlayerPos: PlayerPos, selectedPlayer: PlayerPos) {
        
        if self.selectedTab == "Visitor" {
            var temp: [PlayerPos] = []
            var temp2: [[PlayerPos]] = []
            for each in self.visitorCurrentLineup {
                if each.id == selectedPlayer.id {
                    temp.append(newPlayerPos)
                } else {
                    temp.append(each)
                }
            }
            self.visitorCurrentLineup = temp
            
            for each in self.visitorLineup {
                var temp = each
                if each.last!.id == selectedPlayer.id {
                    temp.append(newPlayerPos)
                }
                temp2.append(temp)
            }
            self.visitorLineup = temp2
            
        } else {
            var temp: [PlayerPos] = []
            var temp2: [[PlayerPos]] = []
            for each in self.homeCurrentLineup {
                if each.id == selectedPlayer.id {
                    temp.append(newPlayerPos)
                } else {
                    temp.append(each)
                }
            }
            self.homeCurrentLineup = temp
            
            for each in self.homeLineup {
                var temp = each
                if each.last!.id == selectedPlayer.id {
                    temp.append(newPlayerPos)
                }
                temp2.append(temp)
            }
            self.homeLineup = temp2
        }
        // replace batter in plate appearances and pitcher if the pither was changed
        for each in game.innings {
            for app in each.plateAppearances {
                
                if !app.active {
                    if app.batter == selectedPlayer.player {
                        app.batter = newPlayerPos.player
                    }
                    if app.pitcher == selectedPlayer.player {
                        app.pitcher = newPlayerPos.player
                    }
                }
            }
        }
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
//    func getPitchers() -> [[PitcherStats]] {
//        var allPitchers: [[PitcherStats]] = []
//        var pitchers: [PitcherStats] = []
//        
//        for each in self.pitcherStats {
//            if self.visitors.contains(where: { $0.id == each.pitcherID }) {
//                print("vis: \(each.pitcherID)")
//                pitchers.append(each)
//            }
//        }
//        print("vis: \(pitchers.count)")
//        allPitchers.append(pitchers)
//        pitchers.removeAll()
//        for each in self.pitcherStats {
//            if self.home.contains(where: { $0.id == each.pitcherID }) {
//                print("home: \(each.pitcherID)")
//                pitchers.append(each)
//            }
//        }
//        print("home: \(pitchers.count)")
//        allPitchers.append(pitchers)
//        return allPitchers
//    }
    
    func getDefense(defense: [PlayerPos]) -> [String: Player]{
        let positions = ["P", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF"]
        var lineup: [String: Player] = [:]
        for pos in positions {
            for player in defense {
                if player.position == pos {
                    lineup[pos] = player.player
                    print("pos: \(pos) player:\(lineup[pos]?.number ?? "no player") assigned pos: \(lineup[pos]?.position ?? "no position")")
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
        print("\(inningRunRule)")
        if inningRuns < inningRunRule || inningRunRule == 0 {
            if team == 0 {
                print("vis score + 1 \(inningNumber[team])")
                score["visitor"]![inningNumber[0]/10 - 1] += 1
            } else {
                print("home score + 1 \(inningNumber[team])")
                score["home"]![inningNumber[1]/10 - 1] += 1
            }
            inningRuns += 1
        }
    }
    
    func getTotalScore(team: String) -> Int {
        return score[team]!.reduce(0, +)
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
    
//    func moveRunners(bases: Int, runnerToAdvance: Int) { //0, 1, 2, 3 for which base runner is at 0 = home
//        if runnerToAdvance == 0 {
//            for runner in baseRunners {
//                runner.baseOccupied += bases
//            }
//        } else if runnerToAdvance == 1 {
//            for i in 1..<baseRunners.count {
//                baseRunners[i].baseOccupied += bases
//            }
//        } else if runnerToAdvance == 2 {
//            for i in 2..<baseRunners.count {
//                baseRunners[i].baseOccupied += bases
//            }
//        } else {
//            for i in 3..<baseRunners.count {
//                baseRunners[i].baseOccupied += bases
//            }
//        }
//    }
    
    func getBaserunner(number: String) -> OffensivePlateAppearance {
        for runner in baseRunners {
            if runner.batter.number == number {
                return runner
            }
        }
        return self.baseRunners[0]
    }
    
    func getPlayerPA(innings: [Inning], player: Player) -> [OffensivePlateAppearance] {
        var plateAppearances: [OffensivePlateAppearance] = []
        
        for inning in innings {
            plateAppearances.append(contentsOf: inning.plateAppearances.filter { $0.batter.id == player.id } )
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
    
    func getPitcherPA(innings: [Inning], pitcher: Player) -> [OffensivePlateAppearance] {
        var plateAppearances: [OffensivePlateAppearance] = []
        
        for inning in innings {
            plateAppearances.append(contentsOf: inning.plateAppearances.filter { $0.pitcher.id == pitcher.id } )
        }
        return plateAppearances
    }
    
    func getPitcherStats(plateAppearances: [OffensivePlateAppearance]) -> PitcherStats {
        var pitcherStats = PitcherStats()
        var minInning = 200
        var maxInning = 10
        print("pa: \(plateAppearances.count)")
        for appearance in plateAppearances {
            if appearance.active {
                if appearance.inning < minInning {
                    minInning = appearance.inning
                } else if appearance.inning > maxInning {
                    maxInning = appearance.inning
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
        pitcherStats.inningsPitched = Double(maxInning/10 - minInning/10) + Double(self.outs)/3
        if pitcherStats.inningsPitched < 0 {
            pitcherStats.inningsPitched = 0.0
        }
            
        print("IP: \(pitcherStats.inningsPitched) \(self.outs)")
        return pitcherStats
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
        stats = self.getPlayerStats(plateAppearances: appearances)
        
        return stats
    }
    
    func checkGameComplete() {
        
        if self.inningNumber[0]/10 == self.totalInnings {
            if self.halfInning == 1 {
                if self.outs < 3 {
                    if self.getTotalScore(team: "home") > self.getTotalScore(team: "visitor") {
                        print("walk off home wins")
                        self.game.isComplete = true
                    }
                } else {
                    if self.getTotalScore(team: "home") < self.getTotalScore(team: "visitor") {
                        print("visitor wins")
                        self.game.isComplete = true
                    }
                }
            } else {
                if self.outs == 3 {
                    if self.getTotalScore(team: "home") > self.getTotalScore(team: "visitor") {
                        print("home wins")
                        self.game.isComplete = true
                    }
                }
            }
        }
        if self.game.isComplete {
            self.game.visitingLineup = decomposeLineup(lineup: self.visitorLineup)
            self.game.homeLineup = decomposeLineup(lineup: self.homeLineup)
            self.game.homeTeam?.lineup = self.homeCurrentLineup
            self.game.visitingTeam?.lineup = self.visitorCurrentLineup
            for inning in game.innings {
                for _ in inning.plateAppearances {
                    inning.plateAppearances.removeAll(where: { !$0.active })
                }
            }
        }
    }
    func checkInningComplete() -> Bool {
        print("outs: \(self.outs)")
        if self.inningRunRule != 0 {
            if self.inningRuns == self.inningRunRule {
                print("run rule")
                return true
            }
        }
        if self.outs >= 3 {
            print("3 outs")
            return true
        }
        print("continue inning")
        return false
    }
    
    func saveViewModelAsJSON() -> String {
        game.visitingFullLineup = self.visitorLineup
        game.homeFullLineup = self.homeLineup
        game.visitingLineup = self.visitorCurrentLineup
        game.homeLineup = self.homeCurrentLineup
        game.innings.append(contentsOf: self.visitorInnings)
        game.innings.append(contentsOf: self.homeInnings)
        
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = [.prettyPrinted]
//        if let jsonData = try? encoder.encode(self),
//           let jsonString = String(data: jsonData, encoding: .utf8) {
//            game.viewModel.append(jsonData)
//            print("saved view model")
//            return jsonString
//        }
        
        return "failed to encode view model"
    }
    
    
}
