//
//  ContentView.swift
//  SevenSummaries
//
//  Created by Henry Rausch on 04.10.24.
//

import SwiftUI

struct MainWindowView: View {
    enum NavigationItem: Hashable {
        case fileSelection
        case transcription
        case summary
        case settings
    }
    
    @State private var selectedNavItem: NavigationItem? = .fileSelection
    
    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            NavigationStack {
                mainContent
            }
        }
    }
    
    var sidebar: some View {
        List(selection: $selectedNavItem) {
            NavigationLink(value: NavigationItem.fileSelection) {
                Label("Select File", systemImage: "doc")
            }
            
            NavigationLink(value: NavigationItem.transcription) {
                Label("Transcription", systemImage: "waveform")
            }
            
            NavigationLink(value: NavigationItem.summary) {
                Label("Summary", systemImage: "text.alignleft")
            }
            
            NavigationLink(value: NavigationItem.settings) {
                Label("Settings", systemImage: "gear")
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
    }
    
    var mainContent: some View {
        Group {
            switch selectedNavItem {
            case .fileSelection:
                Text("File Selection View")
            case .transcription:
                Text("Transcription View")
            case .summary:
                Text("Summary View")
            case .settings:
                Text("Settings View")
            case .none:
                Text("Select an item from the sidebar")
            }
        }
        .navigationDestination(for: NavigationItem.self) { item in
            switch item {
            case .fileSelection:
                Text("File Selection View")
            case .transcription:
                Text("Transcription View")
            case .summary:
                Text("Summary View")
            case .settings:
                Text("Settings View")
            }
        }
    }
}

struct MainWindowView_Previews: PreviewProvider {
    static var previews: some View {
        MainWindowView()
    }
}
