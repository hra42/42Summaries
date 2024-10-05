//
//  TranscriptionStatus.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI

enum TranscriptionStatus: String {
    case notStarted = "Not Started"
    case preparing = "Preparing"
    case transcribing = "Transcribing"
    case completed = "Completed"
}

extension TranscriptionStatus {
    var icon: String {
        switch self {
        case .notStarted:
            return "circle"
        case .preparing:
            return "gear"
        case .transcribing:
            return "waveform"
        case .completed:
            return "checkmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .notStarted:
            return .secondary
        case .preparing:
            return .blue
        case .transcribing:
            return .green
        case .completed:
            return .purple
        }
    }
}
