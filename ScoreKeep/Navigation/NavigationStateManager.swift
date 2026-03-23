//
//  NavigationStateManager.swift
//  ScoreKeep
//
//  Created by Neal Homan on 3/23/26.
//

import Foundation
import SwiftUI

class NavigationStateManager: ObservableObject {
    
    @Published var path = NavigationPath()
    
    func popToRoot() {
        path = NavigationPath()
    }
}
