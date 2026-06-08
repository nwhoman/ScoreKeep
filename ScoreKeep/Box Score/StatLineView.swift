//
//  StatLineView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 6/8/26.
//


import SwiftData
import SwiftUI

struct BattingStatLineView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var geo: GeometryProxy
    let spacing: CGFloat = CGFloat(StatLabels.allCases.count)
    var statLine: [String: Any]
    
//    [
//        "player": Player,
//        "batting": PlayerStats
//    ]?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let player = statLine["player"] as? Player {
                    Text("\(player.lastName), \(player.firstName.prefix(1))")
                        .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                        .minimumScaleFactor(0.5)

                } else {
                    Text("Totals")
                        .frame(width: geo.size.width * 0.3, alignment: .init(horizontal: .leading, vertical: .center))
                        .border(Color.gray, width: 1)
                }
                
                
                HStack {
                    let playerStats = statLine["batting"] as! PlayerStats
                    ForEach(playerStats.statSummary, id: \.self) { stat in
                        Text("\(stat)")
                            .frame(width: geo.size.width / spacing)
                    }
                    Spacer()
                }
                
            }
        }
        .font(.caption2)
        .frame(maxWidth: .infinity)
    }
}
