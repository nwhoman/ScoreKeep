//
//  LargePlateAppearanceView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/21/25.
//

import SwiftUI

struct LargePlateAppearanceView: View {
    
    var scale: CGFloat = 0.75
    
    var body: some View {
        GeometryReader { geo in
            
            
            VStack(alignment: .leading) {
                
                VStack {
                    HStack {
                        Text("1B")
                            .font(.system(size: 28))
                            .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
                            .padding(.horizontal, -2)
                        Text("2B")
                            .font(.system(size: 28))
                            .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
                            .padding(.horizontal, -2)
                        Text("3B")
                            .font(.system(size: 28))
                            .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
                            .padding(.horizontal, -2)
                        Text("HR")
                            .font(.system(size: 28))
                            .frame(width: geo.size.width*0.2, height: geo.size.height*0.2)
                            .padding(.horizontal, -2)
                    }
                    .frame(width: geo.size.width, height: geo.size.height*0.1)
                    ZStack {
                        
                        PlateAppearanceView(scale: 1.0, xoffset: 0, yoffset: 0)
                            .frame(width: geo.size.width, height: geo.size.height)
                        VStack {
                            Rectangle()
                                .fill(Color.clear)
                                .opacity(0.2)
                                .frame(width: geo.size.width, height: geo.size.height*0.35)
                            HStack {
                                CountView()
                                    .frame(width: geo.size.width*0.4, height: geo.size.height*0.15)
                                    .padding(-10)
                                VStack(alignment: .center) {
                                    Text("RBI")
                                    Text("2")
                                        .padding(.leading,-0)
                                        .font(.system(size: 30).bold())
                                        
                                        .foregroundColor(Color.black)
                                    
                                        .padding(.top, -10)
                                }
                                .frame(width: geo.size.width*0.4, height: geo.size.height*0.15)
                                Text("3")
                                    
                                    .font(.system(size: 50).bold())
                                    .frame(width: geo.size.width*0.2, height: geo.size.height*0.15)
                                    .foregroundColor(Color.red)
                                        //.background(Color.black)
                                    .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 1)))
                                    .foregroundColor(Color.red)
                                    .padding(.top, -35)
                                    .padding(.leading,-40)
                            }
                            .frame(width: geo.size.width, height: geo.size.height*0.5)
                            Spacer()
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height*0.75, alignment: .topLeading)
                    
                    
                }
                .frame(width: geo.size.width, height: geo.size.height*0.75, alignment: .topLeading)
                //.border(Color.black, width: 1)
                
            }
            
        }
        .background(Color.white)
        .scaleEffect(scale)
        
    }
}

#Preview {
    LargePlateAppearanceView()
}
