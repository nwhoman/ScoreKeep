//
//  CoachDetailView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/1/24.
//

import SwiftData
import SwiftUI

struct CoachDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nav: NavigationStateManager

    @Bindable var coach: Coach
    
    var body: some View {
            Form {
                Section {
                    HStack(content: {
                        Text("First Name:")
                        TextField("Coach's First Name:", text: $coach.firstName)
                    })
                    HStack(content: {
                        Text("Last Name:")
                        TextField("Coach's Last Name:", text: $coach.lastName)
                    })
                }
                Picker("Years Coaching:", selection: $coach.yearsCoaching){
                    ForEach(0..<40){
                        Text("\($0)")
                    }
                }
                Section {
                    Button("Save Coach"){
                        //add coach
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
            .toolbar{
                /*ToolbarItem(placement: .topBarLeading){
                    Button("back"){//}, systemImage: "arrowshape.turn.up.backward"){
                        dismiss()
                    }
                }*/
            }
        
        
    }
}

#Preview {
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])
    
    return NavigationStack {
        CoachDetailView(coach: game.homeTeam!.coaches![0])
            .modelContainer(preview.modelContainer)
    }
}
