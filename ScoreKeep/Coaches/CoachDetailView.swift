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
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Team.self, configurations: config)
        let coach = Coach(firstName: "example", lastName: "example", yearsCoaching: 5)

        return CoachDetailView(coach: coach)
            .modelContainer(container)
    }  catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
    
}
