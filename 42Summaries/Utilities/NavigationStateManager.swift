//
//  NavigationStateManager.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI

class NavigationStateManager: ObservableObject {
    @Published var selectedNavItem: NavigationItem = .homeView
    @Published var bounceStates: [NavigationItem: Bool] = [:]
    
    func selectNavItem(_ item: NavigationItem) {
        selectedNavItem = item
        bounceIcon(for: item)
    }
    
    private func bounceIcon(for item: NavigationItem) {
        bounceStates[item] = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.bounceStates[item] = false
        }
    }
}
