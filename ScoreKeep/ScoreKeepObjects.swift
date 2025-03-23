//
//  ScoreKeepObjects.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/26/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Team {
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
    @Relationship(deleteRule: .cascade, inverse: \OffensivePlateAppearance.batter) var plateAppearances: [OffensivePlateAppearance]?
    @Relationship(deleteRule: .cascade, inverse: \OffensivePlateAppearance.pitcher) var battersFaced: [OffensivePlateAppearance]?
    

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
    var homeLineup: [PlayerPos] = []
    var visitingTeam: Team? = nil
    var visitingLineup: [PlayerPos] = []
    var date: Date  //includes time
    var location: String
    var isComplete: Bool = false
    
    
    init(name: String, date: Date = .now, location: String, homeTeam: Team? = nil, visitingTeam: Team? = nil) {
        self.id = UUID()
        self.name = name
        self.homeTeam = homeTeam
        self.visitingTeam = visitingTeam
        self.date = date
        self.location = location
        self.isComplete = isComplete
    }
    
//    static var defaultGame: Game {
//        var homeTeam = Team.defaultTeam
//        var visitingTeam = Team.defaultTeam
//        let gameName = "\(homeTeam.name) vs \(visitingTeam.name)"
//        let newGame = Game(name: gameName, date: Date(), location: "", homeTeam: homeTeam, visitingTeam: visitingTeam)
//        return newGame
//    }
}

@Model
class Inning {
    var id: UUID = UUID()
    var number: Int = 0
    var homeLineup: [Player] = []
    var visitorLineup: [Player] = []
    var game: Game? = nil
    @Relationship(deleteRule: .cascade, inverse: \OffensivePlateAppearance.inning) var homePlateAppearances: [OffensivePlateAppearance]?
    @Relationship(deleteRule: .cascade, inverse: \OffensivePlateAppearance.inning) var visitorPlateAppearances: [OffensivePlateAppearance]?
    
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
class OffensivePlateAppearance {
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
        self.inning = inning
    }
}

@Model
class DefensivePlateAppearance {
    var id: UUID
    var pitcher: Player

    init(id: UUID, pitcher: Player) {
        self.id = id
        self.pitcher = pitcher
    }
}

@Model
class PlayerPos: Identifiable, Hashable {
    var id: UUID
    var batting: Int
    var player: Player
    //var firstName: String
    //var lastName: String
    //var number: String
    var position: String
    
    
    init(player: Player, position: String, batting: Int = 0) {
        self.id = UUID()
        self.batting = batting
        self.player = player
        //self.firstName = firstName
        //self.lastName = lastName
        //self.number = number
        self.position = position
    }
    
}

struct BattingLineupView: View {
    
    let geo: GeometryProxy
    let team: Team
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(team.name)")
                .padding(.horizontal, 5)
                .padding(.top, 5)
                .frame(width: geo.size.width*0.4, height: 50, alignment: .leading)
                .border(Color.blue)
            ForEach(team.lineup, id: \.self) { player in
                HStack {
                    Text("\(player.batting+1)) \(player.player.number) - \(player.player.lastName), \(player.player.firstName.first!)")
                    Spacer(minLength: 10)
                    Text("\(player.position)")
                }.lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                .padding(.horizontal, 5)
                .padding(.top, 5)
                .frame(width: geo.size.width*0.4, height: 75, alignment: .topLeading)
                .border(Color.blue)
            }
        }
        
            
    }
        
}
//#Preview {
//    
//    BattingLineupView()
//}
struct ScoreView: View {
    let innings: [Int] = [1, 2, 3, 4, 5, 6, 7]
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack {
                Text("Visitor:")
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 45.0, height: 15.0)
                Text("Home: ")
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 45.0, height: 15.0)
                    //.padding(.bottom, -10)
            }
            VStack(alignment: .leading) {
                HStack {
                    
                    ForEach(innings, id: \.self) {inning in
                        Text("\(inning)")
                            .font(.system(size: 12, weight: .bold))
                            .frame(width: 15.0, height: 15.0)
                    }
                }
                .padding(.bottom, -5)
                HStack {
                    
                    ForEach(innings, id: \.self) {inning in
                        Text("\(inning)")
                            .font(.system(size: 12, weight: .bold))
                            .frame(width: 15.0, height: 15.0)
                    }
                }.padding(.bottom, -5)
                HStack {
                    
                    ForEach(innings, id: \.self) {inning in
                        Text("\(inning)")
                            .font(.system(size: 12, weight: .bold))
                            .frame(width: 15.0, height: 15.0)
                    }
                }.padding(.bottom, -5)
            }
            .frame(width: 150, height: 50)
        }
        .frame(width: 400, height: 75, alignment: .leading)
    }
}

struct CountView: View {
    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                Text("Strikes:")
                    .font(.title3)
                Text("Balls:")
                    .font(.title3)
                //Text("Outs:")
                    //.font(.title3)
            }
            VStack(alignment: .leading) {
                HStack {
                    Image("red-sphere")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 15.0, height: 20.0)
                        .padding(-2)
                    Image("red-sphere")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 15.0, height: 20.0)
                        .padding(-2)
                    Image("red-sphere")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 15.0, height: 20.0)
                }
                HStack{
                    
                    Image("blue-sphere")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 15.0, height: 20.0)
                        .padding(-2)
                    Image("blue-sphere")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 15.0, height: 20.0)
                        .padding(-2)
                    Image("blue-sphere")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 15.0, height: 20.0)
                        .padding(-2)
                    Image("blue-sphere")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 15.0, height: 20.0)
                        .padding(-2)
                }
//                HStack {
//                    Image("green-sphere")
//                        .resizable()
//                        .padding(-5)
//                        .frame(width: 20.0, height: 20.0)
//                        .padding(-2)
//                    Image("green-sphere")
//                        .resizable()
//                        .padding(-5)
//                        .frame(width: 20.0, height: 20.0)
//                        .padding(-2)
//                    Image("green-sphere")
//                        .resizable()
//                        .padding(-5)
//                        .frame(width: 20.0, height: 20.0)
//                        .padding(-2)
//                        
//                }
            }
            
        }
        
    }

}

struct FieldView: View {
    var base: Int
    
    let xoffset: CGFloat
    let yoffset: CGFloat
    
    var body: some View {
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

