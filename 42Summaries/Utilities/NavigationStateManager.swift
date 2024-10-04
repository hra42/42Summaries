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
            print("selectedNavItem changed to: \(selectedNavItem)")
        }
    }
    @Published var bounceStates: [NavigationItem: Bool] = [:] {
        didSet {
            print("bounceStates changed: \(bounceStates)")
        }
    }
    
    func selectNavItem(_ item: NavigationItem) {
        print("selectNavItem called with: \(item)")
        if selectedNavItem != item {
            selectedNavItem = item
            animateIcon(for: item)
        }
    }
    
    private func animateIcon(for item: NavigationItem) {
        print("animateIcon called for: \(item)")
        bounceStates[item] = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            print("Resetting bounce state for: \(item)")
            self?.bounceStates[item] = false
        }
    }
}
