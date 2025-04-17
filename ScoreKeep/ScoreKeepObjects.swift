//
//  ScoreKeepObjects.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/26/24.
//

import Foundation
import SpriteKit
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
    var isStarted: Bool = false
    @Relationship(deleteRule: .cascade, inverse: \Inning.game) var innings: [Inning] = []
    
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
}

@Model
class Inning {
    var id: UUID = UUID()
    var number: Int
    var game: Game
    
    var visitorOffense: [OffensivePlateAppearance] = []
    var homeDefense: [DefensivePlateAppearance] = []
    var homeOffense: [OffensivePlateAppearance] = []
    var visitorDefense: [DefensivePlateAppearance] = []
   
    init(number: Int, game: Game) {
        self.number = number
        self.game = game
        
    }
}

@Model
class OffensivePlateAppearance {
    var id: UUID
    var order: Int
    var batter: Player
    var inning: Int
    var pitches: [Pitch]
    var outs: Int
    var outcome: String
    var baseOccupied: Int
    var rbi: Int
    var run: Bool
    var earnedRun: Bool
    var sb: [Int]?
    var lob: Int?
    var active: Bool
    
    init(order: Int, batter: Player, inning: Int) {
        self.id = UUID()
        self.order = order
        self.batter = batter
        self.inning = inning
        self.pitches = []
        self.outs = 0
        self.outcome = ""
        self.baseOccupied = 0
        self.rbi = 0
        self.run = false
        self.earnedRun = false
        self.sb = []
        self.lob = 0
        self.active = false
    }
    
}

@Model
class DefensivePlateAppearance {
    var id: UUID
    var order: Int
    var pitcher: Player
    var inning: Int
    var run: Bool
    var earnedRun: Bool
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
}

@Model
class PlayerPos: Identifiable, Hashable {
    var id: UUID
    var batting: Int
    var player: Player
    var position: String
    
    init(player: Player, position: String, batting: Int = 0) {
        self.id = UUID()
        self.batting = batting
        self.player = player
        self.position = position
    }
}

class BaseRunner: SKLabelNode {
    var player: OffensivePlateAppearance
    
    init(player: OffensivePlateAppearance) {
        self.player = player
        
        super.init(fontNamed: "Trebuchet MS")
        self.name = player.batter.number
        self.text = "#\(player.batter.number)"
        self.fontSize = 20
        self.fontColor = SKColor.blue
        self.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = 0x1 << 0
        self.physicsBody?.contactTestBitMask = 0x1 << 0
        self.physicsBody?.collisionBitMask = 0x1 << 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct BattingLineupView: View {
    
    let geo: GeometryProxy
    let team: Team
    
    var battingOrder: [PlayerPos] {
        return team.lineup.sorted { $0.batting < $1.batting }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(team.name)")
                .padding(.horizontal, 5)
                .padding(.top, 5)
                .frame(width: geo.size.width*0.4, height: 50, alignment: .leading)
                .border(Color.blue)
            ForEach(battingOrder, id: \.self) { player in
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
    @ObservedObject var gameViewModel: GameViewModel

    let innings: [Any] = [1, 2, 3, 4, 5, 6, 7, "R", "H", "E"]
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .trailing) {
                Spacer()
                Text("Visitor:")
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 45.0, height: 15.0)
                Text("Home: ")
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 45.0, height: 15.0)
                    //.padding(.bottom, -10)
            }
            .frame(width: 70, height: 55)
            .border(Color.gray, width: 0.5)
            VStack(alignment: .leading) {
                HStack {
           
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
                    Text("\(gameViewModel.getTotalScore(team: "visitor"))") // change to hits
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
                    Text("\(gameViewModel.getTotalScore(team: "home"))") // change to hits
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 15.0, height: 15.0)
                    Text("\(gameViewModel.getTotalScore(team: "home"))") // change to errors
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 15.0, height: 15.0)
                }.padding(.bottom, -5)
            }
            .frame(width: 220, height: 55)
            .border(Color.gray, width: 0.5)
        }
        .frame(width: 400, height: 75, alignment: .leading)
    }
}

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
                                    .foregroundStyle(.white)
                            }
                                .frame(width: 15.0, height: 17.0)
                        }
                    }
                    Spacer()
                }
                .frame(width: 135.0, height: 17.0)
                .padding(.leading, 0)
                
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
        .border(Color.red)
        
    }

}
#Preview {

    CountView(pitches: [.ball, .strikeSwinging, .ball, .ball, .strikeLooking, .foul, .ball, .foul, .foul, .foul])
}
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

