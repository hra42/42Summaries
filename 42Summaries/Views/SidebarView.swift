//
//  SidebarView.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI

struct SidebarView: View {
    @ObservedObject var navigationManager: NavigationStateManager
    
    var body: some View {
        List(NavigationItem.allCases, selection: $navigationManager.selectedNavItem) { item in
            NavigationLink(value: item) {
                Label {
                    Text(item.rawValue)
                } icon: {
                    Image(systemName: item.icon)
                        .scaleEffect(navigationManager.bounceStates[item, default: false] ? 1.2 : 1.0)
                        .animation(.interpolatingSpring(stiffness: 300, damping: 10), value: navigationManager.bounceStates[item])
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
        .onChange(of: navigationManager.selectedNavItem) { _, newValue in
            navigationManager.selectNavItem(newValue)
        }
    }
}

#Preview {
    SidebarView(navigationManager: NavigationStateManager())
}

