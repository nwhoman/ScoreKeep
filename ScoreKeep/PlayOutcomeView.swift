//
//  PlayOutcomeView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/26/24.
//

import SwiftUI

struct PlayOutcomeView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                VStack{
                    Text("Hits:")
                }
                Button("Save Changes"){
                    //add book
                    //let newBook = Book(title: title, author: author, genre: //genre, review: review, rating: rating)
                    //modelContext.insert(newBook)
                    dismiss()
                }
            }
        }
        .navigationTitle("Play Outcome")
    }
}

#Preview {
    PlayOutcomeView()
}
