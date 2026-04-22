//
//  NavigationStateManager.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/23/26.
//

import Foundation
import SwiftUI

@MainActor
class NavigationStateManager: ObservableObject {
    
    @Published var path = NavigationPath()
    
    func popToRoot() {
        path = NavigationPath()
    }
    func push(_ route: AppRoute) {
        path.append(route)
    }
    func pop() {
        path.removeLast()
    }
    
}

enum AppRoute: Hashable {
    case home
    case team(team: Team)
    case teams
    case games
}
