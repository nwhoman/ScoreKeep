//
//  ContentView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/25/24.
//
import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        //PlateAppearanceView()
        MainMenuView()
    }
}

#Preview {
    let preview = Preview()
    preview.addSampleGames([Game.defaultGame])
    return ContentView()
        .modelContainer(preview.modelContainer)
}
