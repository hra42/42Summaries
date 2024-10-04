//
//  NavigationItem.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//

import SwiftUI

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
