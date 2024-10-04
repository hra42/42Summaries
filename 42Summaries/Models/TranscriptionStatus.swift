//
//  TranscriptionStatus.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import Foundation

enum TranscriptionStatus: Equatable {
    case notStarted
    case preparing
    case transcribing
    case completed
    case error(String)
    
    var message: String {
        switch self {
        case .notStarted:
            return "Ready to start transcription"
        case .preparing:
            return "Preparing audio for transcription..."
        case .transcribing:
            return "Transcribing..."
        case .completed:
            return "Transcription completed!"
        case .error(let errorMessage):
            return "Error: \(errorMessage)"
        }
    }
    
    static func == (lhs: TranscriptionStatus, rhs: TranscriptionStatus) -> Bool {
        switch (lhs, rhs) {
        case (.notStarted, .notStarted),
             (.preparing, .preparing),
             (.transcribing, .transcribing),
             (.completed, .completed):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

