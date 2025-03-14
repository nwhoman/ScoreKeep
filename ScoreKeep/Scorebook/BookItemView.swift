//
//  BookItemView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/23/24.
//

import SwiftData
import SwiftUI

struct BookItemView: View {
    var body: some View {
        
        ZStack{
            
            Outfield(startAngle: .degrees(-30), endAngle: .degrees(210))
                .stroke(.green, lineWidth: 3)
                .fill(.green)
                .frame(width: 400, height: 400)
                .background(Color.brown)
            Infield(width: 150)
                .stroke(.green, lineWidth: 3)
                .fill(.green)
                .frame(width: 400, height: 400)
            Base(xOffset: 0.0, yOffset: 0.0)
                .stroke(.black, lineWidth: 1)
                .fill(.white)
                .frame(width: 400, height: 400)
            Base(xOffset: -80.0, yOffset: -80.0)
                .stroke(.black, lineWidth: 1)
                .fill(.white)
                .frame(width: 400, height: 400)
            Base(xOffset: -160.0, yOffset: 0.0)
                .stroke(.black, lineWidth: 1)
                .fill(.white)
                .frame(width: 400, height: 400)
            Base(xOffset: -80.0, yOffset: 80.0)
                .stroke(.black, lineWidth: 1)
                .fill(.white)
                .frame(width: 400, height: 400)
        }
        

        /*Path { path in
            path.move(to: CGPoint(x: 200, y: 700))
            path.addLine(to: CGPoint(x: 300, y: 600))
            path.addLine(to: CGPoint(x: 200, y: 500))
            path.addLine(to: CGPoint(x: 100, y: 600))
            path.addLine(to: CGPoint(x: 200, y: 700))
            path.move(to: CGPoint(x: 300, y: 600))
            path.addLine(to: CGPoint(x: 330, y: 570))
            path.addArc(center: CGPoint(x: 200, y: 600), radius: 150, startAngle: .degrees(-17), endAngle: .degrees(197), clockwise: true)
            path.addLine(to: CGPoint(x: 100, y: 600))
            path.move(to: CGPoint(x: 300, y: 600))
            path.addArc(center: CGPoint(x: 200, y: 600), radius: 275, startAngle: .degrees(-30), endAngle: .degrees(210), clockwise: true)
            path.addLine(to: CGPoint(x: 100, y: 600))
         
        }
        .stroke(lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
        .fill(.green)*/
        
    }
}
struct Base: Shape {
    var xOffset: CGFloat
    var yOffset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX*1.5+xOffset, y: rect.maxY*0.75+yOffset))
        path.addLine(to: CGPoint(x: rect.midX*1.5-20+xOffset, y: rect.maxY*0.75-20+yOffset))
        path.addLine(to: CGPoint(x: rect.midX*1.5-40+xOffset, y: rect.maxY*0.75+yOffset))
        path.addLine(to: CGPoint(x: rect.midX*1.5-20+xOffset, y: rect.maxY*0.75+20+yOffset))
        path.closeSubpath()
        
        return path
    }
}
struct Infield: Shape {
    var width: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        //path.addRect(CGRect(x: Int(rect.minX)+95, y: Int(rect.minY)-15, width: width, height: width), transform: CGAffineTransform(rotationAngle: Double.pi*0.25))
    
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX*1.5, y: rect.maxY*0.75))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY*0.5))
        path.addLine(to: CGPoint(x: rect.midX*0.5, y: rect.maxY*0.75))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        
        return path
}
}
struct Outfield: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        //path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        //path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY*0.7), radius: 150, startAngle: .degrees(197), endAngle: .degrees(-17), clockwise: false)
        //path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        //path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY*0.7), radius: 275, startAngle: .degrees(-30), endAngle: .degrees(210), clockwise: true)
        //path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    BookItemView()
}
