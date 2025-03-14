//
//  ScoreKeepObjects.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/26/24.
//

import Foundation
import SwiftData

@Model
class Team {
    var id: UUID
    var name: String
    var ageGroup: String
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
}

@Model
class Coach {
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
}

@Model
class Player {
    var id: UUID
    var firstName: String
    var lastName: String
    var age: Int
    var number: String = ""
    var team: Team? = nil
    var position: String = ""
    @Relationship(deleteRule: .cascade, inverse: \PlateAppearance.batter) var plateAppearances: [PlateAppearance]?
    @Relationship(deleteRule: .cascade, inverse: \PlateAppearance.pitcher) var battersFaced: [PlateAppearance]?
    

    init(firstName: String, lastName: String, age: Int = 0, number: String, team: Team? = nil) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.number = number
        self.team = team
        self.position = position
    }
}

@Model
class Game {
    var id: UUID
    var name: String
    var homeTeam: Team? = nil
    var visitingTeam: Team? = nil
    var date: Date  //includes time
    var location: String
    var isComplete: Bool = false
    var homeLineup: [PlayerPos] = []
    var visitorLineup: [PlayerPos] = []
    
    init(name: String, date: Date, location: String, homeTeam: Team? = nil, visitingTeam: Team? = nil) {
        self.id = UUID()
        self.name = name
        self.homeTeam = homeTeam
        self.visitingTeam = visitingTeam
        self.date = date
        self.location = location
        self.isComplete = isComplete
    }
}

@Model
class Inning {
    var id: UUID = UUID()
    var number: Int = 0
    var homeLineup: [Player] = []
    var visitorLineup: [Player] = []
    var game: Game? = nil
    @Relationship(deleteRule: .cascade, inverse: \PlateAppearance.inning) var homePlateAppearances: [PlateAppearance]?
    @Relationship(deleteRule: .cascade, inverse: \PlateAppearance.inning) var visitorPlateAppearances: [PlateAppearance]?
    
    init() {
        self.number = number
        self.homeLineup = homeLineup
        self.visitorLineup = visitorLineup
        self.game = game
        self.homePlateAppearances = homePlateAppearances
        self.visitorPlateAppearances = visitorPlateAppearances
    }
}

@Model
class PlateAppearance {
    var id: UUID
    var balls: [Int]
    var strikes: [Int]
    var fouls: [Int]
    var outcome: String
    var rbi: Int
    var run: Bool
    var earnedRun: Bool
    var sb: [Int]?
    var lob: Int?
    var batter: Player
    var pitcher: Player
    var inning: Inning
    
    init(batter: Player, pitcher: Player, inning: Inning) {
        self.id = UUID()
        self.balls = []
        self.strikes = []
        self.fouls = []
        self.outcome = ""
        self.rbi = 0
        self.run = false
        self.earnedRun = false
        self.sb = []
        self.lob = 0
        self.batter = batter
        self.pitcher = pitcher
        self.inning = inning
    }
}

@Model
class PlayerPos {
    var id: UUID
    var batting: Int
    //var player: Player
    var firstName: String
    var lastName: String
    var number: String
    var position: String
    var game: Game? = nil
    
    init(batting: Int, firstName: String, lastName: String, number: String, position: String, game: Game) {
        self.id = UUID()
        self.batting = batting
        self.firstName = firstName
        self.lastName = lastName
        self.number = number
        self.position = position
        self.game = game
    }
    
}

