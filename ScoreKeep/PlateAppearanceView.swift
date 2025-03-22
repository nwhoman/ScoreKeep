//
//  PlateAppearance.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/25/24.
//

import Foundation
import SwiftUI

struct PlateAppearanceView: View {
    @Environment(\.dismiss) var dismiss

    @State private var totalBalls: Int = 0
    @State private var totalStrikes: Int = 0
    @State private var pitchCount: Int = 0
    @State private var balls = [Int]()
    @State private var strikes = [Int]()
    @State private var fouls = [Int]()
    @State private var baseRunners = [Int]()
    @State private var showPlayOutcome: Bool = false
    @State var base: Int = 0
    var scale: CGFloat = 0.35
    var xoffset: CGFloat = 0
    var yoffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                FieldView(base: base, xoffset: xoffset, yoffset: yoffset)
            }
            .frame(width: geometry.size.width, height: geometry.size.height*0.15)
            .scaleEffect(scale)
        }
    }
}

#Preview {
    var scale: CGFloat = 0.55
    var xoffset: CGFloat = 0
    var yoffset: CGFloat = 0
    PlateAppearanceView(scale: scale, xoffset: xoffset, yoffset: yoffset)
}
//        VStack(alignment: .leading) {
//            Spacer()
//            Spacer()
//            HStack {
//                VStack{
//                    Text("Pitcher:").fontWeight(.bold)
//                        .font(.system(size: 25))
//                    HStack{
//                        Text("B: ").fontWeight(.bold).font(.system(size: 25))
//                        Text("\(totalBalls)").fontWeight(.bold).font(.system(size: 25))
//                    }
//                    
//                    HStack{
//                        Text("S: ").fontWeight(.bold).font(.system(size: 25))
//                        Text("\(totalStrikes)").fontWeight(.bold).font(.system(size: 25))
//                    }
//                }
//                Spacer()
//
//                VStack{
//                    Text("Runner:").fontWeight(.bold)
//                        .font(.system(size: 25))
//                    HStack{
//                        Text("3: ").fontWeight(.bold).font(.system(size: 25))
//                        if baseRunners.count > 2 {
//                            Text("\(baseRunners[2])")
//                                .fontWeight(.bold).font(.system(size: 25))
//                        }
//                    }
//                    HStack{
//                        Text("2: ").fontWeight(.bold).font(.system(size: 25))
//                        if baseRunners.count > 1 {
//                            Text("\(baseRunners[1])")
//                                .fontWeight(.bold).font(.system(size: 25))
//                        }
//                    }
//                    HStack{
//                        Text("1: ").fontWeight(.bold).font(.system(size: 25))
//                        if baseRunners.count > 0 {
//                            Text("\(baseRunners[0])")
//                                .fontWeight(.bold).font(.system(size: 25))
//                        }
//                    }
//                }
//            }
//            Spacer()
//
//            Text("Count:").fontWeight(.bold)
//                .font(.system(size: 25))
//            HStack{
//                Text("B: ").fontWeight(.bold).font(.system(size: 25))
//                if !balls.isEmpty {
//                    ForEach(balls, id: \.self) {
//                        Text("\($0)")
//                            .fontWeight(.bold).font(.system(size: 25))
//                    }
//                }
//            }
//            HStack{
//                Text("S: ").fontWeight(.bold).font(.system(size: 25))
//                if !strikes.isEmpty {
//                    ForEach(strikes, id: \.self) {
//                        Text("\($0)")
//                            .fontWeight(.bold).font(.system(size: 25))
//                    }
//                }
//            }
//            HStack{
//                Text("F: ").fontWeight(.bold).font(.system(size: 25))
//                if !fouls.isEmpty {
//                    ForEach(fouls, id: \.self) {
//                        Text("\($0)")
//                            .fontWeight(.bold).font(.system(size: 25))
//                    }
//                }
//            }
//            Spacer()
//            Text("Pitch:").fontWeight(.bold).font(.system(size: 25))
//           
//            List(pitches, id: \.self) { pitch in
//                Button(pitch){
//                    switch pitch {
//                    case "Ball":
//                        pitchCount = pitchCount + 1
//                        totalBalls = totalBalls + 1
//                        balls.append(pitchCount)
//                        if balls.count == 4 {
//                            baseRunners.insert(totalBalls, at: 0)
//                            pitchCount = 0
//                            balls = []
//                            strikes = []
//                            fouls = []
//                            //walk
//                        }
//                    case "Strike":
//                        pitchCount = pitchCount + 1
//                        totalStrikes = totalStrikes + 1
//                        strikes.append(pitchCount)
//                        if strikes.count == 3 {
//                            pitchCount = 0
//                            balls = []
//                            strikes = []
//                            fouls = []
//                            //strikeout
//                        }
//                    case "Foul":
//                        pitchCount = pitchCount + 1
//                        totalStrikes = totalStrikes + 1
//                        fouls.append(pitchCount)
//                        if strikes.count < 2 {
//                            strikes.append(pitchCount)
//                        }
//                    case "In Play":
//                        pitchCount = 0
//                        totalStrikes = totalStrikes + 1
//                        balls = []
//                        strikes = []
//                        fouls = []
//                        showPlayOutcome = true
//                    case "HP":
//                        pitchCount = pitchCount + 1
//                        baseRunners.insert(pitchCount, at: 0)
//                        pitchCount = 0
//                        totalBalls = totalBalls + 1
//                        balls = []
//                        strikes = []
//                        fouls = []
//                        // adv br 1 base
//                    default:
//                        print("what happened?")
//                    }
//                }
//            }
//            .frame(width: 125, height: 280, alignment: .leading)
//            
//        }
//        .padding()
//        .sheet(isPresented: $showPlayOutcome, content: {
//            PlayOutcomeView()
//        })
//    }


