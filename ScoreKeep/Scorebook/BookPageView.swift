//
//  BookPageView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/21/25.
//

import SwiftUI

struct BookPageView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var game: Game
    @State var showLargeView: Bool = false
    let innings: [Int] = [1, 2, 3, 4, 5, 6, 7]
    var selectedTab: String
    
    var team: Team {
        if selectedTab == "Home" {
            return game.homeTeam!
        } else {
            return game.visitingTeam!
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                // score by inning + RHE
                ScoreView()
                    .padding()
                ScrollView() {
                    HStack {
                        BattingLineupView(geo: geo, team: team)
                            //.padding(.leading)
                            .border(Color.blue)
                        ScrollView(Axis.Set.horizontal) {
                            InningsView(showLargeView: $showLargeView, team: team, innings: innings)
                                
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: $showLargeView)
        {
            LargePlateAppearanceView()
                .presentationBackground(alignment: .top) {
                    LinearGradient(colors: [Color.gray, Color.green], startPoint: .bottomLeading, endPoint: .topTrailing)
              }
              .presentationCornerRadius(50)
        }
    }
}

#Preview {
    var game = Game.defaultGame
    let preview = Preview()
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
    
    return BookPageView(game: game, selectedTab: "Home - \(game.homeTeam!.name)")
        .modelContainer(preview.modelContainer)
}

struct InningsView: View {
    @Binding var showLargeView: Bool
    var team: Team
    var innings: [Int]
    var body: some View {
        HStack {
            ForEach(innings, id: \.self) { inning in
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                    Text("\(inning)")
                        .frame(width: 75, height: 50, alignment: .center)
                        .border(Color.blue)
                        ForEach(team.lineup, id: \.self) { player in
                            GeometryReader { geo in
                                SmallPlateAppearanceView(scale: 0.15)
                                    .onTapGesture {
                                        showLargeView.toggle()
                                    }
                            }
                            
                            
                        }
                        .frame(width: 75, height: 75, alignment: .topLeading)
                        //.border(Color.black)
                    }
                }
            }
            
        }
    }
}
struct SmallPlateAppearanceView: View {
    let scale: CGFloat
    var body: some View {
        GeometryReader { geo in
            
            VStack(alignment: .leading) {
                
                ZStack {
                    
                    PlateAppearanceView(scale: scale, xoffset: -150, yoffset: -70)
                        .frame(width: geo.size.width, height: geo.size.height)
                    VStack {
                        HStack {
                            Text("")
                                .font(.system(size: 8))
                                .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
                                .padding(.horizontal, -2)
                            Text("2B")
                                .font(.system(size: 8))
                                .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
                                .padding(.horizontal, -2)
                            Text("")
                                .font(.system(size: 8))
                                .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
                                .padding(.horizontal, -2)
                            Text("")
                                    .font(.system(size: 8))
                                    .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
                                    .padding(.horizontal, -2)
                            }
                            .frame(width: geo.size.width, height: geo.size.height*0.2)
                        Text("")
                                .font(.system(size: 14))
                                .frame(width: geo.size.width*0.6, height: geo.size.height*0.05)
                                .padding(.horizontal, -2)
                        
                        HStack {
                            
                            CountView()
                                .frame(width: geo.size.width*0.4, height: geo.size.height*0.2)
                                .scaleEffect(0.25)
                                .padding(.leading, -5)
                                .padding(.top, -15)
                            Text("")
                                .padding(.leading,-5)
                                .font(.system(size: 10).bold())
                                .frame(width: geo.size.width*0.15, height: geo.size.height*0.2)
                                .foregroundColor(Color.black)
                                    
                                .padding(.top, -10)
                            Text("")
                                
                                .font(.system(size: 14).bold())
                                .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
                                .foregroundColor(Color.red)
                                    //.background(Color.black)
                                .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 1)))
                                .foregroundColor(Color.red)
                                .padding(.top, -15)
                                .padding(.leading,-5)
                        }.frame(width: geo.size.width, height: geo.size.height)
                    }//.border(Color.red)
                }
                .frame(width: 75, height: 75, alignment: .topLeading)
                .border(Color.blue)
                .overlay(!true ? Rectangle().fill(Color.gray).opacity(0.6) : nil)
            }
        }
    }

}
