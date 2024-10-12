import SwiftUI

struct TranscriptionView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var notificationManager: NotificationManager
    @ObservedObject private var transcriptionManager: TranscriptionManager
    @State private var showingExportOptions = false
    @State private var fontSize: CGFloat = 12
    @State private var textAlignment: TextAlignment = .leading
    
    init(transcriptionManager: TranscriptionManager) {
        self.transcriptionManager = transcriptionManager
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Transcription")
                .font(.largeTitle)
                .fontWeight(.bold)
            progressView
            
            if transcriptionManager.status == .completed {
                transcriptionResultView
            } else {
                controlButtons
            }
            
            if let errorMessage = transcriptionManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView(
                content: transcriptionManager.transcriptionResult,
                fileName: "Transcription",
                fontSize: $fontSize,
                textAlignment: $textAlignment
            )
        }
    }
    
    private var progressView: some View {
        VStack {
            ProgressView(value: transcriptionManager.progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var statusText: String {
        switch transcriptionManager.status {
        case .notStarted:
            return "Ready to start transcription"
        case .preparing:
            return "Preparing audio for transcription..."
        case .transcribing:
            return "Transcribing: \(Int(transcriptionManager.progress * 100))% complete"
        case .completed:
            return "Transcription completed"
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 20) {
            Button("Start Transcription") {
                transcriptionManager.startTranscription()
                showNotification(title: "Transcription Started", body: "The transcription process has begun.")
            }
            .disabled(transcriptionManager.status != .notStarted || appState.selectedFile == nil)
            
            Button("Cancel") {
                transcriptionManager.cancelTranscription()
                showNotification(title: "Transcription Cancelled", body: "The transcription process has been cancelled.")
            }
            .disabled(transcriptionManager.status != .transcribing && transcriptionManager.status != .preparing)
        }
    }
    
    private var transcriptionResultView: some View {
        VStack(spacing: 20) {
            ScrollView {
                Text(transcriptionManager.transcriptionResult)
                    .padding()
            }
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
            
            HStack {
                Button(action: copyTranscription) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                
                Button(action: showExportOptions) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
    
    private func showNotification(title: String, body: String) {
        if notificationManager.isNotificationPermissionGranted {
            notificationManager.showNotification(title: title, body: body)
        } else {
            notificationManager.requestAuthorization()
        }
    }
    
    private func copyTranscription() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(transcriptionManager.transcriptionResult, forType: .string)
        showNotification(title: "Copied", body: "Transcription copied to clipboard.")
    }
    
    private func showExportOptions() {
        showingExportOptions = true
    }
}
