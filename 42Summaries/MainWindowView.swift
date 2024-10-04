//
//  ContentView.swift
//  42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI

struct MainWindowView: View {
    @StateObject private var navigationManager = NavigationStateManager()
    
    var body: some View {
        NavigationSplitView {
            SidebarView(navigationManager: navigationManager)
        } detail: {
            mainContent
        }
        .navigationTitle("")
        .onChange(of: navigationManager.selectedNavItem) { _, newValue in
            print("MainWindowView detected change in selectedNavItem: \(newValue)")
        }
    }
    
    var mainContent: some View {
        NavigationStack {
            Group {
                switch navigationManager.selectedNavItem {
                case .fileSelection:
                    FileSelectionView()
                case .transcription:
                    TranscriptionView()
                case .summary:
                    SummaryView()
                case .settings:
                    SettingsView()
                case .homeView:
                    WelcomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    HStack {
                        Image("AppIconImage")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 32)
                        Text("42Summaries")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
}

struct MainWindowView_Previews: PreviewProvider {
    static var previews: some View {
        MainWindowView()
    }
}
