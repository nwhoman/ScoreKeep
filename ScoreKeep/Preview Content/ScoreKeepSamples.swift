//
//  ScoreKeepSamples.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/15/25.
//

import Foundation

extension Player {
    static var firstNames: String { ["Neal", "John", "Michael", "David", "Robert", "William", "James", "Charles", "Thomas", "Christopher", "Daniel", "Matthew", "Andrew", "Joseph", "James", "Robert", "Harry", "Hermione", "Ron", "Ginny", "Fleur", "Luna", "Cho", "Neville", "Fred", "George", "Rubeus", "Quirinus", "Albus", "Severus", "Bellatrix", "Rita", "Vernon", "Minerva", "Pomona", "Salazar", "Tom"].randomElement()!}
    static var lastNames: String {  ["Homan", "Potter", "Weasley", "Hagrid", "Dumbledore", "Snape", "Lestrange", "Skeeter", "Dursley", "McGonigal", "Trewlany", "Slytherin", "Hufflepuff", "Ravenclaw", "Riddell", "Flitwick", "Finnegin", "Thomas", "Chang", "Granger", "Black", "Lupin", "Lovegood", "Longbottom", "DeLaceur", "Pettigrew", "Quirrell", "Filch"].randomElement()!}
    static var numbers: String {
        var newNum = ["00"]
        for i in (0..<100) {
            newNum.append(String(i))
        }
        return newNum.randomElement()!
    }
    
    static var newPlayer: Player {
        return Player(firstName: firstNames, lastName: lastNames, number: numbers)
    }
}

extension Coach {
    static var firstNames: String { ["Neal", "John", "Michael", "David", "Robert", "William", "James", "Charles", "Thomas", "Christopher", "Daniel", "Matthew", "Andrew", "Joseph", "James", "Robert", "Harry", "Hermione", "Ron", "Ginny", "Fleur", "Luna", "Cho", "Neville", "Fred", "George", "Rubeus", "Quirinus", "Albus", "Severus", "Bellatrix", "Rita", "Vernon", "Minerva", "Pomona", "Salazar", "Tom"].randomElement()!}
    static var lastNames: String {  ["Homan", "Potter", "Weasley", "Hagrid", "Dumbledore", "Snape", "Lestrange", "Skeeter", "Dursley", "McGonigal", "Trewlany", "Slytherin", "Hufflepuff", "Ravenclaw", "Riddell", "Flitwick", "Finnegin", "Thomas", "Chang", "Granger", "Black", "Lupin", "Lovegood", "Longbottom", "DeLaceur", "Pettigrew", "Quirrell", "Filch"].randomElement()!}
    
    static var createCoach: Coach {
        return Coach(firstName: firstNames, lastName: lastNames)
    }
}

extension Game {
    static var states: String {
        return ["Alabama", "Alaska", "Oregon", "Washington", "California", "Idaho", "Montana", "Utah", "Colorado"].randomElement()!
    }
    static var names: String {
        return ["Thunder", "Lightning", "Raptors", "Warriors", "Celtics", "Nets", "76ers", "Bulls", "Mavericks", "Nuggets", "Heat", "Bucks", "Cavaliers", "Pistons", "Bucks", "Nuggets", "Heat", "Bucks", "Cavaliers", "Pistons"].randomElement()!
    }
    static var location: String {
        return states
    }
    static var  getName: String {
        return "\(location) \(names)"
    }
    static var defaultTeam: Team {
        var teams: [Team] = []
        
        let team = Team(name: getName)
        for _ in 0..<11 {
            team.players?.append(Player.newPlayer)
        }
        var ageGroup: String {
            var newNum: [String] = []
            for i in (8..<18) {
                newNum.append("U\(String(i))")
            }
            return newNum.randomElement()!
        }
        team.ageGroup = ageGroup
        team.coaches?.append(Coach.createCoach)
        teams.append(team)
        
        
        return team
    }
    static var defaultGame: Game {
        let home: Team = self.defaultTeam
        let visitor: Team = self.defaultTeam
        let location: String = home.name.components(separatedBy: " ").first ?? ("\(home.name)")
        return Game(name: "\(visitor.name) v \(home.name)", location: "\(location) Stadium", homeTeam: home, visitingTeam: visitor)
    }
    
    func createLineup(players: [Player]) -> [PlayerPos] {
        var positions: [String] = ["P", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF"]
        var lineup: [PlayerPos] = []
        
        for i in 0..<positions.count {
            lineup.append(PlayerPos(player: players[i], position: positions[i], batting: i ))
        }
        return lineup
    }
}
