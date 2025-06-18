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
    @Published var visitorLineup: [PlayerPos]
    @Published var homeLineup: [PlayerPos]
    @Published var score = [
        "visitor": [0, 0, 0, 0, 0, 0, 0],
        "home": [0, 0, 0, 0, 0, 0, 0]
    ]
    @Published var inningNumber = 1
    @Published var halfInning = 0 // 1 for home half
    @Published var outs: Int = 0
    @Published var balls: Int = 0
    @Published var strikes: Int = 0
    @Published var pitches: [Pitch] = []
    @Published var batterUp = [0, 0]
    @Published var batter: OffensivePlateAppearance?
    @Published var pitcher: DefensivePlateAppearance?
    @Published var baseRunners: [BaseRunnerNode] = []
    
    var defensiveLineup: [String: Player] {
        if halfInning == 0 {
            return getDefense(defense: game.homeLineup)
        } else {
            return getDefense(defense: game.visitingLineup)
        }
    }
    
    
    init(game: Game) {
        self.game = game
        self.visitors = game.visitingTeam!.players!
        self.home = game.homeTeam!.players!
        self.visitorLineup = game.visitingLineup.sorted(by: {$0.batting < $1.batting})
        self.homeLineup = game.homeLineup.sorted(by: {$0.batting < $1.batting})
        //setUpGame()
        //getBatter()
    }
    
    func setUpGame() {
        for i in 1...9 {
            let inning = Inning(number: i*10, game: game)
            addInning(inning: inning, lineup: game.visitingLineup, halfInning: 0)
            addInning(inning: inning, lineup: game.homeLineup, halfInning: 1)
            //game.innings.append(inning)
        }
        getPitcher()
        //getBatter()
            //add generic plate appearances
            //visitor offense - home defense
//        var order = 1
//        for visBatter in game.visitingLineup {
//            for inning in game.innings {
//                inning.visitorOffense.append(OffensivePlateAppearance(order: order, batter: visBatter.player, inning: inning.number))
//                inning.homeDefense.append(DefensivePlateAppearance(order: order, pitcher: homePitcher.player, inning: inning.number))
//            }
//            order += 1
//        }
            
            // home offense - visitor defense
        //order = 1
//        for homeBatter in game.homeLineup {
//            for inning in game.innings {
//                inning.homeOffense.append(OffensivePlateAppearance(order: order, batter: homeBatter.player, inning: inning.number))
//                inning.visitorDefense.append(DefensivePlateAppearance(order: order, pitcher: visitorPitcher.player, inning: inning.number))
//            }
//        order += 1
//        }
    }
    func addInning(inning: Inning, lineup: [PlayerPos], halfInning: Int) {
        let visitorPitcher = game.visitingLineup.filter({$0.position == "P"}).first!
        let homePitcher = game.homeLineup.filter({$0.position == "P"}).first!
        var order = 1
        for batter in lineup {
            if halfInning == 0 {
                inning.visitorOffense.append(OffensivePlateAppearance(order: order, batter: batter.player, inning: inning.number))
                inning.homeDefense.append(DefensivePlateAppearance(order: order, pitcher: homePitcher.player, inning: inning.number))
            } else {
                inning.homeOffense.append(OffensivePlateAppearance(order: order, batter: batter.player, inning: inning.number))
                inning.visitorDefense.append(DefensivePlateAppearance(order: order, pitcher: visitorPitcher.player, inning: inning.number))
            }
            
            order += 1
        }
        game.innings.append(inning)
    }
    
    func getBatter() {
        let innings = game.innings.sorted(by: {$0.number < $1.number})
        let inning = innings[inningNumber-1]
        if halfInning == 0 {
            self.batter = inning.visitorOffense[batterUp[halfInning]]
            inning.visitorOffense[batterUp[halfInning]].active = true
            self.batter!.active = true
            
            baseRunners.insert(BaseRunnerNode(player: self.batter!), at: 0)
        } else {
            self.batter = inning.homeOffense[batterUp[halfInning]]
            self.batter!.active = true
            baseRunners.insert(BaseRunnerNode(player: self.batter!), at: 0)
        }
        
    }
    func getPitcher() {
        let innings = game.innings.sorted(by: {$0.number < $1.number})
        let inning = innings[inningNumber-1]
        if halfInning == 0 {
            self.pitcher = inning.homeDefense[batterUp[halfInning]]
            
        } else {
            self.pitcher = inning.visitorDefense[batterUp[halfInning]]
            
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
        
        batterUp[halfInning] += 1
        getBatter()
    }
    
    func incrementScore(team: Int) {
        if team == 0 {
            print(inningNumber)
            score["visitor"]![inningNumber/10 - 1] += 1
        } else {
            score["home"]![inningNumber - 1] += 1
        }
    }
    
    func getTotalScore(team: String) -> Int {
        return score[team]!.reduce(0, +)
    }
    
    func getTeamHits() -> [String: Int] { // 0 for visitor 1 for home
        var vHits = 0
        var hHits = 0
        for inning in self.game.innings {
            vHits += inning.visitorOffense.count(where: {$0.hit > 0})
            hHits += inning.homeOffense.count(where: {$0.hit > 0})
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
}
