//
//  BookView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/25/24.
//

import SwiftData
import SwiftUI

struct BookView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    BookView()
}
