//
//  ContentView.swift
//  SevenSummaries
//
//  Created by Henry Rausch on 04.10.24.
//

import SwiftUI

struct MainWindowView: View {
    enum NavigationItem: String, CaseIterable, Identifiable {
        case homeView = "Home"
        case fileSelection = "Select File"
        case transcription = "Transcription"
        case summary = "Summary"
        case settings = "Settings"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .homeView: return "house.fill"
            case .fileSelection: return "doc"
            case .transcription: return "waveform"
            case .summary: return "text.alignleft"
            case .settings: return "gear"
            }
        }
    }
    
    @State private var selectedNavItem: NavigationItem = .homeView
    @State private var bounceStates: [NavigationItem: Bool] = [:]
    
    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            mainContent
        }
        .navigationTitle("")
    }
    
    var sidebar: some View {
        List(NavigationItem.allCases, selection: $selectedNavItem) { item in
            NavigationLink(value: item) {
                Label {
                    Text(item.rawValue)
                } icon: {
                    Image(systemName: item.icon)
                        .scaleEffect(bounceStates[item, default: false] ? 1.2 : 1.0)
                        .animation(.interpolatingSpring(stiffness: 300, damping: 10), value: bounceStates[item])
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
        .onChange(of: selectedNavItem) { _, newValue in
            bounceIcon(for: newValue)
        }
    }
    
    func bounceIcon(for item: NavigationItem) {
        bounceStates[item] = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            bounceStates[item] = false
        }
    }
    
    var mainContent: some View {
        NavigationStack {
            Group {
                switch selectedNavItem {
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
                        Text("SevenSummaries")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
}

struct FileSelectionView: View {
    var body: some View {
        Text("File Selection View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TranscriptionView: View {
    var body: some View {
        Text("Transcription View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SummaryView: View {
    var body: some View {
        Text("Summary View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WelcomeView: View {
    var body: some View {
        VStack {
            Image("AppIconImage") // Use the name you gave to the Image Set
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
            Text("Welcome to SevenSummaries")
                .font(.title)
            Text("Select an item from the sidebar to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MainWindowView_Previews: PreviewProvider {
    static var previews: some View {
        MainWindowView()
    }
}
