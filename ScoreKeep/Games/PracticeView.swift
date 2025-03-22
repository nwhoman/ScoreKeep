//
//  PracticeView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/19/25.
//

import SwiftUI

struct PracticeView: View {
    
    @State private var countries = ["USA", "Canada", "Mexico", "England", "Spain", "Germany", "Cameroon", "South Africa" , "Japan", "South Korea"]
    
    var body: some View {
        NavigationView {
            List ($countries, id: \.self, editActions: .move) { $country in
        
                    Text(country)
                
            }
            .toolbar {
                EditButton()
            }
        }
    }
    private func moveRow(source: IndexSet, destination: Int) {
        countries.move(fromOffsets: source, toOffset: destination)
    }
    
}

#Preview {
    PracticeView()
}
