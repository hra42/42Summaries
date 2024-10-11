//
//  NavigationStateManager.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI

class NavigationStateManager: ObservableObject {
    @Published var selectedNavItem: NavigationItem = .homeView {
        didSet {
        }
    }
    @Published var bounceStates: [NavigationItem: Bool] = [:] {
        didSet {
        }
    }
    
    func selectNavItem(_ item: NavigationItem) {
        if selectedNavItem != item {
            selectedNavItem = item
            animateIcon(for: item)
        }
    }
    
    private func animateIcon(for item: NavigationItem) {
        bounceStates[item] = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.bounceStates[item] = false
        }
    }
}
