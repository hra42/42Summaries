//
//  TranscriptionView.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI

struct TranscriptionView: View {
    @StateObject private var transcriptionManager = TranscriptionManager()
    
    var body: some View {
        VStack {
            TranscriptionProgressView(progress: $transcriptionManager.progress, status: $transcriptionManager.status)
            
            Button("Start Transcription") {
                transcriptionManager.startTranscription()
            }
            .disabled(transcriptionManager.status == .transcribing)
            
            Button("Cancel") {
                transcriptionManager.cancelTranscription()
            }
            .disabled(transcriptionManager.status == .notStarted || transcriptionManager.status == .completed)
        }
        .padding()
    }
}

#Preview {
    TranscriptionView()
}
