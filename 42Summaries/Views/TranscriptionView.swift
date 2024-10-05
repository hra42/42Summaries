//
//  TranscriptionView.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI

struct TranscriptionView: View {
    @StateObject private var transcriptionManager = TranscriptionManager()
    @EnvironmentObject private var notificationManager: NotificationManager
    
    var body: some View {
        VStack(spacing: 20) {
            TranscriptionProgressView(progress: transcriptionManager.progress, status: transcriptionManager.status)
                .padding()
            
            HStack(spacing: 20) {
                Button("Start Transcription") {
                    transcriptionManager.startTranscription()
                    if notificationManager.isNotificationPermissionGranted {
                        notificationManager.showNotification(title: "Transcription Started", body: "The transcription process has begun.")
                    } else {
                        print("Cannot show notification: Permission not granted")
                        notificationManager.requestAuthorization()
                    }
                }
                .disabled(transcriptionManager.status != .notStarted)
                
                Button("Cancel") {
                    transcriptionManager.cancelTranscription()
                    if notificationManager.isNotificationPermissionGranted {
                        notificationManager.showNotification(title: "Transcription Cancelled", body: "The transcription process has been cancelled.")
                    } else {
                        print("Cannot show notification: Permission not granted")
                        notificationManager.requestAuthorization()
                    }
                }
                .disabled(transcriptionManager.status != .transcribing && transcriptionManager.status != .preparing)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onChange(of: transcriptionManager.status) { _, newStatus in
            if newStatus == .completed {
                if notificationManager.isNotificationPermissionGranted {
                    notificationManager.showNotification(title: "Transcription Completed", body: "The transcription process has finished successfully.")
                } else {
                    print("Cannot show notification: Permission not granted")
                    notificationManager.requestAuthorization()
                }
            }
        }
    }
}

#Preview {
    TranscriptionView()
}
