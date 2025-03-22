//
//  CoachesView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/29/24.
//

import SwiftUI
import SwiftData

struct CoachesView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    let team: Team

    //@Query(sort: \Team.name) var teams: [Team]
    @Query(sort: \Coach.lastName) var coaches: [Coach]
    @State private var path = [Coach]()
    @State private var showAddCoachScreen = false
    
    init(for team: Team){
        let id = team.id
        self._coaches = Query(filter: #Predicate {
            $0.team?.id == id
        }, sort: \Coach.lastName)
        self.team = team
    }
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(coaches) { coach in
                    NavigationLink(value: coach){
                        HStack {
                            Text("\(coach.firstName)")
                                .font(.system(size: 14))
                            Text("\(coach.lastName)")
                                .font(.system(size: 14))
                        }
                    }
                }
                .onDelete(perform: deleteCoach)
            }
            .navigationDestination(for: Coach.self) {
                coach in
                CoachDetailView(coach: coach)
            }
            .toolbar{
                
                ToolbarItem(placement: .topBarLeading){
                    Button("back", systemImage: "arrowshape.turn.up.backward"){
                        dismiss()
                    }
                    
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button("Add Coach", systemImage: "plus"){
                        showAddCoachScreen.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $showAddCoachScreen) {
            AddCoachView(team: team)
        }
    }
    func deleteCoach(at offsets: IndexSet){
        for offset in offsets {
            let coach = coaches[offset]
            modelContext.delete(coach)
        }
    }
}

#Preview {
    let preview = Preview()
    let game = Game.defaultGame
    preview.addSampleGames([game])
    
    return NavigationStack {
        CoachesView(for: game.homeTeam!)
            .modelContainer(preview.modelContainer)
    }
}
