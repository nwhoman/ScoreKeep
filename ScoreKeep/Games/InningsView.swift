//
//  InningsView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 5/2/26.
//

import SwiftData
import SwiftUI

struct InningsListView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var nav: NavigationStateManager
    @Query(sort: \Inning.game.name) private var innings: [Inning]
    @Query(sort: \GameViewModel.id) private var viewModels: [GameViewModel]
    @Query(sort: \OffensivePlateAppearance.batter.lastName) private var plateAppearances: [OffensivePlateAppearance]
    
    var body: some View {
        //NavigationStack {
        
        List {
            ForEach(innings, id: \.id) { inning in
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(inning.id)")
                                .font(.headline)
                            Text("\(inning.plateAppearances.count)")
                                .foregroundStyle(.secondary)
                            
                        }
                        Text("\(inning.game.name)")
                            .foregroundStyle(.secondary)
                        Text("\(inning.game.date.formatted(date: .complete, time: .shortened))")
                        List {
                            ForEach(inning.plateAppearances, id: \.id) { pa in
                                Text("\(pa.batter.lastName), \(pa.batter.firstName)")
                            }
                            .onDelete(perform: deletePlateAppearance)
                        }
                        .frame(height: 100)
                    }
                }
            }
            .onDelete(perform: deleteInning)
        }
        List {
            ForEach(plateAppearances.sorted { $0.batter.lastName < $1.batter.lastName }, id: \.id) { pa in
                HStack {
                    VStack(alignment: .leading) {
                        
                            Text("\(pa.batter.lastName), \(pa.batter.firstName)")
                        if pa.active {
                            Text("Active")
                        } else {
                            Text("Inactive")
                        }
                        
                    }
                }
            }
            .onDelete(perform: deletePlateAppearance)
            .navigationTitle("Innings")
        }
    }
    func deleteInning(at offsets: IndexSet){
        for offset in offsets {
            let inning = innings[offset]
//            for pa in inning.plateAppearances {
//                modelContext.delete(pa)
//                try? modelContext.save()
//            }
            modelContext.delete(inning)
            try? modelContext.save()
        }
    }
    func deletePlateAppearance(at offsets: IndexSet){
        for offset in offsets {
            let pa = plateAppearances.sorted { $0.batter.lastName < $1.batter.lastName }[offset]
            modelContext.delete(pa)
            try? modelContext.save()
        }
    }
    
}

#Preview {
    InningsListView()
}
