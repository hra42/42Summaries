import Foundation
import WhisperKit

class TranscriptionManager: ObservableObject {
    @Published private(set) var progress: Double = 0.0
    @Published var status: TranscriptionStatus = .notStarted
    @Published var transcriptionResult: String = ""
    @Published var errorMessage: String?
    
    private var selectedFileURL: URL?
    private let transcriptionService = TranscriptionService()
    var whisperKit: WhisperKit?
    private var transcribeTask: Task<Void, Never>?
    
    // Add a reference to NotificationManager
    private let notificationManager: NotificationManager
    
    // Update the initializer to include NotificationManager
    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
    }
    
    func setSelectedFile(_ url: URL) {
        DispatchQueue.main.async {
            self.selectedFileURL = url
            self.status = .notStarted
            self.progress = 0.0
            self.transcriptionResult = ""
            self.errorMessage = nil
        }
    }
    
    func startTranscription() {
        guard let fileURL = selectedFileURL, let whisperKit = whisperKit else {
            DispatchQueue.main.async {
                self.errorMessage = "No file selected or WhisperKit not initialized"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.status = .preparing
        }
        
        transcribeTask = Task {
            await MainActor.run {
                self.status = .transcribing
            }
            
            transcriptionService.transcribeAudioFile(
                url: fileURL,
                whisperKit: whisperKit,
                progressHandler: { progress in
                    DispatchQueue.main.async {
                        self.progress = Double(progress)
                    }
                },
                completionHandler: { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let transcription):
                            self.transcriptionResult = self.processTranscription(transcription)
                            self.status = .completed
                            self.progress = 1.0
                            // Show notification when transcription is completed
                            self.notificationManager.showNotification(title: "Transcription Completed", body: "Your audio file has been successfully transcribed.")
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                            self.status = .notStarted
                            self.progress = 0.0
                            // Show notification for transcription failure
                            self.notificationManager.showNotification(title: "Transcription Failed", body: "An error occurred during transcription.")
                        }
                    }
                }
            )
        }
    }
    
    func cancelTranscription() {
        transcribeTask?.cancel()
        transcribeTask = nil
        DispatchQueue.main.async {
            self.status = .notStarted
            self.progress = 0.0
        }
    }
    
    private func processTranscription(_ raw: String) -> String {
        // Remove special tokens and clean up the text
        var cleanedText = raw
            .replacingOccurrences(of: "<|startoftranscript|>", with: "")
            .replacingOccurrences(of: "<|en|>", with: "")
            .replacingOccurrences(of: "<|transcribe|>", with: "")
            .replacingOccurrences(of: "<|endoftext|>", with: "")
        
        // Remove timestamp tokens (e.g., <|0.00|>)
        let timestampPattern = "<|\\d+\\.\\d+|>"
        cleanedText = cleanedText.replacingOccurrences(of: timestampPattern, with: "", options: .regularExpression)
        
        // Split the text by "||" and process each segment
        let segments = cleanedText.components(separatedBy: "||")
        let processedSegments = segments.map { segment -> String in
            let trimmedSegment = segment.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedSegment.isEmpty ? "" : trimmedSegment
        }.filter { !$0.isEmpty }
        
        // Join the processed segments
        let joinedText = processedSegments.joined(separator: "\n\n")
        
        // Remove any remaining excessive newlines
        let excessiveNewlinesPattern = "\n{3,}"
        let finalText = joinedText.replacingOccurrences(of: excessiveNewlinesPattern, with: "\n\n", options: .regularExpression)
        
        return finalText
    }
}
