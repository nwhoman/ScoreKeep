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
            for appearance in inning.offense {
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
            appearances.append(contentsOf: inning.offense.filter { $0.batter.id == player.id } )
        }
        stats = getPlayerStats(plateAppearances: appearances)
        return stats
    }
}

@Model
class Inning {
    var id: UUID = UUID()
    var number: Int
    var game: Game
    var half: Int
    
    var offense: [OffensivePlateAppearance] = []
    var defense: [DefensivePlateAppearance] = []
    //var homeOffense: [OffensivePlateAppearance] = []
    //var visitorDefense: [DefensivePlateAppearance] = []
   
    init(number: Int, game: Game, half: Int) {
        self.number = number
        self.game = game
        self.half = half
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
    var hit: Int
    var outcome: [String]
    var baseOccupied: Int
    var rbi: Int
    var run: Bool
    var earnedRun: Bool
    var sb: [Int]
    var lob: Int?
    var bb: Int = 0
    var hp: Int = 0
    var sac: Int = 0
    var re: Int = 0
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
    
    init(order: Int, batter: Player, inning: Int) {
        self.id = UUID()
        self.order = order
        self.batter = batter
        self.inning = inning
        self.pitches = []
        self.outs = 0
        self.hit = 0
        self.outcome = []
        self.baseOccupied = 0
        self.rbi = 0
        self.run = false
        self.earnedRun = false
        self.sb = []
        self.lob = 0
        self.active = false
        self.hitLoc = CGPoint(x: 0.0, y: 0.0)
    }
    private var _hitLocX: Double = 0.0
    private var _hitLocY: Double = 0.0
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
    var statSummary: [Int] {
        return [self.plateAppearances, self.atBats, self.hits, self.doubles, self.triples, self.homeRuns, self.runs, self.rbi, self.bb, self.k, self.hp, self.sac]
    }
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
                    Text("\(player.batting)) \(player.player.number) - \(player.player.lastName), \(player.player.firstName.first!)")
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
                        .frame(width: geo.size.width, height: geo.size.height)

                        .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 1)))
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
            .frame(width: geo.size.width*0.75, height: 17)
            //.border(Color.black)
        }
    }
}
//#Preview {
//    SacOutView()
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


struct BaseRunnerNode {
    var player: OffensivePlateAppearance
    var node: SKLabelNode
    
    init(player: OffensivePlateAppearance) {
        self.player = player
        self.node = SKLabelNode(fontNamed: "Trebuchet MS")
        self.node.fontColor = .blue
        
    
        self.node.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        self.node.physicsBody?.affectedByGravity = false
    
        self.node.text = "#\(player.batter.number)"
        self.node.name = "\(player.batter.number)"
        self.node.fontSize = 20
        self.node.fontColor = SKColor.blue
        self.node.physicsBody?.isDynamic = true
        self.node.physicsBody?.restitution = 0.0
        self.node.physicsBody?.categoryBitMask = (1 << 0)
        self.node.physicsBody?.contactTestBitMask = (1 << 1)
        self.node.physicsBody?.collisionBitMask = (1 << 1)
    }
}
