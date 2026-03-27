//
//  GameViewModel.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/29/25.
//

import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    var game: Game
    @Published var visitors: [Player]
    @Published var home: [Player]
    @Published var visitorLineup: [[PlayerPos]] = []                // book lineup
    @Published var homeLineup: [[PlayerPos]] = []
    @Published var visitorCurrentLineup: [PlayerPos]           // lineup changing lineup
    @Published var homeCurrentLineup: [PlayerPos]
    @Published var selectedTab: String = "Visitor"
    @Published var totalInnings: Int
    @Published var score:[String : [Int]] = [:]
    @Published var inningNumber = 10
    @Published var halfInning = 0 // 1 for home half
    @Published var outs: Int = 0
    @Published var balls: Int = 0
    @Published var strikes: Int = 0
    @Published var pitches: [Pitch] = []
    @Published var batterUp = [1, 1]
    @Published var batterCount = [0, 0]
    @Published var batter: OffensivePlateAppearance?
    @Published var pitcher: DefensivePlateAppearance?
    @Published var baseRunners: [BaseRunnerNode] = []
    @Published var player: OffensivePlateAppearance?
    @Published var undoPlay: [GameViewModel] = []
    @Published var pitcherStats: [PitcherStats] = []
    
    var sortedVisitorLineup: [[PlayerPos]] {
        visitorLineup.sorted(by: { $0.last!.batting < $1.last!.batting })
    }
    
    var sortedHomeLineup: [[PlayerPos]] {
        homeLineup.sorted(by: { $0.last!.batting < $1.last!.batting })
    }
    
    var defensiveLineup: [String: Player] {
        if halfInning == 0 {
            return getDefense(defense: game.homeLineup)
        } else {
            return getDefense(defense: game.visitingLineup)
        }
    }
    
    var visitorInnings: [Inning] {
        game.innings.filter { $0.half == 0 }.sorted(by: {$0.number < $1.number})
    }
    
    var homeInnings: [Inning] {
        game.innings.filter { $0.half == 1 }.sorted(by: {$0.number < $1.number})
    }
    
    init(game: Game, totalInnings: Int) {
        self.game = game
        self.visitors = game.visitingTeam!.players!
        self.home = game.homeTeam!.players!
        
        self.visitorCurrentLineup = game.visitingTeam?.lineup ?? []
        self.homeCurrentLineup = game.homeTeam?.lineup ?? []
        self.totalInnings = totalInnings
        self.score = setScoreTable()
        //self.visitorLineup = setInitialLineup(halfInning: 0)
        //self.homeLineup = setInitialLineup(halfInning: 1)
        //setUpGame()
        //getBatter()
        
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
        print("batterCount \(batterCount)")
        for i in 1...9 {
            print("adding inning: \(i)")
            let vInning = Inning(number: i*10, game: game, half: 0)
            addInning(inning: vInning, lineup: game.visitingLineup, halfInning: 0)
            let hInning = Inning(number: i*10, game: game, half: 1)
            addInning(inning: hInning, lineup: game.homeLineup, halfInning: 1)
        }
        //getPitcher()
        //print(self.batterCount)
        
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
    func addInning(inning: Inning, lineup: [PlayerPos], halfInning: Int) {
        var visitorPitcher: PlayerPos!
        var homePitcher: PlayerPos!
        if self.visitorCurrentLineup.filter({$0.position == "P"}).first != nil {
            visitorPitcher = self.visitorCurrentLineup.filter({$0.position == "P"}).first
        } else {
            visitorPitcher = self.visitorCurrentLineup.filter({$0.position == "F"}).first
        }
        if self.homeCurrentLineup.filter({$0.position == "P"}).first != nil {
            homePitcher = self.homeCurrentLineup.filter({$0.position == "P"}).first
        } else {
            homePitcher = self.homeCurrentLineup.filter({$0.position == "F"}).first
        }
        
        var order = 1
        
            if halfInning == 0 {
                inning.half = halfInning
                print("Vis line: \(lineup.count)")
                for batter in self.visitorCurrentLineup.sorted(by: { $0.batting < $1.batting }) {
                    print("adding VOPA to inning: \(batter.player.number) HDPA: \(homePitcher.player.number)")
                    inning.offense.append(OffensivePlateAppearance(order: order, batter: batter.player, inning: inning.number))
                    inning.defense.append(DefensivePlateAppearance(order: order, pitcher: homePitcher.player, inning: inning.number))
                    order += 1
                }
                game.innings.append(inning)
                
            } else {
                inning.half = halfInning
                print("home line: \(lineup.count)")
                for batter in self.homeCurrentLineup.sorted(by: { $0.batting < $1.batting }) {
                    print("adding HOPA to inning: \(batter.player.number) VDPA: \(homePitcher.player.number)")
                    inning.offense.append(OffensivePlateAppearance(order: order, batter: batter.player, inning: inning.number))
                    inning.defense.append(DefensivePlateAppearance(order: order, pitcher: visitorPitcher.player, inning: inning.number))
                    order += 1
                }
                game.innings.append(inning)
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
        for each in game.innings {
            for app in each.offense {
                
                if !app.active && app.batter == selectedPlayer.player {
                    app.batter = newPlayerPos.player
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
            let inning = visitorInnings[inningNumber/10-1]
            self.batter = inning.offense[batterUp[halfInning]]
            inning.offense[batterUp[halfInning]].active = true
            self.batter!.active = true
            
            baseRunners.insert(BaseRunnerNode(player: self.batter!), at: 0)
        } else {
            let inning = homeInnings[inningNumber/10-1]
            self.batter = inning.offense[batterUp[halfInning]]
            self.batter!.active = true
            baseRunners.insert(BaseRunnerNode(player: self.batter!), at: 0)
        }
        
    }
    func getPitcher() {
        
        if halfInning == 0 {
            let inning = visitorInnings[inningNumber/10-1]
            print("\(inning.defense.count) \(batterUp[halfInning])")
            
            self.pitcher = inning.defense[batterUp[halfInning]-1]
            self.pitcher!.active = true

        } else {
            let inning = homeInnings[inningNumber/10-1]
            print("\(inning.defense.count) \(batterUp[halfInning]-1)")
            
            self.pitcher = inning.defense[batterUp[halfInning]]
            self.pitcher!.active = true
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
        print("before \(batterUp[halfInning]-1) \(batterCount[halfInning])")
        if batterUp[halfInning] != self.batterCount[halfInning] {
            batterUp[halfInning] += 1
        } else {
            batterUp[halfInning] = 1
        }
        print("after \(batterUp[halfInning]-1)")
    }
    
    func decrementBatterUp() {
        if batterUp[halfInning] != 1 {
            batterUp[halfInning] -= 1
        } else {
            batterUp[halfInning] = self.batterCount[halfInning]
        }
    }
    
    func incrementScore(team: Int) {
        if team == 0 {
            score["visitor"]![inningNumber/10 - 1] += 1
        } else {
            score["home"]![inningNumber/10 - 1] += 1
        }
    }
    
    func getTotalScore(team: String) -> Int {
        return score[team]!.reduce(0, +)
    }
    
    func getTeamHits() -> [String: Int] { // 0 for visitor 1 for home
        var vHits = 0
        var hHits = 0
        for inning in self.visitorInnings {
            vHits += inning.offense.count(where: {$0.hit > 0})
        }
        for inning in self.homeInnings {
            hHits += inning.offense.count(where: {$0.hit > 0})
        }
        return [
            "visitor": vHits,
            "home": hHits
        ]
    }
    
    func moveRunners(bases: Int, runnerToAdvance: Int) { //0, 1, 2, 3 for which base runner is at 0 = home
        if runnerToAdvance == 0 {
            for runner in baseRunners {
                runner.player.baseOccupied += bases
            }
        } else if runnerToAdvance == 1 {
            for i in 1..<baseRunners.count {
                baseRunners[i].player.baseOccupied += bases
            }
        } else if runnerToAdvance == 2 {
            for i in 2..<baseRunners.count {
                baseRunners[i].player.baseOccupied += bases
            }
        } else {
            for i in 3..<baseRunners.count {
                baseRunners[i].player.baseOccupied += bases
            }
        }
    }
    func getBaserunner(number: String) -> BaseRunnerNode {
        for runner in baseRunners {
            if runner.player.batter.number == number {
                return runner
            }
        }
        return self.baseRunners[0]
    }
    
    func getPlayerPA(innings: [Inning], player: Player) -> [OffensivePlateAppearance] {
        var plateAppearances: [OffensivePlateAppearance] = []
        
        for inning in innings {
            plateAppearances.append(contentsOf: inning.offense.filter { $0.batter.id == player.id } )
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
    
    func getPitcherPA(innings: [Inning], pitcher: Player) -> [DefensivePlateAppearance] {
        var plateAppearances: [DefensivePlateAppearance] = []
        
        for inning in innings {
            plateAppearances.append(contentsOf: inning.defense.filter { $0.pitcher.id == pitcher.id } )
        }
        print(plateAppearances.count)
        return plateAppearances
    }
    
    func getPitcherStats(plateAppearances: [DefensivePlateAppearance]) -> PitcherStats {
        var pitcherStats = PitcherStats()
        var minInning = 200
        var maxInning = 0
        
        for appearance in plateAppearances {
            if appearance.active {
                if appearance.inning < minInning {
                    minInning = appearance.inning
                } else if appearance.inning > maxInning {
                    maxInning = appearance.inning
                }
                for pitch in appearance.pitches {
                    if pitch == .ball {
                        pitcherStats.balls += 1
                    } else if pitch == .strikeLooking || pitch == .strikeSwinging || pitch == .foul{
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
                }
                if appearance.earnedRun {
                    pitcherStats.er += 1
                }
                pitcherStats.bb += appearance.bb
                pitcherStats.k += appearance.k
                
                pitcherStats.hp += appearance.hp
                pitcherStats.sac += appearance.sac
                pitcherStats.wp += appearance.wp
            }

        }
        pitcherStats.inningsPitched = Double(maxInning/10 - minInning/10) + Double(self.outs/3)
        
        return pitcherStats
    }
    
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
            for appearance in inning.offense {
                if appearance.active {
                    appearances.append(appearance)
                }
            }
        }
        stats = self.getPlayerStats(plateAppearances: appearances)
        
        return stats
    }
    
    func checkGameComplete() {
        
        if self.inningNumber/10 == self.totalInnings {
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
            
            for inning in game.innings {
                for app in inning.offense {
                    inning.offense.removeAll(where: { !$0.active })
                }
                for app in inning.defense {
                    inning.defense.removeAll(where: { !$0.active })
                }
            }
        }
    }
}
